# Exam Timetable PWA

A responsive Progressive Web App for students to choose course units and view
their exam schedule. Administrators can manage course units and exams. The
frontend uses React and Vite; the API uses Express and MySQL.

## Project layout

```text
client/   React application, styles, and PWA configuration
server/   Express API, MySQL schema, and environment variable example
```

## Requirements

- Node.js 18 or newer
- MySQL 8 or newer

## First-time setup

1. Create or update the database tables and import the NKUMBA August 2026
   examination workbook by running `server/schema.sql` in MySQL.    The script adds the degree-program and exam school/program columns to an
   existing installation, creates persistent chat read-state tracking for
   unread-message badges, migrates existing tables, and imports the Day,
   Weekend, and Masters timetable entries. The workbook import is designed to
   be repeatable.
   For example, from PowerShell:

   ```powershell
   Get-Content .\server\schema.sql | mysql -u root -p
   ```

2. Import the SBA Day timetable for November 12–30, 2026. This import is safe
   to rerun and adds the SBA degree categories (`DEG`, `DIP`, `HCBM`, `NBCA`)
   to the course units shown to matching students:

   ```powershell
   Get-Content .\server\sba-day-timetable.sql | mysql -u root -p exam_pwa
   ```

3. Create the server environment file and edit it with your own database
   credentials and secrets:

   ```powershell
   Copy-Item .\server\.env.example .\server\.env
   ```

   Set `JWT_SECRET` to a long, random value and change the demo administrator
   email and password before using the app beyond a local presentation.

3. Install dependencies in each app:

   ```powershell
   Set-Location .\server
   npm install
   Set-Location ..\client
   npm install
   Set-Location ..
   ```

## Run locally

Open two PowerShell terminals from the project directory.

Terminal 1:

```powershell
Set-Location .\server
npm run dev
```

Terminal 2:

```powershell
Set-Location .\client
npm run dev
```

Open <http://localhost:5173>. Vite forwards `/api` requests to the server on
port 5000.

Students and administrators use the same sign-in form. The API determines the
account role from the credentials and routes the user to the student timetable
or the appropriate admin panel. Super Admins can create school-scoped admins
and Lecture Coordinator accounts from Manage Admins. Assign each Lecture
Coordinator to the course units they support from Manage. Coordinators can
confirm assigned-unit lecture rooms, send in-app reminders to the assigned
lecturer (using the email saved on the lecturer profile), and manage same-day
attendance; students can check in to their ongoing registered classes with a
coordinator-generated code. On
server startup, `ADMIN_EMAIL` and
`ADMIN_PASSWORD` are hashed and inserted as the initial Super Admin if that
email is not already present in the `admins` table. Keep these values private
and use a strong password. The Super Admin can create school-scoped admins;
School Admin API access is restricted to their assigned school.

The NKUMBA workbook timetable is tagged for the School of Computing and
Informatics (`SCI`); the separate SBA Day timetable import is tagged `SBA`.
SBA entries are assigned to Year 1, Semester 1, and use the degree categories
listed in the course catalog. During sign-up, the degree-program dropdown is
filtered to the selected school using that school's course-unit records. For
example, add course units with `school = 'SBA'` and `degree_program = 'BBA'`
or `'BHRM'` to make those programs available to SBA students. Students can
browse and search course units for their school, including units from a
different year or semester, and register for the units they take. Course units
marked public are visible and registerable by students across all schools;
non-public units remain limited to students in their own school.
The exam timetable shows only exams attached to a student's registrations and
matching the student's Day/Weekend program (or marked `BOTH`). The signup form
includes degree codes found in the workbook. The configured administrator can
add degree-tagged course units and schedule an exam for one or more units.

Existing student accounts that were migrated receive the `UNASSIGNED` degree
program because their degree cannot be safely inferred. Set the real degree
and check that the school, study year, and semester are correct before they use
the timetable, for example:

```sql
UPDATE students
SET degree_program = 'BIST', school = 'SCI'
WHERE student_number = 'YOUR_STUDENT_NUMBER';
```

### Web push notifications

Generate a VAPID key pair from the server directory with:

```powershell
npx web-push generate-vapid-keys
```

Set `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, and `VAPID_SUBJECT` (for example,
`mailto:admin@school.ac.ug`) in `server/.env`, then restart the API. Keep the
private key secret. Apply `server/schema.sql` to create the push subscription
table. Students can opt in from Profile settings; push requires a supported
browser and HTTPS (localhost is supported for development).

Two timetable entries without a clear degree/year/semester are imported as
general `ALL` units (year and semester `0`) available across schools. Some degree-only
entries with no cohort level are also available to all years and semesters of
that degree. The original workbook cell text and its sheet/row/date label are
retained on each imported exam and can be expanded from the exam card.

The Masters sheet labels two sessions as December 28 and 29, although those
dates fall on different weekdays than the headings imply. They are scheduled
on November 28 and 29, 2026, while the original labels remain available in the
exam details. Two explicit timetable notes also override their column dates:
the Day User Interface Design session is scheduled November 21, and Research
Methods is scheduled November 28. Review these source notes against the
university's final approved timetable before publishing it.

## Production build

```powershell
Set-Location .\client
npm run build
```

The Express server serves `client/dist` when that build exists. Keep the
environment file private and use HTTPS when deploying the PWA.
