CREATE DATABASE IF NOT EXISTS exam_pwa
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE exam_pwa;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL DEFAULT '',
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('SUPER_ADMIN', 'UNIVERSITY_ADMIN', 'SCHOOL_ADMIN', 'EXAM_OFFICER', 'COORDINATOR') NOT NULL,
  university_code VARCHAR(30) NULL,
  school ENUM('SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other', 'ALL') NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_admins_university_role_school (university_code, role, school)
);

CREATE TABLE IF NOT EXISTS api_keys (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  university_code VARCHAR(30) NULL,
  key_prefix VARCHAR(16) NOT NULL,
  key_hash CHAR(64) NOT NULL UNIQUE,
  created_by INT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_used_at TIMESTAMP NULL DEFAULT NULL,
  KEY idx_api_keys_created_by (created_by),
  CONSTRAINT fk_api_key_admin FOREIGN KEY (created_by)
    REFERENCES admins(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  student_number VARCHAR(20) NOT NULL UNIQUE,
  academic_level ENUM('Certificate', 'Diploma', 'Degree', 'Masters', 'PhD') NOT NULL DEFAULT 'Degree',
  program ENUM('DAY', 'WEEKEND', 'EVENING', 'DISTANCE') NOT NULL,
  university_code VARCHAR(30) NOT NULL DEFAULT 'NKUMBA',
  school ENUM('SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other') NOT NULL,
  phone_number VARCHAR(20) NULL,
  degree_program VARCHAR(30) NOT NULL DEFAULT 'UNASSIGNED',
  year_of_study TINYINT UNSIGNED NOT NULL,
  semester TINYINT UNSIGNED NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  profile_picture LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_students_university_school (university_code, school)
);

CREATE TABLE IF NOT EXISTS push_subscriptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  endpoint TEXT NOT NULL,
  endpoint_hash CHAR(64) NOT NULL,
  p256dh VARCHAR(255) NOT NULL,
  auth VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_push_endpoint_hash (endpoint_hash),
  KEY idx_push_subscriptions_student (student_id),
  CONSTRAINT fk_push_subscription_student FOREIGN KEY (student_id)
    REFERENCES students(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lecturers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  university_code VARCHAR(30) NOT NULL DEFAULT 'NKUMBA',
  school ENUM('SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other') NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_lecturers_university_school (university_code, school)
);

CREATE TABLE IF NOT EXISTS course_units (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(40) NOT NULL,
  name VARCHAR(120) NOT NULL,
  university_code VARCHAR(30) NOT NULL DEFAULT 'NKUMBA',
  school ENUM('SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other') NOT NULL,
  degree_program VARCHAR(30) NOT NULL DEFAULT 'UNASSIGNED',
  academic_level ENUM('Certificate', 'Diploma', 'Degree', 'Masters', 'PhD') NOT NULL DEFAULT 'Degree',
  lecturer_id INT NULL,
  coordinator_id INT NULL,
  is_public BOOLEAN NOT NULL DEFAULT FALSE,
  year_of_study TINYINT UNSIGNED NOT NULL,
  semester TINYINT UNSIGNED NOT NULL,
  KEY idx_course_units_lecturer_id (lecturer_id),
  KEY idx_course_units_coordinator_id (coordinator_id),
  KEY idx_course_units_university_school (university_code, school),
  UNIQUE KEY uniq_course_offering
    (university_code, school, degree_program, academic_level, year_of_study, semester, code, name),
  CONSTRAINT fk_course_lecturer FOREIGN KEY (lecturer_id)
    REFERENCES lecturers(id) ON DELETE SET NULL,
  CONSTRAINT fk_course_coordinator FOREIGN KEY (coordinator_id)
    REFERENCES admins(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS class_schedules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_unit_id INT NOT NULL,
  lecturer_id INT NULL,
  coordinator_id INT NULL,
  day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  room VARCHAR(50) NOT NULL,
  program ENUM('DAY', 'WEEKEND', 'EVENING', 'DISTANCE', 'BOTH') NOT NULL DEFAULT 'BOTH',
  session_code VARCHAR(6) NULL,
  session_code_generated_by INT NULL,
  KEY idx_class_schedules_course_program (course_unit_id, program),
  KEY idx_class_schedules_day_time (day_of_week, start_time),
  KEY idx_class_schedules_lecturer_id (lecturer_id),
  KEY idx_class_schedules_coordinator_id (coordinator_id),
  CONSTRAINT fk_class_schedule_course FOREIGN KEY (course_unit_id)
    REFERENCES course_units(id) ON DELETE CASCADE,
  CONSTRAINT fk_class_schedule_lecturer FOREIGN KEY (lecturer_id)
    REFERENCES lecturers(id) ON DELETE SET NULL,
  CONSTRAINT fk_class_schedule_coordinator FOREIGN KEY (coordinator_id)
    REFERENCES admins(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_schedule_id INT NOT NULL,
  student_id INT NOT NULL,
  date DATE NOT NULL,
  status ENUM('PRESENT', 'ABSENT', 'LATE') NOT NULL,
  marked_by INT NULL,
  UNIQUE KEY uniq_attendance_schedule_student_date (class_schedule_id, student_id, date),
  KEY idx_attendance_student_date (student_id, date),
  CONSTRAINT fk_attendance_schedule FOREIGN KEY (class_schedule_id)
    REFERENCES class_schedules(id) ON DELETE CASCADE,
  CONSTRAINT fk_attendance_student FOREIGN KEY (student_id)
    REFERENCES students(id) ON DELETE CASCADE,
  CONSTRAINT fk_attendance_admin FOREIGN KEY (marked_by)
    REFERENCES admins(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS lecturer_notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  lecturer_id INT NOT NULL,
  course_unit_id INT NOT NULL,
  class_schedule_id INT NOT NULL,
  coordinator_admin_id INT NULL,
  message VARCHAR(500) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP NULL DEFAULT NULL,
  KEY idx_lecturer_notifications_unread (lecturer_id, read_at, created_at),
  CONSTRAINT fk_lecturer_notification_lecturer FOREIGN KEY (lecturer_id)
    REFERENCES lecturers(id) ON DELETE CASCADE,
  CONSTRAINT fk_lecturer_notification_course FOREIGN KEY (course_unit_id)
    REFERENCES course_units(id) ON DELETE CASCADE,
  CONSTRAINT fk_lecturer_notification_schedule FOREIGN KEY (class_schedule_id)
    REFERENCES class_schedules(id) ON DELETE CASCADE,
  CONSTRAINT fk_lecturer_notification_coordinator FOREIGN KEY (coordinator_admin_id)
    REFERENCES admins(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS notes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_unit_id INT NOT NULL,
  lecturer_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_notes_course_uploaded (course_unit_id, uploaded_at),
  CONSTRAINT fk_note_course FOREIGN KEY (course_unit_id)
    REFERENCES course_units(id) ON DELETE CASCADE,
  CONSTRAINT fk_note_lecturer FOREIGN KEY (lecturer_id)
    REFERENCES lecturers(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS registrations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_unit_id INT NOT NULL,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_registration (student_id, course_unit_id),
  CONSTRAINT fk_registration_student FOREIGN KEY (student_id)
    REFERENCES students(id) ON DELETE CASCADE,
  CONSTRAINT fk_registration_course FOREIGN KEY (course_unit_id)
    REFERENCES course_units(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS exams (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_unit_id INT NOT NULL,
  exam_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  room VARCHAR(50) NOT NULL,
  program ENUM('DAY', 'WEEKEND', 'EVENING', 'DISTANCE', 'BOTH', 'ALL') NOT NULL DEFAULT 'BOTH',
  university_code VARCHAR(30) NOT NULL DEFAULT 'NKUMBA',
  school ENUM('SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other') NOT NULL DEFAULT 'Other',
  invigilator_id INT NULL,
  room_assigned_by INT NULL,
  status ENUM('PENDING', 'SCHEDULED', 'ONGOING', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
  source_sheet VARCHAR(50) NULL,
  source_row INT UNSIGNED NULL,
  source_column TINYINT UNSIGNED NULL,
  source_date_label VARCHAR(100) NULL,
  source_text TEXT NULL,
  KEY idx_exams_invigilator_id (invigilator_id),
  KEY idx_exams_university_school (university_code, school),
  CONSTRAINT fk_exam_course FOREIGN KEY (course_unit_id)
    REFERENCES course_units(id) ON DELETE CASCADE,
  CONSTRAINT fk_exam_invigilator FOREIGN KEY (invigilator_id)
    REFERENCES lecturers(id) ON DELETE SET NULL,
  CONSTRAINT fk_exam_room_assigned_by FOREIGN KEY (room_assigned_by)
    REFERENCES admins(id) ON DELETE SET NULL,
  UNIQUE KEY uniq_exam_source (course_unit_id, source_sheet, source_row, source_column)
);

CREATE TABLE IF NOT EXISTS malpractice_cases (
  id INT AUTO_INCREMENT PRIMARY KEY,
  exam_id INT NOT NULL,
  student_id INT NOT NULL,
  reported_by INT NOT NULL,
  description TEXT NOT NULL,
  status ENUM('PENDING', 'RESOLVED', 'DISMISSED') NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_malpractice_cases_status_created (status, created_at),
  CONSTRAINT fk_malpractice_exam FOREIGN KEY (exam_id)
    REFERENCES exams(id) ON DELETE CASCADE,
  CONSTRAINT fk_malpractice_student FOREIGN KEY (student_id)
    REFERENCES students(id) ON DELETE CASCADE,
  CONSTRAINT fk_malpractice_reporter FOREIGN KEY (reported_by)
    REFERENCES lecturers(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sender_id INT NULL,
  sender_lecturer_id INT NULL,
  sender_name VARCHAR(101) NOT NULL,
  text TEXT NOT NULL,
  is_broadcast BOOLEAN NOT NULL DEFAULT FALSE,
  target_room VARCHAR(100) NOT NULL DEFAULT 'GLOBAL',
  university_code VARCHAR(30) NOT NULL DEFAULT 'NKUMBA',
  target_school ENUM('SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other', 'ALL') NOT NULL DEFAULT 'ALL',
  course_unit_id INT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  edited_at TIMESTAMP NULL DEFAULT NULL,
  KEY idx_messages_created_at (created_at, id),
  KEY idx_messages_target_room_created (target_room, created_at, id),
  KEY idx_messages_university_school (university_code, target_school, created_at, id),
  KEY idx_messages_course_unit_created (course_unit_id, created_at, id),
  KEY idx_messages_sender_lecturer_id (sender_lecturer_id),
  CONSTRAINT fk_message_sender FOREIGN KEY (sender_id)
    REFERENCES students(id) ON DELETE SET NULL,
  CONSTRAINT fk_message_lecturer FOREIGN KEY (sender_lecturer_id)
    REFERENCES lecturers(id) ON DELETE SET NULL,
  CONSTRAINT fk_message_course FOREIGN KEY (course_unit_id)
    REFERENCES course_units(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS chat_read_states (
  student_id INT NOT NULL,
  room_key VARCHAR(100) NOT NULL,
  last_read_message_id INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (student_id, room_key),
  CONSTRAINT fk_chat_read_student FOREIGN KEY (student_id)
    REFERENCES students(id) ON DELETE CASCADE
);

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS drop_course_offering_unique;

DELIMITER //

CREATE PROCEDURE add_column_if_missing(
  IN table_name_to_check VARCHAR(64),
  IN column_name_to_check VARCHAR(64),
  IN column_definition TEXT
)
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = table_name_to_check
      AND column_name = column_name_to_check
  ) THEN
    SET @migration_sql = CONCAT(
      'ALTER TABLE `',
      REPLACE(table_name_to_check, '`', '``'),
      '` ADD COLUMN `',
      REPLACE(column_name_to_check, '`', '``'),
      '` ',
      column_definition
    );
    PREPARE migration_statement FROM @migration_sql;
    EXECUTE migration_statement;
    DEALLOCATE PREPARE migration_statement;
  END IF;
END//

CREATE PROCEDURE drop_legacy_course_code_unique()
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'course_units'
      AND index_name = 'code'
      AND non_unique = 0
  ) THEN
    ALTER TABLE course_units DROP INDEX code;
  END IF;
END//

CREATE PROCEDURE drop_course_offering_unique()
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'course_units'
      AND index_name = 'uniq_course_offering'
  ) THEN
    ALTER TABLE course_units DROP INDEX uniq_course_offering;
  END IF;
END//

CREATE PROCEDURE add_index_if_missing(
  IN table_name_to_check VARCHAR(64),
  IN index_name_to_check VARCHAR(64),
  IN index_definition TEXT
)
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = table_name_to_check
      AND index_name = index_name_to_check
  ) THEN
    SET @migration_sql = CONCAT(
      'ALTER TABLE `',
      REPLACE(table_name_to_check, '`', '``'),
      '` ADD ',
      index_definition
    );
    PREPARE migration_statement FROM @migration_sql;
    EXECUTE migration_statement;
    DEALLOCATE PREPARE migration_statement;
  END IF;
END//

CREATE PROCEDURE add_constraint_if_missing(
  IN table_name_to_check VARCHAR(64),
  IN constraint_name_to_check VARCHAR(64),
  IN constraint_definition TEXT
)
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_schema = DATABASE()
      AND table_name = table_name_to_check
      AND constraint_name = constraint_name_to_check
  ) THEN
    SET @migration_sql = CONCAT(
      'ALTER TABLE `',
      REPLACE(table_name_to_check, '`', '``'),
      '` ADD ',
      constraint_definition
    );
    PREPARE migration_statement FROM @migration_sql;
    EXECUTE migration_statement;
    DEALLOCATE PREPARE migration_statement;
  END IF;
END//

DELIMITER ;

CALL add_column_if_missing(
  'students',
  'degree_program',
  'VARCHAR(30) NOT NULL DEFAULT ''UNASSIGNED'' AFTER school'
);
CALL add_column_if_missing(
  'students',
  'academic_level',
  'ENUM(''Certificate'', ''Diploma'', ''Degree'', ''Masters'', ''PhD'') NOT NULL DEFAULT ''Degree'''
);
CALL add_column_if_missing(
  'course_units',
  'degree_program',
  'VARCHAR(30) NOT NULL DEFAULT ''UNASSIGNED'' AFTER school'
);
CALL add_column_if_missing(
  'course_units',
  'academic_level',
  'ENUM(''Certificate'', ''Diploma'', ''Degree'', ''Masters'', ''PhD'') NOT NULL DEFAULT ''Degree'''
);
CALL add_column_if_missing(
  'class_schedules',
  'program',
  'ENUM(''DAY'', ''WEEKEND'', ''EVENING'', ''DISTANCE'', ''BOTH'') NOT NULL DEFAULT ''BOTH'''
);
CALL add_column_if_missing('students', 'profile_picture', 'LONGTEXT NULL');
CALL add_column_if_missing('students', 'phone_number', 'VARCHAR(20) NULL');
CALL add_column_if_missing('registrations', 'is_completed', 'BOOLEAN NOT NULL DEFAULT FALSE');
CALL add_column_if_missing('course_units', 'lecturer_id', 'INT NULL');
CALL add_column_if_missing('course_units', 'coordinator_id', 'INT NULL');
CALL add_column_if_missing('course_units', 'is_public', 'BOOLEAN NOT NULL DEFAULT FALSE');
CALL add_column_if_missing('messages', 'course_unit_id', 'INT NULL');
CALL add_column_if_missing('messages', 'sender_lecturer_id', 'INT NULL');
CALL add_column_if_missing('messages', 'edited_at', 'TIMESTAMP NULL DEFAULT NULL');
CALL add_column_if_missing('class_schedules', 'session_code', 'VARCHAR(6) NULL');
CALL add_column_if_missing('class_schedules', 'session_code_generated_by', 'INT NULL');
CALL add_column_if_missing(
  'messages',
  'target_school',
  'ENUM(''SCI'', ''SBA'', ''SOSS'', ''LAW'', ''Nursing'', ''EDU'', ''Other'', ''ALL'') NOT NULL DEFAULT ''ALL'''
);
CALL add_column_if_missing(
  'exams',
  'program',
  'ENUM(''DAY'', ''WEEKEND'', ''EVENING'', ''DISTANCE'', ''BOTH'', ''ALL'') NOT NULL DEFAULT ''BOTH'''
);
CALL add_column_if_missing(
  'exams',
  'school',
  'ENUM(''SCI'', ''SBA'', ''SOSS'', ''LAW'', ''Nursing'', ''EDU'', ''Other'') NOT NULL DEFAULT ''Other'''
);
CALL add_column_if_missing('exams', 'invigilator_id', 'INT NULL');
CALL add_column_if_missing('exams', 'room_assigned_by', 'INT NULL');
CALL add_column_if_missing(
  'exams',
  'status',
  'ENUM(''PENDING'', ''SCHEDULED'', ''ONGOING'', ''COMPLETED'') NOT NULL DEFAULT ''PENDING'''
);
CALL add_index_if_missing(
  'exams',
  'idx_exams_invigilator_id',
  'KEY idx_exams_invigilator_id (invigilator_id)'
);
CALL add_column_if_missing('exams', 'source_sheet', 'VARCHAR(50) NULL');
CALL add_column_if_missing('exams', 'source_row', 'INT UNSIGNED NULL');
CALL add_column_if_missing('exams', 'source_column', 'TINYINT UNSIGNED NULL');
CALL add_column_if_missing('exams', 'source_date_label', 'VARCHAR(100) NULL');
CALL add_column_if_missing('exams', 'source_text', 'TEXT NULL');
CALL add_column_if_missing(
  'messages',
  'target_room',
  'VARCHAR(100) NOT NULL DEFAULT ''GLOBAL'''
);
CALL add_column_if_missing('admins', 'name', 'VARCHAR(100) NOT NULL DEFAULT '''' AFTER id');
CALL add_column_if_missing('admins', 'university_code', 'VARCHAR(30) NULL AFTER role');
CALL add_column_if_missing('students', 'university_code', 'VARCHAR(30) NOT NULL DEFAULT ''NKUMBA'' AFTER program');
CALL add_column_if_missing('lecturers', 'university_code', 'VARCHAR(30) NOT NULL DEFAULT ''NKUMBA'' AFTER password_hash');
CALL add_column_if_missing('course_units', 'university_code', 'VARCHAR(30) NOT NULL DEFAULT ''NKUMBA'' AFTER name');
CALL add_column_if_missing('exams', 'university_code', 'VARCHAR(30) NOT NULL DEFAULT ''NKUMBA'' AFTER program');
CALL add_column_if_missing('messages', 'university_code', 'VARCHAR(30) NOT NULL DEFAULT ''NKUMBA'' AFTER target_room');
CALL add_column_if_missing('class_schedules', 'coordinator_id', 'INT NULL AFTER lecturer_id');

ALTER TABLE admins
  MODIFY COLUMN role ENUM('SUPER_ADMIN', 'UNIVERSITY_ADMIN', 'SCHOOL_ADMIN', 'EXAM_OFFICER', 'COORDINATOR') NOT NULL;
ALTER TABLE admins
  MODIFY COLUMN school ENUM('SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other', 'ALL') NULL;

ALTER TABLE course_units MODIFY COLUMN code VARCHAR(40) NOT NULL;
ALTER TABLE students
  MODIFY COLUMN program ENUM('DAY', 'WEEKEND', 'EVENING', 'DISTANCE') NOT NULL;
ALTER TABLE exams
  MODIFY COLUMN program ENUM('DAY', 'WEEKEND', 'EVENING', 'DISTANCE', 'BOTH', 'ALL') NOT NULL DEFAULT 'BOTH';
CALL drop_legacy_course_code_unique();
CALL drop_course_offering_unique();
CALL add_index_if_missing(
  'course_units',
  'uniq_course_offering',
  'UNIQUE KEY uniq_course_offering (university_code, school, degree_program, academic_level, year_of_study, semester, code, name)'
);
CALL add_index_if_missing(
  'admins',
  'idx_admins_university_role_school',
  'KEY idx_admins_university_role_school (university_code, role, school)'
);
CALL add_index_if_missing(
  'students',
  'idx_students_university_school',
  'KEY idx_students_university_school (university_code, school)'
);
CALL add_index_if_missing(
  'lecturers',
  'idx_lecturers_university_school',
  'KEY idx_lecturers_university_school (university_code, school)'
);
CALL add_index_if_missing(
  'course_units',
  'idx_course_units_university_school',
  'KEY idx_course_units_university_school (university_code, school)'
);
CALL add_index_if_missing(
  'exams',
  'idx_exams_university_school',
  'KEY idx_exams_university_school (university_code, school)'
);
CALL add_index_if_missing(
  'messages',
  'idx_messages_university_school',
  'KEY idx_messages_university_school (university_code, target_school, created_at, id)'
);
CALL add_index_if_missing(
  'class_schedules',
  'idx_class_schedules_coordinator_id',
  'KEY idx_class_schedules_coordinator_id (coordinator_id)'
);
CALL add_index_if_missing(
  'exams',
  'uniq_exam_source',
  'UNIQUE KEY uniq_exam_source (course_unit_id, source_sheet, source_row, source_column)'
);
CALL add_index_if_missing(
  'messages',
  'idx_messages_target_room_created',
  'KEY idx_messages_target_room_created (target_room, created_at, id)'
);
CALL add_index_if_missing(
  'course_units',
  'idx_course_units_lecturer_id',
  'KEY idx_course_units_lecturer_id (lecturer_id)'
);
CALL add_index_if_missing(
  'course_units',
  'idx_course_units_coordinator_id',
  'KEY idx_course_units_coordinator_id (coordinator_id)'
);
CALL add_index_if_missing(
  'class_schedules',
  'idx_class_schedules_course_program',
  'KEY idx_class_schedules_course_program (course_unit_id, program)'
);
CALL add_index_if_missing(
  'messages',
  'idx_messages_course_unit_created',
  'KEY idx_messages_course_unit_created (course_unit_id, created_at, id)'
);
CALL add_index_if_missing(
  'messages',
  'idx_messages_sender_lecturer_id',
  'KEY idx_messages_sender_lecturer_id (sender_lecturer_id)'
);
CALL add_constraint_if_missing(
  'course_units',
  'fk_course_lecturer',
  'CONSTRAINT fk_course_lecturer FOREIGN KEY (lecturer_id) REFERENCES lecturers(id) ON DELETE SET NULL'
);
CALL add_constraint_if_missing(
  'course_units',
  'fk_course_coordinator',
  'CONSTRAINT fk_course_coordinator FOREIGN KEY (coordinator_id) REFERENCES admins(id) ON DELETE SET NULL'
);
CALL add_constraint_if_missing(
  'class_schedules',
  'fk_class_schedule_coordinator',
  'CONSTRAINT fk_class_schedule_coordinator FOREIGN KEY (coordinator_id) REFERENCES admins(id) ON DELETE SET NULL'
);
CALL add_constraint_if_missing(
  'messages',
  'fk_message_course',
  'CONSTRAINT fk_message_course FOREIGN KEY (course_unit_id) REFERENCES course_units(id) ON DELETE CASCADE'
);
CALL add_constraint_if_missing(
  'messages',
  'fk_message_lecturer',
  'CONSTRAINT fk_message_lecturer FOREIGN KEY (sender_lecturer_id) REFERENCES lecturers(id) ON DELETE SET NULL'
);
CALL add_constraint_if_missing(
  'class_schedules',
  'fk_class_schedule_code_admin',
  'CONSTRAINT fk_class_schedule_code_admin FOREIGN KEY (session_code_generated_by) REFERENCES admins(id) ON DELETE SET NULL'
);
CALL add_constraint_if_missing(
  'exams',
  'fk_exam_invigilator',
  'CONSTRAINT fk_exam_invigilator FOREIGN KEY (invigilator_id) REFERENCES lecturers(id) ON DELETE SET NULL'
);
CALL add_constraint_if_missing(
  'exams',
  'fk_exam_room_assigned_by',
  'CONSTRAINT fk_exam_room_assigned_by FOREIGN KEY (room_assigned_by) REFERENCES admins(id) ON DELETE SET NULL'
);

DROP PROCEDURE add_column_if_missing;
DROP PROCEDURE drop_legacy_course_code_unique;
DROP PROCEDURE drop_course_offering_unique;
DROP PROCEDURE add_index_if_missing;
DROP PROCEDURE add_constraint_if_missing;

UPDATE admins
SET university_code = NULL, school = NULL
WHERE role = 'SUPER_ADMIN';

UPDATE admins
SET school = NULL
WHERE role IN ('UNIVERSITY_ADMIN', 'EXAM_OFFICER');

UPDATE admins
SET university_code = 'NKUMBA'
WHERE role IN ('UNIVERSITY_ADMIN', 'SCHOOL_ADMIN', 'EXAM_OFFICER', 'COORDINATOR')
  AND (university_code IS NULL OR TRIM(university_code) = '');

UPDATE students
SET degree_program = 'UNASSIGNED'
WHERE degree_program IS NULL OR TRIM(degree_program) = '';

UPDATE students
SET degree_program = UPPER(TRIM(degree_program))
WHERE degree_program <> 'UNASSIGNED';

UPDATE messages m
LEFT JOIN students s ON s.id = m.sender_id
SET m.target_room = CASE
  WHEN s.id IS NOT NULL THEN CONCAT(
    s.school, '-', s.degree_program, '-', s.program,
    '-Y', s.year_of_study, '-S', s.semester
  )
  ELSE 'ARCHIVE'
END
WHERE m.target_room = 'GLOBAL'
  AND m.is_broadcast = FALSE;

UPDATE course_units
SET degree_program = 'UNASSIGNED'
WHERE degree_program IS NULL OR TRIM(degree_program) = '';

UPDATE course_units
SET degree_program = CASE
  WHEN UPPER(code) REGEXP '^BIST[[:space:]]*[1-5]:[1-2]([[:space:]]|$)' THEN 'BIST'
  WHEN UPPER(code) REGEXP '^BCS[[:space:]]*[1-5]:[1-2]([[:space:]]|$)' THEN 'BCS'
  WHEN UPPER(code) REGEXP '^DIST[[:space:]]*[1-5]:[1-2]([[:space:]]|$)' THEN 'DIST'
  WHEN UPPER(code) REGEXP '^BCDF[[:space:]]*[1-5]:[1-2]([[:space:]]|$)' THEN 'BCDF'
  WHEN UPPER(code) REGEXP '^CSC[[:space:][:digit:]]' THEN 'BCS'
  ELSE UPPER(TRIM(degree_program))
END
WHERE degree_program = 'UNASSIGNED';

UPDATE course_units
SET degree_program = UPPER(TRIM(degree_program))
WHERE degree_program <> 'UNASSIGNED';

UPDATE exams e
JOIN course_units cu ON cu.id = e.course_unit_id
SET e.school = cu.school
WHERE e.school = 'Other';

-- Remove only the original demo rows from the previous schema.
DELETE e
FROM exams e
JOIN course_units cu ON cu.id = e.course_unit_id
WHERE e.source_sheet IS NULL
  AND (
    (cu.code = 'CSC1101' AND e.exam_date = '2027-05-04' AND e.room = 'LR-101')
    OR (cu.code = 'CSC1102' AND e.exam_date = '2027-05-05' AND e.room = 'LR-102')
    OR (cu.code = 'CSC1103' AND e.exam_date = '2027-05-06' AND e.room = 'LAB-3')
    OR (cu.code = 'CSC1201' AND e.exam_date = '2027-05-07' AND e.room = 'LR-201')
    OR (cu.code = 'SBA1101' AND e.exam_date = '2027-05-08' AND e.room = 'LR-301')
    OR (cu.code = 'SBA1102' AND e.exam_date = '2027-05-09' AND e.room = 'LR-302')
    OR (cu.code = 'SOSS1101' AND e.exam_date = '2027-05-11' AND e.room = 'LR-401')
    OR (cu.code = 'LAW1101' AND e.exam_date = '2027-05-12' AND e.room = 'LR-402')
    OR (cu.code = 'NUR1101' AND e.exam_date = '2027-05-13' AND e.room = 'LR-403')
    OR (cu.code = 'EDU1101' AND e.exam_date = '2027-05-14' AND e.room = 'LR-404')
  );

DELETE FROM course_units
WHERE (code = 'CSC1101' AND name = 'Introduction to Programming')
   OR (code = 'CSC1102' AND name = 'Discrete Mathematics')
   OR (code = 'CSC1103' AND name = 'Computer Organisation')
   OR (code = 'CSC1201' AND name = 'Data Structures and Algorithms')
   OR (code = 'SBA1101' AND name = 'Principles of Management')
   OR (code = 'SBA1102' AND name = 'Business Mathematics')
   OR (code = 'SOSS1101' AND name = 'Introduction to Sociology')
   OR (code = 'LAW1101' AND name = 'Legal Methods')
   OR (code = 'NUR1101' AND name = 'Anatomy and Physiology I')
   OR (code = 'EDU1101' AND name = 'Foundations of Education');



-- NKUMBA August 2026 semester examination timetable imported from the supplied workbook.
-- Original sheet, row, column, date heading, and cell text are retained on each exam.
INSERT IGNORE INTO course_units (code, name, school, degree_program, year_of_study, semester) VALUES
  ('ALL', 'Business Computing', 'SCI', 'ALL', 0, 0),
  ('ALL', 'Project proposal Diploma Students', 'SCI', 'ALL', 0, 0),
  ('BCDF 1:1', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:1', 'Business Communication Skills', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:1', 'CDF 1104 Principles of Cybersecurity', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:1', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:1', 'CDF 1209 Information Systems Architecture and Design', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:1', 'Computer Applications and Systems / Computer Applications', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:1', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:1', 'Human Behaviour Psychology', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:1', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:1', 'Principles of Cybersecurity', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:1', 'Structured Programming', 'SCI', 'BCDF', 1, 1),
  ('BCDF 1:2', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BCDF', 1, 2),
  ('BCDF 1:2', 'Business Communication Skills', 'SCI', 'BCDF', 1, 2),
  ('BCDF 1:2', 'CDF 1209 Information Systems Architecture and Design', 'SCI', 'BCDF', 1, 2),
  ('BCDF 1:2', 'Computer Applications and Systems / Computer Applications', 'SCI', 'BCDF', 1, 2),
  ('BCDF 1:2', 'Computer Crimes', 'SCI', 'BCDF', 1, 2),
  ('BCDF 1:2', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BCDF', 1, 2),
  ('BCDF 1:2', 'Human Behaviour Psychology', 'SCI', 'BCDF', 1, 2),
  ('BCDF 1:2', 'Intrusion and Penetration Testing', 'SCI', 'BCDF', 1, 2),
  ('BCDF 1:2', 'Principles of Cybersecurity', 'SCI', 'BCDF', 1, 2),
  ('BCDF 1:2', 'Structured Programming', 'SCI', 'BCDF', 1, 2),
  ('BCDF 2:1', 'BCS 2102 Database Management Systems', 'SCI', 'BCDF', 2, 1),
  ('BCDF 2:1', 'BIST 2104 Operating Systems', 'SCI', 'BCDF', 2, 1),
  ('BCDF 2:1', 'CDF 2101 Software Security', 'SCI', 'BCDF', 2, 1),
  ('BCDF 2:1', 'CDF 2102 Cryptography and Coding Theory', 'SCI', 'BCDF', 2, 1),
  ('BCDF 2:1', 'CDF 2105 Computer Forensic Evidence Collection Tools and Techniques', 'SCI', 'BCDF', 2, 1),
  ('BCDF 2:1', 'CDF 2106 Incident Response and Investigation', 'SCI', 'BCDF', 2, 1),
  ('BCDF 2:1', 'Computer Forensic Evidence Collection Tools and Techniques', 'SCI', 'BCDF', 2, 1),
  ('BCDF 2:1', 'Cryptography and Coding Theory', 'SCI', 'BCDF', 2, 1),
  ('BCDF 2:1', 'Incident Response and Investigation', 'SCI', 'BCDF', 2, 1),
  ('BCDF 2:1', 'Software Security', 'SCI', 'BCDF', 2, 1),
  ('BCDF 2:2', 'BCS 3104 Multimedia Systems / Multimedia Applications', 'SCI', 'BCDF', 2, 2),
  ('BCDF 2:2', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation', 'SCI', 'BCDF', 2, 2),
  ('BCDF 2:2', 'CDF 2201 Evidence Handling and Presentation', 'SCI', 'BCDF', 2, 2),
  ('BCDF 2:2', 'CDF 2202 Operating Systems Forensics', 'SCI', 'BCDF', 2, 2),
  ('BCDF 2:2', 'CDF 2205 Security Modelling', 'SCI', 'BCDF', 2, 2),
  ('BCDF 2:2', 'Computer Security Techniques', 'SCI', 'BCDF', 2, 2),
  ('BCDF 2:2', 'Data Mining and Business Intelligence', 'SCI', 'BCDF', 2, 2),
  ('BCDF 2:2', 'Evidence Handling and Presentation', 'SCI', 'BCDF', 2, 2),
  ('BCDF 2:2', 'Operating Systems Forensics', 'SCI', 'BCDF', 2, 2),
  ('BCDF 2:2', 'Security Modelling', 'SCI', 'BCDF', 2, 2),
  ('BCDF 3:1', 'BIST 3201 Information Systems Audit', 'SCI', 'BCDF', 3, 1),
  ('BCDF 3:1', 'CDF 3101 Criminal Profiling', 'SCI', 'BCDF', 3, 1),
  ('BCDF 3:1', 'CDF 3102 Digital Devices Forensics', 'SCI', 'BCDF', 3, 1),
  ('BCDF 3:1', 'CDF 3106 Mobile and Wireless Security', 'SCI', 'BCDF', 3, 1),
  ('BCDF 3:1', 'Criminal profiling', 'SCI', 'BCDF', 3, 1),
  ('BCDF 3:1', 'Cyber Laws and Security Policy', 'SCI', 'BCDF', 3, 1),
  ('BCDF 3:1', 'Data Forensics', 'SCI', 'BCDF', 3, 1),
  ('BCDF 3:1', 'Digital Devices Forensics', 'SCI', 'BCDF', 3, 1),
  ('BCDF 3:1', 'Information Systems Audit', 'SCI', 'BCDF', 3, 1),
  ('BCS', 'User Interface Design', 'SCI', 'BCS', 0, 0),
  ('BCS 1:1', 'BCS 1102 Linear Programming', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'BCS 1105 Survey of Programming Languages', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'BCS 1106 Numerical Methods', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'Business Communication Skills', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'Linear Programming', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'Numerical Methods', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'Structured Programming', 'SCI', 'BCS', 1, 1),
  ('BCS 1:1', 'Survey of Programming Languages', 'SCI', 'BCS', 1, 1),
  ('BCS 1:2', 'BCS 1106 Numerical Methods', 'SCI', 'BCS', 1, 2),
  ('BCS 1:2', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'BCS', 1, 2),
  ('BCS 1:2', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BCS', 1, 2),
  ('BCS 1:2', 'Business Communication Skills', 'SCI', 'BCS', 1, 2),
  ('BCS 1:2', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'BCS', 1, 2),
  ('BCS 1:2', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BCS', 1, 2),
  ('BCS 1:2', 'Linear Programming', 'SCI', 'BCS', 1, 2),
  ('BCS 1:2', 'Numerical Methods', 'SCI', 'BCS', 1, 2),
  ('BCS 1:2', 'Structured Programming', 'SCI', 'BCS', 1, 2),
  ('BCS 1:2', 'Survey of Programming Languages', 'SCI', 'BCS', 1, 2),
  ('BCS 2:1', 'BCS 2101 Computer Algorithm', 'SCI', 'BCS', 2, 1),
  ('BCS 2:1', 'BCS 2102 Database Management Systems', 'SCI', 'BCS', 2, 1),
  ('BCS 2:1', 'BCS 2103 Computer Architecture and Organization', 'SCI', 'BCS', 2, 1),
  ('BCS 2:1', 'BCS 2104 Event Driven Programming', 'SCI', 'BCS', 2, 1),
  ('BCS 2:1', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation', 'SCI', 'BCS', 2, 1),
  ('BCS 2:1', 'Computer Algorithm', 'SCI', 'BCS', 2, 1),
  ('BCS 2:1', 'Database Management Systems', 'SCI', 'BCS', 2, 1),
  ('BCS 2:1', 'Event Driven Programming', 'SCI', 'BCS', 2, 1),
  ('BCS 2:1', 'Information Systems Security', 'SCI', 'BCS', 2, 1),
  ('BCS 2:1', 'Research Methods / IT Research Design and Implementation', 'SCI', 'BCS', 2, 1),
  ('BCS 2:2', 'BCS 2201 Systems Programming', 'SCI', 'BCS', 2, 2),
  ('BCS 2:2', 'BCS 2202 Software Engineering / Principles of Software Engineering', 'SCI', 'BCS', 2, 2),
  ('BCS 2:2', 'BCS 2203 Computer Graphics', 'SCI', 'BCS', 2, 2),
  ('BCS 2:2', 'BCS 2205 Web Application Development / Website Development', 'SCI', 'BCS', 2, 2),
  ('BCS 2:2', 'Computer Graphics', 'SCI', 'BCS', 2, 2),
  ('BCS 2:2', 'Database Programming', 'SCI', 'BCS', 2, 2),
  ('BCS 2:2', 'Modeling and Simulation', 'SCI', 'BCS', 2, 2),
  ('BCS 2:2', 'Principles of Software Engineering', 'SCI', 'BCS', 2, 2),
  ('BCS 2:2', 'Systems Programming', 'SCI', 'BCS', 2, 2),
  ('BCS 2:2', 'Website Development / Web Application Development', 'SCI', 'BCS', 2, 2),
  ('BCS 3:1', 'Artificial Intelligence', 'SCI', 'BCS', 3, 1),
  ('BCS 3:1', 'Automata, Complexity and Computability', 'SCI', 'BCS', 3, 1),
  ('BCS 3:1', 'BCS 3104 Multimedia Systems / Multimedia Applications', 'SCI', 'BCS', 3, 1),
  ('BCS 3:1', 'BCS 3106 Distributed Systems', 'SCI', 'BCS', 3, 1),
  ('BCS 3:1', 'Distributed Systems', 'SCI', 'BCS', 3, 1),
  ('BCS 3:1', 'Multimedia Applications / Multimedia Systems', 'SCI', 'BCS', 3, 1),
  ('BCS 3:1', 'Wireless Networking', 'SCI', 'BCS', 3, 1),
  ('BCS 3:2', 'BCS 3202 Systems Administration', 'SCI', 'BCS', 3, 2),
  ('BCS 3:2', 'BCS 3203 Computer Repair and Maintenance', 'SCI', 'BCS', 3, 2),
  ('BCS 3:2', 'BCS 3207 Data Warehousing and Data Mining', 'SCI', 'BCS', 3, 2),
  ('BCS 3:2', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BCS', 3, 2),
  ('BCS 3:2', 'Computer Repair and Maintenance', 'SCI', 'BCS', 3, 2),
  ('BCS 3:2', 'Data Warehousing and Data Mining', 'SCI', 'BCS', 3, 2),
  ('BCS 3:2', 'Emerging Trends in Information Systems and Technology', 'SCI', 'BCS', 3, 2),
  ('BCS 3:2', 'Emerging Trends in Information Systems and Technology / Computer Science', 'SCI', 'BCS', 3, 2),
  ('BCS 3:2', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BCS', 3, 2),
  ('BIST 1:1', 'BCS 2205 Web Application Development / Website Development', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'Business Communication Skills', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'Computer Applications / ICDL', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'Computer Applications 1 / ICDL', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'Computer Applications and Systems / Computer Applications', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'Information Systems and Technology Foundations', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'Structured Programming', 'SCI', 'BIST', 1, 1),
  ('BIST 1:1', 'Website Development / Web Application Development', 'SCI', 'BIST', 1, 1),
  ('BIST 1:2', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'BIST', 1, 2),
  ('BIST 1:2', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BIST', 1, 2),
  ('BIST 1:2', 'Business Communication Skills', 'SCI', 'BIST', 1, 2),
  ('BIST 1:2', 'Computer Applications / ICDL', 'SCI', 'BIST', 1, 2),
  ('BIST 1:2', 'Computer Applications 1 / ICDL', 'SCI', 'BIST', 1, 2),
  ('BIST 1:2', 'Computer Applications and Systems / Computer Applications', 'SCI', 'BIST', 1, 2),
  ('BIST 1:2', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'BIST', 1, 2),
  ('BIST 1:2', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BIST', 1, 2),
  ('BIST 1:2', 'Information Systems and Technology Foundations', 'SCI', 'BIST', 1, 2),
  ('BIST 1:2', 'Structured Programming', 'SCI', 'BIST', 1, 2),
  ('BIST 1:2', 'Website Development / Web Application Development', 'SCI', 'BIST', 1, 2),
  ('BIST 2:1', 'BCS 2102 Database Management Systems', 'SCI', 'BIST', 2, 1),
  ('BIST 2:1', 'BCS 2202 Software Engineering / Principles of Software Engineering', 'SCI', 'BIST', 2, 1),
  ('BIST 2:1', 'BCS 3104 Multimedia Systems / Multimedia Applications', 'SCI', 'BIST', 2, 1),
  ('BIST 2:1', 'BIST 2104 Operating Systems', 'SCI', 'BIST', 2, 1),
  ('BIST 2:1', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BIST', 2, 1),
  ('BIST 2:1', 'Database Management Systems', 'SCI', 'BIST', 2, 1),
  ('BIST 2:1', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BIST', 2, 1),
  ('BIST 2:1', 'Information Systems Security', 'SCI', 'BIST', 2, 1),
  ('BIST 2:1', 'Multimedia Applications / Multimedia Systems', 'SCI', 'BIST', 2, 1),
  ('BIST 2:1', 'Operating Systems', 'SCI', 'BIST', 2, 1),
  ('BIST 2:1', 'Principles of Software Engineering', 'SCI', 'BIST', 2, 1),
  ('BIST 2:2', 'Artificial Intelligence', 'SCI', 'BIST', 2, 2),
  ('BIST 2:2', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation', 'SCI', 'BIST', 2, 2),
  ('BIST 2:2', 'BIST 2209 Digital Forensics Investigation', 'SCI', 'BIST', 2, 2),
  ('BIST 2:2', 'BIST 2210 E-services / WordPress', 'SCI', 'BIST', 2, 2),
  ('BIST 2:2', 'BIST 2211 Legal and Ethical Issues of Computing', 'SCI', 'BIST', 2, 2),
  ('BIST 2:2', 'Digital Forensics Investigation', 'SCI', 'BIST', 2, 2),
  ('BIST 2:2', 'E-services', 'SCI', 'BIST', 2, 2),
  ('BIST 2:2', 'Legal and Ethical Issues of Computing', 'SCI', 'BIST', 2, 2),
  ('BIST 2:2', 'Research Methods / IT Research Design and Implementation', 'SCI', 'BIST', 2, 2),
  ('BIST 3:1', 'BCS 3202 Systems Administration', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'BCS 3203 Computer Repair and Maintenance', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'BIST 3102 Network and Cyber Security', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'BIST 3103 Business Process Modeling', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'BIST 3104 Enterprise Network Management', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'BIST 3105 Mobile Applications Development and Intellectual Property', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'Business Process Modeling', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'Computer Repair and Maintenance', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'Enterprise Network Management', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'Mobile Applications Development and Intellectual Property', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'Network and Cyber Security', 'SCI', 'BIST', 3, 1),
  ('BIST 3:1', 'Systems Administration (', 'SCI', 'BIST', 3, 1),
  ('BIST 3:2', 'BIST 3201 Information Systems Audit', 'SCI', 'BIST', 3, 2),
  ('BIST 3:2', 'BIST 3202 Software Systems Testing', 'SCI', 'BIST', 3, 2),
  ('BIST 3:2', 'Data Mining and Business Intelligence', 'SCI', 'BIST', 3, 2),
  ('BIST 3:2', 'Emerging Trends in Information Systems and Technology', 'SCI', 'BIST', 3, 2),
  ('BIST 3:2', 'Emerging Trends in Information Systems and Technology / Computer Science', 'SCI', 'BIST', 3, 2),
  ('BIST 3:2', 'IT Project Development and Management', 'SCI', 'BIST', 3, 2),
  ('BIST 3:2', 'Information Systems Audit', 'SCI', 'BIST', 3, 2),
  ('BIST 3:2', 'Software Systems Testing', 'SCI', 'BIST', 3, 2),
  ('DCS 1:1', 'BCS 1102 Linear Programming', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'BCS 1105 Survey of Programming Languages', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'BCS 1106 Numerical Methods', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'Business Communication Skills', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'Linear Programming', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'Numerical Methods', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'Structured Programming', 'SCI', 'DCS', 1, 1),
  ('DCS 1:1', 'Survey of Programming Languages', 'SCI', 'DCS', 1, 1),
  ('DCS 1:2', 'BCS 1106 Numerical Methods', 'SCI', 'DCS', 1, 2),
  ('DCS 1:2', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'DCS', 1, 2),
  ('DCS 1:2', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'DCS', 1, 2),
  ('DCS 1:2', 'Business Communication Skills', 'SCI', 'DCS', 1, 2),
  ('DCS 1:2', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'DCS', 1, 2),
  ('DCS 1:2', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'DCS', 1, 2),
  ('DCS 1:2', 'Linear Programming', 'SCI', 'DCS', 1, 2),
  ('DCS 1:2', 'Numerical Methods', 'SCI', 'DCS', 1, 2),
  ('DCS 1:2', 'Structured Programming', 'SCI', 'DCS', 1, 2),
  ('DCS 1:2', 'Survey of Programming Languages', 'SCI', 'DCS', 1, 2),
  ('DCS 2:1', 'BCS 2101 Computer Algorithm', 'SCI', 'DCS', 2, 1),
  ('DCS 2:1', 'BCS 2102 Database Management Systems', 'SCI', 'DCS', 2, 1),
  ('DCS 2:1', 'BCS 2103 Computer Architecture and Organization', 'SCI', 'DCS', 2, 1),
  ('DCS 2:1', 'BCS 2104 Event Driven Programming', 'SCI', 'DCS', 2, 1),
  ('DCS 2:1', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation', 'SCI', 'DCS', 2, 1),
  ('DCS 2:1', 'Computer Algorithm', 'SCI', 'DCS', 2, 1),
  ('DCS 2:1', 'Database Management Systems', 'SCI', 'DCS', 2, 1),
  ('DCS 2:1', 'Event Driven Programming', 'SCI', 'DCS', 2, 1),
  ('DCS 2:1', 'Information Systems Security', 'SCI', 'DCS', 2, 1),
  ('DCS 2:1', 'Research Methods / IT Research Design and Implementation', 'SCI', 'DCS', 2, 1),
  ('DCS 2:2', 'BCS 2201 Systems Programming', 'SCI', 'DCS', 2, 2),
  ('DCS 2:2', 'BCS 2202 Software Engineering / Principles of Software Engineering', 'SCI', 'DCS', 2, 2),
  ('DCS 2:2', 'BCS 2203 Computer Graphics', 'SCI', 'DCS', 2, 2),
  ('DCS 2:2', 'BCS 2205 Web Application Development / Website Development', 'SCI', 'DCS', 2, 2),
  ('DCS 2:2', 'Computer Graphics', 'SCI', 'DCS', 2, 2),
  ('DCS 2:2', 'Database Programming', 'SCI', 'DCS', 2, 2),
  ('DCS 2:2', 'Modeling and Simulation', 'SCI', 'DCS', 2, 2),
  ('DCS 2:2', 'Principles of Software Engineering', 'SCI', 'DCS', 2, 2),
  ('DCS 2:2', 'Systems Programming', 'SCI', 'DCS', 2, 2),
  ('DCS 2:2', 'Website Development / Web Application Development', 'SCI', 'DCS', 2, 2),
  ('DIST', 'Management of Information Systems', 'SCI', 'DIST', 0, 0),
  ('DIST', 'Systems Analysis and Design', 'SCI', 'DIST', 0, 0),
  ('DIST 1:1', 'BCS 2205 Web Application Development / Website Development', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'Business Communication Skills', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'Computer Applications / ICDL', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'Computer Applications 1 / ICDL', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'Computer Applications and Systems / Computer Applications', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'Information Systems and Technology Foundations', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'Structured Programming', 'SCI', 'DIST', 1, 1),
  ('DIST 1:1', 'Website Development / Web Application Development', 'SCI', 'DIST', 1, 1),
  ('DIST 1:2', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'DIST', 1, 2),
  ('DIST 1:2', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'DIST', 1, 2),
  ('DIST 1:2', 'Business Communication Skills', 'SCI', 'DIST', 1, 2),
  ('DIST 1:2', 'Computer Applications / ICDL', 'SCI', 'DIST', 1, 2),
  ('DIST 1:2', 'Computer Applications 1 / ICDL', 'SCI', 'DIST', 1, 2),
  ('DIST 1:2', 'Computer Applications and Systems / Computer Applications', 'SCI', 'DIST', 1, 2),
  ('DIST 1:2', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'DIST', 1, 2),
  ('DIST 1:2', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'DIST', 1, 2),
  ('DIST 1:2', 'Information Systems and Technology Foundations', 'SCI', 'DIST', 1, 2),
  ('DIST 1:2', 'Structured Programming', 'SCI', 'DIST', 1, 2),
  ('DIST 1:2', 'Website Development / Web Application Development', 'SCI', 'DIST', 1, 2),
  ('DIST 2:1', 'BCS 2102 Database Management Systems', 'SCI', 'DIST', 2, 1),
  ('DIST 2:1', 'BCS 2202 Software Engineering / Principles of Software Engineering', 'SCI', 'DIST', 2, 1),
  ('DIST 2:1', 'BCS 3104 Multimedia Systems / Multimedia Applications', 'SCI', 'DIST', 2, 1),
  ('DIST 2:1', 'BIST 2104 Operating Systems', 'SCI', 'DIST', 2, 1),
  ('DIST 2:1', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'DIST', 2, 1),
  ('DIST 2:1', 'Database Management Systems', 'SCI', 'DIST', 2, 1),
  ('DIST 2:1', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'DIST', 2, 1),
  ('DIST 2:1', 'Information Systems Security', 'SCI', 'DIST', 2, 1),
  ('DIST 2:1', 'Multimedia Applications / Multimedia Systems', 'SCI', 'DIST', 2, 1),
  ('DIST 2:1', 'Operating Systems', 'SCI', 'DIST', 2, 1),
  ('DIST 2:1', 'Principles of Software Engineering', 'SCI', 'DIST', 2, 1),
  ('DIST 2:2', 'Artificial Intelligence', 'SCI', 'DIST', 2, 2),
  ('DIST 2:2', 'BCS 3202 Systems Administration', 'SCI', 'DIST', 2, 2),
  ('DIST 2:2', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation', 'SCI', 'DIST', 2, 2),
  ('DIST 2:2', 'BIST 2209 Digital Forensics Investigation', 'SCI', 'DIST', 2, 2),
  ('DIST 2:2', 'BIST 2210 E-services / WordPress', 'SCI', 'DIST', 2, 2),
  ('DIST 2:2', 'BIST 2211 Legal and Ethical Issues of Computing', 'SCI', 'DIST', 2, 2),
  ('DIST 2:2', 'Digital Forensics Investigation', 'SCI', 'DIST', 2, 2),
  ('DIST 2:2', 'E-services', 'SCI', 'DIST', 2, 2),
  ('DIST 2:2', 'Legal and Ethical Issues of Computing', 'SCI', 'DIST', 2, 2),
  ('DIST 2:2', 'Research Methods / IT Research Design and Implementation', 'SCI', 'DIST', 2, 2),
  ('DIT 1:1', 'Information Systems and Technology Foundations', 'SCI', 'DIT', 1, 1),
  ('DIT 1:2', 'BCS 2102 Database Management Systems', 'SCI', 'DIT', 1, 2),
  ('DIT 2:1', 'BCS 2104 Event Driven Programming', 'SCI', 'DIT', 2, 1),
  ('DIT 2:1', 'BCS 3203 Computer Repair and Maintenance', 'SCI', 'DIT', 2, 1),
  ('DIT 2:2', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'DIT', 2, 2),
  ('DIT 2:2', 'Database Programming', 'SCI', 'DIT', 2, 2),
  ('HCBM', 'Business Information Systems', 'SCI', 'HCBM', 0, 0),
  ('MIST 1:1', 'Advanced Database Management and Ms.Atuhairwe Rahab 0783635084', 'SCI', 'MIST', 1, 1),
  ('MIST 1:1', 'Applied Object Oriented Programming and Mr.Sserunkuma Damian 0700409097', 'SCI', 'MIST', 1, 1),
  ('MIST 1:1', 'Human Computer Interaction and Ms.Kyomuhendo Charlotte 0784153648', 'SCI', 'MIST', 1, 1),
  ('MIST 1:1', 'MIST 2115 Distributed Data Mining and Mr.Ssemaganda Shruaim', 'SCI', 'MIST', 1, 1),
  ('MIST 1:1', 'MIST2111 Governance and Management of Information Systems SBA and and', 'SCI', 'MIST', 1, 1),
  ('MIST 1:1', 'MIST2112 Web Application Development and Mr.Sserunkuma Damian 0700409097', 'SCI', 'MIST', 1, 1),
  ('MIST 1:2', 'Advanced Database Management and Ms.Atuhairwe Rahab 0783635084', 'SCI', 'MIST', 1, 2),
  ('MIST 1:2', 'Human Computer Interaction and Ms.Kyomuhendo Charlotte 0784153648', 'SCI', 'MIST', 1, 2),
  ('MIST 1:2', 'MIST 2115 Distributed Data Mining and Mr.Ssemaganda Shruaim', 'SCI', 'MIST', 1, 2),
  ('MIST 1:2', 'MIST2111 Governance and Management of Information Systems SBA and and', 'SCI', 'MIST', 1, 2),
  ('MIST 1:2', 'MIST2112 Web Application Development and Mr.Sserunkuma Damian 0700409097', 'SCI', 'MIST', 1, 2),
  ('MIST 2:1', 'Digital Forensics', 'SCI', 'MIST', 2, 1),
  ('MIST 2:1', 'MIST2211 Semantics of Web services Mr.Sserunkuma Damian 0700409097', 'SCI', 'MIST', 2, 1),
  ('MIST 2:1', 'MIST2212 Advanced Research Methods and Report Writing Dr.Golooba 0751050976', 'SCI', 'MIST', 2, 1),
  ('MIST 2:1', 'MIST2213 Project management and Control Mr.Male Vincent 0782188321', 'SCI', 'MIST', 2, 1),
  ('MIST 2:1', 'Mobile Application Development Mr.Sserunkuma Damian 0700409097', 'SCI', 'MIST', 2, 1),
  ('MIST 2:1', 'Simulation and Modelling Dr.Golooba 0751050976', 'SCI', 'MIST', 2, 1),
  ('MIST 2:2', 'Emerging Trends in Information Systems and Technology - Dr.Hilda Mpirirwe', 'SCI', 'MIST', 2, 2),
  ('MIST 2:2', 'MIST2222 Consultancy Skills development Ms.Kyomuhendo Chalotte 0784153648', 'SCI', 'MIST', 2, 2),
  ('MIST 2:2', 'Seminar Series', 'SCI', 'MIST', 2, 2),
  ('SBA', 'Business Information Systems', 'SCI', 'SBA', 0, 0),
  ('SBA', 'Computer Applications II', 'SCI', 'SBA', 0, 0),
  ('SBA', 'Human Resource Information Systems', 'SCI', 'SBA', 0, 0),
  ('SBA', 'Introduction to Information Technology', 'SCI', 'SBA', 0, 0),
  ('SBA', 'Management Information Systems', 'SCI', 'SBA', 0, 0),
  ('SBA', 'Management of Information Systems', 'SCI', 'SBA', 0, 0),
  ('SBA', 'Systems Analysis and Design', 'SCI', 'SBA', 0, 0),
  ('SCIAD', 'Introduction to Information Technology', 'SCI', 'SCIAD', 0, 0),
  ('SEDU', 'Introduction to Information Technology', 'SCI', 'SEDU', 0, 0),
  ('SLAW 1:1', 'Introduction to Information Technology and Computer Use', 'SCI', 'SLAW', 1, 1);

INSERT IGNORE INTO exams
  (course_unit_id, exam_date, start_time, end_time, room, program, school, source_sheet, source_row, source_column, source_date_label, source_text)
SELECT cu.id, x.exam_date, x.start_time, x.end_time, x.room, x.program, x.school,
       x.source_sheet, x.source_row, x.source_column, x.source_date_label, x.source_text
FROM (
  SELECT 'BIST 1:1' AS code, 'Computer Applications 1 / ICDL' AS name, 'SCI' AS school, 'BIST' AS degree_program, 1 AS year_of_study, 1 AS semester, '2026-11-12' AS exam_date, '09:00:00' AS start_time, '12:00:00' AS end_time, 'NOT SPECIFIED' AS room, 'DAY' AS program, 'Day Timetable' AS source_sheet, 7 AS source_row, 2 AS source_column, 'THURSDAY 12TH NOVEMBER' AS source_date_label, 'Computer Applications 1 / ICDL (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Mr. Ssemaganda Shuraim (KAMPALA)' AS source_text
  UNION ALL
  SELECT 'BIST 1:2', 'Computer Applications 1 / ICDL', 'SCI', 'BIST', 1, 2, '2026-11-12', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 7, 2, 'THURSDAY 12TH NOVEMBER', 'Computer Applications 1 / ICDL (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Mr. Ssemaganda Shuraim (KAMPALA)'
  UNION ALL
  SELECT 'DIST 1:1', 'Computer Applications 1 / ICDL', 'SCI', 'DIST', 1, 1, '2026-11-12', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 7, 2, 'THURSDAY 12TH NOVEMBER', 'Computer Applications 1 / ICDL (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Mr. Ssemaganda Shuraim (KAMPALA)'
  UNION ALL
  SELECT 'DIST 1:2', 'Computer Applications 1 / ICDL', 'SCI', 'DIST', 1, 2, '2026-11-12', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 7, 2, 'THURSDAY 12TH NOVEMBER', 'Computer Applications 1 / ICDL (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Mr. Ssemaganda Shuraim (KAMPALA)'
  UNION ALL
  SELECT 'BIST 1:1', 'Computer Applications / ICDL', 'SCI', 'BIST', 1, 1, '2026-11-13', '09:00:00', '12:00:00', 'WAVA LABS', 'DAY', 'Day Timetable', 9, 2, 'FRIDAY 13TH NOVEMBER', 'Computer Applications / ICDL (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Ms. Musiime Phiona (145 students) (WAVA LABS)'
  UNION ALL
  SELECT 'BIST 1:2', 'Computer Applications / ICDL', 'SCI', 'BIST', 1, 2, '2026-11-13', '09:00:00', '12:00:00', 'WAVA LABS', 'DAY', 'Day Timetable', 9, 2, 'FRIDAY 13TH NOVEMBER', 'Computer Applications / ICDL (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Ms. Musiime Phiona (145 students) (WAVA LABS)'
  UNION ALL
  SELECT 'DIST 1:1', 'Computer Applications / ICDL', 'SCI', 'DIST', 1, 1, '2026-11-13', '09:00:00', '12:00:00', 'WAVA LABS', 'DAY', 'Day Timetable', 9, 2, 'FRIDAY 13TH NOVEMBER', 'Computer Applications / ICDL (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Ms. Musiime Phiona (145 students) (WAVA LABS)'
  UNION ALL
  SELECT 'DIST 1:2', 'Computer Applications / ICDL', 'SCI', 'DIST', 1, 2, '2026-11-13', '09:00:00', '12:00:00', 'WAVA LABS', 'DAY', 'Day Timetable', 9, 2, 'FRIDAY 13TH NOVEMBER', 'Computer Applications / ICDL (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Ms. Musiime Phiona (145 students) (WAVA LABS)'
  UNION ALL
  SELECT 'BCS 2:2', 'Website Development / Web Application Development', 'SCI', 'BCS', 2, 2, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 12, 2, 'MONDAY 16TH NOVEMBER', 'Website Development / Web Application Development (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 2:2, DCS 2:2) - Ms. Nasozi Betty(M&K)'
  UNION ALL
  SELECT 'BIST 1:1', 'Website Development / Web Application Development', 'SCI', 'BIST', 1, 1, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 12, 2, 'MONDAY 16TH NOVEMBER', 'Website Development / Web Application Development (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 2:2, DCS 2:2) - Ms. Nasozi Betty(M&K)'
  UNION ALL
  SELECT 'BIST 1:2', 'Website Development / Web Application Development', 'SCI', 'BIST', 1, 2, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 12, 2, 'MONDAY 16TH NOVEMBER', 'Website Development / Web Application Development (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 2:2, DCS 2:2) - Ms. Nasozi Betty(M&K)'
  UNION ALL
  SELECT 'DCS 2:2', 'Website Development / Web Application Development', 'SCI', 'DCS', 2, 2, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 12, 2, 'MONDAY 16TH NOVEMBER', 'Website Development / Web Application Development (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 2:2, DCS 2:2) - Ms. Nasozi Betty(M&K)'
  UNION ALL
  SELECT 'DIST 1:1', 'Website Development / Web Application Development', 'SCI', 'DIST', 1, 1, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 12, 2, 'MONDAY 16TH NOVEMBER', 'Website Development / Web Application Development (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 2:2, DCS 2:2) - Ms. Nasozi Betty(M&K)'
  UNION ALL
  SELECT 'DIST 1:2', 'Website Development / Web Application Development', 'SCI', 'DIST', 1, 2, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 12, 2, 'MONDAY 16TH NOVEMBER', 'Website Development / Web Application Development (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 2:2, DCS 2:2) - Ms. Nasozi Betty(M&K)'
  UNION ALL
  SELECT 'BIST 3:1', 'Enterprise Network Management', 'SCI', 'BIST', 3, 1, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 12, 4, 'MONDAY 16TH NOVEMBER', 'Enterprise Network Management (BIST 3:1) - Mr. Male Vincent/ Mr Nabulongo Ali (M&K)'
  UNION ALL
  SELECT 'BIST 2:2', 'Digital Forensics Investigation', 'SCI', 'BIST', 2, 2, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 13, 2, 'MONDAY 16TH NOVEMBER', 'Digital Forensics Investigation (BIST 2:2, DIST 2:2) - Mr. Lugemwa Bryan(M&K)'
  UNION ALL
  SELECT 'DIST 2:2', 'Digital Forensics Investigation', 'SCI', 'DIST', 2, 2, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 13, 2, 'MONDAY 16TH NOVEMBER', 'Digital Forensics Investigation (BIST 2:2, DIST 2:2) - Mr. Lugemwa Bryan(M&K)'
  UNION ALL
  SELECT 'BCDF 2:2', 'CDF 2202 Operating Systems Forensics', 'SCI', 'BCDF', 2, 2, '2026-11-16', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 13, 4, 'MONDAY 16TH NOVEMBER', 'CDF 2202 Operating Systems Forensics (BCDF 2:2) - Mr. Ssendi Samuel'
  UNION ALL
  SELECT 'SBA', 'Computer Applications II', 'SCI', 'SBA', 0, 0, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 14, 2, 'MONDAY 16TH NOVEMBER', 'Computer Applications II (SBA) - Dr. Namara Khadija'
  UNION ALL
  SELECT 'HCBM', 'Business Information Systems', 'SCI', 'HCBM', 0, 0, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 15, 2, 'MONDAY 16TH NOVEMBER', 'Business Information Systems (SBA, HCBM) - Dr. Namara Khadija'
  UNION ALL
  SELECT 'SBA', 'Business Information Systems', 'SCI', 'SBA', 0, 0, '2026-11-16', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 15, 2, 'MONDAY 16TH NOVEMBER', 'Business Information Systems (SBA, HCBM) - Dr. Namara Khadija'
  UNION ALL
  SELECT 'BCS 2:1', 'Database Management Systems', 'SCI', 'BCS', 2, 1, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 17, 2, 'TUESDAY 17TH NOVEMBER', 'Database Management Systems (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1, SBA, SEDU) - Mr. Kawooya Michael / Mr. Ssemaganda Shuraim(M&K)'
  UNION ALL
  SELECT 'BIST 2:1', 'Database Management Systems', 'SCI', 'BIST', 2, 1, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 17, 2, 'TUESDAY 17TH NOVEMBER', 'Database Management Systems (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1, SBA, SEDU) - Mr. Kawooya Michael / Mr. Ssemaganda Shuraim(M&K)'
  UNION ALL
  SELECT 'DCS 2:1', 'Database Management Systems', 'SCI', 'DCS', 2, 1, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 17, 2, 'TUESDAY 17TH NOVEMBER', 'Database Management Systems (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1, SBA, SEDU) - Mr. Kawooya Michael / Mr. Ssemaganda Shuraim(M&K)'
  UNION ALL
  SELECT 'DIST 2:1', 'Database Management Systems', 'SCI', 'DIST', 2, 1, '2026-11-17', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 17, 2, 'TUESDAY 17TH NOVEMBER', 'Database Management Systems (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1, SBA, SEDU) - Mr. Kawooya Michael / Mr. Ssemaganda Shuraim(M&K)'
  UNION ALL
  SELECT 'BCDF 1:1', 'Principles of Cybersecurity', 'SCI', 'BCDF', 1, 1, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 17, 4, 'TUESDAY 17TH NOVEMBER', 'Principles of Cybersecurity (BCDF 1:1, BCDF 1:2) - Ms. Nasozi Betty/ Ms Kyomuhendo charity(M&K)'
  UNION ALL
  SELECT 'BCDF 1:2', 'Principles of Cybersecurity', 'SCI', 'BCDF', 1, 2, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 17, 4, 'TUESDAY 17TH NOVEMBER', 'Principles of Cybersecurity (BCDF 1:1, BCDF 1:2) - Ms. Nasozi Betty/ Ms Kyomuhendo charity(M&K)'
  UNION ALL
  SELECT 'BIST 3:2', 'Software Systems Testing', 'SCI', 'BIST', 3, 2, '2026-11-17', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 18, 4, 'TUESDAY 17TH NOVEMBER', 'Software Systems Testing (BIST 3:2) - Mr. Kawooya Michael(M&K)'
  UNION ALL
  SELECT 'BIST 3:1', 'Systems Administration (', 'SCI', 'BIST', 3, 1, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 20, 2, 'WEDNESDAY 18TH NOVEMBER', 'Systems Administration (BIST3:1 Mr Segawa Andrew (K)'
  UNION ALL
  SELECT 'BCDF 3:1', 'Digital Devices Forensics', 'SCI', 'BCDF', 3, 1, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 20, 4, 'WEDNESDAY 18TH NOVEMBER', 'Digital Devices Forensics (BCDF 3:1) - Mr. Ssendi Samuel/ Charles Kikwanga(M&K)'
  UNION ALL
  SELECT 'BCS 2:2', 'Systems Programming', 'SCI', 'BCS', 2, 2, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 21, 2, 'WEDNESDAY 18TH NOVEMBER', 'Systems Programming (BCS 2:2, DCS 2:2) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'DCS 2:2', 'Systems Programming', 'SCI', 'DCS', 2, 2, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 21, 2, 'WEDNESDAY 18TH NOVEMBER', 'Systems Programming (BCS 2:2, DCS 2:2) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'ALL', 'Business Computing', 'SCI', 'ALL', 0, 0, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 21, 4, 'WEDNESDAY 18TH NOVEMBER', 'Business Computing (School of Science) - Mr. Otemo Vincent'
  UNION ALL
  SELECT 'BCS 3:1', 'Distributed Systems', 'SCI', 'BCS', 3, 1, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 22, 2, 'WEDNESDAY 18TH NOVEMBER', 'Distributed Systems (BCS 3:1) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'BCS 3:2', 'BCS 3202 Systems Administration', 'SCI', 'BCS', 3, 2, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 22, 4, 'WEDNESDAY 18TH NOVEMBER', 'BCS 3202 Systems Administration (BIST 3:1, BCS 3:2, DIST 2:2) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'BIST 3:1', 'BCS 3202 Systems Administration', 'SCI', 'BIST', 3, 1, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 22, 4, 'WEDNESDAY 18TH NOVEMBER', 'BCS 3202 Systems Administration (BIST 3:1, BCS 3:2, DIST 2:2) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'DIST 2:2', 'BCS 3202 Systems Administration', 'SCI', 'DIST', 2, 2, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 22, 4, 'WEDNESDAY 18TH NOVEMBER', 'BCS 3202 Systems Administration (BIST 3:1, BCS 3:2, DIST 2:2) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'ALL', 'Project proposal Diploma Students', 'SCI', 'ALL', 0, 0, '2026-11-18', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 23, 2, 'WEDNESDAY 18TH NOVEMBER', 'Project proposal Diploma Students'
  UNION ALL
  SELECT 'ALL', 'Project proposal Diploma Students', 'SCI', 'ALL', 0, 0, '2026-11-18', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 23, 4, 'WEDNESDAY 18TH NOVEMBER', 'Project proposal Diploma Students'
  UNION ALL
  SELECT 'BCDF 1:1', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BCDF', 1, 1, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 25, 2, 'THURSDAY 19TH NOVEMBER', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles (BIST 2:1, DIST 2:1, BCS 3:2, BCDF 1:1) - Dr. Namara Khadija/ Dr Violet Asiimwe(M&K)'
  UNION ALL
  SELECT 'BCS 3:2', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BCS', 3, 2, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 25, 2, 'THURSDAY 19TH NOVEMBER', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles (BIST 2:1, DIST 2:1, BCS 3:2, BCDF 1:1) - Dr. Namara Khadija/ Dr Violet Asiimwe(M&K)'
  UNION ALL
  SELECT 'BIST 2:1', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BIST', 2, 1, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 25, 2, 'THURSDAY 19TH NOVEMBER', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles (BIST 2:1, DIST 2:1, BCS 3:2, BCDF 1:1) - Dr. Namara Khadija/ Dr Violet Asiimwe(M&K)'
  UNION ALL
  SELECT 'DIST 2:1', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'DIST', 2, 1, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 25, 2, 'THURSDAY 19TH NOVEMBER', 'ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles (BIST 2:1, DIST 2:1, BCS 3:2, BCDF 1:1) - Dr. Namara Khadija/ Dr Violet Asiimwe(M&K)'
  UNION ALL
  SELECT 'BCDF 3:1', 'Data Forensics', 'SCI', 'BCDF', 3, 1, '2026-11-19', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 25, 4, 'THURSDAY 19TH NOVEMBER', 'Data Forensics (BCDF 3:1) - Mr. Karim Abdu(M&K)'
  UNION ALL
  SELECT 'BCS 1:1', 'Linear Programming', 'SCI', 'BCS', 1, 1, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 26, 2, 'THURSDAY 19TH NOVEMBER', 'Linear Programming (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Mr. Tumukunde Ivan(M&K)'
  UNION ALL
  SELECT 'BCS 1:2', 'Linear Programming', 'SCI', 'BCS', 1, 2, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 26, 2, 'THURSDAY 19TH NOVEMBER', 'Linear Programming (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Mr. Tumukunde Ivan(M&K)'
  UNION ALL
  SELECT 'DCS 1:1', 'Linear Programming', 'SCI', 'DCS', 1, 1, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 26, 2, 'THURSDAY 19TH NOVEMBER', 'Linear Programming (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Mr. Tumukunde Ivan(M&K)'
  UNION ALL
  SELECT 'DCS 1:2', 'Linear Programming', 'SCI', 'DCS', 1, 2, '2026-11-19', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 26, 2, 'THURSDAY 19TH NOVEMBER', 'Linear Programming (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Mr. Tumukunde Ivan(M&K)'
  UNION ALL
  SELECT 'BCS', 'User Interface Design', 'SCI', 'BCS', 0, 0, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'BOTH', 'Day Timetable', 28, 2, 'FRIDAY 20TH NOVEMBER', 'User Interface Design (BCS) - Mr. Kawooya Michael(M&K) to be done by both day & weekedend on 21st November 2026'
  UNION ALL
  SELECT 'BIST 2:2', 'Legal and Ethical Issues of Computing', 'SCI', 'BIST', 2, 2, '2026-11-20', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 28, 4, 'FRIDAY 20TH NOVEMBER', 'Legal and Ethical Issues of Computing (BIST 2:2, DIST 2:2) - Dr. Namara Khadija/ Kyomuhendo Carity (M&K)'
  UNION ALL
  SELECT 'DIST 2:2', 'Legal and Ethical Issues of Computing', 'SCI', 'DIST', 2, 2, '2026-11-20', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 28, 4, 'FRIDAY 20TH NOVEMBER', 'Legal and Ethical Issues of Computing (BIST 2:2, DIST 2:2) - Dr. Namara Khadija/ Kyomuhendo Carity (M&K)'
  UNION ALL
  SELECT 'BCDF 1:1', 'Human Behaviour Psychology', 'SCI', 'BCDF', 1, 1, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 29, 2, 'FRIDAY 20TH NOVEMBER', 'Human Behaviour Psychology (BCDF 1:1, BCDF 1:2) - Mr. Kawuma Richard (M&K)'
  UNION ALL
  SELECT 'BCDF 1:2', 'Human Behaviour Psychology', 'SCI', 'BCDF', 1, 2, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 29, 2, 'FRIDAY 20TH NOVEMBER', 'Human Behaviour Psychology (BCDF 1:1, BCDF 1:2) - Mr. Kawuma Richard (M&K)'
  UNION ALL
  SELECT 'BIST 3:1', 'Mobile Applications Development and Intellectual Property', 'SCI', 'BIST', 3, 1, '2026-11-20', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 29, 4, 'FRIDAY 20TH NOVEMBER', 'Mobile Applications Development and Intellectual Property (BIST 3:1) - Mr. Tumukunde Ivan/ Ssegawa Andrew (M&K)'
  UNION ALL
  SELECT 'SBA', 'Introduction to Information Technology', 'SCI', 'SBA', 0, 0, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 30, 2, 'FRIDAY 20TH NOVEMBER', 'Introduction to Information Technology (SBA, SEDU, SCIAD) - Mr. Kato David'
  UNION ALL
  SELECT 'SCIAD', 'Introduction to Information Technology', 'SCI', 'SCIAD', 0, 0, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 30, 2, 'FRIDAY 20TH NOVEMBER', 'Introduction to Information Technology (SBA, SEDU, SCIAD) - Mr. Kato David'
  UNION ALL
  SELECT 'SEDU', 'Introduction to Information Technology', 'SCI', 'SEDU', 0, 0, '2026-11-20', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 30, 2, 'FRIDAY 20TH NOVEMBER', 'Introduction to Information Technology (SBA, SEDU, SCIAD) - Mr. Kato David'
  UNION ALL
  SELECT 'BCS 1:1', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'BCS', 1, 1, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 32, 2, 'MONDAY 23RD NOVEMBER', 'Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'BCS 1:2', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'BCS', 1, 2, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 32, 2, 'MONDAY 23RD NOVEMBER', 'Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'BIST 1:1', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'BIST', 1, 1, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 32, 2, 'MONDAY 23RD NOVEMBER', 'Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'BIST 1:2', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'BIST', 1, 2, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 32, 2, 'MONDAY 23RD NOVEMBER', 'Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'DCS 1:1', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'DCS', 1, 1, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 32, 2, 'MONDAY 23RD NOVEMBER', 'Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'DCS 1:2', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'DCS', 1, 2, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 32, 2, 'MONDAY 23RD NOVEMBER', 'Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'DIST 1:1', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'DIST', 1, 1, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 32, 2, 'MONDAY 23RD NOVEMBER', 'Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'DIST 1:2', 'Discrete Mathematics / Computer Mathematics', 'SCI', 'DIST', 1, 2, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 32, 2, 'MONDAY 23RD NOVEMBER', 'Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'BCDF 2:2', 'Computer Security Techniques', 'SCI', 'BCDF', 2, 2, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 32, 4, 'MONDAY 23RD NOVEMBER', 'Computer Security Techniques (BCDF 2:2) - Mr. Lugemwa Bryan'
  UNION ALL
  SELECT 'BCS 3:1', 'Artificial Intelligence', 'SCI', 'BCS', 3, 1, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 33, 2, 'MONDAY 23RD NOVEMBER', 'Artificial Intelligence (BIST 2:2, DIST 2:2, BCS 3:1) - Mr. Kawuma Richard(M&K)'
  UNION ALL
  SELECT 'BIST 2:2', 'Artificial Intelligence', 'SCI', 'BIST', 2, 2, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 33, 2, 'MONDAY 23RD NOVEMBER', 'Artificial Intelligence (BIST 2:2, DIST 2:2, BCS 3:1) - Mr. Kawuma Richard(M&K)'
  UNION ALL
  SELECT 'DIST 2:2', 'Artificial Intelligence', 'SCI', 'DIST', 2, 2, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 33, 2, 'MONDAY 23RD NOVEMBER', 'Artificial Intelligence (BIST 2:2, DIST 2:2, BCS 3:1) - Mr. Kawuma Richard(M&K)'
  UNION ALL
  SELECT 'BCDF 2:1', 'Incident Response and Investigation', 'SCI', 'BCDF', 2, 1, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 33, 4, 'MONDAY 23RD NOVEMBER', 'Incident Response and Investigation (BCDF 2:1) - Mr. Lugemwa Bryan (M&K)'
  UNION ALL
  SELECT 'BCS 2:2', 'Database Programming', 'SCI', 'BCS', 2, 2, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 34, 2, 'MONDAY 23RD NOVEMBER', 'Database Programming (BCS 2:2, DCS 2:2) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'DCS 2:2', 'Database Programming', 'SCI', 'DCS', 2, 2, '2026-11-23', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 34, 2, 'MONDAY 23RD NOVEMBER', 'Database Programming (BCS 2:2, DCS 2:2) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'DIST', 'Systems Analysis and Design', 'SCI', 'DIST', 0, 0, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 34, 4, 'MONDAY 23RD NOVEMBER', 'Systems Analysis and Design (DIST, SBA) - Mr. Ssenyomo Abubaker/ Ssemaganda Shuraim (M&K)'
  UNION ALL
  SELECT 'SBA', 'Systems Analysis and Design', 'SCI', 'SBA', 0, 0, '2026-11-23', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 34, 4, 'MONDAY 23RD NOVEMBER', 'Systems Analysis and Design (DIST, SBA) - Mr. Ssenyomo Abubaker/ Ssemaganda Shuraim (M&K)'
  UNION ALL
  SELECT 'BCDF 1:1', 'Business Communication Skills', 'SCI', 'BCDF', 1, 1, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 2, 'TUESDAY 24TH NOVEMBER', 'Business Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet(M&K)'
  UNION ALL
  SELECT 'BCDF 1:2', 'Business Communication Skills', 'SCI', 'BCDF', 1, 2, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 2, 'TUESDAY 24TH NOVEMBER', 'Business Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet(M&K)'
  UNION ALL
  SELECT 'BCS 1:1', 'Business Communication Skills', 'SCI', 'BCS', 1, 1, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 2, 'TUESDAY 24TH NOVEMBER', 'Business Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet(M&K)'
  UNION ALL
  SELECT 'BCS 1:2', 'Business Communication Skills', 'SCI', 'BCS', 1, 2, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 2, 'TUESDAY 24TH NOVEMBER', 'Business Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet(M&K)'
  UNION ALL
  SELECT 'BIST 1:1', 'Business Communication Skills', 'SCI', 'BIST', 1, 1, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 2, 'TUESDAY 24TH NOVEMBER', 'Business Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet(M&K)'
  UNION ALL
  SELECT 'BIST 1:2', 'Business Communication Skills', 'SCI', 'BIST', 1, 2, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 2, 'TUESDAY 24TH NOVEMBER', 'Business Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet(M&K)'
  UNION ALL
  SELECT 'DCS 1:1', 'Business Communication Skills', 'SCI', 'DCS', 1, 1, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 2, 'TUESDAY 24TH NOVEMBER', 'Business Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet(M&K)'
  UNION ALL
  SELECT 'DCS 1:2', 'Business Communication Skills', 'SCI', 'DCS', 1, 2, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 2, 'TUESDAY 24TH NOVEMBER', 'Business Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet(M&K)'
  UNION ALL
  SELECT 'DIST 1:1', 'Business Communication Skills', 'SCI', 'DIST', 1, 1, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 2, 'TUESDAY 24TH NOVEMBER', 'Business Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet(M&K)'
  UNION ALL
  SELECT 'DIST 1:2', 'Business Communication Skills', 'SCI', 'DIST', 1, 2, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 2, 'TUESDAY 24TH NOVEMBER', 'Business Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet(M&K)'
  UNION ALL
  SELECT 'BIST 3:1', 'Network and Cyber Security', 'SCI', 'BIST', 3, 1, '2026-11-24', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 36, 4, 'TUESDAY 24TH NOVEMBER', 'Network and Cyber Security (BIST 3:1) - Mr. Musasizi Timothy/ Mr Lugemwa Brian (M&K)'
  UNION ALL
  SELECT 'BCS 3:2', 'Emerging Trends in Information Systems and Technology / Computer Science', 'SCI', 'BCS', 3, 2, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 37, 2, 'TUESDAY 24TH NOVEMBER', 'Emerging Trends in Information Systems and Technology / Computer Science (BIST 3:2, BCS 3:2) - Ms. Nasozi Betty/ Ali Nabulogo(M&K)'
  UNION ALL
  SELECT 'BIST 3:2', 'Emerging Trends in Information Systems and Technology / Computer Science', 'SCI', 'BIST', 3, 2, '2026-11-24', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 37, 2, 'TUESDAY 24TH NOVEMBER', 'Emerging Trends in Information Systems and Technology / Computer Science (BIST 3:2, BCS 3:2) - Ms. Nasozi Betty/ Ali Nabulogo(M&K)'
  UNION ALL
  SELECT 'BCS 3:1', 'Multimedia Applications / Multimedia Systems', 'SCI', 'BCS', 3, 1, '2026-11-25', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 39, 2, 'WEDNESDAY 25TH NOVEMBER', 'Multimedia Applications / Multimedia Systems (BIST 2:1, DIST 2:1, BCS 3:1) - Mr. Walikurungi Harryson(M&K)'
  UNION ALL
  SELECT 'BIST 2:1', 'Multimedia Applications / Multimedia Systems', 'SCI', 'BIST', 2, 1, '2026-11-25', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 39, 2, 'WEDNESDAY 25TH NOVEMBER', 'Multimedia Applications / Multimedia Systems (BIST 2:1, DIST 2:1, BCS 3:1) - Mr. Walikurungi Harryson(M&K)'
  UNION ALL
  SELECT 'DIST 2:1', 'Multimedia Applications / Multimedia Systems', 'SCI', 'DIST', 2, 1, '2026-11-25', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 39, 2, 'WEDNESDAY 25TH NOVEMBER', 'Multimedia Applications / Multimedia Systems (BIST 2:1, DIST 2:1, BCS 3:1) - Mr. Walikurungi Harryson(M&K)'
  UNION ALL
  SELECT 'BIST 2:2', 'E-services', 'SCI', 'BIST', 2, 2, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 39, 4, 'WEDNESDAY 25TH NOVEMBER', 'E-services (BIST 2:2, DIST 2:2) - Mr. Ssendi Samuel (M&K)'
  UNION ALL
  SELECT 'DIST 2:2', 'E-services', 'SCI', 'DIST', 2, 2, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 39, 4, 'WEDNESDAY 25TH NOVEMBER', 'E-services (BIST 2:2, DIST 2:2) - Mr. Ssendi Samuel (M&K)'
  UNION ALL
  SELECT 'BIST 3:1', 'Business Process Modeling', 'SCI', 'BIST', 3, 1, '2026-11-25', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 40, 4, 'WEDNESDAY 25TH NOVEMBER', 'Business Process Modeling (BIST 3:1) - Mr. Kawooya Michael/ Ssemaganda Shuraim (M&K) (14)'
  UNION ALL
  SELECT 'DIST', 'Management of Information Systems', 'SCI', 'DIST', 0, 0, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 42, 2, 'THURSDAY 26TH NOVEMBER', 'Management of Information Systems (DIST, SBA) - Mr. Ssenyomo Abubaker/ Kato Mustapha(M&K)'
  UNION ALL
  SELECT 'SBA', 'Management of Information Systems', 'SCI', 'SBA', 0, 0, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 42, 2, 'THURSDAY 26TH NOVEMBER', 'Management of Information Systems (DIST, SBA) - Mr. Ssenyomo Abubaker/ Kato Mustapha(M&K)'
  UNION ALL
  SELECT 'BCDF 2:2', 'Evidence Handling and Presentation', 'SCI', 'BCDF', 2, 2, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 42, 4, 'THURSDAY 26TH NOVEMBER', 'Evidence Handling and Presentation (BCDF 2:2) - Mr. Kikwanga Charles'
  UNION ALL
  SELECT 'BCS 2:2', 'Computer Graphics', 'SCI', 'BCS', 2, 2, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 43, 2, 'THURSDAY 26TH NOVEMBER', 'Computer Graphics (BCS 2:2, DCS 2:2) - Mr. Walulya'
  UNION ALL
  SELECT 'DCS 2:2', 'Computer Graphics', 'SCI', 'DCS', 2, 2, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 43, 2, 'THURSDAY 26TH NOVEMBER', 'Computer Graphics (BCS 2:2, DCS 2:2) - Mr. Walulya'
  UNION ALL
  SELECT 'SLAW 1:1', 'Introduction to Information Technology and Computer Use', 'SCI', 'SLAW', 1, 1, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 43, 4, 'THURSDAY 26TH NOVEMBER', 'Introduction to Information Technology & Computer Use (SLAW 1:1) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'BCS 3:2', 'Data Warehousing and Data Mining', 'SCI', 'BCS', 3, 2, '2026-11-26', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 44, 2, 'THURSDAY 26TH NOVEMBER', 'Data Warehousing and Data Mining (BCS 3:2) - Mr. Semaganda Shuraim'
  UNION ALL
  SELECT 'BCS 3:1', 'Wireless Networking', 'SCI', 'BCS', 3, 1, '2026-11-26', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 44, 4, 'THURSDAY 26TH NOVEMBER', 'Wireless Networking (BCS3:1) Mr Sendi (M&K)'
  UNION ALL
  SELECT 'BCS 2:1', 'BCS 2103 Computer Architecture and Organization', 'SCI', 'BCS', 2, 1, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 46, 2, 'FRIDAY 27TH NOVEMBER', 'BCS 2103 Computer Architecture and Organization (BCS 2:1, DCS 2:1) - Mr. Ssenyomo Abubaker/ Kato David(M&K)'
  UNION ALL
  SELECT 'DCS 2:1', 'BCS 2103 Computer Architecture and Organization', 'SCI', 'DCS', 2, 1, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 46, 2, 'FRIDAY 27TH NOVEMBER', 'BCS 2103 Computer Architecture and Organization (BCS 2:1, DCS 2:1) - Mr. Ssenyomo Abubaker/ Kato David(M&K)'
  UNION ALL
  SELECT 'BCDF 1:1', 'CDF 1209 Information Systems Architecture and Design', 'SCI', 'BCDF', 1, 1, '2026-11-27', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 46, 4, 'FRIDAY 27TH NOVEMBER', 'CDF 1209 Information Systems Architecture and Design (BCDF 1:1, BCDF 1:2) - Mr. Ssenyomo Abubaker'
  UNION ALL
  SELECT 'BCDF 1:2', 'CDF 1209 Information Systems Architecture and Design', 'SCI', 'BCDF', 1, 2, '2026-11-27', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 46, 4, 'FRIDAY 27TH NOVEMBER', 'CDF 1209 Information Systems Architecture and Design (BCDF 1:1, BCDF 1:2) - Mr. Ssenyomo Abubaker'
  UNION ALL
  SELECT 'BIST 1:1', 'Information Systems and Technology Foundations', 'SCI', 'BIST', 1, 1, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 47, 2, 'FRIDAY 27TH NOVEMBER', 'Information Systems and Technology Foundations (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Mr. Kawuma Richard/ Betty nassozi(M&K)'
  UNION ALL
  SELECT 'BIST 1:2', 'Information Systems and Technology Foundations', 'SCI', 'BIST', 1, 2, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 47, 2, 'FRIDAY 27TH NOVEMBER', 'Information Systems and Technology Foundations (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Mr. Kawuma Richard/ Betty nassozi(M&K)'
  UNION ALL
  SELECT 'DIST 1:1', 'Information Systems and Technology Foundations', 'SCI', 'DIST', 1, 1, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 47, 2, 'FRIDAY 27TH NOVEMBER', 'Information Systems and Technology Foundations (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Mr. Kawuma Richard/ Betty nassozi(M&K)'
  UNION ALL
  SELECT 'DIST 1:2', 'Information Systems and Technology Foundations', 'SCI', 'DIST', 1, 2, '2026-11-27', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 47, 2, 'FRIDAY 27TH NOVEMBER', 'Information Systems and Technology Foundations (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2) - Mr. Kawuma Richard/ Betty nassozi(M&K)'
  UNION ALL
  SELECT 'BCDF 3:1', 'Cyber Laws and Security Policy', 'SCI', 'BCDF', 3, 1, '2026-11-27', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 47, 4, 'FRIDAY 27TH NOVEMBER', 'Cyber Laws & Security Policy (BCDF 3:1) - Ms. Kyomuhendo Charlotte (M&K)'
  UNION ALL
  SELECT 'BCS 3:2', 'Computer Repair and Maintenance', 'SCI', 'BCS', 3, 2, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 49, 2, 'MONDAY 30TH NOVEMBER', 'Computer Repair and Maintenance (BIST 3:1, BCS 3:2, SEDU) - Mr. ssegawa Andrew/Mr. Kato David (M&K)'
  UNION ALL
  SELECT 'BIST 3:1', 'Computer Repair and Maintenance', 'SCI', 'BIST', 3, 1, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 49, 2, 'MONDAY 30TH NOVEMBER', 'Computer Repair and Maintenance (BIST 3:1, BCS 3:2, SEDU) - Mr. ssegawa Andrew/Mr. Kato David (M&K)'
  UNION ALL
  SELECT 'BIST 3:2', 'IT Project Development and Management', 'SCI', 'BIST', 3, 2, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'BOTH', 'Day Timetable', 49, 4, 'MONDAY 30TH NOVEMBER', 'IT Project Development and Management (BIST 3:2) - Mr. Male Vincent (M&K) to be done by both day &weekend students on 6th November 2026'
  UNION ALL
  SELECT 'BCS 1:1', 'Numerical Methods', 'SCI', 'BCS', 1, 1, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 50, 2, 'MONDAY 30TH NOVEMBER', 'Numerical Methods (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'BCS 1:2', 'Numerical Methods', 'SCI', 'BCS', 1, 2, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 50, 2, 'MONDAY 30TH NOVEMBER', 'Numerical Methods (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'DCS 1:1', 'Numerical Methods', 'SCI', 'DCS', 1, 1, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 50, 2, 'MONDAY 30TH NOVEMBER', 'Numerical Methods (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'DCS 1:2', 'Numerical Methods', 'SCI', 'DCS', 1, 2, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 50, 2, 'MONDAY 30TH NOVEMBER', 'Numerical Methods (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona(M&K)'
  UNION ALL
  SELECT 'BCDF 2:2', 'Security Modelling', 'SCI', 'BCDF', 2, 2, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 50, 4, 'MONDAY 30TH NOVEMBER', 'Security Modelling (BCDF 2:2) - Mr. Mutebi Bashir'
  UNION ALL
  SELECT 'BCS 2:1', 'Information Systems Security', 'SCI', 'BCS', 2, 1, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 51, 2, 'MONDAY 30TH NOVEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Lugemwa Bryan(M&K)'
  UNION ALL
  SELECT 'BIST 2:1', 'Information Systems Security', 'SCI', 'BIST', 2, 1, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 51, 2, 'MONDAY 30TH NOVEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Lugemwa Bryan(M&K)'
  UNION ALL
  SELECT 'DCS 2:1', 'Information Systems Security', 'SCI', 'DCS', 2, 1, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 51, 2, 'MONDAY 30TH NOVEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Lugemwa Bryan(M&K)'
  UNION ALL
  SELECT 'DIST 2:1', 'Information Systems Security', 'SCI', 'DIST', 2, 1, '2026-11-30', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 51, 2, 'MONDAY 30TH NOVEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Lugemwa Bryan(M&K)'
  UNION ALL
  SELECT 'BCDF 1:2', 'Computer Crimes', 'SCI', 'BCDF', 1, 2, '2026-11-30', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 51, 4, 'MONDAY 30TH NOVEMBER', 'Computer Crimes (BCDF 1:2) - Mr. Ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'BCS 2:1', 'Research Methods / IT Research Design and Implementation', 'SCI', 'BCS', 2, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'BOTH', 'Day Timetable', 52, 2, 'MONDAY 30TH NOVEMBER', 'Research Methods / IT Research Design and Implementation (BIST 2:2, DIST 2:2, BCS 2:1, DCS 2:1) - Dr. Ssendawula(M&K)to be done by both day &weekend students on 28th November 2026'
  UNION ALL
  SELECT 'BIST 2:2', 'Research Methods / IT Research Design and Implementation', 'SCI', 'BIST', 2, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'BOTH', 'Day Timetable', 52, 2, 'MONDAY 30TH NOVEMBER', 'Research Methods / IT Research Design and Implementation (BIST 2:2, DIST 2:2, BCS 2:1, DCS 2:1) - Dr. Ssendawula(M&K)to be done by both day &weekend students on 28th November 2026'
  UNION ALL
  SELECT 'DCS 2:1', 'Research Methods / IT Research Design and Implementation', 'SCI', 'DCS', 2, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'BOTH', 'Day Timetable', 52, 2, 'MONDAY 30TH NOVEMBER', 'Research Methods / IT Research Design and Implementation (BIST 2:2, DIST 2:2, BCS 2:1, DCS 2:1) - Dr. Ssendawula(M&K)to be done by both day &weekend students on 28th November 2026'
  UNION ALL
  SELECT 'DIST 2:2', 'Research Methods / IT Research Design and Implementation', 'SCI', 'DIST', 2, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'BOTH', 'Day Timetable', 52, 2, 'MONDAY 30TH NOVEMBER', 'Research Methods / IT Research Design and Implementation (BIST 2:2, DIST 2:2, BCS 2:1, DCS 2:1) - Dr. Ssendawula(M&K)to be done by both day &weekend students on 28th November 2026'
  UNION ALL
  SELECT 'BCS 2:2', 'Principles of Software Engineering', 'SCI', 'BCS', 2, 2, '2026-12-01', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 54, 2, 'TUESDAY 1ST DECEMBER', 'Principles of Software Engineering (BIST 2:1, DIST 2:1, BCS 2:2, DCS 2:2, SEDU) - Mr. Otemo Vincent/ Mr Ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'BIST 2:1', 'Principles of Software Engineering', 'SCI', 'BIST', 2, 1, '2026-12-01', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 54, 2, 'TUESDAY 1ST DECEMBER', 'Principles of Software Engineering (BIST 2:1, DIST 2:1, BCS 2:2, DCS 2:2, SEDU) - Mr. Otemo Vincent/ Mr Ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'DCS 2:2', 'Principles of Software Engineering', 'SCI', 'DCS', 2, 2, '2026-12-01', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 54, 2, 'TUESDAY 1ST DECEMBER', 'Principles of Software Engineering (BIST 2:1, DIST 2:1, BCS 2:2, DCS 2:2, SEDU) - Mr. Otemo Vincent/ Mr Ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'DIST 2:1', 'Principles of Software Engineering', 'SCI', 'DIST', 2, 1, '2026-12-01', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 54, 2, 'TUESDAY 1ST DECEMBER', 'Principles of Software Engineering (BIST 2:1, DIST 2:1, BCS 2:2, DCS 2:2, SEDU) - Mr. Otemo Vincent/ Mr Ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'BCS 2:1', 'Event Driven Programming', 'SCI', 'BCS', 2, 1, '2026-12-01', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 54, 4, 'TUESDAY 1ST DECEMBER', 'Event Driven Programming (BCS 2:1, DCS 2:1) - Mr. Tumukunde Ivan (M&K)'
  UNION ALL
  SELECT 'DCS 2:1', 'Event Driven Programming', 'SCI', 'DCS', 2, 1, '2026-12-01', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 54, 4, 'TUESDAY 1ST DECEMBER', 'Event Driven Programming (BCS 2:1, DCS 2:1) - Mr. Tumukunde Ivan (M&K)'
  UNION ALL
  SELECT 'BCS 1:1', 'Survey of Programming Languages', 'SCI', 'BCS', 1, 1, '2026-12-01', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 55, 2, 'TUESDAY 1ST DECEMBER', 'Survey of Programming Languages (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Mr. Mulinde Hakimu/ Nabulongo Ali (M&K)'
  UNION ALL
  SELECT 'BCS 1:2', 'Survey of Programming Languages', 'SCI', 'BCS', 1, 2, '2026-12-01', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 55, 2, 'TUESDAY 1ST DECEMBER', 'Survey of Programming Languages (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Mr. Mulinde Hakimu/ Nabulongo Ali (M&K)'
  UNION ALL
  SELECT 'DCS 1:1', 'Survey of Programming Languages', 'SCI', 'DCS', 1, 1, '2026-12-01', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 55, 2, 'TUESDAY 1ST DECEMBER', 'Survey of Programming Languages (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Mr. Mulinde Hakimu/ Nabulongo Ali (M&K)'
  UNION ALL
  SELECT 'DCS 1:2', 'Survey of Programming Languages', 'SCI', 'DCS', 1, 2, '2026-12-01', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 55, 2, 'TUESDAY 1ST DECEMBER', 'Survey of Programming Languages (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Mr. Mulinde Hakimu/ Nabulongo Ali (M&K)'
  UNION ALL
  SELECT 'BCDF 2:1', 'Cryptography and Coding Theory', 'SCI', 'BCDF', 2, 1, '2026-12-01', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 55, 4, 'TUESDAY 1ST DECEMBER', 'Cryptography and Coding Theory (BCDF 2:1) - Mr. Musasizi Timothy )M&K)'
  UNION ALL
  SELECT 'BCDF 3:1', 'Information Systems Audit', 'SCI', 'BCDF', 3, 1, '2026-12-02', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 57, 2, 'WEDNESDAY 2ND DECEMBER', 'Information Systems Audit (BIST 3:2, BCDF 3:1) - Mr. Lugemwa Brian/Nabulongo(M&K)'
  UNION ALL
  SELECT 'BIST 3:2', 'Information Systems Audit', 'SCI', 'BIST', 3, 2, '2026-12-02', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 57, 2, 'WEDNESDAY 2ND DECEMBER', 'Information Systems Audit (BIST 3:2, BCDF 3:1) - Mr. Lugemwa Brian/Nabulongo(M&K)'
  UNION ALL
  SELECT 'BCS 3:1', 'Automata, Complexity and Computability', 'SCI', 'BCS', 3, 1, '2026-12-02', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 57, 4, 'WEDNESDAY 2ND DECEMBER', 'Automata, Complexity and Computability (BCS 3:1) - Mr. Otemo Vincent (M&K)'
  UNION ALL
  SELECT 'BCDF 2:1', 'Computer Forensic Evidence Collection Tools and Techniques', 'SCI', 'BCDF', 2, 1, '2026-12-02', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 58, 4, 'WEDNESDAY 2ND DECEMBER', 'Computer Forensic Evidence Collection Tools and Techniques (BCDF 2:1) - Ms. Atuhaire Rahab/ Abdu Karim/ Brian Lugemwa (M&K)'
  UNION ALL
  SELECT 'BCS 2:1', 'Information Systems Security', 'SCI', 'BCS', 2, 1, '2026-12-03', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 60, 2, 'THURSDAY 3RD DECEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Lugemwa Bryan(M&K)'
  UNION ALL
  SELECT 'BIST 2:1', 'Information Systems Security', 'SCI', 'BIST', 2, 1, '2026-12-03', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 60, 2, 'THURSDAY 3RD DECEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Lugemwa Bryan(M&K)'
  UNION ALL
  SELECT 'DCS 2:1', 'Information Systems Security', 'SCI', 'DCS', 2, 1, '2026-12-03', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 60, 2, 'THURSDAY 3RD DECEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Lugemwa Bryan(M&K)'
  UNION ALL
  SELECT 'DIST 2:1', 'Information Systems Security', 'SCI', 'DIST', 2, 1, '2026-12-03', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 60, 2, 'THURSDAY 3RD DECEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Lugemwa Bryan(M&K)'
  UNION ALL
  SELECT 'BIST 3:2', 'Data Mining and Business Intelligence', 'SCI', 'BIST', 3, 2, '2026-12-03', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 60, 4, 'THURSDAY 3RD DECEMBER', 'Data Mining & Business Intelligence (BIST 3:2) - Mr. Semaganda Shuraim (M&K)'
  UNION ALL
  SELECT 'SBA', 'Human Resource Information Systems', 'SCI', 'SBA', 0, 0, '2026-12-03', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 61, 2, 'THURSDAY 3RD DECEMBER', 'Human Resource Information Systems (SBA) - Dr. Namara Khadija'
  UNION ALL
  SELECT 'BCDF 2:1', 'Software Security', 'SCI', 'BCDF', 2, 1, '2026-12-03', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 61, 4, 'THURSDAY 3RD DECEMBER', 'Software Security (BCDF 2:1) - Mr. Musasizi Timothy (M&K)'
  UNION ALL
  SELECT 'BCS 2:2', 'Modeling and Simulation', 'SCI', 'BCS', 2, 2, '2026-12-03', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 62, 2, 'THURSDAY 3RD DECEMBER', 'Modeling and Simulation (BCS 2:2, DCS 2:2) - Mr. Kawooya Michael'
  UNION ALL
  SELECT 'DCS 2:2', 'Modeling and Simulation', 'SCI', 'DCS', 2, 2, '2026-12-03', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 62, 2, 'THURSDAY 3RD DECEMBER', 'Modeling and Simulation (BCS 2:2, DCS 2:2) - Mr. Kawooya Michael'
  UNION ALL
  SELECT 'BCDF 1:1', 'Structured Programming', 'SCI', 'BCDF', 1, 1, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 2, 'FRIDAY 4TH DECEMBER', 'Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Mr. Mulinde Hakimu/ Mr ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'BCDF 1:2', 'Structured Programming', 'SCI', 'BCDF', 1, 2, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 2, 'FRIDAY 4TH DECEMBER', 'Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Mr. Mulinde Hakimu/ Mr ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'BCS 1:1', 'Structured Programming', 'SCI', 'BCS', 1, 1, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 2, 'FRIDAY 4TH DECEMBER', 'Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Mr. Mulinde Hakimu/ Mr ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'BCS 1:2', 'Structured Programming', 'SCI', 'BCS', 1, 2, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 2, 'FRIDAY 4TH DECEMBER', 'Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Mr. Mulinde Hakimu/ Mr ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'BIST 1:1', 'Structured Programming', 'SCI', 'BIST', 1, 1, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 2, 'FRIDAY 4TH DECEMBER', 'Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Mr. Mulinde Hakimu/ Mr ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'BIST 1:2', 'Structured Programming', 'SCI', 'BIST', 1, 2, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 2, 'FRIDAY 4TH DECEMBER', 'Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Mr. Mulinde Hakimu/ Mr ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'DCS 1:1', 'Structured Programming', 'SCI', 'DCS', 1, 1, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 2, 'FRIDAY 4TH DECEMBER', 'Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Mr. Mulinde Hakimu/ Mr ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'DCS 1:2', 'Structured Programming', 'SCI', 'DCS', 1, 2, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 2, 'FRIDAY 4TH DECEMBER', 'Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Mr. Mulinde Hakimu/ Mr ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'DIST 1:1', 'Structured Programming', 'SCI', 'DIST', 1, 1, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 2, 'FRIDAY 4TH DECEMBER', 'Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Mr. Mulinde Hakimu/ Mr ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'DIST 1:2', 'Structured Programming', 'SCI', 'DIST', 1, 2, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 2, 'FRIDAY 4TH DECEMBER', 'Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Mr. Mulinde Hakimu/ Mr ssegawa Andrew(M&K)'
  UNION ALL
  SELECT 'BCS 2:1', 'Computer Algorithm', 'SCI', 'BCS', 2, 1, '2026-12-04', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 4, 'FRIDAY 4TH DECEMBER', 'Computer Algorithm (BCS 2:1, DCS 2:1) - Mr. Otemo Vincent/ Musiime Phiona (M&K)'
  UNION ALL
  SELECT 'DCS 2:1', 'Computer Algorithm', 'SCI', 'DCS', 2, 1, '2026-12-04', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 64, 4, 'FRIDAY 4TH DECEMBER', 'Computer Algorithm (BCS 2:1, DCS 2:1) - Mr. Otemo Vincent/ Musiime Phiona (M&K)'
  UNION ALL
  SELECT 'BIST 2:1', 'Operating Systems', 'SCI', 'BIST', 2, 1, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 65, 2, 'FRIDAY 4TH DECEMBER', 'Operating Systems (BIST 2:1, DIST 2:1) - Ms. Nasozi Betty/ Ssemaganda Shuraim(M&K)'
  UNION ALL
  SELECT 'DIST 2:1', 'Operating Systems', 'SCI', 'DIST', 2, 1, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 65, 2, 'FRIDAY 4TH DECEMBER', 'Operating Systems (BIST 2:1, DIST 2:1) - Ms. Nasozi Betty/ Ssemaganda Shuraim(M&K)'
  UNION ALL
  SELECT 'BCDF 3:1', 'CDF 3106 Mobile and Wireless Security', 'SCI', 'BCDF', 3, 1, '2026-12-04', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 65, 4, 'FRIDAY 4TH DECEMBER', 'CDF 3106 Mobile and Wireless Security (BCDF 3:1) - Mr. Kawuma Richard/Kato David (M&K)'
  UNION ALL
  SELECT 'BCDF 3:1', 'Criminal profiling', 'SCI', 'BCDF', 3, 1, '2026-12-04', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 66, 2, 'FRIDAY 4TH DECEMBER', 'Criminal profiling BCDF 3:1 Mr. Kikwanga Charles (K)'
  UNION ALL
  SELECT 'BCDF 1:2', 'Intrusion and Penetration Testing', 'SCI', 'BCDF', 1, 2, '2026-12-04', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'DAY', 'Day Timetable', 66, 4, 'FRIDAY 4TH DECEMBER', 'Intrusion and Penetration Testing (BCDF1:2) Mr Brian lugemwa (K)'
  UNION ALL
  SELECT 'BCDF 1:1', 'Computer Applications and Systems / Computer Applications', 'SCI', 'BCDF', 1, 1, '2026-11-14', '09:00:00', '12:00:00', 'WAHA LABS', 'WEEKEND', 'Weekend Timetable', 7, 2, 'SATURDAY 14TH NOVEMBER', 'Computer Applications & Systems / Computer Applications (BCDF 1:1, BCDF 1:2, BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, SBA) - Mr. Sserunkuma Damian(M&K) (WAHA LABS)'
  UNION ALL
  SELECT 'BCDF 1:2', 'Computer Applications and Systems / Computer Applications', 'SCI', 'BCDF', 1, 2, '2026-11-14', '09:00:00', '12:00:00', 'WAHA LABS', 'WEEKEND', 'Weekend Timetable', 7, 2, 'SATURDAY 14TH NOVEMBER', 'Computer Applications & Systems / Computer Applications (BCDF 1:1, BCDF 1:2, BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, SBA) - Mr. Sserunkuma Damian(M&K) (WAHA LABS)'
  UNION ALL
  SELECT 'BIST 1:1', 'Computer Applications and Systems / Computer Applications', 'SCI', 'BIST', 1, 1, '2026-11-14', '09:00:00', '12:00:00', 'WAHA LABS', 'WEEKEND', 'Weekend Timetable', 7, 2, 'SATURDAY 14TH NOVEMBER', 'Computer Applications & Systems / Computer Applications (BCDF 1:1, BCDF 1:2, BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, SBA) - Mr. Sserunkuma Damian(M&K) (WAHA LABS)'
  UNION ALL
  SELECT 'BIST 1:2', 'Computer Applications and Systems / Computer Applications', 'SCI', 'BIST', 1, 2, '2026-11-14', '09:00:00', '12:00:00', 'WAHA LABS', 'WEEKEND', 'Weekend Timetable', 7, 2, 'SATURDAY 14TH NOVEMBER', 'Computer Applications & Systems / Computer Applications (BCDF 1:1, BCDF 1:2, BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, SBA) - Mr. Sserunkuma Damian(M&K) (WAHA LABS)'
  UNION ALL
  SELECT 'DIST 1:1', 'Computer Applications and Systems / Computer Applications', 'SCI', 'DIST', 1, 1, '2026-11-14', '09:00:00', '12:00:00', 'WAHA LABS', 'WEEKEND', 'Weekend Timetable', 7, 2, 'SATURDAY 14TH NOVEMBER', 'Computer Applications & Systems / Computer Applications (BCDF 1:1, BCDF 1:2, BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, SBA) - Mr. Sserunkuma Damian(M&K) (WAHA LABS)'
  UNION ALL
  SELECT 'DIST 1:2', 'Computer Applications and Systems / Computer Applications', 'SCI', 'DIST', 1, 2, '2026-11-14', '09:00:00', '12:00:00', 'WAHA LABS', 'WEEKEND', 'Weekend Timetable', 7, 2, 'SATURDAY 14TH NOVEMBER', 'Computer Applications & Systems / Computer Applications (BCDF 1:1, BCDF 1:2, BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, SBA) - Mr. Sserunkuma Damian(M&K) (WAHA LABS)'
  UNION ALL
  SELECT 'BCS', 'User Interface Design', 'SCI', 'BCS', 0, 0, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'BOTH', 'Weekend Timetable', 11, 2, 'SATURDAY 21ST NOVEMBER', 'User Interface Design (BCS) - Mr. Kawooya Michael(M&K) to To be done by both day and weekend students on 21st November2026'
  UNION ALL
  SELECT 'BCS 2:1', 'BCS 2104 Event Driven Programming', 'SCI', 'BCS', 2, 1, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 11, 4, 'SATURDAY 21ST NOVEMBER', 'BCS 2104 Event Driven Programming (BCS 2:1, DCS 2:1, DIT 2:1) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'DCS 2:1', 'BCS 2104 Event Driven Programming', 'SCI', 'DCS', 2, 1, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 11, 4, 'SATURDAY 21ST NOVEMBER', 'BCS 2104 Event Driven Programming (BCS 2:1, DCS 2:1, DIT 2:1) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'DIT 2:1', 'BCS 2104 Event Driven Programming', 'SCI', 'DIT', 2, 1, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 11, 4, 'SATURDAY 21ST NOVEMBER', 'BCS 2104 Event Driven Programming (BCS 2:1, DCS 2:1, DIT 2:1) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'BIST 3:1', 'BIST 3103 Business Process Modeling', 'SCI', 'BIST', 3, 1, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 12, 2, 'SATURDAY 21ST NOVEMBER', 'BIST 3103 Business Process Modeling (BIST 3:1) - Mr. Semaganda Shuraim'
  UNION ALL
  SELECT 'BCDF 2:2', 'CDF 2205 Security Modelling', 'SCI', 'BCDF', 2, 2, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 12, 4, 'SATURDAY 21ST NOVEMBER', 'CDF 2205 Security Modelling (BCDF 2:2) - Mr. Karim Abdu'
  UNION ALL
  SELECT 'BIST 2:2', 'BIST 2211 Legal and Ethical Issues of Computing', 'SCI', 'BIST', 2, 2, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 13, 2, 'SATURDAY 21ST NOVEMBER', 'BIST 2211 Legal and Ethical Issues of Computing (BIST 2:2, DIST 2:2) - Dr. Namara Khadija'
  UNION ALL
  SELECT 'DIST 2:2', 'BIST 2211 Legal and Ethical Issues of Computing', 'SCI', 'DIST', 2, 2, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 13, 2, 'SATURDAY 21ST NOVEMBER', 'BIST 2211 Legal and Ethical Issues of Computing (BIST 2:2, DIST 2:2) - Dr. Namara Khadija'
  UNION ALL
  SELECT 'SBA', 'Management Information Systems', 'SCI', 'SBA', 0, 0, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 13, 4, 'SATURDAY 21ST NOVEMBER', 'Management Information Systems (SBA) - Mr. Ssenyomo Abubaker'
  UNION ALL
  SELECT 'BCDF 3:1', 'CDF 3106 Mobile and Wireless Security', 'SCI', 'BCDF', 3, 1, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 14, 2, 'SATURDAY 21ST NOVEMBER', 'CDF 3106 Mobile and Wireless Security (BCDF 3:1) - Mr. Karim Abdu'
  UNION ALL
  SELECT 'BCS 2:2', 'Modeling and Simulation', 'SCI', 'BCS', 2, 2, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 14, 4, 'SATURDAY 21ST NOVEMBER', 'Modeling and Simulation (BCS 2:2, DCS 2:2) - Dr. Namwano Sylvia'
  UNION ALL
  SELECT 'DCS 2:2', 'Modeling and Simulation', 'SCI', 'DCS', 2, 2, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 14, 4, 'SATURDAY 21ST NOVEMBER', 'Modeling and Simulation (BCS 2:2, DCS 2:2) - Dr. Namwano Sylvia'
  UNION ALL
  SELECT 'BCDF 2:1', 'BIST 2104 Operating Systems', 'SCI', 'BCDF', 2, 1, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 15, 2, 'SATURDAY 21ST NOVEMBER', 'BIST 2104 Operating Systems (BIST 2:1, DIST 2:1, BCDF 2:1) - Ms. Nasozi Betty'
  UNION ALL
  SELECT 'BIST 2:1', 'BIST 2104 Operating Systems', 'SCI', 'BIST', 2, 1, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 15, 2, 'SATURDAY 21ST NOVEMBER', 'BIST 2104 Operating Systems (BIST 2:1, DIST 2:1, BCDF 2:1) - Ms. Nasozi Betty'
  UNION ALL
  SELECT 'DIST 2:1', 'BIST 2104 Operating Systems', 'SCI', 'DIST', 2, 1, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 15, 2, 'SATURDAY 21ST NOVEMBER', 'BIST 2104 Operating Systems (BIST 2:1, DIST 2:1, BCDF 2:1) - Ms. Nasozi Betty'
  UNION ALL
  SELECT 'BCDF 2:2', 'BCS 3104 Multimedia Systems / Multimedia Applications', 'SCI', 'BCDF', 2, 2, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 15, 4, 'SATURDAY 21ST NOVEMBER', 'BCS 3104 Multimedia Systems / Multimedia Applications (BCS 3:1, BIST 2:1, DIST 2:1, BCDF 2:2) - Mr. Walikurungi Harryson'
  UNION ALL
  SELECT 'BCS 3:1', 'BCS 3104 Multimedia Systems / Multimedia Applications', 'SCI', 'BCS', 3, 1, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 15, 4, 'SATURDAY 21ST NOVEMBER', 'BCS 3104 Multimedia Systems / Multimedia Applications (BCS 3:1, BIST 2:1, DIST 2:1, BCDF 2:2) - Mr. Walikurungi Harryson'
  UNION ALL
  SELECT 'BIST 2:1', 'BCS 3104 Multimedia Systems / Multimedia Applications', 'SCI', 'BIST', 2, 1, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 15, 4, 'SATURDAY 21ST NOVEMBER', 'BCS 3104 Multimedia Systems / Multimedia Applications (BCS 3:1, BIST 2:1, DIST 2:1, BCDF 2:2) - Mr. Walikurungi Harryson'
  UNION ALL
  SELECT 'DIST 2:1', 'BCS 3104 Multimedia Systems / Multimedia Applications', 'SCI', 'DIST', 2, 1, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 15, 4, 'SATURDAY 21ST NOVEMBER', 'BCS 3104 Multimedia Systems / Multimedia Applications (BCS 3:1, BIST 2:1, DIST 2:1, BCDF 2:2) - Mr. Walikurungi Harryson'
  UNION ALL
  SELECT 'BCDF 1:1', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BCDF', 1, 1, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 1106 Business Communication / Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet (M&K)'
  UNION ALL
  SELECT 'BCDF 1:2', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BCDF', 1, 2, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 1106 Business Communication / Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet (M&K)'
  UNION ALL
  SELECT 'BCS 1:1', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BCS', 1, 1, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 1106 Business Communication / Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet (M&K)'
  UNION ALL
  SELECT 'BCS 1:2', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BCS', 1, 2, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 1106 Business Communication / Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet (M&K)'
  UNION ALL
  SELECT 'BIST 1:1', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BIST', 1, 1, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 1106 Business Communication / Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet (M&K)'
  UNION ALL
  SELECT 'BIST 1:2', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'BIST', 1, 2, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 1106 Business Communication / Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet (M&K)'
  UNION ALL
  SELECT 'DCS 1:1', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'DCS', 1, 1, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 1106 Business Communication / Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet (M&K)'
  UNION ALL
  SELECT 'DCS 1:2', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'DCS', 1, 2, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 1106 Business Communication / Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet (M&K)'
  UNION ALL
  SELECT 'DIST 1:1', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'DIST', 1, 1, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 1106 Business Communication / Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet (M&K)'
  UNION ALL
  SELECT 'DIST 1:2', 'BIST 1106 Business Communication / Communication Skills', 'SCI', 'DIST', 1, 2, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 1106 Business Communication / Communication Skills (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Ms. Matama Harriet (M&K)'
  UNION ALL
  SELECT 'BCS 3:1', 'Automata, Complexity and Computability', 'SCI', 'BCS', 3, 1, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 18, 4, 'SUNDAY 22TH NOVEMBER', 'Automata, Complexity and Computability (BCS 3:1) - Mr. Otemo Vincent'
  UNION ALL
  SELECT 'SBA', 'Computer Applications II', 'SCI', 'SBA', 0, 0, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 19, 2, 'SUNDAY 22TH NOVEMBER', 'Computer Applications II (SBA) - Dr. Namara Khadija'
  UNION ALL
  SELECT 'BCDF 2:2', 'Data Mining and Business Intelligence', 'SCI', 'BCDF', 2, 2, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 19, 4, 'SUNDAY 22TH NOVEMBER', 'Data Mining & Business Intelligence (BIST 3:2, BCDF 2:2) - Mr. Semaganda Shuraim'
  UNION ALL
  SELECT 'BIST 3:2', 'Data Mining and Business Intelligence', 'SCI', 'BIST', 3, 2, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 19, 4, 'SUNDAY 22TH NOVEMBER', 'Data Mining & Business Intelligence (BIST 3:2, BCDF 2:2) - Mr. Semaganda Shuraim'
  UNION ALL
  SELECT 'BCS 2:1', 'BCS 2103 Computer Architecture and Organization', 'SCI', 'BCS', 2, 1, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 20, 2, 'SUNDAY 22TH NOVEMBER', 'BCS 2103 Computer Architecture and Organization (BCS 2:1, DCS 2:1) - Mr. Ssenyomo Abubaker'
  UNION ALL
  SELECT 'DCS 2:1', 'BCS 2103 Computer Architecture and Organization', 'SCI', 'DCS', 2, 1, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 20, 2, 'SUNDAY 22TH NOVEMBER', 'BCS 2103 Computer Architecture and Organization (BCS 2:1, DCS 2:1) - Mr. Ssenyomo Abubaker'
  UNION ALL
  SELECT 'BCS 2:1', 'Information Systems Security', 'SCI', 'BCS', 2, 1, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 20, 4, 'SUNDAY 22TH NOVEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Ssenyomo Abubaker'
  UNION ALL
  SELECT 'BIST 2:1', 'Information Systems Security', 'SCI', 'BIST', 2, 1, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 20, 4, 'SUNDAY 22TH NOVEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Ssenyomo Abubaker'
  UNION ALL
  SELECT 'DCS 2:1', 'Information Systems Security', 'SCI', 'DCS', 2, 1, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 20, 4, 'SUNDAY 22TH NOVEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Ssenyomo Abubaker'
  UNION ALL
  SELECT 'DIST 2:1', 'Information Systems Security', 'SCI', 'DIST', 2, 1, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 20, 4, 'SUNDAY 22TH NOVEMBER', 'Information Systems Security (BIST 2:1, DIST 2:1, BCS 2:1, DCS 2:1) - Mr. Ssenyomo Abubaker'
  UNION ALL
  SELECT 'BCDF 2:1', 'CDF 2105 Computer Forensic Evidence Collection Tools and Techniques', 'SCI', 'BCDF', 2, 1, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 21, 2, 'SUNDAY 22TH NOVEMBER', 'CDF 2105 Computer Forensic Evidence Collection Tools and Techniques (BCDF 2:1) - Ms. Atuhaire Rahab'
  UNION ALL
  SELECT 'BCS 1:1', 'BCS 1102 Linear Programming', 'SCI', 'BCS', 1, 1, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 21, 4, 'SUNDAY 22TH NOVEMBER', 'BCS 1102 Linear Programming (BCS 1:1, DCS 1:1) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'DCS 1:1', 'BCS 1102 Linear Programming', 'SCI', 'DCS', 1, 1, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 21, 4, 'SUNDAY 22TH NOVEMBER', 'BCS 1102 Linear Programming (BCS 1:1, DCS 1:1) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'BIST 3:2', 'BIST 3202 Software Systems Testing', 'SCI', 'BIST', 3, 2, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 22, 2, 'SUNDAY 22TH NOVEMBER', 'BIST 3202 Software Systems Testing (BIST 3:2) - Mr. Sserunkuma Damian'
  UNION ALL
  SELECT 'BCS 3:2', 'BCS 3202 Systems Administration', 'SCI', 'BCS', 3, 2, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 22, 4, 'SUNDAY 22TH NOVEMBER', 'BCS 3202 Systems Administration (BIST 3:1, BCS 3:2, DIST 2:2) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'BIST 3:1', 'BCS 3202 Systems Administration', 'SCI', 'BIST', 3, 1, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 22, 4, 'SUNDAY 22TH NOVEMBER', 'BCS 3202 Systems Administration (BIST 3:1, BCS 3:2, DIST 2:2) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'DIST 2:2', 'BCS 3202 Systems Administration', 'SCI', 'DIST', 2, 2, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 22, 4, 'SUNDAY 22TH NOVEMBER', 'BCS 3202 Systems Administration (BIST 3:1, BCS 3:2, DIST 2:2) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'BCDF 3:1', 'Cyber Laws and Security Policy', 'SCI', 'BCDF', 3, 1, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 23, 2, 'SUNDAY 22TH NOVEMBER', 'Cyber Laws & Security Policy (BCDF 3:1) - Ms. Kyomuhendo Charlotte'
  UNION ALL
  SELECT 'BCS 3:1', 'Artificial Intelligence', 'SCI', 'BCS', 3, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 25, 2, 'SATURDAY 28TH NOVEMBER', 'Artificial Intelligence (BCS 3:1, BIST 2:2, DIST 2:2) - Mr. Kawuma Richard'
  UNION ALL
  SELECT 'BIST 2:2', 'Artificial Intelligence', 'SCI', 'BIST', 2, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 25, 2, 'SATURDAY 28TH NOVEMBER', 'Artificial Intelligence (BCS 3:1, BIST 2:2, DIST 2:2) - Mr. Kawuma Richard'
  UNION ALL
  SELECT 'DIST 2:2', 'Artificial Intelligence', 'SCI', 'DIST', 2, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 25, 2, 'SATURDAY 28TH NOVEMBER', 'Artificial Intelligence (BCS 3:1, BIST 2:2, DIST 2:2) - Mr. Kawuma Richard'
  UNION ALL
  SELECT 'BCS 1:1', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'BCS', 1, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 26, 2, 'SATURDAY 28TH NOVEMBER', 'BIST 1105 Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, DIT 2:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'BCS 1:2', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'BCS', 1, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 26, 2, 'SATURDAY 28TH NOVEMBER', 'BIST 1105 Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, DIT 2:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'BIST 1:1', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'BIST', 1, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 26, 2, 'SATURDAY 28TH NOVEMBER', 'BIST 1105 Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, DIT 2:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'BIST 1:2', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'BIST', 1, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 26, 2, 'SATURDAY 28TH NOVEMBER', 'BIST 1105 Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, DIT 2:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'DCS 1:1', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'DCS', 1, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 26, 2, 'SATURDAY 28TH NOVEMBER', 'BIST 1105 Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, DIT 2:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'DCS 1:2', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'DCS', 1, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 26, 2, 'SATURDAY 28TH NOVEMBER', 'BIST 1105 Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, DIT 2:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'DIST 1:1', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'DIST', 1, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 26, 2, 'SATURDAY 28TH NOVEMBER', 'BIST 1105 Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, DIT 2:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'DIST 1:2', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'DIST', 1, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 26, 2, 'SATURDAY 28TH NOVEMBER', 'BIST 1105 Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, DIT 2:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'DIT 2:2', 'BIST 1105 Discrete Mathematics / Computer Mathematics', 'SCI', 'DIT', 2, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 26, 2, 'SATURDAY 28TH NOVEMBER', 'BIST 1105 Discrete Mathematics / Computer Mathematics (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, DIT 2:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'BCDF 2:2', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation', 'SCI', 'BCDF', 2, 2, '2026-11-28', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'BOTH', 'Weekend Timetable', 26, 4, 'SATURDAY 28TH NOVEMBER', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation (BIST 2:2, DIST 2:2, BCDF 2:2, BCS 2:1, DCS 2:1) - Dr. SsendawulaTo be done by both day and weekend students on 28th November 2026'
  UNION ALL
  SELECT 'BCS 2:1', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation', 'SCI', 'BCS', 2, 1, '2026-11-28', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'BOTH', 'Weekend Timetable', 26, 4, 'SATURDAY 28TH NOVEMBER', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation (BIST 2:2, DIST 2:2, BCDF 2:2, BCS 2:1, DCS 2:1) - Dr. SsendawulaTo be done by both day and weekend students on 28th November 2026'
  UNION ALL
  SELECT 'BIST 2:2', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation', 'SCI', 'BIST', 2, 2, '2026-11-28', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'BOTH', 'Weekend Timetable', 26, 4, 'SATURDAY 28TH NOVEMBER', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation (BIST 2:2, DIST 2:2, BCDF 2:2, BCS 2:1, DCS 2:1) - Dr. SsendawulaTo be done by both day and weekend students on 28th November 2026'
  UNION ALL
  SELECT 'DCS 2:1', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation', 'SCI', 'DCS', 2, 1, '2026-11-28', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'BOTH', 'Weekend Timetable', 26, 4, 'SATURDAY 28TH NOVEMBER', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation (BIST 2:2, DIST 2:2, BCDF 2:2, BCS 2:1, DCS 2:1) - Dr. SsendawulaTo be done by both day and weekend students on 28th November 2026'
  UNION ALL
  SELECT 'DIST 2:2', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation', 'SCI', 'DIST', 2, 2, '2026-11-28', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'BOTH', 'Weekend Timetable', 26, 4, 'SATURDAY 28TH NOVEMBER', 'BIST 2208 / BCS 2106 Research Methods / IT Research Design and Implementation (BIST 2:2, DIST 2:2, BCDF 2:2, BCS 2:1, DCS 2:1) - Dr. SsendawulaTo be done by both day and weekend students on 28th November 2026'
  UNION ALL
  SELECT 'BCDF 1:1', 'Human Behaviour Psychology', 'SCI', 'BCDF', 1, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 27, 2, 'SATURDAY 28TH NOVEMBER', 'Human Behaviour Psychology (BCDF 1:1, BCDF 1:2) - Mr. Kawuma Richard (M&K)'
  UNION ALL
  SELECT 'BCDF 1:2', 'Human Behaviour Psychology', 'SCI', 'BCDF', 1, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 27, 2, 'SATURDAY 28TH NOVEMBER', 'Human Behaviour Psychology (BCDF 1:1, BCDF 1:2) - Mr. Kawuma Richard (M&K)'
  UNION ALL
  SELECT 'BCS 3:2', 'Emerging Trends in Information Systems and Technology', 'SCI', 'BCS', 3, 2, '2026-11-28', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 27, 4, 'SATURDAY 28TH NOVEMBER', 'Emerging Trends in Information Systems and Technology (BIST 3:2, BCS 3:2) - Ms. Kyomuhendo Charlotte'
  UNION ALL
  SELECT 'BIST 3:2', 'Emerging Trends in Information Systems and Technology', 'SCI', 'BIST', 3, 2, '2026-11-28', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 27, 4, 'SATURDAY 28TH NOVEMBER', 'Emerging Trends in Information Systems and Technology (BIST 3:2, BCS 3:2) - Ms. Kyomuhendo Charlotte'
  UNION ALL
  SELECT 'BCDF 3:1', 'CDF 3101 Criminal Profiling', 'SCI', 'BCDF', 3, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 28, 2, 'SATURDAY 28TH NOVEMBER', 'CDF 3101 Criminal Profiling (BCDF 3:1) - Mr. Kikwanga Charles'
  UNION ALL
  SELECT 'BCDF 2:1', 'CDF 2101 Software Security', 'SCI', 'BCDF', 2, 1, '2026-11-28', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 28, 4, 'SATURDAY 28TH NOVEMBER', 'CDF 2101 Software Security (BCDF 2:1) - Mr. Musasizi Timothy'
  UNION ALL
  SELECT 'BIST 3:1', 'BIST 3105 Mobile Applications Development and Intellectual Property', 'SCI', 'BIST', 3, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 29, 2, 'SATURDAY 28TH NOVEMBER', 'BIST 3105 Mobile Applications Development and Intellectual Property (BIST 3:1) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'BCDF 2:1', 'BCS 2102 Database Management Systems', 'SCI', 'BCDF', 2, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 32, 2, 'SUNDAY 29TH NOVEMBER', 'BCS 2102 Database Management Systems (BCS 2:1, DCS 2:1, BIST 2:1, DIST 2:1, BCDF 2:1, DIT 1:2, SBA) - Ms. Atuhaire Rahab'
  UNION ALL
  SELECT 'BCS 2:1', 'BCS 2102 Database Management Systems', 'SCI', 'BCS', 2, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 32, 2, 'SUNDAY 29TH NOVEMBER', 'BCS 2102 Database Management Systems (BCS 2:1, DCS 2:1, BIST 2:1, DIST 2:1, BCDF 2:1, DIT 1:2, SBA) - Ms. Atuhaire Rahab'
  UNION ALL
  SELECT 'BIST 2:1', 'BCS 2102 Database Management Systems', 'SCI', 'BIST', 2, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 32, 2, 'SUNDAY 29TH NOVEMBER', 'BCS 2102 Database Management Systems (BCS 2:1, DCS 2:1, BIST 2:1, DIST 2:1, BCDF 2:1, DIT 1:2, SBA) - Ms. Atuhaire Rahab'
  UNION ALL
  SELECT 'DCS 2:1', 'BCS 2102 Database Management Systems', 'SCI', 'DCS', 2, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 32, 2, 'SUNDAY 29TH NOVEMBER', 'BCS 2102 Database Management Systems (BCS 2:1, DCS 2:1, BIST 2:1, DIST 2:1, BCDF 2:1, DIT 1:2, SBA) - Ms. Atuhaire Rahab'
  UNION ALL
  SELECT 'DIST 2:1', 'BCS 2102 Database Management Systems', 'SCI', 'DIST', 2, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 32, 2, 'SUNDAY 29TH NOVEMBER', 'BCS 2102 Database Management Systems (BCS 2:1, DCS 2:1, BIST 2:1, DIST 2:1, BCDF 2:1, DIT 1:2, SBA) - Ms. Atuhaire Rahab'
  UNION ALL
  SELECT 'DIT 1:2', 'BCS 2102 Database Management Systems', 'SCI', 'DIT', 1, 2, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 32, 2, 'SUNDAY 29TH NOVEMBER', 'BCS 2102 Database Management Systems (BCS 2:1, DCS 2:1, BIST 2:1, DIST 2:1, BCDF 2:1, DIT 1:2, SBA) - Ms. Atuhaire Rahab'
  UNION ALL
  SELECT 'BCDF 2:2', 'Computer Security Techniques', 'SCI', 'BCDF', 2, 2, '2026-11-29', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 32, 4, 'SUNDAY 29TH NOVEMBER', 'Computer Security Techniques (BCDF 2:2) - Mr. Lugemwa Bryan'
  UNION ALL
  SELECT 'BCDF 3:1', 'CDF 3102 Digital Devices Forensics', 'SCI', 'BCDF', 3, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 33, 2, 'SUNDAY 29TH NOVEMBER', 'CDF 3102 Digital Devices Forensics (BCDF 3:1) - Mr. Kikwanga Charles'
  UNION ALL
  SELECT 'BIST 3:1', 'BIST 3102 Network and Cyber Security', 'SCI', 'BIST', 3, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 34, 2, 'SUNDAY 29TH NOVEMBER', 'BIST 3102 Network and Cyber Security (BIST 3:1) - Mr. Musasizi Timothy'
  UNION ALL
  SELECT 'BIST 2:2', 'BIST 2209 Digital Forensics Investigation', 'SCI', 'BIST', 2, 2, '2026-11-29', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 34, 4, 'SUNDAY 29TH NOVEMBER', 'BIST 2209 Digital Forensics Investigation (BIST 2:2, DIST 2:2) - Mr. Kikwanga Charles'
  UNION ALL
  SELECT 'DIST 2:2', 'BIST 2209 Digital Forensics Investigation', 'SCI', 'DIST', 2, 2, '2026-11-29', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 34, 4, 'SUNDAY 29TH NOVEMBER', 'BIST 2209 Digital Forensics Investigation (BIST 2:2, DIST 2:2) - Mr. Kikwanga Charles'
  UNION ALL
  SELECT 'BIST 1:1', 'Information Systems and Technology Foundations', 'SCI', 'BIST', 1, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 35, 2, 'SUNDAY 29TH NOVEMBER', 'Information Systems and Technology Foundations (BIST 1:1, DIST 1:1, DIT 1:1, SBA) - Mr. Kato David'
  UNION ALL
  SELECT 'DIST 1:1', 'Information Systems and Technology Foundations', 'SCI', 'DIST', 1, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 35, 2, 'SUNDAY 29TH NOVEMBER', 'Information Systems and Technology Foundations (BIST 1:1, DIST 1:1, DIT 1:1, SBA) - Mr. Kato David'
  UNION ALL
  SELECT 'DIT 1:1', 'Information Systems and Technology Foundations', 'SCI', 'DIT', 1, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 35, 2, 'SUNDAY 29TH NOVEMBER', 'Information Systems and Technology Foundations (BIST 1:1, DIST 1:1, DIT 1:1, SBA) - Mr. Kato David'
  UNION ALL
  SELECT 'BCS 3:1', 'BCS 3106 Distributed Systems', 'SCI', 'BCS', 3, 1, '2026-11-29', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 35, 4, 'SUNDAY 29TH NOVEMBER', 'BCS 3106 Distributed Systems (BCS 3:1) - Dr. Namwano Sylvia'
  UNION ALL
  SELECT 'BCS 1:1', 'BCS 1105 Survey of Programming Languages', 'SCI', 'BCS', 1, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 36, 2, 'SUNDAY 29TH NOVEMBER', 'BCS 1105 Survey of Programming Languages (BCS 1:1, DCS 1:1) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'DCS 1:1', 'BCS 1105 Survey of Programming Languages', 'SCI', 'DCS', 1, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 36, 2, 'SUNDAY 29TH NOVEMBER', 'BCS 1105 Survey of Programming Languages (BCS 1:1, DCS 1:1) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'BCS 1:1', 'BCS 1106 Numerical Methods', 'SCI', 'BCS', 1, 1, '2026-11-29', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 36, 4, 'SUNDAY 29TH NOVEMBER', 'BCS 1106 Numerical Methods (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'BCS 1:2', 'BCS 1106 Numerical Methods', 'SCI', 'BCS', 1, 2, '2026-11-29', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 36, 4, 'SUNDAY 29TH NOVEMBER', 'BCS 1106 Numerical Methods (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'DCS 1:1', 'BCS 1106 Numerical Methods', 'SCI', 'DCS', 1, 1, '2026-11-29', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 36, 4, 'SUNDAY 29TH NOVEMBER', 'BCS 1106 Numerical Methods (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'DCS 1:2', 'BCS 1106 Numerical Methods', 'SCI', 'DCS', 1, 2, '2026-11-29', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 36, 4, 'SUNDAY 29TH NOVEMBER', 'BCS 1106 Numerical Methods (BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2) - Ms. Musiime Phiona'
  UNION ALL
  SELECT 'BCDF 1:1', 'CDF 1104 Principles of Cybersecurity', 'SCI', 'BCDF', 1, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 37, 2, 'SUNDAY 29TH NOVEMBER', 'CDF 1104 Principles of Cybersecurity (BCDF 1:1) - Mr. Karim Abdu(M&K)'
  UNION ALL
  SELECT 'BCS 2:2', 'Database Programming', 'SCI', 'BCS', 2, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 39, 2, 'SATURDAY 5TH DECEMBER', 'Database Programming (BCS 2:2, DCS 2:2, DIT 2:2) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'DCS 2:2', 'Database Programming', 'SCI', 'DCS', 2, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 39, 2, 'SATURDAY 5TH DECEMBER', 'Database Programming (BCS 2:2, DCS 2:2, DIT 2:2) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'DIT 2:2', 'Database Programming', 'SCI', 'DIT', 2, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 39, 2, 'SATURDAY 5TH DECEMBER', 'Database Programming (BCS 2:2, DCS 2:2, DIT 2:2) - Mr. Tumukunde Ivan'
  UNION ALL
  SELECT 'BCS 2:2', 'BCS 2203 Computer Graphics', 'SCI', 'BCS', 2, 2, '2026-12-05', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 39, 4, 'SATURDAY 5TH DECEMBER', 'BCS 2203 Computer Graphics (BCS 2:2, DCS 2:2) - Mr. Walulya'
  UNION ALL
  SELECT 'DCS 2:2', 'BCS 2203 Computer Graphics', 'SCI', 'DCS', 2, 2, '2026-12-05', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 39, 4, 'SATURDAY 5TH DECEMBER', 'BCS 2203 Computer Graphics (BCS 2:2, DCS 2:2) - Mr. Walulya'
  UNION ALL
  SELECT 'BCDF 3:1', 'Data Forensics', 'SCI', 'BCDF', 3, 1, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 40, 2, 'SATURDAY 5TH DECEMBER', 'Data Forensics (BCDF 3:1) - Mr. Karim Abdu'
  UNION ALL
  SELECT 'BCDF 1:1', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BCDF', 1, 1, '2026-12-05', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 40, 4, 'SATURDAY 5TH DECEMBER', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles (BIST 2:1, DIST 2:1, BCS 3:2, BCDF 1:1) - Dr. Namara Khadija/ Dr Asiimwe Viola(M&K)'
  UNION ALL
  SELECT 'BCS 3:2', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BCS', 3, 2, '2026-12-05', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 40, 4, 'SATURDAY 5TH DECEMBER', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles (BIST 2:1, DIST 2:1, BCS 3:2, BCDF 1:1) - Dr. Namara Khadija/ Dr Asiimwe Viola(M&K)'
  UNION ALL
  SELECT 'BIST 2:1', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'BIST', 2, 1, '2026-12-05', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 40, 4, 'SATURDAY 5TH DECEMBER', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles (BIST 2:1, DIST 2:1, BCS 3:2, BCDF 1:1) - Dr. Namara Khadija/ Dr Asiimwe Viola(M&K)'
  UNION ALL
  SELECT 'DIST 2:1', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles', 'SCI', 'DIST', 2, 1, '2026-12-05', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 40, 4, 'SATURDAY 5TH DECEMBER', 'CDF 1106 ICT Entrepreneurship Skills / Entrepreneurship Theory and Principles (BIST 2:1, DIST 2:1, BCS 3:2, BCDF 1:1) - Dr. Namara Khadija/ Dr Asiimwe Viola(M&K)'
  UNION ALL
  SELECT 'BCS 3:2', 'BCS 3207 Data Warehousing and Data Mining', 'SCI', 'BCS', 3, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 41, 2, 'SATURDAY 5TH DECEMBER', 'BCS 3207 Data Warehousing and Data Mining (BCS 3:2) - Ms. Atuhaire Rahab'
  UNION ALL
  SELECT 'BCDF 2:1', 'CDF 2106 Incident Response and Investigation', 'SCI', 'BCDF', 2, 1, '2026-12-05', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 41, 4, 'SATURDAY 5TH DECEMBER', 'CDF 2106 Incident Response and Investigation (BCDF 2:1) - Mr. Lugemwa Bryan'
  UNION ALL
  SELECT 'BCDF 1:1', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BCDF', 1, 1, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 42, 2, 'SATURDAY 5TH DECEMBER', 'Fundamentals of Structured Programming / Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Dr. Namwano Sylvia/ Mr Segawa Andrew(M&K)'
  UNION ALL
  SELECT 'BCDF 1:2', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BCDF', 1, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 42, 2, 'SATURDAY 5TH DECEMBER', 'Fundamentals of Structured Programming / Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Dr. Namwano Sylvia/ Mr Segawa Andrew(M&K)'
  UNION ALL
  SELECT 'BCS 1:1', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BCS', 1, 1, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 42, 2, 'SATURDAY 5TH DECEMBER', 'Fundamentals of Structured Programming / Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Dr. Namwano Sylvia/ Mr Segawa Andrew(M&K)'
  UNION ALL
  SELECT 'BCS 1:2', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BCS', 1, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 42, 2, 'SATURDAY 5TH DECEMBER', 'Fundamentals of Structured Programming / Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Dr. Namwano Sylvia/ Mr Segawa Andrew(M&K)'
  UNION ALL
  SELECT 'BIST 1:1', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BIST', 1, 1, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 42, 2, 'SATURDAY 5TH DECEMBER', 'Fundamentals of Structured Programming / Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Dr. Namwano Sylvia/ Mr Segawa Andrew(M&K)'
  UNION ALL
  SELECT 'BIST 1:2', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'BIST', 1, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 42, 2, 'SATURDAY 5TH DECEMBER', 'Fundamentals of Structured Programming / Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Dr. Namwano Sylvia/ Mr Segawa Andrew(M&K)'
  UNION ALL
  SELECT 'DCS 1:1', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'DCS', 1, 1, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 42, 2, 'SATURDAY 5TH DECEMBER', 'Fundamentals of Structured Programming / Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Dr. Namwano Sylvia/ Mr Segawa Andrew(M&K)'
  UNION ALL
  SELECT 'DCS 1:2', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'DCS', 1, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 42, 2, 'SATURDAY 5TH DECEMBER', 'Fundamentals of Structured Programming / Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Dr. Namwano Sylvia/ Mr Segawa Andrew(M&K)'
  UNION ALL
  SELECT 'DIST 1:1', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'DIST', 1, 1, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 42, 2, 'SATURDAY 5TH DECEMBER', 'Fundamentals of Structured Programming / Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Dr. Namwano Sylvia/ Mr Segawa Andrew(M&K)'
  UNION ALL
  SELECT 'DIST 1:2', 'Fundamentals of Structured Programming / Structured Programming', 'SCI', 'DIST', 1, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 42, 2, 'SATURDAY 5TH DECEMBER', 'Fundamentals of Structured Programming / Structured Programming (BIST 1:1, BIST 1:2, DIST 1:1, DIST 1:2, BCS 1:1, BCS 1:2, DCS 1:1, DCS 1:2, BCDF 1:1, BCDF 1:2) - Dr. Namwano Sylvia/ Mr Segawa Andrew(M&K)'
  UNION ALL
  SELECT 'BIST 3:1', 'BIST 3104 Enterprise Network Management', 'SCI', 'BIST', 3, 1, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 43, 2, 'SATURDAY 5TH DECEMBER', 'BIST 3104 Enterprise Network Management (BIST 3:1) - Mr. Kawuma Richard'
  UNION ALL
  SELECT 'BCDF 2:2', 'Operating Systems Forensics', 'SCI', 'BCDF', 2, 2, '2026-12-05', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 43, 4, 'SATURDAY 5TH DECEMBER', 'Operating Systems Forensics (BCDF 2:2) - Mr. Karim Abdu'
  UNION ALL
  SELECT 'BIST 2:2', 'BIST 2210 E-services / WordPress', 'SCI', 'BIST', 2, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 44, 2, 'SATURDAY 5TH DECEMBER', 'BIST 2210 E-services / WordPress (BIST 2:2, DIST 2:2) - Dr. Namara Khadija'
  UNION ALL
  SELECT 'DIST 2:2', 'BIST 2210 E-services / WordPress', 'SCI', 'DIST', 2, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 44, 2, 'SATURDAY 5TH DECEMBER', 'BIST 2210 E-services / WordPress (BIST 2:2, DIST 2:2) - Dr. Namara Khadija'
  UNION ALL
  SELECT 'SBA', 'Systems Analysis and Design', 'SCI', 'SBA', 0, 0, '2026-12-05', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 44, 4, 'SATURDAY 5TH DECEMBER', 'Systems Analysis and Design (SBA) - Mr. Ssenyomo Abubaker'
  UNION ALL
  SELECT 'BCS 3:2', 'BCS 3203 Computer Repair and Maintenance', 'SCI', 'BCS', 3, 2, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 48, 2, 'SUNDAY 6TH DECEMBER', 'BCS 3203 Computer Repair and Maintenance (BIST 3:1, BCS 3:2, DIT 2:1) - Mr. Sserunkuma Damian'
  UNION ALL
  SELECT 'BIST 3:1', 'BCS 3203 Computer Repair and Maintenance', 'SCI', 'BIST', 3, 1, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 48, 2, 'SUNDAY 6TH DECEMBER', 'BCS 3203 Computer Repair and Maintenance (BIST 3:1, BCS 3:2, DIT 2:1) - Mr. Sserunkuma Damian'
  UNION ALL
  SELECT 'DIT 2:1', 'BCS 3203 Computer Repair and Maintenance', 'SCI', 'DIT', 2, 1, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 48, 2, 'SUNDAY 6TH DECEMBER', 'BCS 3203 Computer Repair and Maintenance (BIST 3:1, BCS 3:2, DIT 2:1) - Mr. Sserunkuma Damian'
  UNION ALL
  SELECT 'BCDF 2:1', 'CDF 2102 Cryptography and Coding Theory', 'SCI', 'BCDF', 2, 1, '2026-12-06', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 48, 4, 'SUNDAY 6TH DECEMBER', 'CDF 2102 Cryptography and Coding Theory (BCDF 2:1) - Mr. Musasizi Timothy'
  UNION ALL
  SELECT 'BCDF 2:2', 'CDF 2201 Evidence Handling and Presentation', 'SCI', 'BCDF', 2, 2, '2026-12-06', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 49, 4, 'SUNDAY 6TH DECEMBER', 'CDF 2201 Evidence Handling and Presentation (BCDF 2:2) - Mr. Karim Abdu'
  UNION ALL
  SELECT 'BIST 3:2', 'IT Project Development and Management', 'SCI', 'BIST', 3, 2, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'BOTH', 'Weekend Timetable', 50, 2, 'SUNDAY 6TH DECEMBER', 'IT Project Development and Management (BIST 3:2) - Mr. Male Vincent to To be done by both day and weekend students on 6th November'
  UNION ALL
  SELECT 'BCDF 3:1', 'BIST 3201 Information Systems Audit', 'SCI', 'BCDF', 3, 1, '2026-12-06', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 50, 4, 'SUNDAY 6TH DECEMBER', 'BIST 3201 Information Systems Audit (BIST 3:2, BCDF 3:1) - Ms. Nasozi Betty'
  UNION ALL
  SELECT 'BIST 3:2', 'BIST 3201 Information Systems Audit', 'SCI', 'BIST', 3, 2, '2026-12-06', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 50, 4, 'SUNDAY 6TH DECEMBER', 'BIST 3201 Information Systems Audit (BIST 3:2, BCDF 3:1) - Ms. Nasozi Betty'
  UNION ALL
  SELECT 'BCDF 1:1', 'CDF 1104 Principles of Cybersecurity', 'SCI', 'BCDF', 1, 1, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 51, 2, 'SUNDAY 6TH DECEMBER', 'CDF 1104 Principles of Cybersecurity (BCDF 1:1) - Mr. Karim Abdu(M&K)'
  UNION ALL
  SELECT 'BCS 2:2', 'BCS 2205 Web Application Development / Website Development', 'SCI', 'BCS', 2, 2, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 52, 2, 'SUNDAY 6TH DECEMBER', 'BCS 2205 Web Application Development / Website Development (BCS 2:2, DCS 2:2, BIST 1:1, DIST 1:1) - Ms. Nasozi Betty'
  UNION ALL
  SELECT 'BIST 1:1', 'BCS 2205 Web Application Development / Website Development', 'SCI', 'BIST', 1, 1, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 52, 2, 'SUNDAY 6TH DECEMBER', 'BCS 2205 Web Application Development / Website Development (BCS 2:2, DCS 2:2, BIST 1:1, DIST 1:1) - Ms. Nasozi Betty'
  UNION ALL
  SELECT 'DCS 2:2', 'BCS 2205 Web Application Development / Website Development', 'SCI', 'DCS', 2, 2, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 52, 2, 'SUNDAY 6TH DECEMBER', 'BCS 2205 Web Application Development / Website Development (BCS 2:2, DCS 2:2, BIST 1:1, DIST 1:1) - Ms. Nasozi Betty'
  UNION ALL
  SELECT 'DIST 1:1', 'BCS 2205 Web Application Development / Website Development', 'SCI', 'DIST', 1, 1, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 52, 2, 'SUNDAY 6TH DECEMBER', 'BCS 2205 Web Application Development / Website Development (BCS 2:2, DCS 2:2, BIST 1:1, DIST 1:1) - Ms. Nasozi Betty'
  UNION ALL
  SELECT 'BCS 2:1', 'BCS 2101 Computer Algorithm', 'SCI', 'BCS', 2, 1, '2026-12-06', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 52, 4, 'SUNDAY 6TH DECEMBER', 'BCS 2101 Computer Algorithm (BCS 2:1, DCS 2:1) - Mr. Otemo Vincent'
  UNION ALL
  SELECT 'DCS 2:1', 'BCS 2101 Computer Algorithm', 'SCI', 'DCS', 2, 1, '2026-12-06', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 52, 4, 'SUNDAY 6TH DECEMBER', 'BCS 2101 Computer Algorithm (BCS 2:1, DCS 2:1) - Mr. Otemo Vincent'
  UNION ALL
  SELECT 'BCS 2:2', 'BCS 2201 Systems Programming', 'SCI', 'BCS', 2, 2, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 53, 2, 'SUNDAY 6TH DECEMBER', 'BCS 2201 Systems Programming (BCS 2:2, DCS 2:2) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'DCS 2:2', 'BCS 2201 Systems Programming', 'SCI', 'DCS', 2, 2, '2026-12-06', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 53, 2, 'SUNDAY 6TH DECEMBER', 'BCS 2201 Systems Programming (BCS 2:2, DCS 2:2) - Mr. Mulinde Hakimu'
  UNION ALL
  SELECT 'BCS 2:2', 'BCS 2202 Software Engineering / Principles of Software Engineering', 'SCI', 'BCS', 2, 2, '2026-12-06', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 53, 4, 'SUNDAY 6TH DECEMBER', 'BCS 2202 Software Engineering / Principles of Software Engineering (BCS 2:2, DCS 2:2, BIST 2:1, DIST 2:1) - Mr. Otemo Vincent'
  UNION ALL
  SELECT 'BIST 2:1', 'BCS 2202 Software Engineering / Principles of Software Engineering', 'SCI', 'BIST', 2, 1, '2026-12-06', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 53, 4, 'SUNDAY 6TH DECEMBER', 'BCS 2202 Software Engineering / Principles of Software Engineering (BCS 2:2, DCS 2:2, BIST 2:1, DIST 2:1) - Mr. Otemo Vincent'
  UNION ALL
  SELECT 'DCS 2:2', 'BCS 2202 Software Engineering / Principles of Software Engineering', 'SCI', 'DCS', 2, 2, '2026-12-06', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 53, 4, 'SUNDAY 6TH DECEMBER', 'BCS 2202 Software Engineering / Principles of Software Engineering (BCS 2:2, DCS 2:2, BIST 2:1, DIST 2:1) - Mr. Otemo Vincent'
  UNION ALL
  SELECT 'DIST 2:1', 'BCS 2202 Software Engineering / Principles of Software Engineering', 'SCI', 'DIST', 2, 1, '2026-12-06', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Weekend Timetable', 53, 4, 'SUNDAY 6TH DECEMBER', 'BCS 2202 Software Engineering / Principles of Software Engineering (BCS 2:2, DCS 2:2, BIST 2:1, DIST 2:1) - Mr. Otemo Vincent'
  UNION ALL
  SELECT 'MIST 1:1', 'MIST2111 Governance and Management of Information Systems SBA and and', 'SCI', 'MIST', 1, 1, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 8, 1, 'SATURDAY 21 st NOVEMBER', 'MIST2111 Governance & Management of Information Systems SBA& MIST 1:1 & MIST 1:2 Mr. Kawuma R 0777180016'
  UNION ALL
  SELECT 'MIST 1:2', 'MIST2111 Governance and Management of Information Systems SBA and and', 'SCI', 'MIST', 1, 2, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 8, 1, 'SATURDAY 21 st NOVEMBER', 'MIST2111 Governance & Management of Information Systems SBA& MIST 1:1 & MIST 1:2 Mr. Kawuma R 0777180016'
  UNION ALL
  SELECT 'MIST 2:1', 'MIST2211 Semantics of Web services Mr.Sserunkuma Damian 0700409097', 'SCI', 'MIST', 2, 1, '2026-11-21', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 8, 2, 'SATURDAY 21 st NOVEMBER', 'MIST2211 Semantics of Web services 2:1 Mr.Sserunkuma Damian 0700409097'
  UNION ALL
  SELECT 'MIST 2:2', 'Seminar Series', 'SCI', 'MIST', 2, 2, '2026-11-21', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 9, 1, 'SATURDAY 21 st NOVEMBER', 'Seminar Series MIST 2:2 Dr. Hilda Mpirirwe 0702116603'
  UNION ALL
  SELECT 'MIST 1:1', 'Human Computer Interaction and Ms.Kyomuhendo Charlotte 0784153648', 'SCI', 'MIST', 1, 1, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 12, 1, 'SUNDAY 22ND NOVEMBER', 'Human Computer Interaction MIST 1:1 & MIST 1:2 Ms.Kyomuhendo Charlotte 0784153648'
  UNION ALL
  SELECT 'MIST 1:2', 'Human Computer Interaction and Ms.Kyomuhendo Charlotte 0784153648', 'SCI', 'MIST', 1, 2, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 12, 1, 'SUNDAY 22ND NOVEMBER', 'Human Computer Interaction MIST 1:1 & MIST 1:2 Ms.Kyomuhendo Charlotte 0784153648'
  UNION ALL
  SELECT 'MIST 2:1', 'Digital Forensics', 'SCI', 'MIST', 2, 1, '2026-11-22', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 12, 2, 'SUNDAY 22ND NOVEMBER', 'Digital Forensics 2:1 Mr. Karim Abdu 0785295875'
  UNION ALL
  SELECT 'MIST 2:2', 'MIST2222 Consultancy Skills development Ms.Kyomuhendo Chalotte 0784153648', 'SCI', 'MIST', 2, 2, '2026-11-22', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 13, 1, 'SUNDAY 22ND NOVEMBER', 'MIST2222 Consultancy Skills development MIST 2:2 Ms.Kyomuhendo Chalotte 0784153648'
  UNION ALL
  SELECT 'MIST 1:1', 'MIST2112 Web Application Development and Mr.Sserunkuma Damian 0700409097', 'SCI', 'MIST', 1, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 15, 1, 'SATURDAY 28TH DECEMBER', 'MIST2112 Web Application Development MIST 1:1 & MIST 1:2 Mr.Sserunkuma Damian 0700409097'
  UNION ALL
  SELECT 'MIST 1:2', 'MIST2112 Web Application Development and Mr.Sserunkuma Damian 0700409097', 'SCI', 'MIST', 1, 2, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 15, 1, 'SATURDAY 28TH DECEMBER', 'MIST2112 Web Application Development MIST 1:1 & MIST 1:2 Mr.Sserunkuma Damian 0700409097'
  UNION ALL
  SELECT 'MIST 2:1', 'Mobile Application Development Mr.Sserunkuma Damian 0700409097', 'SCI', 'MIST', 2, 1, '2026-11-28', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 16, 1, 'SATURDAY 28TH DECEMBER', 'Mobile Application Development MIST 2:1 Mr.Sserunkuma Damian 0700409097'
  UNION ALL
  SELECT 'MIST 1:1', 'Advanced Database Management and Ms.Atuhairwe Rahab 0783635084', 'SCI', 'MIST', 1, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 19, 1, 'SUNDAY 29TH DECEMBER', 'Advanced Database Management MIST 1:1 & MIST 1:2 Ms.Atuhairwe Rahab 0783635084'
  UNION ALL
  SELECT 'MIST 1:2', 'Advanced Database Management and Ms.Atuhairwe Rahab 0783635084', 'SCI', 'MIST', 1, 2, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 19, 1, 'SUNDAY 29TH DECEMBER', 'Advanced Database Management MIST 1:1 & MIST 1:2 Ms.Atuhairwe Rahab 0783635084'
  UNION ALL
  SELECT 'MIST 2:2', 'Emerging Trends in Information Systems and Technology - Dr.Hilda Mpirirwe', 'SCI', 'MIST', 2, 2, '2026-11-29', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 19, 2, 'SUNDAY 29TH DECEMBER', 'Emerging Trends in Information Systems and Technology MIST 2:2- Dr.Hilda Mpirirwe'
  UNION ALL
  SELECT 'MIST 2:1', 'MIST2213 Project management and Control Mr.Male Vincent 0782188321', 'SCI', 'MIST', 2, 1, '2026-11-29', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 20, 1, 'SUNDAY 29TH DECEMBER', 'MIST2213 Project management and Control 2:1 Mr.Male Vincent 0782188321'
  UNION ALL
  SELECT 'MIST 2:1', 'MIST2212 Advanced Research Methods and Report Writing Dr.Golooba 0751050976', 'SCI', 'MIST', 2, 1, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 22, 1, 'SATURDAY 5TH DECEMBER', 'MIST2212 Advanced Research Methods and Report Writing 2:1 Dr.Golooba 0751050976'
  UNION ALL
  SELECT 'MIST 2:1', 'Simulation and Modelling Dr.Golooba 0751050976', 'SCI', 'MIST', 2, 1, '2026-12-05', '14:00:00', '17:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 22, 2, 'SATURDAY 5TH DECEMBER', 'Simulation and Modelling 2:1 Dr.Golooba 0751050976'
  UNION ALL
  SELECT 'MIST 1:1', 'MIST 2115 Distributed Data Mining and Mr.Ssemaganda Shruaim', 'SCI', 'MIST', 1, 1, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 23, 1, 'SATURDAY 5TH DECEMBER', 'MIST 2115 Distributed Data Mining MIST 1:1 & MIST 1:2 Mr.Ssemaganda Shruaim'
  UNION ALL
  SELECT 'MIST 1:2', 'MIST 2115 Distributed Data Mining and Mr.Ssemaganda Shruaim', 'SCI', 'MIST', 1, 2, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 23, 1, 'SATURDAY 5TH DECEMBER', 'MIST 2115 Distributed Data Mining MIST 1:1 & MIST 1:2 Mr.Ssemaganda Shruaim'
  UNION ALL
  SELECT 'MIST 1:1', 'Applied Object Oriented Programming and Mr.Sserunkuma Damian 0700409097', 'SCI', 'MIST', 1, 1, '2026-12-05', '09:00:00', '12:00:00', 'NOT SPECIFIED', 'WEEKEND', 'Masters', 25, 1, 'SATURDAY 5TH DECEMBER', 'Applied Object Oriented Programming MIST 1:1& 1:2 Mr.Sserunkuma Damian 0700409097'
) AS x
JOIN course_units cu
  ON cu.code = x.code AND cu.name = x.name AND cu.school = x.school
 AND cu.degree_program = x.degree_program AND cu.year_of_study = x.year_of_study
 AND cu.semester = x.semester;
