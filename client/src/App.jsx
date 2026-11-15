import { useCallback, useEffect, useRef, useState } from 'react';
import { api, clearSession, getToken, setSession } from './api';
import ChatPanel from './ChatPanel';
import { useToast } from './Toast';
import Avatar from './Avatar';

const SCHOOLS = ['SCI', 'SBA', 'SOSS', 'LAW', 'Nursing', 'EDU', 'Other'];
const ACADEMIC_LEVELS = ['Certificate', 'Diploma', 'Degree', 'Masters', 'PhD'];
const PROGRAM_MODES = ['DAY', 'WEEKEND', 'EVENING', 'DISTANCE'];
const WEEK_DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const APP_THEMES = [
  { id: 'blue', label: 'Ocean blue', color: '#1e3a8a' },
  { id: 'teal', label: 'Fresh teal', color: '#0f766e' },
  { id: 'purple', label: 'Royal purple', color: '#6d28d9' },
  { id: 'rose', label: 'Warm rose', color: '#be123c' }
];
const DEGREE_PROGRAMS = [
  // School of Computing (SCI)
  'BCS', 'BIST', 'DIST', 'BCDF', 'DCS', 'DIT', 'MIST', 'SCIAD',
  
  // School of Business Administration (SBA) - Degrees
  'BBA', 'BHRM', 'BPSM', 'BTHM', 'BRIM', 'BLIS', 'BIS',
  
  // School of Business Administration (SBA) - Diplomas
  'DBA', 'DAF', 'DHRM', 'DPSM', 'DTHM', 'DRIM',
  
  // SBA Certificates / Other
  'HCBM', 'NBCA',

  // Other Schools
  'SEDU', 'SLAW'
];

function useDebouncedValue(value, delay = 300) {
  const [debouncedValue, setDebouncedValue] = useState(value);
  useEffect(() => {
    const timer = window.setTimeout(() => setDebouncedValue(value), delay);
    return () => window.clearTimeout(timer);
  }, [value, delay]);
  return debouncedValue;
}

function base64UrlToUint8Array(value) {
  const padding = '='.repeat((4 - (value.length % 4)) % 4);
  const base64 = `${value}${padding}`.replace(/-/g, '+').replace(/_/g, '/');
  const raw = window.atob(base64);
  return Uint8Array.from(raw, (character) => character.charCodeAt(0));
}

function usePushNotifications(notify) {
  const [status, setStatus] = useState('checking');
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    let active = true;
    if (!('Notification' in window) || !('serviceWorker' in navigator) || !('PushManager' in window)) {
      setStatus('unsupported');
      return () => { active = false; };
    }
    if (Notification.permission === 'denied') {
      setStatus('denied');
      return () => { active = false; };
    }
    if (Notification.permission !== 'granted') {
      setStatus('disabled');
      return () => { active = false; };
    }
    navigator.serviceWorker.ready
      .then((registration) => registration.pushManager.getSubscription())
      .then((subscription) => {
        if (active) setStatus(subscription ? 'enabled' : 'disabled');
      })
      .catch(() => {
        if (active) setStatus('disabled');
      });
    return () => { active = false; };
  }, []);

  async function enable() {
    if (busy) return;
    setBusy(true);
    try {
      if (!('Notification' in window) || !('serviceWorker' in navigator) || !('PushManager' in window)) {
        setStatus('unsupported');
        throw new Error('Push notifications are not supported by this browser.');
      }
      const permission = Notification.permission === 'default'
        ? await Notification.requestPermission()
        : Notification.permission;
      if (permission !== 'granted') {
        setStatus(permission === 'denied' ? 'denied' : 'disabled');
        throw new Error(permission === 'denied'
          ? 'Notifications are blocked. Allow them in your browser settings to enable alerts.'
          : 'Notification permission was not granted.');
      }

      const { publicKey } = await api('/push/public-key');
      if (!publicKey) throw new Error('Push notifications are not configured on this server.');
      const registration = await navigator.serviceWorker.ready;
      const subscription = await registration.pushManager.getSubscription() ||
        await registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: base64UrlToUint8Array(publicKey)
        });
      await api('/push/subscribe', {
        method: 'POST',
        body: JSON.stringify(subscription.toJSON())
      });
      setStatus('enabled');
      notify('Push notifications enabled for this device.');
    } catch (error) {
      notify(error.message || 'Could not enable push notifications.', 'error');
    } finally {
      setBusy(false);
    }
  }

  return { status, busy, enable };
}

function SearchBar({ value, onChange, placeholder, label = 'Search' }) {
  return (
    <label className="search-bar">
      <svg className="search-icon" viewBox="0 0 24 24" aria-hidden="true">
        <circle cx="10.8" cy="10.8" r="6.8" />
        <path d="m16 16 5 5" />
      </svg>
      <input type="search" value={value} onChange={(event) => onChange(event.target.value)}
        placeholder={placeholder} aria-label={label} maxLength={100} />
      {value && (
        <button type="button" className="search-clear" onClick={() => onChange('')}
          aria-label="Clear search">×</button>
      )}
    </label>
  );
}

function Modal({ title, onClose, children, className = '' }) {
  return (
    <div className="modal-backdrop" role="presentation" onMouseDown={(event) => {
      if (event.target === event.currentTarget) onClose();
    }}>
      <section className={`modal feature-modal ${className}`} role="dialog" aria-modal="true"
        aria-label={title}>
        <button type="button" className="modal-close-button" aria-label="Close dialog"
          onClick={onClose}>×</button>
        {children}
      </section>
    </div>
  );
}

function StatusBadge({ status }) {
  return <span className={`status-badge status-${status.toLowerCase()}`}>{status}</span>;
}

function noSearchResults(search) {
  return <p className="search-empty muted">No results found for ‘{search}’. Try adjusting your search.</p>;
}

function formatDate(value) {
  return new Intl.DateTimeFormat(undefined, {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  }).format(new Date(`${value}T00:00:00`));
}

function formatTime(value) {
  return value.slice(0, 5);
}

function isClassOngoing(classSession) {
  if (!classSession?.startTime || !classSession?.endTime) return false;
  const toMinutes = (value) => {
    const [hours, minutes] = value.split(':').map(Number);
    return hours * 60 + minutes;
  };
  const now = new Date();
  const currentMinutes = now.getHours() * 60 + now.getMinutes();
  return currentMinutes >= toMinutes(classSession.startTime) &&
    currentMinutes <= toMinutes(classSession.endTime);
}

function formatChatPreviewTime(value) {
  if (!value) return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '';
  const sameDay = date.toDateString() === new Date().toDateString();
  return new Intl.DateTimeFormat(undefined, sameDay
    ? { hour: 'numeric', minute: '2-digit' }
    : { weekday: 'short' }).format(date);
}

async function downloadNote(note) {
  const token = getToken();
  const response = await fetch(`/api/notes/${note.id}/download`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.error || 'Could not download this file. Please try again.');
  }
  const blob = await response.blob();
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `${note.title || 'class-note'}${note.fileExtension || ''}`;
  document.body.append(link);
  link.click();
  link.remove();
  window.setTimeout(() => URL.revokeObjectURL(url), 1000);
}

function NotesList({ courseUnitId, lecturerMode = false }) {
  const [notes, setNotes] = useState([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [busyNoteId, setBusyNoteId] = useState(null);
  const notify = useToast();
  const debouncedSearch = useDebouncedValue(search);

  useEffect(() => {
    let active = true;
    setLoading(true);
    const endpoint = lecturerMode
      ? `/lecturer/notes?course_unit_id=${courseUnitId}&search=${encodeURIComponent(debouncedSearch)}`
      : `/notes/${courseUnitId}?search=${encodeURIComponent(debouncedSearch)}`;
    api(endpoint)
      .then((result) => {
        if (active) setNotes(result);
      })
      .catch((error) => {
        if (active) notify(error.message || 'Could not load class notes.', 'error');
      })
      .finally(() => {
        if (active) setLoading(false);
      });
    return () => { active = false; };
  }, [courseUnitId, debouncedSearch, lecturerMode, notify]);

  async function handleDownload(note) {
    setBusyNoteId(note.id);
    try {
      await downloadNote(note);
    } catch (error) {
      notify(error.message || 'Could not download this file.', 'error');
    } finally {
      setBusyNoteId(null);
    }
  }

  return (
    <section className="card notes-card">
      <h2>Class notes</h2>
      <SearchBar value={search} onChange={setSearch} placeholder="Search notes by title…" label="Search uploaded notes" />
      {loading ? (
        <div className="inline-loading"><span className="spinner" /> Loading notes…</div>
      ) : !notes.length ? (
        search ? noSearchResults(search) : <p className="muted small">No notes have been uploaded for this class yet.</p>
      ) : (
        <ul className="notes-list">
          {notes.map((note) => (
            <li key={note.id}>
              <button type="button" className="file-pill" onClick={() => handleDownload(note)}
                disabled={busyNoteId === note.id}>
                <span aria-hidden="true">📄</span>
                <span>{note.title}</span>
                {busyNoteId === note.id && <span className="spinner" aria-label="Downloading" />}
              </button>
              <time className="muted small">{new Date(note.uploadedAt).toLocaleDateString()}</time>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}

function groupExamSessions(exams) {
  const sessions = new Map();

  for (const exam of exams) {
    const key = [
      exam.examDate,
      exam.startTime,
      exam.endTime,
      exam.room.trim().toLocaleUpperCase()
    ].join('|');

    if (!sessions.has(key)) {
      sessions.set(key, {
        key,
        examDate: exam.examDate,
        startTime: exam.startTime,
        endTime: exam.endTime,
        room: exam.room,
        courses: []
      });
    }

    sessions.get(key).courses.push(exam);
  }

  return [...sessions.values()].sort((a, b) =>
    a.examDate.localeCompare(b.examDate) ||
    a.startTime.localeCompare(b.startTime) ||
    a.room.localeCompare(b.room)
  );
}

export default function App() {
  const initialRole = getToken() ? localStorage.getItem('role') : null;
  const [role, setRole] = useState(initialRole);

  function logout() {
    clearSession();
    setRole(null);
  }

  if (role === 'SUPER_ADMIN') return <SuperAdminApp onLogout={logout} />;
  if (role === 'SCHOOL_ADMIN') return <AdminApp onLogout={logout} />;
  if (role === 'EXAM_OFFICER') return <ExamOfficerApp onLogout={logout} />;
  if (role === 'COORDINATOR') return <CoordinatorApp onLogout={logout} />;
  if (role === 'student') return <StudentApp onLogout={logout} />;
  if (role === 'lecturer') return <LecturerApp onLogout={logout} />;
  return <AuthScreen onAuth={setRole} />;
}

function AuthScreen({ onAuth }) {
  const [tab, setTab] = useState('login');
  const [busy, setBusy] = useState(false);
  const notify = useToast();
  const [login, setLogin] = useState({ email: '', password: '' });
  const [registrationPrograms, setRegistrationPrograms] = useState([]);
  const [loadingRegistrationPrograms, setLoadingRegistrationPrograms] = useState(false);
  const [registration, setRegistration] = useState({
    firstName: '',
    lastName: '',
    studentNumber: '',
    academicLevel: 'Degree',
    program: 'DAY',
    school: 'SCI',
    degreeProgram: '',
    yearOfStudy: 1,
    semester: 1,
    phoneNumber: '',
    email: '',
    password: ''
  });

  useEffect(() => {
    if (tab !== 'register') return undefined;
    let active = true;
    setRegistrationPrograms([]);
    setLoadingRegistrationPrograms(true);
    api(`/registration-programs?school=${encodeURIComponent(registration.school)}&academicLevel=${encodeURIComponent(registration.academicLevel)}`)
      .then((programs) => {
        if (!Array.isArray(programs)) {
          throw new Error('The server returned an invalid degree program list.');
        }
        if (active) setRegistrationPrograms(programs);
      })
      .catch((error) => {
        if (active) notify(error.message || 'Could not load degree programs for this school.', 'error');
      })
      .finally(() => {
        if (active) setLoadingRegistrationPrograms(false);
      });
    return () => { active = false; };
  }, [tab, registration.school, registration.academicLevel, notify]);

  function changeTab(nextTab) {
    setTab(nextTab);
  }

  async function submit(event, endpoint, body, sessionRole) {
    event.preventDefault();
    setBusy(true);
    try {
      const result = await api(endpoint, {
        method: 'POST',
        body: JSON.stringify(body)
      });
      const authenticatedRole = sessionRole || result.role;
      if (!result.token || !['SUPER_ADMIN', 'SCHOOL_ADMIN', 'EXAM_OFFICER', 'COORDINATOR', 'student', 'lecturer'].includes(authenticatedRole)) {
        throw new Error('Sign-in response was invalid. Please try again.');
      }
      setSession(result.token, authenticatedRole);
      onAuth(authenticatedRole);
    } catch (requestError) {
      notify(requestError.message, 'error');
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="auth-page">
      <section className="card auth-card">
        <div className="brand-mark" aria-hidden="true">E</div>
        <h1>Exam Timetable</h1>
        <p className="muted">Your personalised exam schedule</p>

        <div className="tabs" role="tablist" aria-label="Account options">
          <button type="button" className={tab === 'login' ? 'tab active' : 'tab'} onClick={() => changeTab('login')}>Sign in</button>
          <button type="button" className={tab === 'register' ? 'tab active' : 'tab'} onClick={() => changeTab('register')}>Sign up</button>
        </div>

        {tab === 'login' && (
          <form className="form" onSubmit={(event) => submit(event, '/sign-in', login, null)}>
            <p className="muted small">Students, lecturers, coordinators, and administrators can sign in here.</p>
            <label>Email
              <input type="email" autoComplete="email" required value={login.email}
                onChange={(event) => setLogin({ ...login, email: event.target.value })} />
            </label>
            <label>Password
              <input type="password" autoComplete="current-password" required value={login.password}
                onChange={(event) => setLogin({ ...login, password: event.target.value })} />
            </label>
            <button className="btn primary" disabled={busy}>{busy ? 'Please wait…' : 'Sign in'}</button>
          </form>
        )}

        {tab === 'register' && (
          <form className="form" onSubmit={(event) => submit(event, '/register', registration, 'student')}>
            <div className="row">
              <label>First name
                <input autoComplete="given-name" required value={registration.firstName}
                  onChange={(event) => setRegistration({ ...registration, firstName: event.target.value })} />
              </label>
              <label>Last name
                <input autoComplete="family-name" required value={registration.lastName}
                  onChange={(event) => setRegistration({ ...registration, lastName: event.target.value })} />
              </label>
            </div>
            <label>Student number
              <input required value={registration.studentNumber}
                onChange={(event) => setRegistration({ ...registration, studentNumber: event.target.value })} />
            </label>
            <div className="row">
              <label>Academic level
                <select value={registration.academicLevel}
                  onChange={(event) => {
                    setRegistration({
                      ...registration,
                      academicLevel: event.target.value,
                      degreeProgram: ''
                    });
                    setRegistrationPrograms([]);
                    setLoadingRegistrationPrograms(true);
                  }}>
                  {ACADEMIC_LEVELS.map((level) => <option key={level} value={level}>{level}</option>)}
                </select>
              </label>
              <label>Program mode
                <select value={registration.program}
                  onChange={(event) => setRegistration({ ...registration, program: event.target.value })}>
                  {PROGRAM_MODES.map((mode) => (
                    <option key={mode} value={mode}>{mode.charAt(0) + mode.slice(1).toLowerCase()}</option>
                  ))}
                </select>
              </label>
              <label>School
                <select value={registration.school}
                  onChange={(event) => {
                    setRegistration({
                      ...registration,
                      school: event.target.value,
                      degreeProgram: ''
                    });
                    setRegistrationPrograms([]);
                    setLoadingRegistrationPrograms(true);
                  }}>
                  {SCHOOLS.map((school) => <option key={school} value={school}>{school}</option>)}
                </select>
              </label>
            </div>
            <label>Degree program
              <select required value={registration.degreeProgram}
                disabled={loadingRegistrationPrograms || !registrationPrograms.length}
                onChange={(event) => setRegistration({ ...registration, degreeProgram: event.target.value })}>
                <option value="">
                  {loadingRegistrationPrograms ? 'Loading programs…' : 'Select a degree program'}
                </option>
                {registrationPrograms.map((degree) => (
                  <option key={degree} value={degree}>{degree}</option>
                ))}
              </select>
              {!loadingRegistrationPrograms && !registrationPrograms.length && (
                <span className="muted small">No degree programs are listed for this school yet.</span>
              )}
            </label>
            <div className="row">
              <label>Year
                <select value={registration.yearOfStudy}
                  onChange={(event) => setRegistration({ ...registration, yearOfStudy: Number(event.target.value) })}>
                  {[1, 2, 3, 4, 5].map((year) => <option key={year} value={year}>Year {year}</option>)}
                </select>
              </label>
              <label>Semester
                <select value={registration.semester}
                  onChange={(event) => setRegistration({ ...registration, semester: Number(event.target.value) })}>
                  <option value={1}>Semester 1</option>
                  <option value={2}>Semester 2</option>
                </select>
              </label>
            </div>
            <label>Phone Number
              <input type="tel" autoComplete="tel" required maxLength={20}
                placeholder="+256 7XX XXX XXX" value={registration.phoneNumber}
                onChange={(event) => setRegistration({ ...registration, phoneNumber: event.target.value })} />
            </label>
            <label>Email
              <input type="email" autoComplete="email" required value={registration.email}
                onChange={(event) => setRegistration({ ...registration, email: event.target.value })} />
            </label>
            <label>Password
              <input type="password" autoComplete="new-password" minLength={6} required value={registration.password}
                onChange={(event) => setRegistration({ ...registration, password: event.target.value })} />
            </label>
            <button className="btn primary"
              disabled={busy || loadingRegistrationPrograms || !registrationPrograms.length || !registration.degreeProgram}>
              {busy ? 'Creating account…' : 'Create account'}
            </button>
          </form>
        )}

      </section>
    </main>
  );
}

function StudentApp({ onLogout }) {
  const [student, setStudent] = useState(null);
  const [units, setUnits] = useState([]);
  const [courseUnitResults, setCourseUnitResults] = useState([]);
  const [classes, setClasses] = useState([]);
  const [exams, setExams] = useState([]);
  const [tab, setTab] = useState('exams');
  const [courseChatId, setCourseChatId] = useState('');
  const [chatPageOpen, setChatPageOpen] = useState(false);
  const [chatSelected, setChatSelected] = useState(false);
  const [chatPreviews, setChatPreviews] = useState({});
  const [chatUnreadCounts, setChatUnreadCounts] = useState({});
  const [unreadCount, setUnreadCount] = useState(0);
  const [checkinClass, setCheckinClass] = useState(null);
  const [checkinCode, setCheckinCode] = useState('');
  const [checkingIn, setCheckingIn] = useState(false);
  const [profileMenuOpen, setProfileMenuOpen] = useState(false);
  const [appTheme, setAppTheme] = useState(() => {
    const savedTheme = localStorage.getItem('appTheme');
    return APP_THEMES.some((theme) => theme.id === savedTheme) ? savedTheme : 'blue';
  });
  const [examSearch, setExamSearch] = useState('');
  const [classSearch, setClassSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [busyUnitId, setBusyUnitId] = useState(null);
  const [busyRegistrationId, setBusyRegistrationId] = useState(null);
  const [unitSearch, setUnitSearch] = useState('');
  const debouncedExamSearch = useDebouncedValue(examSearch);
  const debouncedUnitSearch = useDebouncedValue(unitSearch);
  const [uploadingPicture, setUploadingPicture] = useState(false);
  const [deletingAccount, setDeletingAccount] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const notify = useToast();
  const pushNotifications = usePushNotifications(notify);
  const unreadErrorShown = useRef(false);
  const profileMenuRef = useRef(null);
  const profilePictureInputRef = useRef(null);
  const classRoomSnapshot = useRef(null);

  useEffect(() => {
    document.documentElement.dataset.theme = appTheme;
    localStorage.setItem('appTheme', appTheme);
  }, [appTheme]);

  useEffect(() => {
    if (!profileMenuOpen) return undefined;
    function closeMenu(event) {
      if (event.type === 'keydown' && event.key !== 'Escape') return;
      if (event.type === 'pointerdown' && profileMenuRef.current?.contains(event.target)) return;
      setProfileMenuOpen(false);
    }

    document.addEventListener('pointerdown', closeMenu);
    document.addEventListener('keydown', closeMenu);
    return () => {
      document.removeEventListener('pointerdown', closeMenu);
      document.removeEventListener('keydown', closeMenu);
    };
  }, [profileMenuOpen]);

  const refreshChatUnread = useCallback(async () => {
    try {
      const result = await api('/chat/unread');
      setChatUnreadCounts(result.rooms || {});
      setUnreadCount(Number(result.total) || 0);
      unreadErrorShown.current = false;
    } catch (error) {
      if (!unreadErrorShown.current) {
        notify(error.message || 'Could not load unread chat counts.', 'error');
        unreadErrorShown.current = true;
      }
    }
  }, [notify]);

  useEffect(() => {
    refreshChatUnread();
    const timer = window.setInterval(refreshChatUnread, 15000);
    return () => window.clearInterval(timer);
  }, [refreshChatUnread]);

  async function load() {
    setLoading(true);
    try {
      const [profile, availableUnits, matchingUnits, scheduledExams, classSchedule] = await Promise.all([
        api('/me'),
        api('/course-units'),
        api(`/course-units?search=${encodeURIComponent(debouncedUnitSearch)}`),
        api(`/exams?search=${encodeURIComponent(debouncedExamSearch)}`),
        api('/classes')
      ]);
      setStudent(profile);
      setUnits(availableUnits);
      setCourseUnitResults(matchingUnits);
      setExams(scheduledExams);
      setClasses(classSchedule);
      classRoomSnapshot.current = Object.fromEntries(classSchedule
        .filter((classSession) => classSession.id)
        .map((classSession) => [classSession.id, classSession.room]));
    } catch (requestError) {
      if (requestError.message === 'Invalid session' || requestError.message === 'Not logged in') {
        onLogout();
        return;
      }
      notify(requestError.message, 'error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  useEffect(() => {
    let active = true;
    api(`/exams?search=${encodeURIComponent(debouncedExamSearch)}`)
      .then((result) => { if (active) setExams(result); })
      .catch((error) => { if (active) notify(error.message || 'Could not search exams.', 'error'); });
    return () => { active = false; };
  }, [debouncedExamSearch, notify]);

  useEffect(() => {
    if (!student) return undefined;
    let active = true;
    const refreshClasses = async () => {
      try {
        const result = await api('/classes');
        if (!active) return;
        const nextRooms = Object.fromEntries(result
          .filter((classSession) => classSession.id)
          .map((classSession) => [classSession.id, classSession.room]));
        if (classRoomSnapshot.current) {
          result.forEach((classSession) => {
            const previousRoom = classRoomSnapshot.current[classSession.id];
            if (previousRoom && classSession.room && previousRoom !== classSession.room) {
              notify(`${classSession.code} room changed: ${previousRoom} → ${classSession.room}`);
            }
          });
        }
        classRoomSnapshot.current = nextRooms;
        setClasses(result);
      } catch (error) {
        if (active) notify(error.message || 'Could not refresh your lecture schedule.', 'error');
      }
    };
    const timer = window.setInterval(refreshClasses, 15000);
    return () => {
      active = false;
      window.clearInterval(timer);
    };
  }, [student?.id, notify]);

  useEffect(() => {
    let active = true;
    api(`/course-units?search=${encodeURIComponent(debouncedUnitSearch)}`)
      .then((result) => { if (active) setCourseUnitResults(result); })
      .catch((error) => { if (active) notify(error.message || 'Could not search course units.', 'error'); });
    return () => { active = false; };
  }, [debouncedUnitSearch, notify]);

  async function toggleRegistration(unit) {
    setBusyUnitId(unit.id);
    try {
      if (unit.registered) {
        await api(`/registrations/${unit.id}`, { method: 'DELETE' });
      } else {
        await api('/registrations', {
          method: 'POST',
          body: JSON.stringify({ courseUnitId: unit.id })
        });
      }
      await load();
      notify(unit.registered ? 'Course unit removed.' : 'Course unit registered.');
    } catch (requestError) {
      notify(requestError.message, 'error');
    } finally {
      setBusyUnitId(null);
    }
  }

  async function markExamDone(exam) {
    setBusyRegistrationId(exam.registrationId);
    try {
      const result = await api(`/registrations/${exam.registrationId}/complete`, {
        method: 'PUT',
        body: JSON.stringify({ isCompleted: true })
      });
      setExams((current) => current.map((item) =>
        item.registrationId === exam.registrationId
          ? { ...item, isCompleted: result.isCompleted }
          : item
      ));
      notify('Exam marked as done.');
    } catch (requestError) {
      notify(requestError.message || 'Could not update exam status. Please try again.', 'error');
    } finally {
      setBusyRegistrationId(null);
    }
  }

  async function checkInToClass() {
    if (!checkinClass || checkingIn) return;
    setCheckingIn(true);
    try {
      await api('/student/check-in', {
        method: 'POST',
        body: JSON.stringify({
          scheduleId: checkinClass.id,
          sessionCode: checkinCode.trim()
        })
      });
      setClasses((current) => current.map((classSession) =>
        classSession.id === checkinClass.id
          ? { ...classSession, attendanceStatus: 'PRESENT' }
          : classSession
      ));
      setCheckinClass(null);
      setCheckinCode('');
      notify('Attendance marked present.');
    } catch (error) {
      notify(error.message || 'Could not check in to this class.', 'error');
    } finally {
      setCheckingIn(false);
    }
  }

  async function uploadProfilePicture(event) {
    const input = event.currentTarget;
    const file = input.files?.[0];
    if (!file) return;
    input.value = '';

    if (!['image/png', 'image/jpeg', 'image/webp', 'image/gif', 'image/avif'].includes(file.type)) {
      notify('Choose a PNG, JPEG, WebP, GIF, or AVIF image.', 'error');
      return;
    }
    if (file.size > 2 * 1024 * 1024) {
      notify('Profile pictures must be 2 MB or smaller.', 'error');
      return;
    }

    setUploadingPicture(true);
    try {
      const profilePicture = await new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => {
          if (typeof reader.result === 'string') resolve(reader.result);
          else reject(new Error('Could not read the selected image.'));
        };
        reader.onerror = () => reject(new Error('Could not read the selected image.'));
        reader.readAsDataURL(file);
      });
      const result = await api('/me/avatar', {
        method: 'PUT',
        body: JSON.stringify({ profilePicture })
      });
      setStudent((current) => ({ ...current, profilePicture: result.profilePicture }));
      notify('Profile picture updated.');
    } catch (requestError) {
      notify(requestError.message, 'error');
    } finally {
      setUploadingPicture(false);
    }
  }

  async function deleteAccount() {
    setDeletingAccount(true);
    try {
      await api('/me', { method: 'DELETE' });
      clearSession();
      notify('Your account has been permanently deleted.');
      onLogout();
    } catch (requestError) {
      notify(requestError.message, 'error');
      setDeletingAccount(false);
    }
  }

  const matchingCourseChats = student
    ? units.filter((unit) => unit.registered)
    : [];
  const chatCourseIds = matchingCourseChats.map((unit) => unit.id).join(',');

  useEffect(() => {
    if (!chatPageOpen || !student) return undefined;
    let active = true;

    async function refreshPreviews() {
      const rooms = [
        { id: 'general', endpoint: '/messages' },
        ...matchingCourseChats.map((unit) => ({
          id: `course-${unit.id}`,
          endpoint: `/messages?course_unit_id=${encodeURIComponent(unit.id)}`
        }))
      ];
      const results = await Promise.allSettled(rooms.map((room) => api(room.endpoint)));
      if (!active) return;

      const previews = {};
      let failed = false;
      results.forEach((result, index) => {
        if (result.status === 'fulfilled') {
          const messages = result.value;
          previews[rooms[index].id] = messages.length ? messages[messages.length - 1] : null;
        } else {
          failed = true;
        }
      });
      setChatPreviews(previews);
      if (failed) notify('Some chat previews could not be loaded.', 'error');
    }

    refreshPreviews();
    const timer = window.setInterval(refreshPreviews, 30000);
    return () => {
      active = false;
      window.clearInterval(timer);
    };
  }, [chatPageOpen, student?.id, chatCourseIds, notify]);

  if (loading && !student) {
    return <main className="page"><div className="loading-state"><span className="spinner" /> Loading your timetable…</div></main>;
  }

  if (!student) {
    return (
      <main className="page">
        <div className="empty">
          <h2>We couldn’t load your timetable</h2>
          <p className="muted">Please check your connection and try again.</p>
          <button type="button" className="btn primary" onClick={load} disabled={loading}>
            {loading ? 'Loading…' : 'Try again'}
          </button>
        </div>
      </main>
    );
  }

  const examsByDate = groupExamSessions(exams).reduce((groups, session) => {
    groups[session.examDate] = groups[session.examDate] || [];
    groups[session.examDate].push(session);
    return groups;
  }, {});
  const sortedExamDates = Object.keys(examsByDate).sort();
  const today = new Date();
  const todayDay = new Intl.DateTimeFormat(undefined, { weekday: 'long' }).format(today);
  const todayDate = [
    today.getFullYear(),
    String(today.getMonth() + 1).padStart(2, '0'),
    String(today.getDate()).padStart(2, '0')
  ].join('-');
  const todayClasses = classes.filter((classSession) =>
    classSession.dayOfWeek === todayDay && classSession.startTime
  );
  const todayExams = exams.filter((exam) => exam.examDate === todayDate);
  const todaySchedule = [
    ...todayClasses.map((classSession) => ({ ...classSession, type: 'lecture' })),
    ...todayExams.map((exam) => ({ ...exam, type: 'exam' }))
  ].sort((first, second) =>
    (first.type === 'exam' ? 0 : 1) - (second.type === 'exam' ? 0 : 1) ||
    first.startTime.localeCompare(second.startTime)
  );
  const visibleClasses = classes.filter((classSession) => {
    const search = classSearch.trim().toLowerCase();
    return !search || [
      classSession.code, classSession.courseName, classSession.lecturerName,
      classSession.room, classSession.dayOfWeek
    ].some((value) => String(value || '').toLowerCase().includes(search));
  });
  const classGroups = WEEK_DAYS.map((day) => ({
    day,
    sessions: visibleClasses.filter((classSession) => classSession.dayOfWeek === day)
  })).filter((group) => group.sessions.length);
  const unscheduledClasses = visibleClasses.filter((classSession) => !classSession.dayOfWeek);
  const normalizedUnitSearch = unitSearch.trim();
  const visibleUnits = courseUnitResults;
  const selectedChatCourse = matchingCourseChats.find((unit) => String(unit.id) === courseChatId);

  return (
    <main className="page">
      <header className="topbar">
        <div>
          <div className="hello">Hi, {student?.firstName || 'Student'}</div>
          {student && <div className="muted small">
            {student.studentNumber} · {student.school} · {student.academicLevel} · Year {student.yearOfStudy} · Semester {student.semester}
          </div>}
        </div>
        <div className="topbar-actions">
          <button type="button" className="btn ghost chats-nav-button"
            onClick={() => {
              setTab('exams');
              setCourseChatId('');
              setChatSelected(false);
              setChatPageOpen(true);
            }}>
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M20 11.5a7.5 7.5 0 0 1-7.5 7.5H6l-3 2v-5.5A7.5 7.5 0 0 1 4.5 5h8A7.5 7.5 0 0 1 20 11.5Z" />
              <path d="M8 11h.01M12 11h.01M16 11h.01" />
            </svg>
            Chats
            {unreadCount > 0 && (
              <span className="chat-unread-badge" aria-label={`${unreadCount} unread messages`}>
                {unreadCount > 99 ? '99+' : unreadCount}
              </span>
            )}
          </button>
          <div className="student-menu-anchor" ref={profileMenuRef}>
            <button type="button" className="student-menu-toggle"
              aria-label="Open profile and settings menu"
              aria-haspopup="menu" aria-expanded={profileMenuOpen}
              onClick={() => setProfileMenuOpen((open) => !open)}>
              <Avatar
                src={student.profilePicture}
                name={`${student.firstName} ${student.lastName}`}
                className="topbar-avatar"
              />
              <span className="student-menu-dots" aria-hidden="true">⋮</span>
            </button>
            {profileMenuOpen && (
              <div className="student-menu-popover" role="menu" aria-label="Profile and settings">
                <div className="student-menu-identity">
                  <strong>{student.firstName} {student.lastName}</strong>
                  <span>{student.studentNumber}</span>
                </div>
                <div className="student-menu-theme">
                  <span className="student-menu-section-label">App colour theme</span>
                  <div className="theme-options" role="group" aria-label="Choose app colour theme">
                    {APP_THEMES.map((theme) => (
                      <button type="button" key={theme.id}
                        className={`theme-option${appTheme === theme.id ? ' selected' : ''}`}
                        style={{ '--theme-swatch': theme.color }}
                        aria-label={theme.label}
                        aria-pressed={appTheme === theme.id}
                        onClick={() => setAppTheme(theme.id)}>
                        <span />
                      </button>
                    ))}
                  </div>
                </div>
                <input ref={profilePictureInputRef} className="student-menu-file-input"
                  type="file" accept="image/*" onChange={uploadProfilePicture}
                  disabled={uploadingPicture} aria-label="Upload profile photo" />
                <button type="button" className="student-menu-item" role="menuitem"
                  disabled={uploadingPicture}
                  onClick={() => profilePictureInputRef.current?.click()}>
                  <span aria-hidden="true">▧</span>
                  {uploadingPicture ? 'Uploading photo…' : 'Upload profile photo'}
                </button>
                <button type="button" className="student-menu-item" role="menuitem"
                  onClick={() => { setTab('units'); setProfileMenuOpen(false); }}>
                  <span aria-hidden="true">＋</span>
                  Register for courses
                </button>
                <button type="button" className="student-menu-item" role="menuitem"
                  onClick={() => { setTab('profile'); setProfileMenuOpen(false); }}>
                  <span aria-hidden="true">⚙</span>
                  Settings
                </button>
                <div className="student-menu-divider" />
                <button type="button" className="student-menu-item logout"
                  role="menuitem" onClick={onLogout}>
                  <span aria-hidden="true">↪</span>
                  Log out
                </button>
              </div>
            )}
          </div>
        </div>
      </header>

      {student && (
        <div className="degree-summary">
          <span>Showing exams for</span>
          <strong>{student.academicLevel} · {student.degreeProgram} · {student.program} · Year {student.yearOfStudy} · Semester {student.semester}</strong>
        </div>
      )}

      <section className="card today-schedule-card" aria-labelledby="today-schedule-title">
        <div className="today-schedule-heading">
          <div>
            <span className="eyebrow">Daily overview</span>
            <h2 id="today-schedule-title">Today’s Schedule</h2>
          </div>
          <time>{new Intl.DateTimeFormat(undefined, {
            weekday: 'long', day: 'numeric', month: 'long'
          }).format(today)}</time>
        </div>
        {!todaySchedule.length ? (
          <p className="muted small">No lectures or exams scheduled for today.</p>
        ) : (
          <div className="today-schedule-list">
            {todaySchedule.map((item) => (
              <article className={`today-schedule-item ${item.type}`} key={`${item.type}-${item.id}`}>
                <time>{formatTime(item.startTime)}–{formatTime(item.endTime)}</time>
                <div>
                  {item.type === 'exam' && <b className="today-exam-alert">EXAM TODAY</b>}
                  <strong>{item.type === 'exam' ? `${item.code} — ${item.courseName}` : item.courseName}</strong>
                  <span>{item.type === 'exam' ? `Room/Hall: ${item.room}` : `Lecture · ${item.room}`}</span>
                  {item.lecturerName && <b>Lecturer: {item.lecturerName}</b>}
                  {item.type === 'lecture' && item.attendanceStatus && (
                    <span className={`attendance-marked-badge ${item.attendanceStatus.toLowerCase()}`}>
                      {item.attendanceStatus === 'PRESENT'
                        ? 'Attendance marked · Present'
                        : item.attendanceStatus === 'LATE'
                          ? 'Attendance marked · Late'
                          : 'Marked absent'}
                    </span>
                  )}
                  {item.type === 'lecture' && !item.attendanceStatus && isClassOngoing(item) && (
                    <button type="button" className="btn primary small check-in-button"
                      onClick={() => { setCheckinClass(item); setCheckinCode(''); }}>
                      Check-in to Class
                    </button>
                  )}
                </div>
              </article>
            ))}
          </div>
        )}
      </section>

      <div className="tabs" role="tablist" aria-label="Student timetable">
        <button type="button" className={tab === 'exams' ? 'tab active' : 'tab'} onClick={() => setTab('exams')}>My exams</button>
        <button type="button" className={tab === 'classes' ? 'tab active' : 'tab'} onClick={() => setTab('classes')}>My Lectures</button>
      </div>

      {loading && <div className="inline-loading"><span className="spinner" /> Updating your timetable…</div>}

      {chatPageOpen && (
        <section className="student-chat-workspace" aria-label="Chats">
          <aside className={`chat-sidebar${chatSelected ? ' conversation-active' : ''}`}>
            <header className="chat-sidebar-header">
              <button type="button" className="chat-dashboard-back"
                onClick={() => setChatPageOpen(false)} aria-label="Back to dashboard">
                <span aria-hidden="true">←</span>
                <span>Dashboard</span>
              </button>
              <div className="chat-sidebar-title">
                <h1>Chats</h1>
                <span>{matchingCourseChats.length + 1} conversations</span>
              </div>
            </header>
            <div className="chat-room-list">
              <button type="button"
                className={`chat-room-option chat-list-item${chatSelected && !courseChatId ? ' active' : ''}`}
                onClick={() => { setCourseChatId(''); setChatSelected(true); }}>
                <span className="chat-room-icon" aria-hidden="true">G</span>
                <span className="chat-room-copy">
                  <span className="chat-room-title">
                    <strong>General {student.school} Chat</strong>
                    {chatUnreadCounts.general > 0 && (
                      <span className="chat-unread-badge">{chatUnreadCounts.general}</span>
                    )}
                  </span>
                  <span>{chatPreviews.general?.text || 'Your school group and university updates'}</span>
                </span>
                <time>{formatChatPreviewTime(chatPreviews.general?.createdAt)}</time>
              </button>
              {matchingCourseChats.map((unit) => {
                const preview = chatPreviews[`course-${unit.id}`];
                return (
                  <button type="button"
                    className={`chat-room-option chat-list-item${chatSelected && courseChatId === String(unit.id) ? ' active' : ''}`}
                    key={unit.id}
                    onClick={() => { setCourseChatId(String(unit.id)); setChatSelected(true); }}>
                    <span className="chat-room-icon course" aria-hidden="true">C</span>
                    <span className="chat-room-copy">
                      <span className="chat-room-title">
                        <strong>{unit.code} — {unit.name}</strong>
                        {chatUnreadCounts[`course-${unit.id}`] > 0 && (
                          <span className="chat-unread-badge">
                            {chatUnreadCounts[`course-${unit.id}`]}
                          </span>
                        )}
                      </span>
                      <span>{preview?.isBroadcast ? '📣 ' : ''}{preview?.text || 'Class chat · Start a conversation'}</span>
                    </span>
                    <time>{formatChatPreviewTime(preview?.createdAt)}</time>
                  </button>
                );
              })}
              {!matchingCourseChats.length && (
                <p className="chat-list-empty">Course chats appear here when you register for course units.</p>
              )}
            </div>
          </aside>
          <div className={`chat-conversation${chatSelected ? ' active' : ''}`}>
            {!chatSelected ? (
              <div className="chat-welcome">
                <span className="chat-welcome-icon" aria-hidden="true">✉</span>
                <h2>Welcome to your chats</h2>
                <p>Select a conversation to start messaging with your school or course groups.</p>
              </div>
            ) : (
              <>
                <header className="chat-conversation-header">
                  <button type="button" className="chat-mobile-back"
                    onClick={() => setChatSelected(false)} aria-label="Back to chat list">
                    ←
                  </button>
                  <span className={`chat-room-icon${courseChatId ? ' course' : ''}`} aria-hidden="true">
                    {courseChatId ? 'C' : 'G'}
                  </span>
                  <div>
                    <strong>{selectedChatCourse
                      ? `${selectedChatCourse.code} — ${selectedChatCourse.name}`
                      : `General ${student.school} Chat`}</strong>
                    <span>{selectedChatCourse
                      ? 'Course discussion'
                      : `${student.school} · ${student.degreeProgram} · Year ${student.yearOfStudy}`}</span>
                  </div>
                </header>
                {courseChatId && !selectedChatCourse ? (
                  <p className="chat-list-empty">This course chat is not available for your registered courses.</p>
                ) : (
                  <ChatPanel
                    key={courseChatId ? `student-class-${courseChatId}` : 'student-general-chat'}
                    student={student}
                    courseUnit={selectedChatCourse}
                    onRead={refreshChatUnread}
                    fullPage
                  />
                )}
              </>
            )}
          </div>
        </section>
      )}

      {tab === 'classes' && (
        <section className="card class-schedule-card">
          <h2>My Lecture Timetable</h2>
          <SearchBar value={classSearch} onChange={setClassSearch}
            placeholder="Search course, lecturer, or room…" label="Search my classes" />
          {!visibleClasses.length ? (
            classSearch ? noSearchResults(classSearch) : (
              <p className="muted">Register for course units to see your weekly lecture timetable here.</p>
            )
          ) : (
            <div className="lecture-timetable">
              {classGroups.map((group) => (
                <section className="lecture-day-group" key={group.day}>
                  <h3>{group.day}</h3>
                  <div className="class-schedule-list">
                    {group.sessions.map((classSession) => (
                      <article className="class-schedule-item lecture-card" key={classSession.id}>
                        <time className="lecture-time">
                          {formatTime(classSession.startTime)}–{formatTime(classSession.endTime)}
                        </time>
                        <div className="class-info">
                          <strong>{classSession.code} — {classSession.courseName}</strong>
                          <span>Room: {classSession.room}</span>
                          {classSession.lecturerName && (
                            <b className="lecture-lecturer">Lecturer: {classSession.lecturerName}</b>
                          )}
                        </div>
                      </article>
                    ))}
                  </div>
                </section>
              ))}
              {unscheduledClasses.length > 0 && (
                <section className="lecture-day-group">
                  <h3>Schedule pending</h3>
                  <div className="class-schedule-list">
                    {unscheduledClasses.map((classSession) => (
                      <article className="class-schedule-item lecture-card" key={`pending-${classSession.courseUnitId}`}>
                        <div className="class-info">
                          <strong>{classSession.code} — {classSession.courseName}</strong>
                          <span className="muted small">Weekly time and room have not been posted yet.</span>
                          {classSession.lecturerName && (
                            <b className="lecture-lecturer">Lecturer: {classSession.lecturerName}</b>
                          )}
                        </div>
                      </article>
                    ))}
                  </div>
                </section>
              )}
            </div>
          )}
        </section>
      )}

      {tab === 'exams' && (
        <section>
          <SearchBar value={examSearch} onChange={setExamSearch}
            placeholder="Search course, code, or room…" label="Search my exams" />
          {!exams.length ? (
            examSearch ? noSearchResults(examSearch) : (
            <div className="empty">
              <h2>No exams yet</h2>
              <p className="muted">Register for your course units to see their exam dates here.</p>
              <button type="button" className="btn primary" onClick={() => setTab('units')}>Choose course units</button>
            </div>
            )
          ) : sortedExamDates.map((date) => (
            <div key={date} className="day-group">
              <h2>{formatDate(date)}</h2>
              {examsByDate[date].map((session) => (
                <ExamSessionCard
                  key={session.key}
                  session={session}
                  onComplete={markExamDone}
                  busyRegistrationId={busyRegistrationId}
                />
              ))}
            </div>
          ))}
        </section>
      )}

      {tab === 'units' && (
        <section className="card">
          <h2>Find and register for course units</h2>
          <p className="muted small">Search course units by code or name, then select Register. You can search units from any year or semester.</p>
          <SearchBar value={unitSearch} onChange={setUnitSearch}
            placeholder="Search course code or name…" label="Search course units" />
          <p className="course-unit-count muted small" aria-live="polite">
            {normalizedUnitSearch
              ? `${visibleUnits.length} matching ${visibleUnits.length === 1 ? 'course unit' : 'course units'}`
              : `${units.length} ${units.length === 1 ? 'course unit' : 'course units'} available`}
          </p>
          {!units.length && (unitSearch
            ? noSearchResults(unitSearch)
            : <p className="muted">No course units have been added for your school yet.</p>)}
          <div className="unit-list">
            {visibleUnits.map((unit) => {
              const year = Number(unit.yearOfStudy);
              const semester = Number(unit.semester);
              const outsideDefaultYear = year > 0 && year !== Number(student.yearOfStudy);
              const outsideDefaultSemester = semester > 0 && semester !== Number(student.semester);
              return (
                <div className={`unit-row${unit.registered ? ' registered' : ''}`} key={unit.id}>
                  <div className="unit-row-details">
                    <strong>{unit.code}</strong>
                    <div className="muted small">{unit.name}</div>
                    <div className="unit-level-badges">
                      <span className="unit-level-badge">{unit.academicLevel}</span>
                      <span className={`unit-level-badge${outsideDefaultYear ? ' outside-default' : ''}`}>
                        {year ? `Year ${year}` : 'All years'}
                      </span>
                      <span className={`unit-level-badge${outsideDefaultSemester ? ' outside-default' : ''}`}>
                        {semester ? `Semester ${semester}` : 'All semesters'}
                      </span>
                      {(unit.degreeProgram === 'ALL' || unit.isPublic) &&
                        <span className={`unit-shared-badge${unit.isPublic ? ' public-course-badge' : ''}`}>
                          {unit.isPublic ? 'Public' : 'Shared'}
                        </span>}
                    </div>
                  </div>
                  <button type="button" className={unit.registered ? 'btn ghost small' : 'btn small'}
                    onClick={() => toggleRegistration(unit)} disabled={busyUnitId === unit.id}>
                    {busyUnitId === unit.id ? <><span className="spinner" /> Saving…</> : unit.registered ? 'Remove' : 'Register'}
                  </button>
                </div>
              );
            })}
          </div>
        </section>
      )}

      {tab === 'profile' && (
        <section className="card profile-settings">
          <h2>Profile settings</h2>
          <section className="push-notification-card" aria-labelledby="push-notification-title">
            <div>
              <h3 id="push-notification-title">Exam and class alerts</h3>
              <p className="muted small">
                Receive important university updates and new class-note alerts on this device.
              </p>
            </div>
            {pushNotifications.status === 'enabled' ? (
              <span className="push-enabled-badge">Notifications enabled</span>
            ) : pushNotifications.status === 'unsupported' ? (
              <p className="muted small">Push notifications are not supported by this browser.</p>
            ) : pushNotifications.status === 'denied' ? (
              <p className="muted small">Notifications are blocked. Allow them in your browser settings.</p>
            ) : (
              <button type="button" className="btn primary"
                onClick={pushNotifications.enable}
                disabled={pushNotifications.busy || pushNotifications.status === 'checking'}>
                {pushNotifications.busy
                  ? <><span className="spinner spinner-light" /> Enabling…</>
                  : 'Enable Push Notifications'}
              </button>
            )}
          </section>
          <div className="danger-zone">
            <h3>Delete account</h3>
            <p className="muted small">Permanently remove your account and your course registrations.</p>
            <button type="button" className="btn danger-btn" onClick={() => setShowDeleteModal(true)}>
              Delete My Account
            </button>
          </div>
        </section>
      )}

      {showDeleteModal && (
        <div className="modal-backdrop" role="presentation">
          <section className="modal" role="dialog" aria-modal="true" aria-labelledby="delete-account-title">
            <h2 id="delete-account-title">Delete your account?</h2>
            <p>Are you sure? This will permanently delete your account and timetable data.</p>
            <div className="modal-actions">
              <button
                type="button"
                className="btn ghost"
                onClick={() => setShowDeleteModal(false)}
                disabled={deletingAccount}
              >
                Cancel
              </button>
              <button
                type="button"
                className="btn danger-btn"
                onClick={deleteAccount}
                disabled={deletingAccount}
              >
                {deletingAccount ? <><span className="spinner spinner-light" /> Deleting…</> : 'Yes, Delete'}
              </button>
            </div>
          </section>
        </div>
      )}
      {checkinClass && (
        <div className="modal-backdrop" role="presentation">
          <form className="modal check-in-modal" role="dialog" aria-modal="true"
            aria-labelledby="check-in-title" onSubmit={(event) => {
              event.preventDefault();
              checkInToClass();
            }}>
            <h2 id="check-in-title">Check-in to {checkinClass.code}</h2>
            <p>Enter the four-digit code shown by your Lecture Coordinator.</p>
            <label>Session code
              <input autoFocus inputMode="numeric" pattern="[0-9]{4}" maxLength={4}
                value={checkinCode} onChange={(event) =>
                  setCheckinCode(event.target.value.replace(/\D/g, '').slice(0, 4))}
                placeholder="0000" required aria-label="Four-digit attendance code" />
            </label>
            <div className="modal-actions">
              <button type="button" className="btn ghost"
                onClick={() => { setCheckinClass(null); setCheckinCode(''); }}
                disabled={checkingIn}>Cancel</button>
              <button type="submit" className="btn primary"
                disabled={checkingIn || checkinCode.length !== 4}>
                {checkingIn ? 'Checking in…' : 'Submit code'}
              </button>
            </div>
          </form>
        </div>
      )}
    </main>
  );
}

function ExamSessionCard({ session, onDelete, onEdit, busyExamId, onComplete, busyRegistrationId }) {
  const sessionCompleted = session.courses.every((course) => course.isCompleted);
  return (
    <article className={`exam-card${sessionCompleted ? ' completed' : ''}`}>
      <div className="exam-main">
        <div className="session-heading">
          <div className="session-date">{formatDate(session.examDate)}</div>
          <div className="session-time">{formatTime(session.startTime)}–{formatTime(session.endTime)}</div>
          <div className="session-room">Room/Hall: {session.room}</div>
        </div>
        <ul className="session-courses">
          {session.courses.map((course) => (
            <li className={`session-course${course.isCompleted ? ' completed' : ''}`} key={course.id}>
              <div className="course-details">
                <span className="course-code">{course.code}</span>
                {course.courseName && <span className="course-name">{course.courseName}</span>}
              </div>
              <div className="program-badges" aria-label="Degree and exam program">
                {course.degreeProgram && (
                  <span className={`program-badge ${course.degreeProgram === 'ALL' ? 'general-badge' : 'degree-badge'}`}>
                    {course.degreeProgram === 'ALL' ? 'General' : course.degreeProgram}
                  </span>
                )}
                <span className="program-badge exam-program-badge">
                  {course.program || 'BOTH'}
                </span>
              </div>
              {course.isCompleted ? (
                <span className="completion-badge"><span aria-hidden="true">✓</span> Completed</span>
              ) : onComplete ? (
                <button type="button" className="btn complete-btn small"
                  onClick={() => onComplete(course)}
                  disabled={busyRegistrationId === course.registrationId}>
                  {busyRegistrationId === course.registrationId
                    ? <><span className="spinner" /> Saving…</>
                    : 'Mark as Done'}
                </button>
              ) : null}
              {course.sourceText && (
                <details className="source-details">
                  <summary>Original timetable details</summary>
                  {course.sourceDateLabel && <p className="source-date">Workbook date heading: {course.sourceDateLabel}</p>}
                  <p>{course.sourceText}</p>
                </details>
              )}
              {onDelete && (
                <div className="exam-admin-actions">
                  {onEdit && (
                    <button type="button" className="btn ghost small" onClick={() => onEdit(course)}>
                      Edit
                    </button>
                  )}
                  <button type="button" className="btn delete-btn small" onClick={() => onDelete(course.id)}
                    disabled={busyExamId === course.id}>
                    {busyExamId === course.id ? <><span className="spinner" /> Deleting…</> : 'Delete'}
                  </button>
                </div>
              )}
            </li>
          ))}
        </ul>
      </div>
    </article>
  );
}

function LecturerApp({ onLogout }) {
  const [lecturer, setLecturer] = useState(null);
  const [courses, setCourses] = useState([]);
  const [invigilations, setInvigilations] = useState([]);
  const [reminders, setReminders] = useState([]);
  const [courseSearch, setCourseSearch] = useState('');
  const debouncedCourseSearch = useDebouncedValue(courseSearch);
  const [selectedCourseId, setSelectedCourseId] = useState('');
  const [activeView, setActiveView] = useState('notes');
  const [title, setTitle] = useState('');
  const [file, setFile] = useState(null);
  const [notesRefresh, setNotesRefresh] = useState(0);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [reportExam, setReportExam] = useState(null);
  const [reportStudents, setReportStudents] = useState([]);
  const [reportStudentId, setReportStudentId] = useState('');
  const [reportDescription, setReportDescription] = useState('');
  const [reportBusy, setReportBusy] = useState(false);
  const [reportLoading, setReportLoading] = useState(false);
  const notify = useToast();

  async function loadCourses() {
    setLoading(true);
    try {
      const [profile, assignedCourses] = await Promise.all([
        api('/lecturer/me'),
        api(`/lecturer/courses?search=${encodeURIComponent(debouncedCourseSearch)}`)
      ]);
      setLecturer(profile);
      setCourses(assignedCourses);
      setInvigilations(await api('/lecturer/invigilations'));
      setSelectedCourseId((current) =>
        assignedCourses.some((course) => String(course.id) === current)
          ? current
          : assignedCourses.length ? String(assignedCourses[0].id) : ''
      );
    } catch (requestError) {
      if (requestError.message === 'Invalid session' || requestError.message === 'Not logged in') {
        onLogout();
        return;
      }
      notify(requestError.message || 'Could not load assigned courses.', 'error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadCourses();
  }, []);

  useEffect(() => {
    let active = true;
    api(`/lecturer/courses?search=${encodeURIComponent(debouncedCourseSearch)}`)
      .then((result) => {
        if (!active) return;
        setCourses(result);
        setSelectedCourseId((current) =>
          result.some((course) => String(course.id) === current)
            ? current
            : result.length ? String(result[0].id) : ''
        );
      })
      .catch((error) => { if (active) notify(error.message || 'Could not search courses.', 'error'); });
    return () => { active = false; };
  }, [debouncedCourseSearch, notify]);

  useEffect(() => {
    let active = true;
    async function loadReminders() {
      try {
        const latest = await api('/lecturer/notifications');
        if (active) setReminders(latest);
      } catch (requestError) {
        if (!active) return;
        if (requestError.message === 'Invalid session' || requestError.message === 'Not logged in') {
          onLogout();
        } else {
          notify(requestError.message || 'Could not load lecture reminders.', 'error');
        }
      }
    }

    loadReminders();
    const timer = window.setInterval(loadReminders, 15000);
    return () => {
      active = false;
      window.clearInterval(timer);
    };
  }, [notify, onLogout]);

  const selectedCourse = courses.find((course) => String(course.id) === selectedCourseId);

  async function beginMalpracticeReport(exam) {
    setReportExam(exam);
    setReportStudents([]);
    setReportStudentId('');
    setReportDescription('');
    setReportLoading(true);
    try {
      const studentsForExam = await api(`/lecturer/invigilations/${exam.id}/students`);
      setReportStudents(studentsForExam);
      if (!studentsForExam.length) notify('No eligible registered students were found for this exam.', 'error');
    } catch (requestError) {
      setReportExam(null);
      notify(requestError.message || 'Could not load registered students.', 'error');
    } finally {
      setReportLoading(false);
    }
  }

  async function submitMalpracticeReport(event) {
    event.preventDefault();
    if (!reportExam || reportBusy) return;
    setReportBusy(true);
    try {
      await api('/lecturer/report-malpractice', {
        method: 'POST',
        body: JSON.stringify({
          exam_id: reportExam.id,
          student_id: Number(reportStudentId),
          description: reportDescription
        })
      });
      notify('Malpractice report submitted to the Examination Office.');
      setReportExam(null);
      setReportStudents([]);
    } catch (requestError) {
      notify(requestError.message || 'Could not submit the report.', 'error');
    } finally {
      setReportBusy(false);
    }
  }

  async function dismissReminder(reminderId) {
    try {
      await api(`/lecturer/notifications/${reminderId}/read`, { method: 'POST' });
      setReminders((current) => current.filter((reminder) => reminder.id !== reminderId));
    } catch (requestError) {
      notify(requestError.message || 'Could not dismiss this reminder.', 'error');
    }
  }

  async function uploadNotes(event) {
    event.preventDefault();
    if (!selectedCourse || !file || uploading) return;
    const form = event.currentTarget;
    setUploading(true);
    try {
      const formData = new FormData();
      formData.append('courseUnitId', selectedCourse.id);
      formData.append('title', title.trim() || file.name.replace(/\.[^.]+$/, ''));
      formData.append('file', file);
      await api('/lecturer/notes', { method: 'POST', body: formData });
      notify('Notes uploaded to the class.');
      setTitle('');
      setFile(null);
      setNotesRefresh((current) => current + 1);
      form.reset();
    } catch (requestError) {
      notify(requestError.message || 'Could not upload notes. Please try again.', 'error');
    } finally {
      setUploading(false);
    }
  }

  return (
    <main className="page lecturer-page">
      <header className="topbar">
        <div>
          <div className="hello">Hi, {lecturer?.name || 'Lecturer'}</div>
          <div className="muted small">Manage class notes and course discussions</div>
        </div>
        <button type="button" className="btn ghost" onClick={onLogout}>Log out</button>
      </header>

      <div className="tabs lecturer-tabs" role="tablist" aria-label="Lecturer dashboard">
        {courses.length > 0 && (
          <>
            <button type="button" className={activeView === 'notes' ? 'tab active' : 'tab'}
              onClick={() => setActiveView('notes')}>Upload Notes</button>
            <button type="button" className={activeView === 'chat' ? 'tab active' : 'tab'}
              onClick={() => setActiveView('chat')}>Class Chat</button>
          </>
        )}
        <button type="button" className={activeView === 'invigilations' ? 'tab active' : 'tab'}
          onClick={() => setActiveView('invigilations')}>My Invigilations</button>
      </div>

      {reminders.length > 0 && (
        <section className="card lecturer-reminders" aria-label="Lecture reminders">
          <h2>Lecture reminders</h2>
          {reminders.map((reminder) => (
            <article className="lecturer-reminder" key={reminder.id}>
              <div>
                <strong>{reminder.code} — {reminder.courseName}</strong>
                <p>{reminder.message}</p>
                <time>{new Date(reminder.createdAt).toLocaleString()}</time>
              </div>
              <button type="button" className="btn ghost small"
                onClick={() => dismissReminder(reminder.id)}>Dismiss</button>
            </article>
          ))}
        </section>
      )}

      {loading ? (
        <div className="loading-state"><span className="spinner" /> Loading your courses…</div>
      ) : activeView === 'invigilations' ? (
        <section className="invigilation-list" aria-label="My invigilations">
          {!invigilations.length ? (
            <section className="empty">
              <h2>No invigilations assigned</h2>
              <p className="muted">Exams assigned to you by the Examination Office will appear here.</p>
            </section>
          ) : invigilations.map((exam) => (
            <article className="card invigilation-card" key={exam.id}>
              <div className="invigilation-heading">
                <div>
                  <p className="eyebrow">{exam.code} · {exam.degreeProgram}</p>
                  <h2>{exam.courseName}</h2>
                  <p className="muted">{formatDate(exam.examDate)} · {formatTime(exam.startTime)}–{formatTime(exam.endTime)}</p>
                  <p className="muted">Room: {exam.room} · Program: {exam.program}</p>
                </div>
                <StatusBadge status={exam.status} />
              </div>
              {exam.canReport && (
                <button type="button" className="btn report-malpractice-btn"
                  onClick={() => beginMalpracticeReport(exam)}>
                  Report Malpractice
                </button>
              )}
            </article>
          ))}
        </section>
      ) : !courses.length ? (
        <section className="empty">
          <h2>No assigned courses yet</h2>
          <p className="muted">An administrator must assign you to a course unit before you can manage class materials.</p>
          <button type="button" className="btn primary" onClick={loadCourses}>Try again</button>
        </section>
      ) : (
        <div className="lecturer-layout">
          <section className="card lecturer-course-list">
            <h2>My course units</h2>
            <SearchBar value={courseSearch} onChange={setCourseSearch}
              placeholder="Search course units…" label="Search my courses" />
            {!courses.length && (courseSearch
              ? noSearchResults(courseSearch)
              : <p className="muted small">No courses are currently assigned.</p>)}
            {courses.map((course) => (
              <button type="button" key={course.id}
                className={`lecturer-course-option${selectedCourseId === String(course.id) ? ' active' : ''}`}
                onClick={() => setSelectedCourseId(String(course.id))}>
                <strong>{course.code}</strong>
                <span>{course.name}</span>
                <small>{course.studentCount} enrolled</small>
              </button>
            ))}
          </section>

          {selectedCourse && (
            <section className="lecturer-course-workspace">
              <header className="lecturer-course-heading">
                <div>
                  <p className="eyebrow">{selectedCourse.school} · {selectedCourse.degreeProgram}</p>
                  <h1>{selectedCourse.code}</h1>
                  <p className="muted">{selectedCourse.name}</p>
                </div>
              </header>
              {activeView === 'notes' ? (
                <div className="lecturer-notes-view">
                  <section className="card">
                    <h2>Upload class notes</h2>
                    <p className="muted small">PDF and DOCX files up to 10 MB are accepted.</p>
                    <form className="form" onSubmit={uploadNotes}>
                      <label>Notes title
                        <input maxLength={200} value={title}
                          onChange={(event) => setTitle(event.target.value)}
                          placeholder="e.g. Week 1 — Introduction" />
                      </label>
                      <label className="file-picker">
                        <span>Choose a PDF or DOCX file</span>
                        <input type="file" accept=".pdf,.docx,application/pdf,application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                          required onChange={(event) => setFile(event.target.files?.[0] || null)} />
                        {file && <small className="selected-file">{file.name}</small>}
                      </label>
                      <button type="submit" className="btn primary" disabled={!file || uploading}>
                        {uploading ? <><span className="spinner spinner-light" /> Uploading…</> : 'Upload notes'}
                      </button>
                    </form>
                  </section>
                  <NotesList key={`${selectedCourse.id}-${notesRefresh}`} courseUnitId={selectedCourse.id} lecturerMode />
                </div>
              ) : (
                <section className="chat-screen-overlay lecturer-chat-screen">
                  <header className="chat-page-title">
                    <button type="button" className="btn ghost chat-back-button"
                      onClick={() => setActiveView('notes')}>
                      <span aria-hidden="true">←</span> Course workspace
                    </button>
                    <span className="eyebrow">Class discussion</span>
                    <h1>{selectedCourse.code} — {selectedCourse.name}</h1>
                    <p className="muted">Messages for students and the lecturer assigned to this course.</p>
                  </header>
                  <ChatPanel
                    key={`lecturer-chat-${selectedCourse.id}`}
                    lecturer={lecturer}
                    courseUnit={selectedCourse}
                    fullPage
                  />
                </section>
              )}
            </section>
          )}
        </div>
      )}
      {reportExam && (
        <Modal title="Report malpractice" onClose={() => {
          if (!reportBusy) setReportExam(null);
        }} className="report-modal">
          <h2>Report malpractice</h2>
          <p className="muted small">{reportExam.code} — {reportExam.courseName}</p>
          {reportLoading ? (
            <div className="loading-state"><span className="spinner" /> Loading registered students…</div>
          ) : (
            <form className="form" onSubmit={submitMalpracticeReport}>
              <label>Student
                <select required value={reportStudentId}
                  onChange={(event) => setReportStudentId(event.target.value)}>
                  <option value="">Select a registered student</option>
                  {reportStudents.map((student) => (
                    <option key={student.id} value={student.id}>
                      {student.firstName} {student.lastName} · {student.studentNumber}
                    </option>
                  ))}
                </select>
              </label>
              <label>Description of offense
                <textarea required minLength={1} maxLength={5000} rows={5}
                  value={reportDescription}
                  onChange={(event) => setReportDescription(event.target.value)}
                  placeholder="Describe what happened and when." />
              </label>
              <div className="modal-actions">
                <button type="button" className="btn ghost"
                  onClick={() => setReportExam(null)} disabled={reportBusy}>Cancel</button>
                <button type="submit" className="btn danger-btn"
                  disabled={reportBusy || !reportStudents.length || !reportStudentId}>
                  {reportBusy ? 'Submitting…' : 'Submit report'}
                </button>
              </div>
            </form>
          )}
        </Modal>
      )}
    </main>
  );
}

function ExamOfficerApp({ onLogout }) {
  const [exams, setExams] = useState([]);
  const [lecturers, setLecturers] = useState([]);
  const [cases, setCases] = useState([]);
  const [tab, setTab] = useState('exams');
  const [loading, setLoading] = useState(true);
  const [assignmentExam, setAssignmentExam] = useState(null);
  const [assignmentForm, setAssignmentForm] = useState({ room: '', invigilatorId: '' });
  const [busy, setBusy] = useState('');
  const notify = useToast();

  async function load() {
    setLoading(true);
    try {
      const [examResults, lecturerResults, caseResults] = await Promise.all([
        api('/examofficer/exams'),
        api('/examofficer/lecturers'),
        api('/examofficer/cases')
      ]);
      setExams(examResults);
      setLecturers(lecturerResults);
      setCases(caseResults);
    } catch (error) {
      if (error.message === 'Invalid session' || error.message === 'Not logged in') {
        onLogout();
      } else {
        notify(error.message || 'Could not load Examination Office data.', 'error');
      }
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  function beginAssignment(exam) {
    setAssignmentExam(exam);
    setAssignmentForm({
      room: exam.room || '',
      invigilatorId: exam.invigilatorId ? String(exam.invigilatorId) : ''
    });
  }

  async function assignExam(event) {
    event.preventDefault();
    if (!assignmentExam) return;
    setBusy(`exam-${assignmentExam.id}`);
    try {
      await api(`/examofficer/exams/${assignmentExam.id}/assign`, {
        method: 'PUT',
        body: JSON.stringify({
          room: assignmentForm.room,
          invigilatorId: Number(assignmentForm.invigilatorId)
        })
      });
      setAssignmentExam(null);
      notify('Room and invigilator assigned.');
      await load();
    } catch (error) {
      notify(error.message || 'Could not assign this exam.', 'error');
    } finally {
      setBusy('');
    }
  }

  async function updateCase(caseItem, status) {
    setBusy(`case-${caseItem.id}`);
    try {
      await api(`/examofficer/cases/${caseItem.id}`, {
        method: 'PUT',
        body: JSON.stringify({ status })
      });
      setCases((current) => current.map((item) =>
        item.id === caseItem.id ? { ...item, status } : item
      ));
      notify(`Case ${status.toLowerCase()}.`);
    } catch (error) {
      notify(error.message || 'Could not update the malpractice case.', 'error');
    } finally {
      setBusy('');
    }
  }

  return (
    <main className="page exam-officer-page">
      <header className="topbar">
        <div>
          <div className="hello">Examination Office</div>
          <div className="muted small">Manage exam rooms, invigilators, and malpractice reports</div>
        </div>
        <button type="button" className="btn ghost" onClick={onLogout}>Log out</button>
      </header>
      <div className="tabs" role="tablist" aria-label="Examination Office sections">
        <button type="button" className={tab === 'exams' ? 'tab active' : 'tab'}
          onClick={() => setTab('exams')}>Manage Exams ({exams.length})</button>
        <button type="button" className={tab === 'cases' ? 'tab active' : 'tab'}
          onClick={() => setTab('cases')}>Malpractice Cases ({cases.length})</button>
      </div>
      {loading && <div className="inline-loading"><span className="spinner" /> Loading Examination Office data…</div>}

      {tab === 'exams' && (
        <section className="exam-officer-list">
          {!exams.length && !loading && <section className="empty"><p>No exams are available to manage.</p></section>}
          {exams.map((exam) => (
            <article className="card officer-exam-card" key={exam.id}>
              <div>
                <p className="eyebrow">{exam.school} · {exam.code} · {exam.degreeProgram}</p>
                <h2>{exam.courseName}</h2>
                <p className="muted">{formatDate(exam.examDate)} · {formatTime(exam.startTime)}–{formatTime(exam.endTime)}</p>
                <p className="muted">Room: {exam.room} · Program: {exam.program}</p>
                <p className="muted">Invigilator: {exam.invigilatorName || 'Not assigned'}</p>
              </div>
              <div className="officer-exam-actions">
                <StatusBadge status={exam.status} />
                <button type="button" className="btn primary"
                  onClick={() => beginAssignment(exam)}>Assign Room &amp; Invigilator</button>
              </div>
            </article>
          ))}
        </section>
      )}

      {tab === 'cases' && (
        <section className="malpractice-case-list">
          {!cases.length && !loading && <section className="empty"><p>No malpractice reports have been submitted.</p></section>}
          {cases.map((caseItem) => (
            <article className="card malpractice-case-card" key={caseItem.id}>
              <div className="case-heading">
                <div>
                  <p className="eyebrow">{caseItem.code} · {caseItem.courseName}</p>
                  <h2>{caseItem.studentName} <span className="muted small">({caseItem.studentNumber})</span></h2>
                  <p className="muted">Exam: {formatDate(caseItem.examDate)} · {formatTime(caseItem.startTime)}</p>
                  <p className="muted">Accuser: {caseItem.lecturerName} · {new Date(caseItem.createdAt).toLocaleString()}</p>
                </div>
                <StatusBadge status={caseItem.status} />
              </div>
              <p className="case-description">{caseItem.description}</p>
              {caseItem.status === 'PENDING' && (
                <div className="case-actions">
                  <button type="button" className="btn resolve-case-btn"
                    onClick={() => updateCase(caseItem, 'RESOLVED')}
                    disabled={busy === `case-${caseItem.id}`}>
                    {busy === `case-${caseItem.id}` ? 'Updating…' : 'Resolve'}
                  </button>
                  <button type="button" className="btn dismiss-case-btn"
                    onClick={() => updateCase(caseItem, 'DISMISSED')}
                    disabled={busy === `case-${caseItem.id}`}>Dismiss</button>
                </div>
              )}
            </article>
          ))}
        </section>
      )}

      {assignmentExam && (
        <Modal title="Assign room and invigilator" onClose={() => {
          if (busy !== `exam-${assignmentExam.id}`) setAssignmentExam(null);
        }} className="exam-edit-modal">
          <h2>Assign Room &amp; Invigilator</h2>
          <p className="muted small">{assignmentExam.code} — {assignmentExam.courseName}</p>
          <form className="form" onSubmit={assignExam}>
            <label>Room
              <input required maxLength={50} value={assignmentForm.room}
                onChange={(event) => setAssignmentForm({ ...assignmentForm, room: event.target.value })} />
            </label>
            <label>Invigilator
              <select required value={assignmentForm.invigilatorId}
                onChange={(event) => setAssignmentForm({ ...assignmentForm, invigilatorId: event.target.value })}>
                <option value="">Select a lecturer</option>
                {lecturers.map((lecturer) => (
                  <option key={lecturer.id} value={lecturer.id}>{lecturer.name} · {lecturer.email}</option>
                ))}
              </select>
            </label>
            <div className="modal-actions">
              <button type="button" className="btn ghost" onClick={() => setAssignmentExam(null)}
                disabled={busy === `exam-${assignmentExam.id}`}>Cancel</button>
              <button type="submit" className="btn primary"
                disabled={busy === `exam-${assignmentExam.id}` || !assignmentForm.invigilatorId}>
                {busy === `exam-${assignmentExam.id}` ? 'Saving…' : 'Assign exam'}
              </button>
            </div>
          </form>
        </Modal>
      )}
    </main>
  );
}

function CoordinatorApp({ onLogout }) {
  const [coordinator, setCoordinator] = useState(null);
  const [lectures, setLectures] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeSchedule, setActiveSchedule] = useState(null);
  const [roster, setRoster] = useState([]);
  const [rosterLoading, setRosterLoading] = useState(false);
  const [roomSchedule, setRoomSchedule] = useState(null);
  const [roomValue, setRoomValue] = useState('');
  const [checkinCode, setCheckinCode] = useState('');
  const [busy, setBusy] = useState('');
  const dirtyAttendanceIds = useRef(new Set());
  const serverAttendanceSnapshot = useRef(new Map());
  const notify = useToast();

  const refreshLectures = useCallback(async () => {
    try {
      setLectures(await api('/coordinator/lectures'));
    } catch (error) {
      if (error.message === 'Invalid session' || error.message === 'Not logged in') {
        onLogout();
        return;
      }
      notify(error.message || 'Could not refresh today’s lectures.', 'error');
    }
  }, [notify, onLogout]);

  const refreshRoster = useCallback(async (scheduleId, silent = false) => {
    try {
      const latest = await api(`/coordinator/schedule/${scheduleId}/students`);
      setRoster((current) => latest.map((student) => {
        const existing = current.find((item) => item.id === student.id);
        const isDirty = dirtyAttendanceIds.current.has(student.id);
        const previousServerStatus = serverAttendanceSnapshot.current.get(student.id) ?? null;
        const serverStatusChanged = Boolean(student.status) &&
          previousServerStatus !== student.status;
        serverAttendanceSnapshot.current.set(student.id, student.status || null);
        return {
          ...student,
          status: (serverStatusChanged ? student.status : null) ||
            (isDirty ? existing?.status : null) || student.status || 'ABSENT'
        };
      }));
    } catch (error) {
      if (!silent) notify(error.message || 'Could not load the class roster.', 'error');
    }
  }, [notify]);

  useEffect(() => {
    let active = true;
    async function loadDashboard() {
      setLoading(true);
      try {
        const [identity, todaysLectures] = await Promise.all([
          api('/coordinator/me'),
          api('/coordinator/lectures')
        ]);
        if (active) {
          setCoordinator(identity);
          setLectures(todaysLectures);
        }
      } catch (error) {
        if (active && (error.message === 'Invalid session' || error.message === 'Not logged in')) {
          onLogout();
        } else if (active) {
          notify(error.message || 'Could not load the coordinator dashboard.', 'error');
        }
      } finally {
        if (active) setLoading(false);
      }
    }

    loadDashboard();
    const timer = window.setInterval(() => {
      if (active) refreshLectures();
    }, 15000);
    return () => {
      active = false;
      window.clearInterval(timer);
    };
  }, [notify, onLogout, refreshLectures]);

  useEffect(() => {
    if (!activeSchedule) return undefined;
    refreshRoster(activeSchedule.id);
    const timer = window.setInterval(() => refreshRoster(activeSchedule.id, true), 4000);
    return () => window.clearInterval(timer);
  }, [activeSchedule?.id, refreshRoster]);

  async function openAttendance(schedule) {
    dirtyAttendanceIds.current.clear();
    serverAttendanceSnapshot.current.clear();
    setRoster([]);
    setCheckinCode('');
    setActiveSchedule(schedule);
    setRosterLoading(true);
    await refreshRoster(schedule.id);
    setRosterLoading(false);
  }

  function updateAttendance(studentId, status) {
    dirtyAttendanceIds.current.add(studentId);
    setRoster((current) => current.map((student) =>
      student.id === studentId ? { ...student, status } : student
    ));
  }

  async function saveAttendance() {
    if (!activeSchedule || !roster.length || busy) return;
    setBusy('attendance');
    try {
      const result = await api('/coordinator/attendance', {
        method: 'POST',
        body: JSON.stringify({
          scheduleId: activeSchedule.id,
          students: roster.map((student) => ({
            student_id: student.id,
            status: student.status || 'ABSENT'
          }))
        })
      });
      dirtyAttendanceIds.current.clear();
      await Promise.all([
        refreshRoster(activeSchedule.id, true),
        refreshLectures()
      ]);
      notify(`Attendance saved for ${result.markedCount} students.`);
    } catch (error) {
      notify(error.message || 'Could not save attendance.', 'error');
    } finally {
      setBusy('');
    }
  }

  async function generateCheckinCode() {
    if (!activeSchedule || busy) return;
    setBusy('code');
    try {
      const result = await api(`/coordinator/schedule/${activeSchedule.id}/generate-code`, {
        method: 'POST'
      });
      setCheckinCode(result.code);
    } catch (error) {
      notify(error.message || 'Could not generate a check-in code.', 'error');
    } finally {
      setBusy('');
    }
  }

  async function saveRoom(event) {
    event.preventDefault();
    if (!roomSchedule || busy) return;
    setBusy('room');
    try {
      const result = await api(`/coordinator/schedule/${roomSchedule.id}/room`, {
        method: 'PUT',
        body: JSON.stringify({ room: roomValue.trim() })
      });
      setLectures((current) => current.map((lecture) =>
        lecture.id === roomSchedule.id ? { ...lecture, room: result.room } : lecture
      ));
      setRoomSchedule(null);
      notify(`Room updated to ${result.room}.`);
    } catch (error) {
      notify(error.message || 'Could not update the lecture room.', 'error');
    } finally {
      setBusy('');
    }
  }

  async function remindLecturer(lecture) {
    if (busy) return;
    setBusy(`remind-${lecture.id}`);
    try {
      const result = await api(`/coordinator/schedule/${lecture.id}/remind-lecturer`, {
        method: 'POST'
      });
      notify(result.lecturerEmail
        ? `In-app lecture reminder sent to ${result.lecturerEmail}.`
        : 'In-app lecture reminder sent.');
    } catch (error) {
      notify(error.message || 'Could not send the lecture reminder.', 'error');
    } finally {
      setBusy('');
    }
  }

  return (
    <main className="page coordinator-page">
      <header className="topbar">
        <div>
          <div className="hello">Lecture Coordinator</div>
          <div className="muted small">{coordinator?.school || 'Your school'} · Assigned course units</div>
        </div>
        <button type="button" className="btn ghost" onClick={onLogout}>Log out</button>
      </header>

      <section className="coordinator-heading">
        <div>
          <span className="eyebrow">{new Intl.DateTimeFormat(undefined, {
            weekday: 'long', day: 'numeric', month: 'long'
          }).format(new Date())}</span>
          <h1>Today’s Lectures</h1>
          <p>Confirm rooms, remind lecturers, and record class attendance for your assigned course units.</p>
        </div>
        <button type="button" className="btn ghost" onClick={refreshLectures}>Refresh</button>
      </section>

      {loading ? (
        <div className="loading-state"><span className="spinner" /> Loading today’s lectures…</div>
      ) : !lectures.length ? (
        <section className="empty">
          <h2>No lectures scheduled today</h2>
          <p className="muted">There are no lectures for your assigned course units today.</p>
        </section>
      ) : (
        <section className="coordinator-lecture-list" aria-label="Today's lectures">
          {lectures.map((lecture) => (
            <article className="card coordinator-lecture-card" key={lecture.id}>
              <div className="coordinator-lecture-time">
                <strong>{formatTime(lecture.startTime)}</strong>
                <span>{formatTime(lecture.endTime)}</span>
              </div>
              <div className="coordinator-lecture-details">
                <h2>{lecture.code} — {lecture.courseName}</h2>
                <p><strong>Room:</strong> {lecture.room}</p>
                <p><strong>Lecturer:</strong> {lecture.lecturerName || 'Not assigned'}</p>
                {lecture.lecturerEmail && (
                  <p><strong>Email:</strong> <a href={`mailto:${lecture.lecturerEmail}`}>{lecture.lecturerEmail}</a></p>
                )}
                <p className="muted small">
                  {lecture.attendedCount} of {lecture.studentCount} students checked in
                </p>
              </div>
              <div className="coordinator-lecture-actions">
                <button type="button" className="btn ghost"
                  onClick={() => remindLecturer(lecture)}
                  disabled={!lecture.lecturerName || busy === `remind-${lecture.id}`}>
                  {busy === `remind-${lecture.id}` ? 'Sending…' : 'Remind Lecturer'}
                </button>
                <button type="button" className="btn ghost"
                  onClick={() => { setRoomSchedule(lecture); setRoomValue(lecture.room); }}>
                  Change Room
                </button>
                <button type="button" className="btn primary"
                  onClick={() => openAttendance(lecture)}>
                  Take Attendance
                </button>
              </div>
            </article>
          ))}
        </section>
      )}

      {roomSchedule && (
        <div className="modal-backdrop" role="presentation">
          <form className="modal" role="dialog" aria-modal="true"
            aria-labelledby="change-room-title" onSubmit={saveRoom}>
            <h2 id="change-room-title">Change lecture room</h2>
            <p>{roomSchedule.code} — {roomSchedule.courseName}</p>
            <label>New room
              <input autoFocus maxLength={50} required value={roomValue}
                onChange={(event) => setRoomValue(event.target.value)} />
            </label>
            <div className="modal-actions">
              <button type="button" className="btn ghost"
                onClick={() => setRoomSchedule(null)} disabled={busy === 'room'}>Cancel</button>
              <button type="submit" className="btn primary"
                disabled={busy === 'room' || !roomValue.trim()}>
                {busy === 'room' ? 'Saving…' : 'Save room'}
              </button>
            </div>
          </form>
        </div>
      )}

      {activeSchedule && (
        <div className="modal-backdrop coordinator-modal-backdrop" role="presentation">
          <section className="modal coordinator-attendance-modal" role="dialog" aria-modal="true"
            aria-labelledby="attendance-title">
            <header className="coordinator-modal-heading">
              <div>
                <span className="eyebrow">{activeSchedule.startTime && formatTime(activeSchedule.startTime)} · {activeSchedule.room}</span>
                <h2 id="attendance-title">{activeSchedule.code} — {activeSchedule.courseName}</h2>
              </div>
              <button type="button" className="modal-close-button" aria-label="Close attendance"
                onClick={() => setActiveSchedule(null)}>×</button>
            </header>
            <div className="checkin-code-section">
              <button type="button" className="btn ghost"
                onClick={generateCheckinCode} disabled={busy === 'code'}>
                {busy === 'code' ? 'Generating…' : 'Generate Check-in Code'}
              </button>
              {checkinCode && (
                <output className="checkin-code" aria-label={`Check-in code ${checkinCode}`}>
                  {checkinCode.split('').join(' ')}
                </output>
              )}
              {checkinCode && <p>Students can use this code to check in during class.</p>}
            </div>
            <div className="coordinator-roster-heading">
              <h3>Class roster <span>({roster.length})</span></h3>
              <span className="live-attendance-label"><i /> Live check-ins</span>
            </div>
            <div className="coordinator-roster">
              {rosterLoading && !roster.length ? (
                <div className="inline-loading"><span className="spinner" /> Loading class roster…</div>
              ) : !roster.length ? (
                <p className="muted small">No eligible registered students are in this class.</p>
              ) : roster.map((student) => (
                <label key={student.id}
                  className={`coordinator-roster-row${['PRESENT', 'LATE'].includes(student.status) ? ' present' : ''}`}>
                  <span className="coordinator-student-name">
                    <strong>{student.firstName} {student.lastName}</strong>
                    <small>{student.studentNumber}</small>
                  </span>
                  <select value={student.status || 'ABSENT'}
                    aria-label={`Attendance status for ${student.firstName} ${student.lastName}`}
                    onChange={(event) => updateAttendance(student.id, event.target.value)}>
                    <option value="PRESENT">Present</option>
                    <option value="ABSENT">Absent</option>
                    <option value="LATE">Late</option>
                  </select>
                </label>
              ))}
            </div>
            <footer className="coordinator-modal-actions">
              <button type="button" className="btn ghost"
                onClick={() => setActiveSchedule(null)}>Close</button>
              <button type="button" className="btn primary"
                onClick={saveAttendance}
                disabled={busy === 'attendance' || rosterLoading || !roster.length}>
                {busy === 'attendance' ? 'Saving…' : 'Save Attendance'}
              </button>
            </footer>
          </section>
        </div>
      )}
    </main>
  );
}

function SuperAdminApp({ onLogout }) {
  return <AdminApp onLogout={onLogout} superAdmin />;
}

function AdminApp({ onLogout, superAdmin = false }) {
  const [adminIdentity, setAdminIdentity] = useState(null);
  const [managedAdmins, setManagedAdmins] = useState([]);
  const [adminForm, setAdminForm] = useState({
    email: '', password: '', school: 'SCI', role: 'SCHOOL_ADMIN'
  });
  const [units, setUnits] = useState([]);
  const [assignmentUnits, setAssignmentUnits] = useState([]);
  const [lecturers, setLecturers] = useState([]);
  const [coordinators, setCoordinators] = useState([]);
  const [visibleLecturers, setVisibleLecturers] = useState([]);
  const [lecturerAssignments, setLecturerAssignments] = useState({});
  const [coordinatorAssignments, setCoordinatorAssignments] = useState({});
  const [classes, setClasses] = useState([]);
  const [exams, setExams] = useState([]);
  const [students, setStudents] = useState([]);
  const [unitSearch, setUnitSearch] = useState('');
  const [lecturerSearch, setLecturerSearch] = useState('');
  const [examSearch, setExamSearch] = useState('');
  const [studentSearch, setStudentSearch] = useState('');
  const debouncedAdminUnitSearch = useDebouncedValue(unitSearch);
  const debouncedLecturerSearch = useDebouncedValue(lecturerSearch);
  const debouncedAdminExamSearch = useDebouncedValue(examSearch);
  const debouncedStudentSearch = useDebouncedValue(studentSearch);
  const [availableDegrees, setAvailableDegrees] = useState(DEGREE_PROGRAMS);
  const [tab, setTab] = useState('manage');
  const [loading, setLoading] = useState(true);
  const [busyAction, setBusyAction] = useState('');
  const [editingClassId, setEditingClassId] = useState(null);
  const [busyExamId, setBusyExamId] = useState(null);
  const [editingExam, setEditingExam] = useState(null);
  const [examEditForm, setExamEditForm] = useState({
    examDate: '', startTime: '', endTime: '', room: '', program: 'BOTH'
  });
  const [broadcastType, setBroadcastType] = useState('global');
  const [broadcastSchool, setBroadcastSchool] = useState('SCI');
  const [broadcastTargetSchool, setBroadcastTargetSchool] = useState('ALL');
  const [broadcastDegree, setBroadcastDegree] = useState('BCS');
  const [broadcastProgram, setBroadcastProgram] = useState('DAY');
  const [broadcastYear, setBroadcastYear] = useState('1');
  const [broadcastSemester, setBroadcastSemester] = useState('1');
  const [broadcastText, setBroadcastText] = useState('');
  const [broadcasts, setBroadcasts] = useState([]);
  const [broadcastsLoading, setBroadcastsLoading] = useState(false);
  const [broadcastBusy, setBroadcastBusy] = useState(false);
  const [adminChatOpen, setAdminChatOpen] = useState(false);
  const notify = useToast();
  const targetRoom = broadcastType === 'global'
    ? 'GLOBAL'
    : `${superAdmin ? broadcastSchool : (adminIdentity?.school || broadcastSchool)}-${broadcastDegree}-${broadcastProgram}-Y${broadcastYear}-S${broadcastSemester}`;
  const isSuperAdminUser = superAdmin || adminIdentity?.role === 'SUPER_ADMIN';
  const [unitForm, setUnitForm] = useState({
    code: '', name: '', school: 'SCI', degreeProgram: '', academicLevel: 'Degree',
    yearOfStudy: 1, semester: 1, lecturerId: '', isPublic: false
  });
  const [lecturerForm, setLecturerForm] = useState({
    name: '', email: '', password: '', school: 'SCI'
  });
  const [classForm, setClassForm] = useState({
    courseUnitId: '', lecturerId: '', dayOfWeek: 'Monday',
    startTime: '', endTime: '', room: '', program: 'BOTH'
  });
  const selectedScheduleCourse = units.find((unit) => String(unit.id) === classForm.courseUnitId);
  const scheduleLecturers = selectedScheduleCourse
    ? lecturers.filter((lecturer) => lecturer.school === selectedScheduleCourse.school)
    : [];
  const [examForm, setExamForm] = useState({
    courseUnitIds: [], examDate: '', startTime: '', endTime: '', room: '', program: 'BOTH'
  });

  async function load() {
    setLoading(true);
    try {
      const [
        availableUnits, assignmentUnitResults, scheduledExams, chatOptions,
        availableLecturers, availableCoordinators, searchedLecturers,
        scheduledClasses, searchedStudents, identity
      ] = await Promise.all([
        api('/admin/course-units'),
        api(`/admin/course-units?search=${encodeURIComponent(debouncedAdminUnitSearch)}`),
        api(`/admin/exams?search=${encodeURIComponent(debouncedAdminExamSearch)}`),
        api('/admin/chat-options'),
        api('/admin/lecturers'),
        api('/admin/coordinators'),
        api(`/admin/lecturers?search=${encodeURIComponent(debouncedLecturerSearch)}`),
        api('/admin/classes'),
        api(`/admin/students?search=${encodeURIComponent(debouncedStudentSearch)}`),
        api('/admin/me')
      ]);
      setUnits(availableUnits);
      setAssignmentUnits(assignmentUnitResults);
      setExams(scheduledExams);
      setLecturers(availableLecturers);
      setCoordinators(availableCoordinators);
      setVisibleLecturers(searchedLecturers);
      setClasses(scheduledClasses);
      setStudents(searchedStudents);
      setAdminIdentity(identity);
      setLecturerAssignments(Object.fromEntries(
        availableUnits.map((unit) => [unit.id, unit.lecturerId ? String(unit.lecturerId) : ''])
      ));
      setCoordinatorAssignments(Object.fromEntries(
        availableUnits.map((unit) => [unit.id, unit.coordinatorId ? String(unit.coordinatorId) : ''])
      ));
      setAvailableDegrees([...new Set([...DEGREE_PROGRAMS, ...chatOptions.degreePrograms])]);
    } catch (requestError) {
      if (requestError.message === 'Invalid session' || requestError.message === 'Not logged in') {
        onLogout();
        return;
      }
      notify(requestError.message, 'error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  useEffect(() => {
    let active = true;
    api(`/admin/course-units?search=${encodeURIComponent(debouncedAdminUnitSearch)}`)
      .then((result) => { if (active) setAssignmentUnits(result); })
      .catch((error) => { if (active) notify(error.message || 'Could not search course units.', 'error'); });
    return () => { active = false; };
  }, [debouncedAdminUnitSearch, notify]);

  useEffect(() => {
    let active = true;
    api(`/admin/lecturers?search=${encodeURIComponent(debouncedLecturerSearch)}`)
      .then((result) => { if (active) setVisibleLecturers(result); })
      .catch((error) => { if (active) notify(error.message || 'Could not search lecturers.', 'error'); });
    return () => { active = false; };
  }, [debouncedLecturerSearch, notify]);

  useEffect(() => {
    let active = true;
    api(`/admin/exams?search=${encodeURIComponent(debouncedAdminExamSearch)}`)
      .then((result) => { if (active) setExams(result); })
      .catch((error) => { if (active) notify(error.message || 'Could not search exams.', 'error'); });
    return () => { active = false; };
  }, [debouncedAdminExamSearch, notify]);

  useEffect(() => {
    let active = true;
    api(`/admin/students?search=${encodeURIComponent(debouncedStudentSearch)}`)
      .then((result) => { if (active) setStudents(result); })
      .catch((error) => { if (active) notify(error.message || 'Could not search students.', 'error'); });
    return () => { active = false; };
  }, [debouncedStudentSearch, notify]);

  useEffect(() => {
    if (tab !== 'chat') return undefined;
    let active = true;
    let hasReportedError = false;

    async function loadBroadcasts() {
      try {
        const latestBroadcasts = await api('/admin/broadcasts');
        if (active) {
          setBroadcasts(latestBroadcasts);
          hasReportedError = false;
        }
      } catch (requestError) {
        if (active && !hasReportedError) {
          notify(requestError.message, 'error');
          hasReportedError = true;
        }
      } finally {
        if (active) setBroadcastsLoading(false);
      }
    }

    setBroadcastsLoading(true);
    loadBroadcasts();
    const timer = window.setInterval(loadBroadcasts, 5000);
    return () => {
      active = false;
      window.clearInterval(timer);
    };
  }, [tab, notify]);

  useEffect(() => {
    if (tab !== 'admins' || !isSuperAdminUser) return undefined;
    let active = true;
    api('/superadmin/admins')
      .then((result) => { if (active) setManagedAdmins(result); })
      .catch((error) => { if (active) notify(error.message || 'Could not load administrators.', 'error'); });
    return () => { active = false; };
  }, [tab, isSuperAdminUser, notify]);

  async function addUnit(event) {
    event.preventDefault();
    setBusyAction('unit');
    try {
      await api('/admin/course-units', {
        method: 'POST',
        body: JSON.stringify(unitForm)
      });
      setUnitForm({
        code: '', name: '', school: adminIdentity?.school || 'SCI',
        degreeProgram: '', academicLevel: 'Degree',
        yearOfStudy: 1, semester: 1, lecturerId: '', isPublic: false
      });
      notify('Course unit added.');
      await load();
    } catch (requestError) {
      notify(requestError.message, 'error');
    } finally {
      setBusyAction('');
    }
  }

  async function addLecturer(event) {
    event.preventDefault();
    setBusyAction('lecturer');
    try {
      await api('/admin/lecturers', {
        method: 'POST',
        body: JSON.stringify(lecturerForm)
      });
      setLecturerForm({ name: '', email: '', password: '', school: 'SCI' });
      notify('Lecturer account created.');
      await load();
    } catch (requestError) {
      notify(requestError.message, 'error');
    } finally {
      setBusyAction('');
    }
  }

  async function addSchoolAdmin(event) {
    event.preventDefault();
    setBusyAction('admin');
    try {
      await api('/superadmin/admins', {
        method: 'POST',
        body: JSON.stringify(adminForm)
      });
      setAdminForm({ email: '', password: '', school: 'SCI', role: 'SCHOOL_ADMIN' });
      setManagedAdmins(await api('/superadmin/admins'));
      if (adminForm.role === 'COORDINATOR') {
        setCoordinators(await api('/admin/coordinators'));
      }
      notify(adminForm.role === 'COORDINATOR'
        ? 'Lecture Coordinator account created.'
        : adminForm.role === 'EXAM_OFFICER'
          ? 'Examination Office account created.'
          : 'School admin account created.');
    } catch (requestError) {
      notify(requestError.message || 'Could not create the account.', 'error');
    } finally {
      setBusyAction('');
    }
  }

  async function assignLecturer(courseUnit) {
    const lecturerId = lecturerAssignments[courseUnit.id] || null;
    setBusyAction(`assign-${courseUnit.id}`);
    try {
      await api(`/admin/course-units/${courseUnit.id}/lecturer`, {
        method: 'PUT',
        body: JSON.stringify({ lecturerId: lecturerId ? Number(lecturerId) : null })
      });
      setUnits((current) => current.map((unit) =>
        unit.id === courseUnit.id
          ? { ...unit, lecturerId: lecturerId ? Number(lecturerId) : null }
          : unit
      ));
      notify(lecturerId ? 'Lecturer assigned to course.' : 'Lecturer assignment removed.');
    } catch (requestError) {
      notify(requestError.message || 'Could not update the course assignment.', 'error');
    } finally {
      setBusyAction('');
    }
  }

  async function assignCoordinator(courseUnit) {
    const coordinatorId = coordinatorAssignments[courseUnit.id] || null;
    setBusyAction(`coordinator-${courseUnit.id}`);
    try {
      await api(`/admin/course-units/${courseUnit.id}/coordinator`, {
        method: 'PUT',
        body: JSON.stringify({ coordinatorId: coordinatorId ? Number(coordinatorId) : null })
      });
      setUnits((current) => current.map((unit) =>
        unit.id === courseUnit.id
          ? {
            ...unit,
            coordinatorId: coordinatorId ? Number(coordinatorId) : null,
            coordinatorEmail: coordinators.find((item) => String(item.id) === coordinatorId)?.email || null
          }
          : unit
      ));
      setAssignmentUnits((current) => current.map((unit) =>
        unit.id === courseUnit.id
          ? {
            ...unit,
            coordinatorId: coordinatorId ? Number(coordinatorId) : null,
            coordinatorEmail: coordinators.find((item) => String(item.id) === coordinatorId)?.email || null
          }
          : unit
      ));
      notify(coordinatorId ? 'Lecture Coordinator assigned to course unit.' : 'Course unit coordinator assignment removed.');
    } catch (requestError) {
      notify(requestError.message || 'Could not update the coordinator assignment.', 'error');
    } finally {
      setBusyAction('');
    }
  }

  async function addClass(event) {
    event.preventDefault();
    setBusyAction('class');
    try {
      await api(editingClassId ? `/admin/classes/${editingClassId}` : '/admin/classes', {
        method: editingClassId ? 'PUT' : 'POST',
        body: JSON.stringify({
          ...classForm,
          courseUnitId: Number(classForm.courseUnitId),
          lecturerId: Number(classForm.lecturerId)
        })
      });
      setClassForm({
        courseUnitId: '', lecturerId: '', dayOfWeek: 'Monday',
        startTime: '', endTime: '', room: '', program: 'BOTH'
      });
      notify(editingClassId ? 'Lecture schedule updated.' : 'Lecture scheduled.');
      setEditingClassId(null);
      await load();
    } catch (requestError) {
      notify(requestError.message, 'error');
    } finally {
      setBusyAction('');
    }
  }

  function editClass(classSession) {
    setEditingClassId(classSession.id);
    setClassForm({
      courseUnitId: String(classSession.courseUnitId),
      lecturerId: String(classSession.lecturerId || ''),
      dayOfWeek: classSession.dayOfWeek,
      startTime: formatTime(classSession.startTime),
      endTime: formatTime(classSession.endTime),
      room: classSession.room,
      program: classSession.program || 'BOTH'
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function cancelClassEdit() {
    setEditingClassId(null);
    setClassForm({
      courseUnitId: '', lecturerId: '', dayOfWeek: 'Monday',
      startTime: '', endTime: '', room: '', program: 'BOTH'
    });
  }

  async function deleteClass(scheduleId) {
    setBusyAction(`delete-class-${scheduleId}`);
    try {
      await api(`/admin/classes/${scheduleId}`, { method: 'DELETE' });
      if (editingClassId === scheduleId) cancelClassEdit();
      notify('Lecture schedule deleted.');
      await load();
    } catch (requestError) {
      notify(requestError.message || 'Could not delete the lecture schedule.', 'error');
    } finally {
      setBusyAction('');
    }
  }

  async function addExam(event) {
    event.preventDefault();
    setBusyAction('exam');
    try {
      await api('/admin/exams', {
        method: 'POST',
        body: JSON.stringify({
          ...examForm,
          courseUnitIds: examForm.courseUnitIds.map(Number)
        })
      });
      setExamForm({ courseUnitIds: [], examDate: '', startTime: '', endTime: '', room: '', program: 'BOTH' });
      notify(examForm.courseUnitIds.length > 1 ? 'Exams scheduled for selected course units.' : 'Exam scheduled.');
      await load();
    } catch (requestError) {
      notify(requestError.message, 'error');
    } finally {
      setBusyAction('');
    }
  }

  async function deleteExam(id) {
    setBusyExamId(id);
    try {
      await api(`/admin/exams/${id}`, { method: 'DELETE' });
      notify('Exam deleted.');
      await load();
    } catch (requestError) {
      notify(requestError.message, 'error');
    } finally {
      setBusyExamId(null);
    }
  }

  function startExamEdit(exam) {
    setEditingExam(exam);
    setExamEditForm({
      examDate: exam.examDate,
      startTime: formatTime(exam.startTime),
      endTime: formatTime(exam.endTime),
      room: exam.room,
      program: exam.program || 'BOTH'
    });
  }

  async function saveExamEdit(event) {
    event.preventDefault();
    if (!editingExam) return;
    setBusyExamId(editingExam.id);
    try {
      await api(`/admin/exams/${editingExam.id}`, {
        method: 'PUT',
        body: JSON.stringify(examEditForm)
      });
      setEditingExam(null);
      notify('Exam updated.');
      await load();
    } catch (requestError) {
      notify(requestError.message || 'Could not update the exam.', 'error');
    } finally {
      setBusyExamId(null);
    }
  }

  async function sendBroadcast(event) {
    event.preventDefault();
    const text = broadcastText.trim();
    if (!text || broadcastBusy) return;

    setBroadcastBusy(true);
    try {
      await api('/admin/broadcast', {
        method: 'POST',
        body: JSON.stringify({ text, target_room: targetRoom, target_school: broadcastTargetSchool })
      });
      setBroadcastText('');
      notify(broadcastTargetSchool === 'ALL'
        ? 'Broadcast sent to the whole university.'
        : `Broadcast sent to ${broadcastTargetSchool}.`);
      setBroadcasts(await api('/admin/broadcasts'));
    } catch (requestError) {
      notify(requestError.message, 'error');
    } finally {
      setBroadcastBusy(false);
    }
  }

  return (
    <main className="page">
      <header className="topbar">
        <div>
          <div className="hello">
            {isSuperAdminUser ? 'Super Admin Panel' : `Admin Panel — ${adminIdentity?.school || 'School'}`}
          </div>
          <div className="muted small">
            {isSuperAdminUser
              ? 'University-wide management'
              : `Managing ${adminIdentity?.school || 'your school'} data only`}
          </div>
        </div>
        <button type="button" className="btn ghost" onClick={onLogout}>Log out</button>
      </header>
      <div className="tabs" role="tablist" aria-label="Admin sections">
        {isSuperAdminUser && (
          <button type="button" className={tab === 'admins' ? 'tab active' : 'tab'}
            onClick={() => setTab('admins')}>Manage admins</button>
        )}
        <button type="button" className={tab === 'manage' ? 'tab active' : 'tab'} onClick={() => setTab('manage')}>Timetable management</button>
        <button type="button" className={tab === 'classes' ? 'tab active' : 'tab'} onClick={() => setTab('classes')}>Schedule lectures</button>
        <button type="button" className={tab === 'lecturers' ? 'tab active' : 'tab'} onClick={() => setTab('lecturers')}>Manage lecturers</button>
        <button type="button" className={tab === 'students' ? 'tab active' : 'tab'} onClick={() => setTab('students')}>Manage students</button>
        <button type="button" className={tab === 'chat' ? 'tab active' : 'tab'} onClick={() => setTab('chat')}>Chat &amp; Updates</button>
      </div>
      {!isSuperAdminUser && (
        <p className="school-scope-note">Showing {adminIdentity?.school || 'your school'} students, lecturers, courses, and exams only.</p>
      )}
      {loading && <div className="inline-loading"><span className="spinner" /> Loading admin data…</div>}

      {tab === 'admins' && isSuperAdminUser && (
        <div className="lecturer-management">
          <section className="card">
            <h2>Create an administrator account</h2>
            <p className="muted small">Create school admins, Lecture Coordinators, or Examination Office accounts.</p>
            <form className="form" onSubmit={addSchoolAdmin}>
              <label>Email
                <input required type="email" autoComplete="email" maxLength={100}
                  value={adminForm.email}
                  onChange={(event) => setAdminForm({ ...adminForm, email: event.target.value })} />
              </label>
              <label>Temporary password
                <input required type="password" autoComplete="new-password" minLength={12}
                  value={adminForm.password}
                  onChange={(event) => setAdminForm({ ...adminForm, password: event.target.value })} />
              </label>
              <label>School
                <select value={adminForm.school}
                  onChange={(event) => setAdminForm({ ...adminForm, school: event.target.value })}>
                  {SCHOOLS.map((school) => <option key={school} value={school}>{school}</option>)}
                </select>
              </label>
              <label>Account role
                <select value={adminForm.role}
                  onChange={(event) => setAdminForm({ ...adminForm, role: event.target.value })}>
                  <option value="SCHOOL_ADMIN">School admin</option>
                  <option value="COORDINATOR">Lecture Coordinator</option>
                  <option value="EXAM_OFFICER">Examination Office</option>
                </select>
              </label>
              <button className="btn primary" disabled={busyAction === 'admin'}>
                {busyAction === 'admin' ? <><span className="spinner spinner-light" /> Creating…</> : 'Create account'}
              </button>
            </form>
          </section>
          <section className="card">
            <h2>Administrators ({managedAdmins.length})</h2>
            {!managedAdmins.length ? <p className="muted">No administrator accounts found.</p> : (
              <ul className="management-list">
                {managedAdmins.map((managedAdmin) => (
                  <li key={managedAdmin.id}>
                    <strong>{managedAdmin.email}</strong>
                    <span>{managedAdmin.role === 'SUPER_ADMIN'
                      ? 'Super Admin · All schools'
                      : `${managedAdmin.role === 'COORDINATOR'
                        ? 'Lecture Coordinator'
                        : managedAdmin.role === 'EXAM_OFFICER' ? 'Examination Office' : 'School Admin'} · ${managedAdmin.school}`}</span>
                  </li>
                ))}
              </ul>
            )}
          </section>
        </div>
      )}

      {tab === 'chat' && (
        <div className="admin-chat-layout">
          <section className="card admin-broadcast-card">
            <h2>Broadcast to Students</h2>
            <p className="muted small">Choose the school audience, then send a global or group-specific update.</p>
            <form className="form" onSubmit={sendBroadcast}>
              <label>Broadcast audience
                <select value={broadcastTargetSchool} onChange={(event) => {
                  setBroadcastTargetSchool(event.target.value);
                  if (event.target.value === 'ALL') setBroadcastType('global');
                }}>
                  <option value="ALL">Entire university</option>
                  {isSuperAdminUser
                    ? SCHOOLS.map((school) => <option key={school} value={school}>{school} only</option>)
                    : adminIdentity?.school && <option value={adminIdentity.school}>{adminIdentity.school} only</option>}
                </select>
              </label>
              <label>Target type
                <select value={broadcastType} onChange={(event) => setBroadcastType(event.target.value)}>
                  <option value="global">Global — all students in the selected audience</option>
                  <option value="specific" disabled={broadcastTargetSchool === 'ALL'}>Specific group</option>
                </select>
              </label>

              {broadcastType === 'specific' && (
                <div className="broadcast-group-fields">
                  {isSuperAdminUser ? (
                    <label>School chat room
                      <select value={broadcastSchool} onChange={(event) => setBroadcastSchool(event.target.value)}>
                        {SCHOOLS.map((school) => <option key={school} value={school}>{school}</option>)}
                      </select>
                    </label>
                  ) : <p className="muted small">Chat room: {adminIdentity?.school}</p>}
                  <label>Degree program
                    <select value={broadcastDegree} onChange={(event) => setBroadcastDegree(event.target.value)}>
                      {availableDegrees.map((degree) => <option key={degree} value={degree}>{degree}</option>)}
                    </select>
                  </label>
                  <label>Program
                    <select value={broadcastProgram} onChange={(event) => setBroadcastProgram(event.target.value)}>
                      {PROGRAM_MODES.map((mode) => (
                        <option key={mode} value={mode}>{mode.charAt(0) + mode.slice(1).toLowerCase()}</option>
                      ))}
                    </select>
                  </label>
                  <label>Year of study
                    <select value={broadcastYear} onChange={(event) => setBroadcastYear(event.target.value)}>
                      {[1, 2, 3, 4, 5].map((year) => <option key={year} value={year}>Year {year}</option>)}
                    </select>
                  </label>
                  <label>Semester
                    <select value={broadcastSemester} onChange={(event) => setBroadcastSemester(event.target.value)}>
                      <option value="1">Semester 1</option>
                      <option value="2">Semester 2</option>
                    </select>
                  </label>
                  <div className="broadcast-room-preview">Target room: <strong>{targetRoom}</strong></div>
                </div>
              )}

              <label>Message
                <textarea
                  value={broadcastText}
                  onChange={(event) => setBroadcastText(event.target.value)}
                  placeholder="Write an important update…"
                  maxLength={2000}
                  rows={4}
                  required
                />
              </label>
              <button type="submit" className="btn primary" disabled={broadcastBusy || !broadcastText.trim()}>
                {broadcastBusy
                  ? <><span className="spinner spinner-light" /> Sending…</>
                : broadcastTargetSchool === 'ALL' ? 'Send University Broadcast' : `Send ${broadcastTargetSchool} Broadcast`}
              </button>
            </form>
          </section>

          <button type="button" className="chat-room-option admin-chat-room-option"
            onClick={() => setAdminChatOpen(true)}>
            <span className="chat-room-icon" aria-hidden="true">C</span>
            <span className="chat-room-copy">
              <strong>{targetRoom === 'GLOBAL' ? 'Open Global Chat' : `Open ${targetRoom} Chat`}</strong>
              <span>View this conversation in a focused chat screen</span>
            </span>
            <span className="chat-room-arrow" aria-hidden="true">›</span>
          </button>

          <section className="card recent-broadcasts">
            <h2>Recent broadcasts</h2>
            {broadcastsLoading && !broadcasts.length ? (
              <div className="inline-loading"><span className="spinner" /> Loading broadcasts…</div>
            ) : !broadcasts.length ? (
              <p className="muted">No broadcasts have been sent yet.</p>
            ) : (
              <div className="broadcast-feed">
                {broadcasts.map((broadcast) => (
                  <article className="broadcast-feed-item" key={broadcast.id}>
                    <div className="broadcast-feed-meta">
                      <strong>
                        {broadcast.targetSchool === 'ALL' ? 'University' : broadcast.targetSchool}
                        {' · '}
                        {broadcast.targetRoom === 'GLOBAL' ? 'Global' : broadcast.targetRoom}
                      </strong>
                      <time>{new Date(broadcast.createdAt).toLocaleString()}</time>
                    </div>
                    <p>{broadcast.text}</p>
                  </article>
                ))}
              </div>
            )}
          </section>
        </div>
      )}

      {tab === 'manage' && <div className="admin-grid">
        <section className="card">
          <h2>Add course unit</h2>
          <form className="form" onSubmit={addUnit}>
            <div className="row">
              <label>Code
                <input required maxLength={20} placeholder="CSC1104" value={unitForm.code}
                  onChange={(event) => setUnitForm({ ...unitForm, code: event.target.value })} />
              </label>
              {isSuperAdminUser ? (
                <label>School
                  <select value={unitForm.school}
                    onChange={(event) => setUnitForm({ ...unitForm, school: event.target.value })}>
                    {SCHOOLS.map((school) => <option key={school} value={school}>{school}</option>)}
                  </select>
                </label>
              ) : (
                <label>School
                  <span className="readonly-school">{adminIdentity?.school || 'Your school'}</span>
                </label>
              )}
            </div>
            <label>Degree program
              <input list="degree-program-options" required maxLength={30}
                placeholder="Select or enter a course (e.g. BCS)"
                value={unitForm.degreeProgram}
                onChange={(event) => setUnitForm({ ...unitForm, degreeProgram: event.target.value })} />
              <datalist id="degree-program-options">
                {DEGREE_PROGRAMS.map((degree) => <option key={degree} value={degree} />)}
              </datalist>
            </label>
            <label>Academic level
              <select required value={unitForm.academicLevel}
                onChange={(event) => setUnitForm({ ...unitForm, academicLevel: event.target.value })}>
                {ACADEMIC_LEVELS.map((level) => <option key={level} value={level}>{level}</option>)}
              </select>
            </label>
            <label>Name
              <input required maxLength={120} placeholder="Operating Systems" value={unitForm.name}
                onChange={(event) => setUnitForm({ ...unitForm, name: event.target.value })} />
            </label>
            <div className="row">
              <label>Year
                <select value={unitForm.yearOfStudy}
                  onChange={(event) => setUnitForm({ ...unitForm, yearOfStudy: Number(event.target.value) })}>
                  {[1, 2, 3, 4, 5].map((year) => <option key={year} value={year}>Year {year}</option>)}
                </select>
              </label>
              <label>Semester
                <select value={unitForm.semester}
                  onChange={(event) => setUnitForm({ ...unitForm, semester: Number(event.target.value) })}>
                  <option value={1}>Semester 1</option>
                  <option value={2}>Semester 2</option>
                </select>
              </label>
            </div>
            <label>Assign lecturer
              <select value={unitForm.lecturerId}
                onChange={(event) => setUnitForm({ ...unitForm, lecturerId: event.target.value })}>
                <option value="">No lecturer assigned</option>
                {lecturers.map((lecturer) => (
                  <option key={lecturer.id} value={lecturer.id}>{lecturer.name} · {lecturer.school}</option>
                ))}
              </select>
            </label>
            <label className="public-course-toggle">
              <input type="checkbox" checked={unitForm.isPublic}
                onChange={(event) => setUnitForm({ ...unitForm, isPublic: event.target.checked })} />
              <span>
                <strong>Make Public</strong>
                <small>Visible to students from other schools.</small>
              </span>
            </label>
            <button className="btn primary" disabled={busyAction === 'unit'}>
              {busyAction === 'unit' ? <><span className="spinner spinner-light" /> Adding…</> : 'Add course unit'}
            </button>
          </form>
        </section>

        <section className="card">
          <h2>Schedule exam</h2>
          <form className="form" onSubmit={addExam}>
            <fieldset className="exam-course-picker">
              <legend>Select course units ({examForm.courseUnitIds.length} selected)</legend>
              <div className="exam-course-options">
                {units.map((unit) => {
                  const unitId = String(unit.id);
                  return (
                    <label className="exam-course-option" key={unit.id}>
                      <input
                        type="checkbox"
                        checked={examForm.courseUnitIds.includes(unitId)}
                        onChange={(event) => setExamForm((current) => ({
                          ...current,
                          courseUnitIds: event.target.checked
                            ? [...current.courseUnitIds, unitId]
                            : current.courseUnitIds.filter((id) => id !== unitId)
                        }))}
                      />
                      <span>
                        <strong>{unit.code}</strong> — {unit.name}
                        <small>{unit.school} · {unit.degreeProgram} · Year {unit.yearOfStudy} · Semester {unit.semester}</small>
                      </span>
                    </label>
                  );
                })}
              </div>
              {!units.length && <p className="muted small">Add course units before scheduling exams.</p>}
            </fieldset>
            <label>Date
              <input type="date" required value={examForm.examDate}
                onChange={(event) => setExamForm({ ...examForm, examDate: event.target.value })} />
            </label>
            <div className="row">
              <label>Start time
                <input type="time" required value={examForm.startTime}
                  onChange={(event) => setExamForm({ ...examForm, startTime: event.target.value })} />
              </label>
              <label>End time
                <input type="time" required value={examForm.endTime}
                  onChange={(event) => setExamForm({ ...examForm, endTime: event.target.value })} />
              </label>
            </div>
            <label>Room
              <input required maxLength={50} placeholder="LR-101" value={examForm.room}
                onChange={(event) => setExamForm({ ...examForm, room: event.target.value })} />
            </label>
            <label>Program
              <select value={examForm.program}
                onChange={(event) => setExamForm({ ...examForm, program: event.target.value })}>
                <option value="BOTH">Both / joint</option>
                {PROGRAM_MODES.map((mode) => (
                  <option key={mode} value={mode}>{mode.charAt(0) + mode.slice(1).toLowerCase()}</option>
                ))}
                <option value="ALL">All program modes</option>
              </select>
            </label>
            <button className="btn primary" disabled={busyAction === 'exam' || !examForm.courseUnitIds.length}>
              {busyAction === 'exam' ? <><span className="spinner spinner-light" /> Scheduling…</> : 'Schedule exam'}
            </button>
          </form>
        </section>

        <section className="card admin-exams">
          <h2>Scheduled exams{!isSuperAdminUser ? ` — ${adminIdentity?.school || 'your school'} only` : ''} ({exams.length})</h2>
          <SearchBar value={examSearch} onChange={setExamSearch}
            placeholder="Search by course, room, or date…" label="Search scheduled exams" />
          {!exams.length && (examSearch ? noSearchResults(examSearch) : <p className="muted">No exams scheduled yet.</p>)}
          {groupExamSessions(exams).map((session) => (
            <ExamSessionCard key={session.key} session={session} onDelete={deleteExam}
              onEdit={startExamEdit} busyExamId={busyExamId} />
          ))}
        </section>
      </div>}

      {tab === 'lecturers' && (
        <div className="lecturer-management">
          <section className="card">
            <h2>Create lecturer account</h2>
            <p className="muted small">Lecturers can sign in after an administrator creates their account.</p>
            <form className="form" onSubmit={addLecturer}>
              <label>Full name
                <input required maxLength={100} value={lecturerForm.name}
                  onChange={(event) => setLecturerForm({ ...lecturerForm, name: event.target.value })} />
              </label>
              <label>Email
                <input required type="email" autoComplete="email" value={lecturerForm.email}
                  onChange={(event) => setLecturerForm({ ...lecturerForm, email: event.target.value })} />
              </label>
              <label>Temporary password
                <input required type="password" minLength={8} autoComplete="new-password"
                  value={lecturerForm.password}
                  onChange={(event) => setLecturerForm({ ...lecturerForm, password: event.target.value })} />
              </label>
              <label>School
                {isSuperAdminUser ? (
                  <select value={lecturerForm.school}
                    onChange={(event) => setLecturerForm({ ...lecturerForm, school: event.target.value })}>
                    {SCHOOLS.map((school) => <option key={school} value={school}>{school}</option>)}
                  </select>
                ) : <span className="readonly-school">{adminIdentity?.school || 'Your school'}</span>}
              </label>
              <button className="btn primary" disabled={busyAction === 'lecturer'}>
                {busyAction === 'lecturer' ? <><span className="spinner spinner-light" /> Creating…</> : 'Create lecturer'}
              </button>
            </form>
          </section>
          <section className="card">
            <h2>Lecturers{!isSuperAdminUser ? ` — ${adminIdentity?.school || 'your school'}` : ''} ({visibleLecturers.length})</h2>
            <SearchBar value={lecturerSearch} onChange={setLecturerSearch}
              placeholder="Search lecturer name or email…" label="Search lecturers" />
            {!visibleLecturers.length ? (
              lecturerSearch ? noSearchResults(lecturerSearch) : <p className="muted">No lecturer accounts yet.</p>
            ) : (
              <ul className="management-list">
                {visibleLecturers.map((lecturer) => (
                  <li key={lecturer.id}>
                    <strong>{lecturer.name}</strong>
                    <span>{lecturer.email} · {lecturer.school}</span>
                    <span className="muted small">{lecturer.courseCount} assigned course units</span>
                  </li>
                ))}
              </ul>
            )}
          </section>
          <section className="card lecturer-assignment-card">
            <h2>Assign lecturers and Lecture Coordinators</h2>
            <p className="muted small">
              Assign a lecturer and one Lecture Coordinator to each course unit. Coordinators can confirm rooms, remind that unit’s lecturer, and take attendance.
            </p>
            {!units.length ? (
              <p className="muted">Create course units before assigning lecturers.</p>
            ) : (
              <>
                {!lecturers.length && <p className="muted small">Create lecturer accounts to enable lecturer assignments.</p>}
                {!coordinators.length && <p className="muted small">Create Lecture Coordinator accounts to enable coordinator assignments.</p>}
                <SearchBar value={unitSearch} onChange={setUnitSearch}
                  placeholder="Search course units by code or name…" label="Search course assignments" />
                {!assignmentUnits.length ? noSearchResults(unitSearch) : null}
                <div className="lecturer-assignment-list">
                {assignmentUnits.map((unit) => (
                  <div className="lecturer-assignment-row" key={unit.id}>
                    <div className="lecturer-assignment-course">
                      <strong>{unit.code} — {unit.name}</strong>
                      <span className="muted small">
                        {unit.school} · {unit.degreeProgram} · Year {unit.yearOfStudy} · Semester {unit.semester}
                      </span>
                    </div>
                    <label className="lecturer-assignment-select">
                      <span className="sr-only">Lecturer for {unit.code}</span>
                      <select
                        value={lecturerAssignments[unit.id] ?? ''}
                        onChange={(event) => setLecturerAssignments((current) => ({
                          ...current,
                          [unit.id]: event.target.value
                        }))}
                      >
                        <option value="">No lecturer assigned</option>
                        {lecturers.map((lecturer) => (
                          <option key={lecturer.id} value={lecturer.id}>
                            {lecturer.name} · {lecturer.school}
                          </option>
                        ))}
                      </select>
                    </label>
                    <button type="button" className="btn primary small"
                      onClick={() => assignLecturer(unit)}
                      disabled={busyAction === `assign-${unit.id}`}>
                      {busyAction === `assign-${unit.id}`
                        ? <><span className="spinner spinner-light" /> Saving…</>
                        : 'Save lecturer'}
                    </button>
                    <label className="lecturer-assignment-select">
                      <span className="sr-only">Lecture Coordinator for {unit.code}</span>
                      <select
                        value={coordinatorAssignments[unit.id] ?? ''}
                        onChange={(event) => setCoordinatorAssignments((current) => ({
                          ...current,
                          [unit.id]: event.target.value
                        }))}
                      >
                        <option value="">No coordinator assigned</option>
                        {coordinators.filter((item) => item.school === unit.school).map((coordinator) => (
                          <option key={coordinator.id} value={coordinator.id}>
                            {coordinator.email} · {coordinator.school}
                          </option>
                        ))}
                      </select>
                    </label>
                    <button type="button" className="btn primary small"
                      onClick={() => assignCoordinator(unit)}
                      disabled={busyAction === `coordinator-${unit.id}`}>
                      {busyAction === `coordinator-${unit.id}`
                        ? <><span className="spinner spinner-light" /> Saving…</>
                        : 'Save coordinator'}
                    </button>
                  </div>
                ))}
                </div>
              </>
            )}
          </section>
        </div>
      )}

      {tab === 'students' && (
        <section className="card admin-students-card">
          <h2>Students{!isSuperAdminUser ? ` — ${adminIdentity?.school || 'your school'} only` : ''} ({students.length})</h2>
          <SearchBar value={studentSearch} onChange={setStudentSearch}
            placeholder="Search name, student number, or program…" label="Search students" />
          {!students.length ? (
            studentSearch ? noSearchResults(studentSearch) : <p className="muted">No student accounts found.</p>
          ) : (
            <div className="admin-student-list">
              {students.map((studentRecord) => (
                <article className="admin-student-row" key={studentRecord.id}>
                  <strong>{studentRecord.firstName} {studentRecord.lastName}</strong>
                  <span>{studentRecord.studentNumber} · {studentRecord.email}</span>
                  <span className="muted small">
                    {studentRecord.school} · {studentRecord.academicLevel} · {studentRecord.degreeProgram} · {studentRecord.program} · Year {studentRecord.yearOfStudy}, Semester {studentRecord.semester}
                  </span>
                </article>
              ))}
            </div>
          )}
        </section>
      )}

      {tab === 'classes' && (
        <div className="lecturer-management">
          <section className="card">
            <h2>{editingClassId ? 'Edit lecture schedule' : 'Schedule a weekly lecture'}</h2>
            <form className="form" onSubmit={addClass}>
              <label>Course unit
                <select required value={classForm.courseUnitId}
                  onChange={(event) => {
                    const selectedUnit = units.find((unit) => String(unit.id) === event.target.value);
                    setClassForm({
                      ...classForm,
                      courseUnitId: event.target.value,
                      lecturerId: selectedUnit?.lecturerId ? String(selectedUnit.lecturerId) : ''
                    });
                  }}>
                  <option value="">Select a course unit</option>
                  {units.map((unit) => (
                    <option key={unit.id} value={unit.id}>
                      {unit.code} — {unit.name} · {unit.academicLevel}
                    </option>
                  ))}
                </select>
              </label>
              <label>Lecturer
                <select required value={classForm.lecturerId}
                  disabled={!scheduleLecturers.length}
                  onChange={(event) => setClassForm({ ...classForm, lecturerId: event.target.value })}>
                  <option value="">Select a lecturer</option>
                  {scheduleLecturers.map((lecturer) => (
                    <option key={lecturer.id} value={lecturer.id}>{lecturer.name}</option>
                  ))}
                </select>
                {selectedScheduleCourse && !scheduleLecturers.length && (
                  <span className="muted small">Create a lecturer account for {selectedScheduleCourse.school} first.</span>
                )}
              </label>
              <label>Day of week
                <select value={classForm.dayOfWeek}
                  onChange={(event) => setClassForm({ ...classForm, dayOfWeek: event.target.value })}>
                  {WEEK_DAYS
                    .map((day) => <option key={day} value={day}>{day}</option>)}
                </select>
              </label>
              <div className="row">
                <label>Start time
                  <input required type="time" value={classForm.startTime}
                    onChange={(event) => setClassForm({ ...classForm, startTime: event.target.value })} />
                </label>
                <label>End time
                  <input required type="time" value={classForm.endTime}
                    onChange={(event) => setClassForm({ ...classForm, endTime: event.target.value })} />
                </label>
              </div>
              <label>Room
                <input required maxLength={50} value={classForm.room}
                  onChange={(event) => setClassForm({ ...classForm, room: event.target.value })} />
              </label>
              <label>Target program mode
                <select value={classForm.program}
                  onChange={(event) => setClassForm({ ...classForm, program: event.target.value })}>
                  <option value="BOTH">Both / all modes</option>
                  {PROGRAM_MODES.map((mode) => (
                    <option key={mode} value={mode}>{mode.charAt(0) + mode.slice(1).toLowerCase()}</option>
                  ))}
                </select>
              </label>
              <button className="btn primary"
                disabled={busyAction === 'class' || !units.length || !classForm.lecturerId}>
                {busyAction === 'class'
                  ? <><span className="spinner spinner-light" /> Saving…</>
                  : editingClassId ? 'Update lecture' : 'Schedule lecture'}
              </button>
              {editingClassId && (
                <button type="button" className="btn ghost" onClick={cancelClassEdit}>Cancel edit</button>
              )}
            </form>
          </section>
          <section className="card">
            <h2>Scheduled lectures ({classes.length})</h2>
            {!classes.length ? <p className="muted">No weekly classes scheduled yet.</p> : (
              <div className="class-schedule-list">
                {classes.map((classSession) => (
                  <article className="class-schedule-item admin-lecture-item" key={classSession.id}>
                    <div className="class-day">{classSession.dayOfWeek}</div>
                    <div className="class-info">
                      <strong>{classSession.code} — {classSession.courseName}</strong>
                      <span>{formatTime(classSession.startTime)}–{formatTime(classSession.endTime)} · {classSession.room}</span>
                      {classSession.lecturerName && (
                        <b className="lecture-lecturer">Lecturer: {classSession.lecturerName}</b>
                      )}
                      <span className="muted small">
                        Target: {classSession.program === 'BOTH' ? 'All program modes' : classSession.program}
                      </span>
                    </div>
                    <div className="lecture-actions">
                      <button type="button" className="btn ghost small"
                        onClick={() => editClass(classSession)}>Edit</button>
                      <button type="button" className="btn danger-btn small"
                        onClick={() => deleteClass(classSession.id)}
                        disabled={busyAction === `delete-class-${classSession.id}`}>
                        {busyAction === `delete-class-${classSession.id}` ? 'Deleting…' : 'Delete'}
                      </button>
                    </div>
                  </article>
                ))}
              </div>
            )}
          </section>
        </div>
      )}
      {tab === 'chat' && adminChatOpen && (
        <section className="chat-screen-overlay admin-chat-screen">
          <header className="chat-page-title">
            <button type="button" className="btn ghost chat-back-button"
              onClick={() => setAdminChatOpen(false)}>
              <span aria-hidden="true">←</span> Chat &amp; Updates
            </button>
            <span className="eyebrow">Conversation</span>
            <h1>{targetRoom === 'GLOBAL' ? 'Global Chat' : targetRoom}</h1>
            <p className="muted">Messages for this chat room, including relevant global updates.</p>
          </header>
          <ChatPanel key={targetRoom} admin targetRoom={targetRoom} fullPage />
        </section>
      )}
      {editingExam && (
        <Modal title="Edit exam" onClose={() => setEditingExam(null)} className="exam-edit-modal">
          <h2>Edit exam</h2>
          <p className="muted small">{editingExam.code} — {editingExam.courseName}</p>
          <form className="form" onSubmit={saveExamEdit}>
            <label>Exam date
              <input type="date" required value={examEditForm.examDate}
                onChange={(event) => setExamEditForm({ ...examEditForm, examDate: event.target.value })} />
            </label>
            <div className="form-row">
              <label>Start time
                <input type="time" required value={examEditForm.startTime}
                  onChange={(event) => setExamEditForm({ ...examEditForm, startTime: event.target.value })} />
              </label>
              <label>End time
                <input type="time" required value={examEditForm.endTime}
                  onChange={(event) => setExamEditForm({ ...examEditForm, endTime: event.target.value })} />
              </label>
            </div>
            <label>Room
              <input required maxLength={50} value={examEditForm.room}
                onChange={(event) => setExamEditForm({ ...examEditForm, room: event.target.value })} />
            </label>
            <label>Program
              <select value={examEditForm.program}
                onChange={(event) => setExamEditForm({ ...examEditForm, program: event.target.value })}>
                {PROGRAM_MODES.map((mode) => <option key={mode} value={mode}>{mode}</option>)}
                <option value="BOTH">All program modes</option>
                <option value="ALL">All students</option>
              </select>
            </label>
            <div className="modal-actions">
              <button type="button" className="btn ghost" onClick={() => setEditingExam(null)}
                disabled={busyExamId === editingExam.id}>Cancel</button>
              <button type="submit" className="btn primary" disabled={busyExamId === editingExam.id}>
                {busyExamId === editingExam.id ? 'Saving…' : 'Save changes'}
              </button>
            </div>
          </form>
        </Modal>
      )}
    </main>
  );
}
