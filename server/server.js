import express from 'express';
import mysql from 'mysql2/promise';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import multer from 'multer';
import { createHash, randomUUID } from 'crypto';
import { createRequire } from 'module';
import { mkdir, open, unlink } from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

dotenv.config();

const webpush = createRequire(import.meta.url)('web-push');

const requiredEnvironment = [
  'JWT_SECRET',
  'ADMIN_EMAIL',
  'ADMIN_PASSWORD'
];
const missingEnvironment = requiredEnvironment.filter((name) => !process.env[name]);

if (missingEnvironment.length) {
  throw new Error(`Missing required environment variables: ${missingEnvironment.join(', ')}`);
}

const app = express();
const port = Number(process.env.PORT || 5000);
const schoolCodes = ['SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other'];
const jwtSecret = process.env.JWT_SECRET;
const adminEmail = process.env.ADMIN_EMAIL.trim().toLowerCase();
const adminPassword = process.env.ADMIN_PASSWORD;
const vapidPublicKey = process.env.VAPID_PUBLIC_KEY || '';
const vapidPrivateKey = process.env.VAPID_PRIVATE_KEY || '';
const vapidSubject = process.env.VAPID_SUBJECT || '';
const vapidEnvironmentValues = [vapidPublicKey, vapidPrivateKey, vapidSubject];
if (vapidEnvironmentValues.some(Boolean) && !vapidEnvironmentValues.every(Boolean)) {
  throw new Error('Set VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY, and VAPID_SUBJECT together');
}
const pushConfigured = Boolean(vapidPublicKey && vapidPrivateKey && vapidSubject);
const currentDirectory = path.dirname(fileURLToPath(import.meta.url));
const uploadDirectory = path.join(currentDirectory, 'uploads');

if (pushConfigured) {
  webpush.setVapidDetails(vapidSubject, vapidPublicKey, vapidPrivateKey);
}

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'exam_pwa',
  waitForConnections: true,
  connectionLimit: 10,
  dateStrings: true
});

app.use(express.json({ limit: '3mb' }));

await mkdir(uploadDirectory, { recursive: true });

const noteUpload = multer({
  storage: multer.diskStorage({
    destination: uploadDirectory,
    filename: (req, file, callback) => {
      const extension = path.extname(file.originalname).toLowerCase();
      callback(null, `${randomUUID()}${extension}`);
    }
  }),
  limits: { fileSize: 10 * 1024 * 1024, files: 1 },
  fileFilter: (req, file, callback) => {
    const extension = path.extname(file.originalname).toLowerCase();
    const validTypes = new Map([
      ['.pdf', 'application/pdf'],
      ['.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
    ]);
    if (validTypes.get(extension) !== file.mimetype) {
      callback(new Error('Upload a PDF or DOCX file only'));
      return;
    }
    callback(null, true);
  }
});

function handleNoteUpload(req, res, next) {
  noteUpload.single('file')(req, res, (error) => {
    if (!error) return next();
    if (error instanceof multer.MulterError && error.code === 'LIMIT_FILE_SIZE') {
      return res.status(413).json({ error: 'Notes must be 10 MB or smaller' });
    }
    if (error instanceof multer.MulterError) {
      return res.status(400).json({ error: 'Choose one PDF or DOCX file to upload' });
    }
    return res.status(400).json({ error: error.message || 'Could not process the uploaded file' });
  });
}

function asyncRoute(handler) {
  return (req, res, next) => {
    Promise.resolve(handler(req, res, next)).catch(next);
  };
}

function auth(role) {
  return (req, res, next) => {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : '';
    if (!token) return res.status(401).json({ error: 'Not logged in' });

    try {
      const payload = jwt.verify(token, jwtSecret);
      const requestedRoles = Array.isArray(role) ? role : [role];
      const allowedRoles = requestedRoles.includes('admin')
        ? [...requestedRoles, 'SUPER_ADMIN', 'SCHOOL_ADMIN']
        : requestedRoles;
      if (typeof payload === 'string' || !allowedRoles.includes(payload.role)) {
        return res.status(403).json({ error: 'Forbidden' });
      }
      if (['student', 'lecturer'].includes(payload.role) && !Number.isInteger(payload.id)) {
        return res.status(401).json({ error: 'Invalid session' });
      }
      if (['SUPER_ADMIN', 'SCHOOL_ADMIN'].includes(payload.role) &&
          (!Number.isInteger(payload.admin_id) ||
           (payload.role === 'SCHOOL_ADMIN' && !isOneOf(payload.school, schoolCodes)))) {
        return res.status(401).json({ error: 'Invalid admin session' });
      }
      req.user = payload;
      return next();
    } catch {
      return res.status(401).json({ error: 'Invalid session' });
    }
  };
}

function authSchoolAdmin(req, res, next) {
  return auth(['SUPER_ADMIN', 'SCHOOL_ADMIN'])(req, res, next);
}

function isSuperAdmin(req) {
  return req.user.role === 'SUPER_ADMIN';
}

function adminSchoolFilter(req, column) {
  return isSuperAdmin(req) ? { sql: '', params: [] } : {
    sql: ` AND ${column} = ?`,
    params: [req.user.school]
  };
}

function isOneOf(value, values) {
  return values.includes(value);
}

function normalizeDegreeProgram(value) {
  if (typeof value !== 'string') return null;
  const degreeProgram = value.trim().toUpperCase();
  return /^[A-Z0-9][A-Z0-9-]{0,29}$/.test(degreeProgram) ? degreeProgram : null;
}

function hashPushEndpoint(endpoint) {
  return createHash('sha256').update(endpoint).digest('hex');
}

async function sendPushToStudent(studentId, payload) {
  if (!pushConfigured) return;
  const [subscriptions] = await pool.query(
    'SELECT id, endpoint, p256dh, auth FROM push_subscriptions WHERE student_id = ?',
    [studentId]
  );
  await Promise.all(subscriptions.map(async (subscription) => {
    try {
      await webpush.sendNotification(
        {
          endpoint: subscription.endpoint,
          keys: { p256dh: subscription.p256dh, auth: subscription.auth }
        },
        JSON.stringify(payload),
        { TTL: 60 * 60 }
      );
    } catch (error) {
      if (error.statusCode === 404 || error.statusCode === 410) {
        await pool.query('DELETE FROM push_subscriptions WHERE id = ?', [subscription.id]);
      } else {
        console.error(`Push delivery failed for subscription ${subscription.id}:`, error.message);
      }
    }
  }));
}

async function sendPushToStudents(studentIds, payload) {
  const uniqueStudentIds = [...new Set(studentIds)];
  for (let offset = 0; offset < uniqueStudentIds.length; offset += 50) {
    const batch = uniqueStudentIds.slice(offset, offset + 50);
    const results = await Promise.allSettled(
      batch.map((studentId) => sendPushToStudent(studentId, payload))
    );
    results.filter((result) => result.status === 'rejected').forEach((result) => {
      console.error('Push notification batch failed:', result.reason);
    });
  }
}

async function getBroadcastStudentIds(targetRoom, targetSchool) {
  const conditions = [];
  const parameters = [];
  if (targetSchool !== 'ALL') {
    conditions.push('s.school = ?');
    parameters.push(targetSchool);
  }
  if (targetRoom !== 'GLOBAL') {
    const room = targetRoom.match(
      /^(SCI|SBA|SOSS|LAW|Nursing|EDU|Other)-([A-Z0-9][A-Z0-9-]{0,29})-(DAY|WEEKEND|EVENING|DISTANCE)-Y([1-5])-S([12])$/
    );
    if (!room) throw new Error('Invalid group room while selecting push recipients');
    conditions.push('s.school = ?', 's.degree_program = ?', 's.program = ?', 's.year_of_study = ?', 's.semester = ?');
    parameters.push(room[1], room[2], room[3], Number(room[4]), Number(room[5]));
  }
  const [students] = await pool.query(
    `SELECT s.id FROM students s
     ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
     ORDER BY s.id`,
    parameters
  );
  return students.map((student) => student.id);
}

async function studentCanAccessCourseUnit(studentId, courseUnitId) {
  const [access] = await pool.query(
    `SELECT cu.academic_level = s.academic_level AND (
       (EXISTS (
         SELECT 1
         FROM registrations r
         WHERE r.student_id = s.id AND r.course_unit_id = cu.id
       ) AND (cu.school = s.school OR cu.is_public = TRUE))
       OR cu.is_public = TRUE OR (
         cu.school = s.school
         AND (cu.degree_program = s.degree_program OR cu.degree_program = 'ALL')
         AND cu.year_of_study = s.year_of_study
         AND cu.semester = s.semester
       )
     ) AS can_access
     FROM students s
     JOIN course_units cu ON cu.id = ?
     WHERE s.id = ?`,
    [courseUnitId, studentId]
  );
  return Boolean(access[0]?.can_access);
}

function getRoomId(student) {
  const degreeProgram = student.degreeProgram ?? student.degree_program;
  const yearOfStudy = student.yearOfStudy ?? student.year_of_study;
  return `${student.school}-${degreeProgram}-${student.program}-Y${yearOfStudy}-S${student.semester}`;
}

function isValidTargetRoom(targetRoom) {
  return targetRoom === 'GLOBAL' ||
    /^(SCI|SBA|SOSS|LAW|Nursing|EDU|Other)-[A-Z0-9][A-Z0-9-]{0,29}-(DAY|WEEKEND|EVENING|DISTANCE)-Y[1-5]-S[12]$/.test(targetRoom);
}

function formatMessages(messages) {
  return messages.reverse().map((message) => ({
    ...message,
    isBroadcast: Boolean(message.isBroadcast)
  }));
}

app.get('/api/health', (req, res) => {
  res.json({ ok: true });
});

app.get('/api/push/public-key', (req, res) => {
  if (!pushConfigured) {
    return res.status(503).json({ error: 'Push notifications are not configured on this server' });
  }
  return res.json({ publicKey: vapidPublicKey });
});

app.get('/api/registration-programs', asyncRoute(async (req, res) => {
  const { school, academicLevel } = req.query;
  const academicLevels = ['Certificate', 'Diploma', 'Degree', 'Masters', 'PhD'];
  if (!isOneOf(school, schoolCodes) || !isOneOf(academicLevel, academicLevels)) {
    return res.status(400).json({ error: 'Choose a valid school and academic level' });
  }
  const [programs] = await pool.query(
    `SELECT DISTINCT degree_program AS degreeProgram
     FROM course_units
     WHERE school = ? AND academic_level = ?
       AND degree_program NOT IN ('ALL', 'UNASSIGNED')
     ORDER BY degree_program`,
    [school, academicLevel]
  );
  return res.json(programs.map((program) => program.degreeProgram));
}));

app.post('/api/push/subscribe', auth('student'), asyncRoute(async (req, res) => {
  if (!pushConfigured) {
    return res.status(503).json({ error: 'Push notifications are not configured on this server' });
  }
  const { endpoint, keys } = req.body || {};
  if (typeof endpoint !== 'string' || endpoint.length > 4096 ||
      typeof keys?.p256dh !== 'string' || keys.p256dh.length > 255 ||
      typeof keys?.auth !== 'string' || keys.auth.length > 255) {
    return res.status(400).json({ error: 'A valid browser push subscription is required' });
  }
  let endpointUrl;
  try {
    endpointUrl = new URL(endpoint);
  } catch {
    return res.status(400).json({ error: 'The push endpoint is invalid' });
  }
  if (endpointUrl.protocol !== 'https:' || endpointUrl.username || endpointUrl.password ||
      !endpointUrl.hostname || endpointUrl.hostname === 'localhost' ||
      endpointUrl.hostname.endsWith('.localhost') || endpointUrl.hostname.endsWith('.local')) {
    return res.status(400).json({ error: 'The push endpoint must be a secure public HTTPS URL' });
  }
  const hostname = endpointUrl.hostname.toLowerCase();
  const trustedPushProvider = hostname === 'fcm.googleapis.com' ||
    hostname === 'push.services.mozilla.com' ||
    hostname.endsWith('.push.services.mozilla.com') ||
    hostname === 'web.push.apple.com' ||
    hostname.endsWith('.push.apple.com') ||
    hostname.endsWith('.notify.windows.com');
  if (!trustedPushProvider) {
    return res.status(400).json({ error: 'The push endpoint is not from a supported browser push service' });
  }
  await pool.query(
    `INSERT INTO push_subscriptions (student_id, endpoint, endpoint_hash, p256dh, auth)
     VALUES (?, ?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE
       student_id = VALUES(student_id),
       endpoint = VALUES(endpoint),
       p256dh = VALUES(p256dh),
       auth = VALUES(auth)`,
    [req.user.id, endpoint, hashPushEndpoint(endpoint), keys.p256dh, keys.auth]
  );
  return res.status(201).json({ ok: true });
}));

app.delete('/api/push/subscribe', auth('student'), asyncRoute(async (req, res) => {
  const endpoint = req.body?.endpoint;
  if (typeof endpoint !== 'string' || endpoint.length > 4096) {
    return res.status(400).json({ error: 'A valid push endpoint is required' });
  }
  await pool.query(
    'DELETE FROM push_subscriptions WHERE student_id = ? AND endpoint_hash = ?',
    [req.user.id, hashPushEndpoint(endpoint)]
  );
  return res.json({ ok: true });
}));

app.post('/api/register', asyncRoute(async (req, res) => {
  const {
    firstName, lastName, studentNumber, program, school,
    degreeProgram: submittedDegreeProgram, yearOfStudy, semester, email, password,
    phoneNumber: submittedPhoneNumber, academicLevel
  } = req.body;
  const degreeProgram = normalizeDegreeProgram(submittedDegreeProgram);
  const phoneNumber = typeof submittedPhoneNumber === 'string' ? submittedPhoneNumber.trim() : '';

  if (![firstName, lastName, studentNumber, email, password, phoneNumber].every(
    (value) => typeof value === 'string' && value.trim()
  )) {
    return res.status(400).json({ error: 'All fields are required' });
  }
  const phoneDigits = phoneNumber.replace(/\D/g, '');
  if (phoneNumber.length > 20 || !/^\+?[0-9\s().-]+$/.test(phoneNumber) ||
      phoneDigits.length < 7 || phoneDigits.length > 15) {
    return res.status(400).json({ error: 'Enter a valid phone number, including country code' });
  }
  if (!isOneOf(academicLevel, ['Certificate', 'Diploma', 'Degree', 'Masters', 'PhD']) ||
      !isOneOf(program, ['DAY', 'WEEKEND', 'EVENING', 'DISTANCE']) ||
      !isOneOf(school, schoolCodes) ||
      !Number.isInteger(Number(yearOfStudy)) || Number(yearOfStudy) < 1 || Number(yearOfStudy) > 5 ||
      !Number.isInteger(Number(semester)) || ![1, 2].includes(Number(semester)) ||
      !degreeProgram || password.length < 6) {
    return res.status(400).json({ error: 'Check the academic level, degree program, study program, school, year, semester, and password' });
  }

  const [matchingPrograms] = await pool.query(
    `SELECT 1 FROM course_units
     WHERE school = ? AND degree_program = ? AND academic_level = ?
     LIMIT 1`,
    [school, degreeProgram, academicLevel]
  );
  if (!matchingPrograms.length) {
    return res.status(400).json({ error: 'Select a degree program offered by the selected school' });
  }

  const normalizedEmail = email.trim().toLowerCase();
  if (normalizedEmail.length > 100 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)) {
    return res.status(400).json({ error: 'Enter a valid email address' });
  }

  try {
    const passwordHash = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      `INSERT INTO students
        (first_name, last_name, student_number, academic_level, program, school, phone_number, degree_program,
         year_of_study, semester, email, password_hash)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        firstName.trim(), lastName.trim(), studentNumber.trim(), academicLevel, program, school, phoneNumber,
        degreeProgram, Number(yearOfStudy), Number(semester), normalizedEmail, passwordHash
      ]
    );
    const token = jwt.sign({
      id: result.insertId,
      role: 'student',
      name: `${firstName.trim()} ${lastName.trim()}`
    }, jwtSecret, { expiresIn: '7d' });
    return res.status(201).json({ token });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Student number or email is already registered' });
    }
    throw error;
  }
}));

app.post('/api/login', asyncRoute(async (req, res) => {
  const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body.password === 'string' ? req.body.password : '';
  const [students] = await pool.query(
    'SELECT id, first_name, last_name, password_hash FROM students WHERE email = ?',
    [email]
  );
  if (!students.length || !(await bcrypt.compare(password, students[0].password_hash))) {
    return res.status(401).json({ error: 'Invalid email or password' });
  }
  const token = jwt.sign({
    id: students[0].id,
    role: 'student',
    name: `${students[0].first_name} ${students[0].last_name}`
  }, jwtSecret, { expiresIn: '7d' });
  return res.json({ token });
}));

app.post('/api/lecturer/login', asyncRoute(async (req, res) => {
  const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body.password === 'string' ? req.body.password : '';
  const [lecturers] = await pool.query(
    'SELECT id, name, password_hash FROM lecturers WHERE email = ?',
    [email]
  );
  if (!lecturers.length || !(await bcrypt.compare(password, lecturers[0].password_hash))) {
    return res.status(401).json({ error: 'Invalid email or password' });
  }
  const token = jwt.sign({
    id: lecturers[0].id,
    role: 'lecturer',
    name: lecturers[0].name
  }, jwtSecret, { expiresIn: '7d' });
  return res.json({ token, role: 'lecturer' });
}));

app.post('/api/sign-in', asyncRoute(async (req, res) => {
  const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body.password === 'string' ? req.body.password : '';

  const [admins] = await pool.query(
    'SELECT id, email, password_hash, school, role FROM admins WHERE email = ?',
    [email]
  );
  if (admins.length && await bcrypt.compare(password, admins[0].password_hash)) {
    const admin = admins[0];
    const token = jwt.sign({
      admin_id: admin.id,
      role: admin.role,
      school: admin.school
    }, jwtSecret, { expiresIn: '12h' });
    return res.json({ token, role: admin.role });
  }

  const [students] = await pool.query(
    'SELECT id, first_name, last_name, password_hash FROM students WHERE email = ?',
    [email]
  );
  if (!students.length || !(await bcrypt.compare(password, students[0].password_hash))) {
    const [lecturers] = await pool.query(
      'SELECT id, name, password_hash FROM lecturers WHERE email = ?',
      [email]
    );
    if (!lecturers.length || !(await bcrypt.compare(password, lecturers[0].password_hash))) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    const token = jwt.sign({
      id: lecturers[0].id,
      role: 'lecturer',
      name: lecturers[0].name
    }, jwtSecret, { expiresIn: '7d' });
    return res.json({ token, role: 'lecturer' });
  }

  const token = jwt.sign({
    id: students[0].id,
    role: 'student',
    name: `${students[0].first_name} ${students[0].last_name}`
  }, jwtSecret, { expiresIn: '7d' });
  return res.json({ token, role: 'student' });
}));

app.post('/api/admin/login', asyncRoute(async (req, res) => {
  const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body.password === 'string' ? req.body.password : '';
  const [admins] = await pool.query(
    'SELECT id, email, password_hash, school, role FROM admins WHERE email = ?',
    [email]
  );
  if (!admins.length || !(await bcrypt.compare(password, admins[0].password_hash))) {
    return res.status(401).json({ error: 'Invalid admin credentials' });
  }
  const admin = admins[0];
  const token = jwt.sign({
    admin_id: admin.id,
    role: admin.role,
    school: admin.school
  }, jwtSecret, { expiresIn: '12h' });
  return res.json({ token, role: admin.role });
}));

app.get('/api/me', auth('student'), asyncRoute(async (req, res) => {
  const [students] = await pool.query(
    `SELECT id, first_name AS firstName, last_name AS lastName, student_number AS studentNumber,
            academic_level AS academicLevel, program, school, degree_program AS degreeProgram,
            year_of_study AS yearOfStudy, semester, email,
            profile_picture AS profilePicture
     FROM students WHERE id = ?`,
    [req.user.id]
  );
  if (!students.length) return res.status(404).json({ error: 'Student not found' });
  return res.json(students[0]);
}));

app.delete('/api/me', auth('student'), asyncRoute(async (req, res) => {
  const connection = await pool.getConnection();
  let transactionStarted = false;
  try {
    await connection.beginTransaction();
    transactionStarted = true;
    await connection.query('DELETE FROM messages WHERE sender_id = ?', [req.user.id]);
    const [result] = await connection.query(
      'DELETE FROM students WHERE id = ?',
      [req.user.id]
    );
    if (!result.affectedRows) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(404).json({ error: 'Student not found' });
    }
    await connection.commit();
    transactionStarted = false;
    return res.json({ ok: true });
  } catch (error) {
    if (transactionStarted) await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}));

app.put('/api/me/avatar', auth('student'), asyncRoute(async (req, res) => {
  const profilePicture = typeof req.body.profilePicture === 'string'
    ? req.body.profilePicture
    : '';
  const match = profilePicture.match(
    /^data:image\/(png|jpeg|webp|gif|avif);base64,([A-Za-z0-9+/]+={0,2})$/i
  );
  if (!match || match[2].length % 4 !== 0) {
    return res.status(400).json({ error: 'Choose a supported image file and try again' });
  }

  const imageData = Buffer.from(match[2], 'base64');
  if (imageData.length > 2 * 1024 * 1024) {
    return res.status(413).json({ error: 'Profile pictures must be 2 MB or smaller' });
  }

  const [result] = await pool.query(
    'UPDATE students SET profile_picture = ? WHERE id = ?',
    [profilePicture, req.user.id]
  );
  if (!result.affectedRows) {
    const [students] = await pool.query('SELECT id FROM students WHERE id = ?', [req.user.id]);
    if (!students.length) return res.status(404).json({ error: 'Student not found' });
  }
  return res.json({ profilePicture });
}));

app.get('/api/course-units', auth('student'), asyncRoute(async (req, res) => {
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  if (req.query.search !== undefined && typeof req.query.search !== 'string') {
    return res.status(400).json({ error: 'Search must be a single text value' });
  }
  if (search.length > 100) {
    return res.status(400).json({ error: 'Search must be 100 characters or fewer' });
  }

  const searchFilter = search ? 'AND (cu.code LIKE ? OR cu.name LIKE ?)' : '';
  const searchPattern = `%${search}%`;
  const [units] = await pool.query(
    `SELECT cu.id, cu.code, cu.name, cu.school, cu.degree_program AS degreeProgram,
            cu.academic_level AS academicLevel,
            cu.year_of_study AS yearOfStudy, cu.semester, cu.is_public AS isPublic,
            CASE WHEN r.id IS NULL THEN 0 ELSE 1 END AS registered,
            l.name AS lecturerName
     FROM course_units cu
     LEFT JOIN lecturers l ON l.id = cu.lecturer_id
     JOIN students s ON s.id = ?
     LEFT JOIN registrations r
       ON r.course_unit_id = cu.id AND r.student_id = s.id
     WHERE cu.academic_level = s.academic_level
       AND (cu.school = s.school OR cu.is_public = TRUE)
       ${searchFilter}
     ORDER BY cu.code, cu.year_of_study, cu.semester`,
    search ? [req.user.id, searchPattern, searchPattern] : [req.user.id]
  );
  return res.json(units.map((unit) => ({ ...unit, registered: Boolean(unit.registered) })));
}));

app.get('/api/classes', auth('student'), asyncRoute(async (req, res) => {
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  if (req.query.search !== undefined && typeof req.query.search !== 'string') {
    return res.status(400).json({ error: 'Search must be a single text value' });
  }
  if (search.length > 100) return res.status(400).json({ error: 'Search must be 100 characters or fewer' });
  const searchFilter = search
    ? 'AND (cu.code LIKE ? OR cu.name LIKE ? OR l.name LIKE ? OR cs.room LIKE ?)'
    : '';
  const searchPattern = `%${search}%`;
  const [classes] = await pool.query(
    `SELECT cs.id, cu.id AS courseUnitId, cu.code, cu.name AS courseName,
            cu.academic_level AS academicLevel,
            cs.day_of_week AS dayOfWeek, cs.start_time AS startTime,
            cs.end_time AS endTime, cs.room, cs.program,
            l.name AS lecturerName
     FROM students s
     JOIN registrations r ON r.student_id = s.id
     JOIN course_units cu ON cu.id = r.course_unit_id
       AND cu.academic_level = s.academic_level
     LEFT JOIN class_schedules cs
       ON cs.course_unit_id = cu.id
       AND (cs.program = 'BOTH' OR cs.program = s.program)
     LEFT JOIN lecturers l ON l.id = COALESCE(cs.lecturer_id, cu.lecturer_id)
     WHERE s.id = ?
       ${searchFilter}
     ORDER BY (cs.id IS NULL), FIELD(cs.day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
                    'Friday', 'Saturday', 'Sunday'), cs.start_time, cu.code`,
    search
      ? [req.user.id, searchPattern, searchPattern, searchPattern, searchPattern]
      : [req.user.id]
  );
  return res.json(classes);
}));

app.post('/api/registrations', auth('student'), asyncRoute(async (req, res) => {
  const courseUnitId = Number(req.body.courseUnitId);
  if (!Number.isInteger(courseUnitId) || courseUnitId < 1) {
    return res.status(400).json({ error: 'A valid course unit is required' });
  }

  try {
    const [result] = await pool.query(
      `INSERT INTO registrations (student_id, course_unit_id)
       SELECT s.id, cu.id
       FROM students s
       JOIN course_units cu
         ON cu.academic_level = s.academic_level
         AND (cu.school = s.school OR cu.is_public = TRUE)
       WHERE s.id = ? AND cu.id = ?`,
      [req.user.id, courseUnitId]
    );
    if (!result.affectedRows) return res.status(404).json({ error: 'Course unit not found for this student' });
    return res.status(201).json({ ok: true });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Already registered for this course unit' });
    }
    throw error;
  }
}));

app.delete('/api/registrations/:courseUnitId', auth('student'), asyncRoute(async (req, res) => {
  const courseUnitId = Number(req.params.courseUnitId);
  if (!Number.isInteger(courseUnitId) || courseUnitId < 1) {
    return res.status(400).json({ error: 'A valid course unit is required' });
  }
  await pool.query(
    'DELETE FROM registrations WHERE student_id = ? AND course_unit_id = ?',
    [req.user.id, courseUnitId]
  );
  return res.json({ ok: true });
}));

app.put('/api/registrations/:id/complete', auth('student'), asyncRoute(async (req, res) => {
  const registrationId = Number(req.params.id);
  const { isCompleted } = req.body;
  if (!Number.isInteger(registrationId) || registrationId < 1 ||
      typeof isCompleted !== 'boolean') {
    return res.status(400).json({ error: 'A valid registration and completion status are required' });
  }

  const [result] = await pool.query(
    'UPDATE registrations SET is_completed = ? WHERE id = ? AND student_id = ?',
    [isCompleted, registrationId, req.user.id]
  );
  if (!result.affectedRows) {
    const [registrations] = await pool.query(
      'SELECT id FROM registrations WHERE id = ? AND student_id = ?',
      [registrationId, req.user.id]
    );
    if (!registrations.length) return res.status(404).json({ error: 'Registration not found' });
  }
  return res.json({ ok: true, isCompleted });
}));

app.get('/api/exams', auth('student'), asyncRoute(async (req, res) => {
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  if (req.query.search !== undefined && typeof req.query.search !== 'string') {
    return res.status(400).json({ error: 'Search must be a single text value' });
  }
  if (search.length > 100) return res.status(400).json({ error: 'Search must be 100 characters or fewer' });
  const searchFilter = search ? 'AND (cu.code LIKE ? OR cu.name LIKE ? OR e.room LIKE ?)' : '';
  const searchPattern = `%${search}%`;
  const [exams] = await pool.query(
    `SELECT e.id, r.id AS registrationId,
            CASE WHEN r.is_completed = TRUE OR CONCAT(e.exam_date, ' ', e.end_time) <= NOW()
                 THEN TRUE ELSE FALSE END AS isCompleted,
            cu.code, cu.name AS courseName, e.exam_date AS examDate,
            e.start_time AS startTime, e.end_time AS endTime, e.room, e.program,
            e.school, cu.degree_program AS degreeProgram,
            e.source_text AS sourceText, e.source_date_label AS sourceDateLabel
     FROM exams e
     JOIN course_units cu ON cu.id = e.course_unit_id
     JOIN registrations r ON r.course_unit_id = cu.id
     JOIN students s ON s.id = r.student_id
     WHERE s.id = ?
       AND cu.academic_level = s.academic_level
       AND (e.program IN ('BOTH', 'ALL') OR e.program = s.program)
       ${searchFilter}
     ORDER BY e.exam_date, e.start_time`,
    search
      ? [req.user.id, searchPattern, searchPattern, searchPattern]
      : [req.user.id]
  );
  return res.json(exams.map((exam) => ({
    ...exam,
    isCompleted: Boolean(exam.isCompleted)
  })));
}));

app.get('/api/messages', auth('student'), asyncRoute(async (req, res) => {
  const courseUnitId = req.query.course_unit_id === undefined
    ? null
    : Number(req.query.course_unit_id);
  if (courseUnitId !== null && (!Number.isInteger(courseUnitId) || courseUnitId < 1)) {
    return res.status(400).json({ error: 'Choose a valid course chat' });
  }
  const [students] = await pool.query(
    `SELECT school, degree_program AS degreeProgram, program,
            year_of_study AS yearOfStudy, semester
     FROM students WHERE id = ?`,
    [req.user.id]
  );
  if (!students.length) return res.status(401).json({ error: 'Invalid session' });

  const targetRoom = getRoomId(students[0]);
  if (courseUnitId !== null) {
    if (!(await studentCanAccessCourseUnit(req.user.id, courseUnitId))) {
      return res.status(403).json({ error: 'You are not enrolled in this course chat' });
    }
  }
  const [messages] = await pool.query(
    `SELECT m.id, m.sender_id AS senderId, m.sender_name AS senderName, m.text,
            m.is_broadcast AS isBroadcast, m.target_room AS targetRoom,
            m.course_unit_id AS courseUnitId,
            m.sender_lecturer_id AS senderLecturerId,
            m.created_at AS createdAt, m.edited_at AS editedAt,
            s.profile_picture AS senderProfilePicture,
            s.phone_number AS senderPhoneNumber
     FROM messages m
     LEFT JOIN students s ON s.id = m.sender_id
     WHERE ((? IS NULL AND m.course_unit_id IS NULL AND m.target_room IN (?, 'GLOBAL'))
            OR m.course_unit_id = ?)
       AND m.target_school IN (?, 'ALL')
     ORDER BY m.created_at DESC, m.id DESC
     LIMIT 100`,
    [courseUnitId, targetRoom, courseUnitId, students[0].school]
  );
  return res.json(formatMessages(messages));
}));

app.post('/api/messages', auth('student'), asyncRoute(async (req, res) => {
  const text = typeof req.body.text === 'string' ? req.body.text.trim() : '';
  if (!text || text.length > 2000) {
    return res.status(400).json({ error: 'Messages must be between 1 and 2000 characters' });
  }
  const courseUnitId = req.body.courseUnitId === undefined || req.body.courseUnitId === null
    ? null
    : Number(req.body.courseUnitId);
  if (courseUnitId !== null && (!Number.isInteger(courseUnitId) || courseUnitId < 1)) {
    return res.status(400).json({ error: 'Choose a valid course chat' });
  }

  const [students] = await pool.query(
    `SELECT first_name, last_name, school, degree_program AS degreeProgram, program,
            year_of_study AS yearOfStudy, semester
     FROM students WHERE id = ?`,
    [req.user.id]
  );
  if (!students.length) return res.status(401).json({ error: 'Invalid session' });
  if (courseUnitId !== null) {
    if (!(await studentCanAccessCourseUnit(req.user.id, courseUnitId))) {
      return res.status(403).json({ error: 'You are not enrolled in this course chat' });
    }
  }

  const [result] = await pool.query(
    `INSERT INTO messages (sender_id, sender_name, text, target_room, course_unit_id)
     VALUES (?, ?, ?, ?, ?)`,
    [
      req.user.id,
      `${students[0].first_name} ${students[0].last_name}`,
      text,
      getRoomId(students[0]),
      courseUnitId
    ]
  );
  return res.status(201).json({ id: result.insertId });
}));

async function getEditableMessage(req) {
  const messageId = Number(req.params.id);
  if (!Number.isInteger(messageId) || messageId < 1) {
    return { status: 400, error: 'Choose a valid message' };
  }

  const [messages] = await pool.query(
    `SELECT id, sender_id AS senderId, sender_lecturer_id AS senderLecturerId,
            is_broadcast AS isBroadcast, course_unit_id AS courseUnitId,
            target_room AS targetRoom, target_school AS targetSchool
     FROM messages
     WHERE id = ?`,
    [messageId]
  );
  const message = messages[0];
  if (!message) return { status: 404, error: 'Message not found' };
  if (message.isBroadcast) return { status: 403, error: 'Broadcast messages cannot be changed here' };

  if (req.user.role === 'student') {
    if (Number(message.senderId) !== req.user.id) {
      return { status: 403, error: 'You can only change your own messages' };
    }

    const [students] = await pool.query(
      `SELECT school, degree_program AS degreeProgram, program,
              year_of_study AS yearOfStudy, semester
       FROM students
       WHERE id = ?`,
      [req.user.id]
    );
    if (!students.length) return { status: 401, error: 'Invalid session' };

    if (message.courseUnitId !== null) {
      if (!(await studentCanAccessCourseUnit(req.user.id, message.courseUnitId))) {
        return { status: 403, error: 'You are no longer enrolled in this course chat' };
      }
    } else if (
      !['GLOBAL', getRoomId(students[0])].includes(message.targetRoom) ||
      !['ALL', students[0].school].includes(message.targetSchool)
    ) {
      return { status: 403, error: 'You no longer have access to this chat' };
    }
  } else if (req.user.role === 'lecturer') {
    if (
      Number(message.senderLecturerId) !== req.user.id ||
      message.courseUnitId === null
    ) {
      return { status: 403, error: 'You can only change your own class messages' };
    }
    const [courses] = await pool.query(
      'SELECT id FROM course_units WHERE id = ? AND lecturer_id = ?',
      [message.courseUnitId, req.user.id]
    );
    if (!courses.length) return { status: 403, error: 'You are not assigned to this course unit' };
  } else {
    return { status: 403, error: 'You cannot change this message' };
  }

  return { message };
}

app.put('/api/messages/:id', auth(['student', 'lecturer']), asyncRoute(async (req, res) => {
  const text = typeof req.body.text === 'string' ? req.body.text.trim() : '';
  if (!text || text.length > 2000) {
    return res.status(400).json({ error: 'Messages must be between 1 and 2000 characters' });
  }

  const access = await getEditableMessage(req);
  if (access.error) return res.status(access.status).json({ error: access.error });

  const senderColumn = req.user.role === 'student' ? 'sender_id' : 'sender_lecturer_id';
  const [result] = await pool.query(
    `UPDATE messages
     SET text = ?, edited_at = CURRENT_TIMESTAMP
     WHERE id = ? AND ${senderColumn} = ? AND is_broadcast = FALSE`,
    [text, req.params.id, req.user.id]
  );
  if (!result.affectedRows) return res.status(404).json({ error: 'Message not found' });
  return res.json({ ok: true });
}));

app.delete('/api/messages/:id', auth(['student', 'lecturer']), asyncRoute(async (req, res) => {
  const access = await getEditableMessage(req);
  if (access.error) return res.status(access.status).json({ error: access.error });

  const senderColumn = req.user.role === 'student' ? 'sender_id' : 'sender_lecturer_id';
  const [result] = await pool.query(
    `DELETE FROM messages
     WHERE id = ? AND ${senderColumn} = ? AND is_broadcast = FALSE`,
    [req.params.id, req.user.id]
  );
  if (!result.affectedRows) return res.status(404).json({ error: 'Message not found' });
  return res.json({ ok: true });
}));

app.get('/api/notes/:courseUnitId', auth(['student', 'lecturer']), asyncRoute(async (req, res) => {
  const courseUnitId = Number(req.params.courseUnitId);
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  if (req.query.search !== undefined && typeof req.query.search !== 'string') {
    return res.status(400).json({ error: 'Search must be a single text value' });
  }
  if (search.length > 100) return res.status(400).json({ error: 'Search must be 100 characters or fewer' });
  if (!Number.isInteger(courseUnitId) || courseUnitId < 1) {
    return res.status(400).json({ error: 'Choose a valid course unit' });
  }
  if (req.user.role === 'student') {
    if (!(await studentCanAccessCourseUnit(req.user.id, courseUnitId))) {
      return res.status(403).json({ error: 'You are not enrolled in this course unit' });
    }
  } else {
    const [courses] = await pool.query(
      'SELECT id FROM course_units WHERE id = ? AND lecturer_id = ?',
      [courseUnitId, req.user.id]
    );
    if (!courses.length) return res.status(403).json({ error: 'You are not assigned to this course unit' });
  }
  const [notes] = await pool.query(
    `SELECT id, title, file_path AS filePath, uploaded_at AS uploadedAt
     FROM notes WHERE course_unit_id = ? ${search ? 'AND title LIKE ?' : ''}
     ORDER BY uploaded_at DESC, id DESC`,
    search ? [courseUnitId, `%${search}%`] : [courseUnitId]
  );
  return res.json(notes.map((note) => ({
    ...note,
    fileName: path.basename(note.filePath),
    fileExtension: path.extname(note.filePath),
    filePath: undefined
  })));
}));

app.get('/api/lecturer/notes', auth('lecturer'), asyncRoute(async (req, res) => {
  const courseUnitId = Number(req.query.course_unit_id);
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  if (req.query.search !== undefined && typeof req.query.search !== 'string') {
    return res.status(400).json({ error: 'Search must be a single text value' });
  }
  if (!Number.isInteger(courseUnitId) || courseUnitId < 1) {
    return res.status(400).json({ error: 'Choose a valid course unit' });
  }
  if (search.length > 100) return res.status(400).json({ error: 'Search must be 100 characters or fewer' });
  const [courses] = await pool.query(
    'SELECT id FROM course_units WHERE id = ? AND lecturer_id = ?',
    [courseUnitId, req.user.id]
  );
  if (!courses.length) return res.status(403).json({ error: 'You are not assigned to this course unit' });
  const [notes] = await pool.query(
    `SELECT id, title, file_path AS filePath, uploaded_at AS uploadedAt
     FROM notes WHERE course_unit_id = ? ${search ? 'AND title LIKE ?' : ''}
     ORDER BY uploaded_at DESC, id DESC`,
    search ? [courseUnitId, `%${search}%`] : [courseUnitId]
  );
  return res.json(notes.map((note) => ({
    ...note,
    fileName: path.basename(note.filePath),
    fileExtension: path.extname(note.filePath),
    filePath: undefined
  })));
}));

app.get('/api/notes/:id/download', auth(['student', 'lecturer', 'admin']), asyncRoute(async (req, res) => {
  const noteId = Number(req.params.id);
  if (!Number.isInteger(noteId) || noteId < 1) {
    return res.status(400).json({ error: 'Choose a valid note' });
  }
  const [notes] = await pool.query(
    `SELECT id, course_unit_id AS courseUnitId, lecturer_id AS lecturerId, file_path AS filePath,
            title
     FROM notes WHERE id = ?`,
    [noteId]
  );
  if (!notes.length) return res.status(404).json({ error: 'Note not found' });
  const note = notes[0];
  if (req.user.role === 'student') {
    if (!(await studentCanAccessCourseUnit(req.user.id, note.courseUnitId))) {
      return res.status(403).json({ error: 'You are not enrolled in this course unit' });
    }
  } else if (req.user.role === 'lecturer' && Number(note.lecturerId) !== Number(req.user.id)) {
    return res.status(403).json({ error: 'You are not assigned to this note' });
  }
  const fileName = path.basename(note.filePath);
  const filePath = path.join(uploadDirectory, fileName);
  return res.download(filePath, `${note.title}${path.extname(fileName)}`, (error) => {
    if (error && !res.headersSent) {
      res.status(error.code === 'ENOENT' ? 404 : 500).json({
        error: error.code === 'ENOENT' ? 'The note file is no longer available' : 'Could not download the note'
      });
    }
  });
}));

app.get('/api/lecturer/me', auth('lecturer'), asyncRoute(async (req, res) => {
  const [lecturers] = await pool.query(
    'SELECT id, name, email, school FROM lecturers WHERE id = ?',
    [req.user.id]
  );
  if (!lecturers.length) return res.status(404).json({ error: 'Lecturer account not found' });
  return res.json(lecturers[0]);
}));

app.get('/api/lecturer/courses', auth('lecturer'), asyncRoute(async (req, res) => {
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  if (req.query.search !== undefined && typeof req.query.search !== 'string') {
    return res.status(400).json({ error: 'Search must be a single text value' });
  }
  if (search.length > 100) return res.status(400).json({ error: 'Search must be 100 characters or fewer' });
  const searchFilter = search ? 'AND (cu.code LIKE ? OR cu.name LIKE ?)' : '';
  const searchPattern = `%${search}%`;
  const [courses] = await pool.query(
    `SELECT cu.id, cu.code, cu.name, cu.school, cu.degree_program AS degreeProgram,
            cu.year_of_study AS yearOfStudy, cu.semester,
            (SELECT COUNT(*) FROM registrations r WHERE r.course_unit_id = cu.id) AS studentCount
     FROM course_units cu
     WHERE cu.lecturer_id = ?
       ${searchFilter}
     ORDER BY cu.code`,
    search ? [req.user.id, searchPattern, searchPattern] : [req.user.id]
  );
  return res.json(courses);
}));

app.get('/api/lecturer/messages', auth('lecturer'), asyncRoute(async (req, res) => {
  const courseUnitId = Number(req.query.course_unit_id);
  if (!Number.isInteger(courseUnitId) || courseUnitId < 1) {
    return res.status(400).json({ error: 'Choose a valid course chat' });
  }
  const [courses] = await pool.query(
    'SELECT id FROM course_units WHERE id = ? AND lecturer_id = ?',
    [courseUnitId, req.user.id]
  );
  if (!courses.length) return res.status(403).json({ error: 'You are not assigned to this course unit' });
  const [messages] = await pool.query(
    `SELECT m.id, m.sender_id AS senderId, m.sender_lecturer_id AS senderLecturerId,
            m.sender_name AS senderName, m.text, m.is_broadcast AS isBroadcast,
            m.target_room AS targetRoom, m.course_unit_id AS courseUnitId,
            m.created_at AS createdAt, m.edited_at AS editedAt,
            s.profile_picture AS senderProfilePicture,
            s.phone_number AS senderPhoneNumber
     FROM messages m
     LEFT JOIN students s ON s.id = m.sender_id
     WHERE m.course_unit_id = ?
     ORDER BY m.created_at DESC, m.id DESC
     LIMIT 100`,
    [courseUnitId]
  );
  return res.json(formatMessages(messages));
}));

app.post('/api/lecturer/messages', auth('lecturer'), asyncRoute(async (req, res) => {
  const text = typeof req.body.text === 'string' ? req.body.text.trim() : '';
  const courseUnitId = Number(req.body.courseUnitId);
  if (!text || text.length > 2000) {
    return res.status(400).json({ error: 'Messages must be between 1 and 2000 characters' });
  }
  if (!Number.isInteger(courseUnitId) || courseUnitId < 1) {
    return res.status(400).json({ error: 'Choose a valid course chat' });
  }
  const [courses] = await pool.query(
    'SELECT id FROM course_units WHERE id = ? AND lecturer_id = ?',
    [courseUnitId, req.user.id]
  );
  if (!courses.length) return res.status(403).json({ error: 'You are not assigned to this course unit' });
  const [result] = await pool.query(
    `INSERT INTO messages (sender_lecturer_id, sender_name, text, course_unit_id)
     VALUES (?, ?, ?, ?)`,
    [req.user.id, req.user.name, text, courseUnitId]
  );
  return res.status(201).json({ id: result.insertId });
}));

app.post('/api/lecturer/notes', auth('lecturer'), handleNoteUpload, asyncRoute(async (req, res) => {
  const courseUnitId = Number(req.body.courseUnitId);
  const title = typeof req.body.title === 'string' ? req.body.title.trim() : '';
  if (!req.file) return res.status(400).json({ error: 'Choose a PDF or DOCX file to upload' });
  if (!Number.isInteger(courseUnitId) || courseUnitId < 1 || !title || title.length > 200) {
    await unlink(req.file.path);
    return res.status(400).json({ error: 'Enter a valid course and note title' });
  }

  const extension = path.extname(req.file.originalname).toLowerCase();
  let fileHandle;
  try {
    const [courses] = await pool.query(
      'SELECT id FROM course_units WHERE id = ? AND lecturer_id = ?',
      [courseUnitId, req.user.id]
    );
    if (!courses.length) {
      await unlink(req.file.path);
      return res.status(403).json({ error: 'You are not assigned to this course unit' });
    }

    fileHandle = await open(req.file.path, 'r');
    const signature = Buffer.alloc(5);
    const { bytesRead } = await fileHandle.read(signature, 0, signature.length, 0);
    await fileHandle.close();
    fileHandle = null;
    const validSignature = extension === '.pdf'
      ? bytesRead >= 5 && signature.subarray(0, 4).toString('ascii') === '%PDF'
      : bytesRead >= 4 && signature[0] === 0x50 && signature[1] === 0x4b &&
        signature[2] === 0x03 && signature[3] === 0x04;
    if (!validSignature) {
      await unlink(req.file.path);
      return res.status(400).json({ error: 'The file contents do not match a valid PDF or DOCX file' });
    }

    const [result] = await pool.query(
      `INSERT INTO notes (course_unit_id, lecturer_id, title, file_path)
       VALUES (?, ?, ?, ?)`,
      [courseUnitId, req.user.id, title, req.file.filename]
    );
    try {
      const [recipients] = await pool.query(
        `SELECT r.student_id AS studentId, cu.code
         FROM registrations r
         JOIN course_units cu ON cu.id = r.course_unit_id
         WHERE r.course_unit_id = ?`,
        [courseUnitId]
      );
      await sendPushToStudents(
        recipients.map((recipient) => recipient.studentId),
        {
          title: `${recipients[0]?.code || 'Course'} notes uploaded`,
          body: title,
          data: { url: '/' }
        }
      );
    } catch (pushError) {
      console.error(`Could not notify students about note ${result.insertId}:`, pushError);
    }
    return res.status(201).json({ id: result.insertId, title });
  } catch (error) {
    if (fileHandle) await fileHandle.close();
    await unlink(req.file.path).catch((cleanupError) => {
      console.error('Unable to remove rejected note upload:', cleanupError);
    });
    throw error;
  }
}));

app.get('/api/admin/me', authSchoolAdmin, (req, res) => {
  return res.json({
    id: req.user.admin_id,
    role: req.user.role,
    school: req.user.school
  });
});

app.get('/api/superadmin/admins', auth('SUPER_ADMIN'), asyncRoute(async (req, res) => {
  const [admins] = await pool.query(
    `SELECT id, email, school, role, created_at AS createdAt
     FROM admins
     ORDER BY role, school, email`
  );
  return res.json(admins);
}));

app.post('/api/superadmin/admins', auth('SUPER_ADMIN'), asyncRoute(async (req, res) => {
  const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body.password === 'string' ? req.body.password : '';
  const school = req.body.school;
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 100 ||
      password.length < 12 || password.length > 200 ||
      !isOneOf(school, ['SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other'])) {
    return res.status(400).json({ error: 'Enter a valid email, school, and password (at least 12 characters)' });
  }
  try {
    const passwordHash = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      `INSERT INTO admins (email, password_hash, school, role)
       VALUES (?, ?, ?, 'SCHOOL_ADMIN')`,
      [email, passwordHash, school]
    );
    return res.status(201).json({ id: result.insertId });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'An admin with that email already exists' });
    }
    throw error;
  }
}));

app.get('/api/admin/lecturers', authSchoolAdmin, asyncRoute(async (req, res) => {
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  if (req.query.search !== undefined && typeof req.query.search !== 'string') {
    return res.status(400).json({ error: 'Search must be a single text value' });
  }
  if (search.length > 100) return res.status(400).json({ error: 'Search must be 100 characters or fewer' });
  const scopeFilter = adminSchoolFilter(req, 'l.school');
  const searchFilter = search
    ? `WHERE (l.name LIKE ? OR l.email LIKE ?)${scopeFilter.sql}`
    : scopeFilter.sql ? `WHERE ${scopeFilter.sql.trim().replace(/^AND /, '')}` : '';
  const searchPattern = `%${search}%`;
  const [lecturers] = await pool.query(
    `SELECT l.id, l.name, l.email, l.school,
            COUNT(cu.id) AS courseCount
     FROM lecturers l
     LEFT JOIN course_units cu ON cu.lecturer_id = l.id
       ${isSuperAdmin(req) ? '' : 'AND cu.school = ?'}
     ${searchFilter}
     GROUP BY l.id
     ORDER BY l.name`,
    [
      ...(!isSuperAdmin(req) ? [req.user.school] : []),
      ...(search ? [searchPattern, searchPattern] : []),
      ...scopeFilter.params
    ]
  );
  return res.json(lecturers);
}));

app.post('/api/admin/lecturers', authSchoolAdmin, asyncRoute(async (req, res) => {
  const name = typeof req.body.name === 'string' ? req.body.name.trim() : '';
  const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body.password === 'string' ? req.body.password : '';
  const school = isSuperAdmin(req) ? req.body.school : req.user.school;
  if (!name || name.length > 100 ||
      !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 100 ||
      password.length < 8 || password.length > 200 ||
      !isOneOf(school, ['SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other'])) {
    return res.status(400).json({ error: 'Enter a valid name, email, school, and password (at least 8 characters)' });
  }
  try {
    const passwordHash = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      'INSERT INTO lecturers (name, email, password_hash, school) VALUES (?, ?, ?, ?)',
      [name, email, passwordHash, school]
    );
    return res.status(201).json({ id: result.insertId });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'A lecturer with that email already exists' });
    }
    throw error;
  }
}));

app.get('/api/admin/classes', authSchoolAdmin, asyncRoute(async (req, res) => {
  const scopeFilter = adminSchoolFilter(req, 'cu.school');
  const [classes] = await pool.query(
    `SELECT cs.id, cs.course_unit_id AS courseUnitId, cu.code, cu.name AS courseName,
            COALESCE(cs.lecturer_id, cu.lecturer_id) AS lecturerId, cs.program,
            cs.day_of_week AS dayOfWeek, cs.start_time AS startTime,
            cs.end_time AS endTime, cs.room, l.name AS lecturerName
     FROM class_schedules cs
     JOIN course_units cu ON cu.id = cs.course_unit_id
     LEFT JOIN lecturers l ON l.id = COALESCE(cs.lecturer_id, cu.lecturer_id)
     WHERE 1 = 1${scopeFilter.sql}
     ORDER BY FIELD(cs.day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
                    'Friday', 'Saturday', 'Sunday'), cs.start_time, cu.code`
    , scopeFilter.params
  );
  return res.json(classes);
}));

app.post('/api/admin/classes', authSchoolAdmin, asyncRoute(async (req, res) => {
  const courseUnitId = Number(req.body.courseUnitId);
  const lecturerId = Number(req.body.lecturerId);
  const { dayOfWeek, startTime, endTime, room, program = 'BOTH' } = req.body;
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  if (!Number.isInteger(courseUnitId) || courseUnitId < 1 ||
      !Number.isInteger(lecturerId) || lecturerId < 1 ||
      !isOneOf(dayOfWeek, days) ||
      typeof startTime !== 'string' || !/^\d{2}:\d{2}$/.test(startTime) ||
      typeof endTime !== 'string' || !/^\d{2}:\d{2}$/.test(endTime) ||
      startTime >= endTime || typeof room !== 'string' || !room.trim() || room.trim().length > 50 ||
      !isOneOf(program, ['DAY', 'WEEKEND', 'EVENING', 'DISTANCE', 'BOTH'])) {
    return res.status(400).json({ error: 'Enter a valid course, lecturer, day, time range, room, and program' });
  }
  const schoolScope = isSuperAdmin(req) ? '' : ' AND cu.school = ?';
  const [matchingCourse] = await pool.query(
    `SELECT cu.id FROM course_units cu
     JOIN lecturers l ON l.id = ? AND l.school = cu.school
     WHERE cu.id = ?${schoolScope}`,
    [lecturerId, courseUnitId, ...(!isSuperAdmin(req) ? [req.user.school] : [])]
  );
  if (!matchingCourse.length) {
    return res.status(400).json({ error: 'Choose a lecturer from the course unit’s school' });
  }
  const [result] = await pool.query(
    `INSERT INTO class_schedules
       (course_unit_id, lecturer_id, day_of_week, start_time, end_time, room, program)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      courseUnitId, lecturerId, dayOfWeek, `${startTime}:00`, `${endTime}:00`, room.trim(), program
    ]
  );
  return res.status(201).json({ id: result.insertId });
}));

app.put('/api/admin/classes/:id', authSchoolAdmin, asyncRoute(async (req, res) => {
  const scheduleId = Number(req.params.id);
  const courseUnitId = Number(req.body.courseUnitId);
  const lecturerId = Number(req.body.lecturerId);
  const { dayOfWeek, startTime, endTime, room, program } = req.body;
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  if (!Number.isInteger(scheduleId) || scheduleId < 1 ||
      !Number.isInteger(courseUnitId) || courseUnitId < 1 ||
      !Number.isInteger(lecturerId) || lecturerId < 1 ||
      !isOneOf(dayOfWeek, days) ||
      typeof startTime !== 'string' || !/^\d{2}:\d{2}$/.test(startTime) ||
      typeof endTime !== 'string' || !/^\d{2}:\d{2}$/.test(endTime) ||
      startTime >= endTime || typeof room !== 'string' || !room.trim() || room.trim().length > 50 ||
      !isOneOf(program, ['DAY', 'WEEKEND', 'EVENING', 'DISTANCE', 'BOTH'])) {
    return res.status(400).json({ error: 'Enter a valid course, lecturer, day, time range, room, and program' });
  }

  const scopeFilter = adminSchoolFilter(req, 'cu.school');
  const [matchingCourse] = await pool.query(
    `SELECT cu.id FROM course_units cu
     JOIN lecturers l ON l.id = ? AND l.school = cu.school
     WHERE cu.id = ?${scopeFilter.sql}`,
    [lecturerId, courseUnitId, ...scopeFilter.params]
  );
  if (!matchingCourse.length) {
    return res.status(400).json({ error: 'Choose a lecturer from the course unit’s school' });
  }

  const [result] = await pool.query(
    `UPDATE class_schedules cs
     JOIN course_units cu ON cu.id = cs.course_unit_id
     SET cs.course_unit_id = ?, cs.lecturer_id = ?, cs.day_of_week = ?,
         cs.start_time = ?, cs.end_time = ?, cs.room = ?, cs.program = ?
     WHERE cs.id = ?${scopeFilter.sql}`,
    [
      courseUnitId, lecturerId, dayOfWeek, `${startTime}:00`, `${endTime}:00`,
      room.trim(), program, scheduleId, ...scopeFilter.params
    ]
  );
  if (!result.affectedRows) {
    const [existing] = await pool.query(
      `SELECT cs.id FROM class_schedules cs
       JOIN course_units cu ON cu.id = cs.course_unit_id
       WHERE cs.id = ?${scopeFilter.sql}`,
      [scheduleId, ...scopeFilter.params]
    );
    if (!existing.length) return res.status(404).json({ error: 'Class schedule not found' });
  }
  return res.json({ ok: true });
}));

app.delete('/api/admin/classes/:id', authSchoolAdmin, asyncRoute(async (req, res) => {
  const scheduleId = Number(req.params.id);
  if (!Number.isInteger(scheduleId) || scheduleId < 1) {
    return res.status(400).json({ error: 'A valid class schedule is required' });
  }
  const scopeFilter = adminSchoolFilter(req, 'cu.school');
  const [result] = await pool.query(
    `DELETE cs FROM class_schedules cs
     JOIN course_units cu ON cu.id = cs.course_unit_id
     WHERE cs.id = ?${scopeFilter.sql}`,
    [scheduleId, ...scopeFilter.params]
  );
  if (!result.affectedRows) return res.status(404).json({ error: 'Class schedule not found' });
  return res.json({ ok: true });
}));

app.post('/api/admin/broadcast', authSchoolAdmin, asyncRoute(async (req, res) => {
  const text = typeof req.body.text === 'string' ? req.body.text.trim() : '';
  const targetRoom = typeof req.body.target_room === 'string' ? req.body.target_room : '';
  const requestedTargetSchool = req.body.target_school === undefined ? 'ALL' : req.body.target_school;
  const targetSchool = requestedTargetSchool;
  if (!text || text.length > 2000) {
    return res.status(400).json({ error: 'Broadcasts must be between 1 and 2000 characters' });
  }
  if (!isValidTargetRoom(targetRoom)) {
    return res.status(400).json({ error: 'Choose a valid broadcast target' });
  }
  if (!isOneOf(targetSchool, ['SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other', 'ALL']) ||
      (!isSuperAdmin(req) && !['ALL', req.user.school].includes(targetSchool))) {
    return res.status(403).json({ error: 'You can only target your own school or the whole university' });
  }
  if (targetSchool === 'ALL' && targetRoom !== 'GLOBAL') {
    return res.status(400).json({ error: 'University-wide broadcasts must use the Global chat room' });
  }
  if (targetRoom !== 'GLOBAL') {
    const roomSchool = targetRoom.split('-')[0];
    if (targetSchool !== 'ALL' && targetSchool !== roomSchool) {
      return res.status(400).json({ error: 'The broadcast school must match the selected chat room' });
    }
  }
  if (!isSuperAdmin(req) && targetRoom !== 'GLOBAL' && !targetRoom.startsWith(`${req.user.school}-`)) {
    return res.status(403).json({ error: 'You can only broadcast to chat groups in your school' });
  }
  const [result] = await pool.query(
    `INSERT INTO messages (sender_id, sender_name, text, is_broadcast, target_room, target_school)
     VALUES (NULL, ?, ?, TRUE, ?, ?)`,
    ['Admin', text, targetRoom, targetSchool]
  );
  try {
    const recipients = await getBroadcastStudentIds(targetRoom, targetSchool);
    await sendPushToStudents(recipients, {
      title: targetSchool === 'ALL' ? 'University update' : `${targetSchool} update`,
      body: text,
      data: { url: '/' }
    });
  } catch (pushError) {
    console.error(`Broadcast ${result.insertId} was saved but push delivery could not start:`, pushError);
  }
  return res.status(201).json({ id: result.insertId });
}));

app.get('/api/admin/messages', authSchoolAdmin, asyncRoute(async (req, res) => {
  const targetRoom = typeof req.query.target_room === 'string' ? req.query.target_room : '';
  if (!isValidTargetRoom(targetRoom)) {
    return res.status(400).json({ error: 'Choose a valid chat room' });
  }
  if (!isSuperAdmin(req) && targetRoom !== 'GLOBAL' && !targetRoom.startsWith(`${req.user.school}-`)) {
    return res.status(403).json({ error: 'You can only view chat rooms in your school' });
  }
  const [messages] = await pool.query(
    `SELECT m.id, m.sender_id AS senderId, m.sender_name AS senderName, m.text,
            m.is_broadcast AS isBroadcast, m.target_room AS targetRoom,
            m.created_at AS createdAt, s.profile_picture AS senderProfilePicture
     FROM messages m
     LEFT JOIN students s ON s.id = m.sender_id
     WHERE m.course_unit_id IS NULL
       AND (m.target_room = ? OR (? <> 'GLOBAL' AND m.target_room = 'GLOBAL'))
       ${isSuperAdmin(req) ? '' : 'AND m.target_school IN (?, \'ALL\')'}
     ORDER BY m.created_at DESC, m.id DESC
     LIMIT 100`,
    [
      targetRoom, targetRoom,
      ...(!isSuperAdmin(req) ? [req.user.school] : [])
    ]
  );
  return res.json(formatMessages(messages));
}));

app.get('/api/admin/broadcasts', authSchoolAdmin, asyncRoute(async (req, res) => {
  const scopeFilter = adminSchoolFilter(req, 'target_school');
  const [messages] = await pool.query(
    `SELECT id, sender_name AS senderName, text,
            is_broadcast AS isBroadcast, target_room AS targetRoom, target_school AS targetSchool,
            created_at AS createdAt
     FROM messages
     WHERE is_broadcast = TRUE${scopeFilter.sql ? ` AND (${scopeFilter.sql.replace(/^ AND /, '')} OR target_school = 'ALL')` : ''}
     ORDER BY created_at DESC, id DESC
     LIMIT 100`,
    scopeFilter.params
  );
  return res.json(messages.map((message) => ({
    ...message,
    isBroadcast: Boolean(message.isBroadcast)
  })));
}));

app.get('/api/admin/chat-options', authSchoolAdmin, asyncRoute(async (req, res) => {
  const scopeFilter = adminSchoolFilter(req, 'school');
  const [degreePrograms] = await pool.query(
    `SELECT DISTINCT degree_program AS degreeProgram
     FROM students
     WHERE degree_program IS NOT NULL AND TRIM(degree_program) <> ''${scopeFilter.sql}
     ORDER BY degree_program`
    , scopeFilter.params
  );
  return res.json({ degreePrograms: degreePrograms.map((row) => row.degreeProgram) });
}));

app.get('/api/admin/course-units', authSchoolAdmin, asyncRoute(async (req, res) => {
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  if (req.query.search !== undefined && typeof req.query.search !== 'string') {
    return res.status(400).json({ error: 'Search must be a single text value' });
  }
  if (search.length > 100) return res.status(400).json({ error: 'Search must be 100 characters or fewer' });
  const scopeFilter = adminSchoolFilter(req, 'school');
  const searchFilter = search
    ? `WHERE (code LIKE ? OR name LIKE ?)${scopeFilter.sql}`
    : scopeFilter.sql ? `WHERE ${scopeFilter.sql.trim().replace(/^AND /, '')}` : '';
  const searchPattern = `%${search}%`;
  const [units] = await pool.query(
    `SELECT id, code, name, school, degree_program AS degreeProgram,
            academic_level AS academicLevel,
            year_of_study AS yearOfStudy, semester, lecturer_id AS lecturerId, is_public AS isPublic
     FROM course_units ${searchFilter} ORDER BY code`,
    [...(search ? [searchPattern, searchPattern] : []), ...scopeFilter.params]
  );
  return res.json(units);
}));

app.get('/api/admin/students', authSchoolAdmin, asyncRoute(async (req, res) => {
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  if (req.query.search !== undefined && typeof req.query.search !== 'string') {
    return res.status(400).json({ error: 'Search must be a single text value' });
  }
  if (search.length > 100) return res.status(400).json({ error: 'Search must be 100 characters or fewer' });
  const scopeFilter = adminSchoolFilter(req, 's.school');
  const searchFilter = search
    ? `WHERE (s.first_name LIKE ? OR s.last_name LIKE ? OR CONCAT(s.first_name, " ", s.last_name) LIKE ? OR s.student_number LIKE ? OR s.degree_program LIKE ?)${scopeFilter.sql}`
    : scopeFilter.sql ? `WHERE ${scopeFilter.sql.trim().replace(/^AND /, '')}` : '';
  const searchPattern = `%${search}%`;
  const [students] = await pool.query(
    `SELECT s.id, s.first_name AS firstName, s.last_name AS lastName,
            s.student_number AS studentNumber, s.email, s.school,
            s.degree_program AS degreeProgram, s.academic_level AS academicLevel, s.program,
            s.year_of_study AS yearOfStudy, s.semester, s.created_at AS createdAt
     FROM students s
     ${searchFilter}
     ORDER BY s.last_name, s.first_name
     LIMIT 500`,
    [
      ...(search
        ? [searchPattern, searchPattern, searchPattern, searchPattern, searchPattern]
        : []),
      ...scopeFilter.params
    ]
  );
  return res.json(students);
}));

app.post('/api/admin/course-units', authSchoolAdmin, asyncRoute(async (req, res) => {
  const { code, name } = req.body;
  const school = isSuperAdmin(req) ? req.body.school : req.user.school;
  const isPublic = req.body.isPublic === undefined ? false : req.body.isPublic;
  const academicLevel = req.body.academicLevel;
  const degreeProgram = normalizeDegreeProgram(req.body.degreeProgram);
  const yearOfStudy = Number(req.body.yearOfStudy);
  const semester = Number(req.body.semester);
  const lecturerId = req.body.lecturerId === '' || req.body.lecturerId === null ||
    req.body.lecturerId === undefined ? null : Number(req.body.lecturerId);
  if (typeof code !== 'string' || !code.trim() ||
      typeof name !== 'string' || !name.trim() ||
      !degreeProgram ||
      !isOneOf(academicLevel, ['Certificate', 'Diploma', 'Degree', 'Masters', 'PhD']) ||
      !isOneOf(school, ['SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other']) ||
      typeof isPublic !== 'boolean' ||
      !Number.isInteger(yearOfStudy) || yearOfStudy < 1 || yearOfStudy > 5 ||
      !Number.isInteger(semester) || ![1, 2].includes(semester) ||
      (lecturerId !== null && (!Number.isInteger(lecturerId) || lecturerId < 1))) {
    return res.status(400).json({ error: 'Enter a valid code, name, academic level, degree program, school, year, and semester' });
  }
  if (lecturerId !== null) {
    const [lecturers] = await pool.query(
      'SELECT id FROM lecturers WHERE id = ? AND school = ?',
      [lecturerId, school]
    );
    if (!lecturers.length) return res.status(404).json({ error: 'Lecturer account not found' });
  }
  try {
    const [result] = await pool.query(
      `INSERT INTO course_units
         (code, name, school, degree_program, academic_level, year_of_study, semester, lecturer_id, is_public)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [code.trim(), name.trim(), school, degreeProgram, academicLevel, yearOfStudy, semester, lecturerId, isPublic]
    );
    return res.status(201).json({ id: result.insertId });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Course code already exists' });
    }
    throw error;
  }
}));

app.put('/api/admin/course-units/:id/lecturer', authSchoolAdmin, asyncRoute(async (req, res) => {
  const courseUnitId = Number(req.params.id);
  const lecturerId = req.body.lecturerId === null || req.body.lecturerId === ''
    ? null
    : Number(req.body.lecturerId);
  if (!Number.isInteger(courseUnitId) || courseUnitId < 1 ||
      (lecturerId !== null && (!Number.isInteger(lecturerId) || lecturerId < 1))) {
    return res.status(400).json({ error: 'Choose a valid course and lecturer' });
  }
  if (lecturerId !== null) {
    const [lecturers] = await pool.query(
      `SELECT l.id FROM lecturers l
       JOIN course_units cu ON cu.school = l.school
       WHERE l.id = ? AND cu.id = ?${isSuperAdmin(req) ? '' : ' AND cu.school = ?'}`,
      [lecturerId, courseUnitId, ...(!isSuperAdmin(req) ? [req.user.school] : [])]
    );
    if (!lecturers.length) {
      return res.status(400).json({ error: 'Assign a lecturer from the same school as the course' });
    }
  }
  const courseScope = isSuperAdmin(req) ? '' : ' AND school = ?';
  const courseParams = [lecturerId, courseUnitId, ...(!isSuperAdmin(req) ? [req.user.school] : [])];
  const [result] = await pool.query(
    `UPDATE course_units SET lecturer_id = ? WHERE id = ?${courseScope}`,
    courseParams
  );
  if (!result.affectedRows) {
    const [courses] = await pool.query(
      `SELECT id FROM course_units WHERE id = ?${isSuperAdmin(req) ? '' : ' AND school = ?'}`,
      [courseUnitId, ...(!isSuperAdmin(req) ? [req.user.school] : [])]
    );
    if (!courses.length) return res.status(404).json({ error: 'Course unit not found' });
  }
  await pool.query(
    `UPDATE class_schedules SET lecturer_id = ? WHERE course_unit_id = ?${isSuperAdmin(req) ? '' : ' AND course_unit_id IN (SELECT id FROM course_units WHERE school = ?)'}`,
    [lecturerId, courseUnitId, ...(!isSuperAdmin(req) ? [req.user.school] : [])]
  );
  return res.json({ ok: true });
}));

app.get('/api/admin/exams', authSchoolAdmin, asyncRoute(async (req, res) => {
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  if (req.query.search !== undefined && typeof req.query.search !== 'string') {
    return res.status(400).json({ error: 'Search must be a single text value' });
  }
  if (search.length > 100) return res.status(400).json({ error: 'Search must be 100 characters or fewer' });
  const scopeFilter = adminSchoolFilter(req, 'cu.school');
  const searchFilter = search
    ? `WHERE (cu.code LIKE ? OR cu.name LIKE ? OR e.room LIKE ? OR DATE_FORMAT(e.exam_date, "%Y-%m-%d") LIKE ?)${scopeFilter.sql}`
    : scopeFilter.sql ? `WHERE ${scopeFilter.sql.trim().replace(/^AND /, '')}` : '';
  const searchPattern = `%${search}%`;
  const [exams] = await pool.query(
    `SELECT e.id, cu.code, cu.name AS courseName, e.exam_date AS examDate,
            e.start_time AS startTime, e.end_time AS endTime, e.room, e.program,
            e.school, cu.degree_program AS degreeProgram,
            e.source_text AS sourceText, e.source_sheet AS sourceSheet,
            e.source_row AS sourceRow, e.source_date_label AS sourceDateLabel
     FROM exams e
     JOIN course_units cu ON cu.id = e.course_unit_id
     ${searchFilter}
     ORDER BY e.exam_date, e.start_time`,
    [
      ...(search ? [searchPattern, searchPattern, searchPattern, searchPattern] : []),
      ...scopeFilter.params
    ]
  );
  return res.json(exams);
}));

app.post('/api/admin/exams', authSchoolAdmin, asyncRoute(async (req, res) => {
  const submittedCourseUnitIds = Array.isArray(req.body.courseUnitIds)
    ? req.body.courseUnitIds
    : [req.body.courseUnitId];
  const courseUnitIds = submittedCourseUnitIds.map((id) =>
    typeof id === 'number' ? id :
      typeof id === 'string' && /^\d+$/.test(id) ? Number(id) : NaN
  );
  const { examDate, startTime, endTime, room } = req.body;
  const program = req.body.program === undefined ? 'BOTH' : req.body.program;
  if (!courseUnitIds.length || courseUnitIds.length > 50 ||
      courseUnitIds.some((id) => !Number.isInteger(id) || id < 1) ||
      new Set(courseUnitIds).size !== courseUnitIds.length ||
      typeof examDate !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(examDate) ||
      typeof startTime !== 'string' || !/^\d{2}:\d{2}$/.test(startTime) ||
      typeof endTime !== 'string' || !/^\d{2}:\d{2}$/.test(endTime) ||
      startTime >= endTime ||
      typeof room !== 'string' || !room.trim() ||
      !isOneOf(program, ['DAY', 'WEEKEND', 'EVENING', 'DISTANCE', 'BOTH', 'ALL'])) {
    return res.status(400).json({ error: 'Select valid course units and enter a valid date, time range, room, and program' });
  }

  const placeholders = courseUnitIds.map(() => '?').join(', ');
  const [units] = await pool.query(
    `SELECT id, school FROM course_units
     WHERE id IN (${placeholders})${isSuperAdmin(req) ? '' : ' AND school = ?'}`,
    [...courseUnitIds, ...(!isSuperAdmin(req) ? [req.user.school] : [])]
  );
  if (units.length !== courseUnitIds.length) {
    return res.status(404).json({ error: 'One or more course units could not be found' });
  }

  const values = units.map(() => '(?, ?, ?, ?, ?, ?, ?)').join(', ');
  const parameters = units.flatMap((unit) => [
    unit.id, examDate, `${startTime}:00`, `${endTime}:00`, room.trim(), program, unit.school
  ]);
  const [result] = await pool.query(
    `INSERT INTO exams (course_unit_id, exam_date, start_time, end_time, room, program, school)
     VALUES ${values}`,
    parameters
  );
  return res.status(201).json({ id: result.insertId, scheduled: result.affectedRows });
}));

app.delete('/api/admin/exams/:id', authSchoolAdmin, asyncRoute(async (req, res) => {
  const examId = Number(req.params.id);
  if (!Number.isInteger(examId) || examId < 1) {
    return res.status(400).json({ error: 'A valid exam is required' });
  }
  await pool.query(
    `DELETE e FROM exams e JOIN course_units cu ON cu.id = e.course_unit_id
     WHERE e.id = ?${isSuperAdmin(req) ? '' : ' AND cu.school = ?'}`,
    [examId, ...(!isSuperAdmin(req) ? [req.user.school] : [])]
  );
  return res.json({ ok: true });
}));

app.use('/api', (req, res) => {
  res.status(404).json({ error: 'API route not found' });
});

const clientDist = path.resolve(currentDirectory, '..', 'client', 'dist');
app.use(express.static(clientDist));
app.get('*', (req, res, next) => {
  res.sendFile(path.join(clientDist, 'index.html'), (error) => {
    if (error) next();
  });
});

app.use((error, req, res, next) => {
  console.error(error);
  if (res.headersSent) return next(error);
  if (error.type === 'entity.too.large') {
    return res.status(413).json({
      error: 'Request body is too large. Profile pictures must be 2 MB or smaller.'
    });
  }
  return res.status(500).json({ error: 'A server error occurred. Please try again later.' });
});

try {
  await pool.query('SELECT 1');
  const [bootstrapAdmins] = await pool.query(
    'SELECT id, role FROM admins WHERE email = ?',
    [adminEmail]
  );
  if (!bootstrapAdmins.length) {
    const bootstrapPasswordHash = await bcrypt.hash(adminPassword, 10);
    await pool.query(
      `INSERT INTO admins (email, password_hash, school, role)
       VALUES (?, ?, 'ALL', 'SUPER_ADMIN')`,
      [adminEmail, bootstrapPasswordHash]
    );
  } else if (bootstrapAdmins[0].role !== 'SUPER_ADMIN') {
    throw new Error('ADMIN_EMAIL must belong to a SUPER_ADMIN account');
  } else {
    await pool.query('UPDATE admins SET school = \'ALL\' WHERE id = ?', [bootstrapAdmins[0].id]);
  }
  app.listen(port, () => {
    console.log(`Exam timetable API running on http://localhost:${port}`);
  });
} catch (error) {
  console.error('Unable to connect to MySQL:', error.message);
  process.exitCode = 1;
  await pool.end();
}
