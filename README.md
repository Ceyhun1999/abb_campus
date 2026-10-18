# ABB Campus

[![Tests](https://github.com/Ceyhun1999/abb_campus/actions/workflows/tests.yml/badge.svg)](https://github.com/Ceyhun1999/abb_campus/actions/workflows/tests.yml)

ABB Campus is an iOS app for students, teachers and staff of the ABB academy.
Students see their next lesson, grades, attendance, schedule and announcements in one place.
Teachers and mentors upload monthly attendance, task and exam scores from Excel, schedule exams and cancel lessons, and students are notified.
Employees (academy staff) manage students, groups, teachers and announcements, and can import a whole group of students or its schedule from an Excel file.

The app works with a Laravel REST API (`https://campus.jeywastudio.com/api`).

The Demo Day plan, demo accounts and answers to "why this architecture, what did you test" are in [`docs/DEMO.md`](docs/DEMO.md). The project requirements are in [`docs/REQUIREMENTS.md`](docs/REQUIREMENTS.md).

## Screenshots

### Employee

| Home | Students | Group | Excel import | Teachers | Announcements |
| --- | --- | --- | --- | --- | --- |
| <img src="docs/screenshots/6-employee-home-light.png" width="140"> | <img src="docs/screenshots/7-employee-students-light.png" width="140"> | <img src="docs/screenshots/8-employee-group-light.png" width="140"> | <img src="docs/screenshots/9-employee-import-light.png" width="140"> | <img src="docs/screenshots/16-employee-teachers-light.png" width="140"> | <img src="docs/screenshots/17-employee-announcements-light.png" width="140"> |
| <img src="docs/screenshots/6-employee-home-dark.png" width="140"> | <img src="docs/screenshots/7-employee-students-dark.png" width="140"> | <img src="docs/screenshots/8-employee-group-dark.png" width="140"> | <img src="docs/screenshots/9-employee-import-dark.png" width="140"> | <img src="docs/screenshots/16-employee-teachers-dark.png" width="140"> | <img src="docs/screenshots/17-employee-announcements-dark.png" width="140"> |

### Teacher and mentor

| Home | Group | Schedule | Exams | Attendance | Cancel a lesson |
| --- | --- | --- | --- | --- | --- |
| <img src="docs/screenshots/18-teacher-home-light.png" width="140"> | <img src="docs/screenshots/19-teacher-group-light.png" width="140"> | <img src="docs/screenshots/20-teacher-schedule-light.png" width="140"> | <img src="docs/screenshots/21-teacher-exams-light.png" width="140"> | <img src="docs/screenshots/22-teacher-attendance-light.png" width="140"> | <img src="docs/screenshots/23-teacher-cancel-light.png" width="140"> |
| <img src="docs/screenshots/18-teacher-home-dark.png" width="140"> | <img src="docs/screenshots/19-teacher-group-dark.png" width="140"> | <img src="docs/screenshots/20-teacher-schedule-dark.png" width="140"> | <img src="docs/screenshots/21-teacher-exams-dark.png" width="140"> | <img src="docs/screenshots/22-teacher-attendance-dark.png" width="140"> | <img src="docs/screenshots/23-teacher-cancel-dark.png" width="140"> |

### Student

| Home | Grades | Schedule | Attendance | Notifications |
| --- | --- | --- | --- | --- | --- |
| <img src="docs/screenshots/10-student-home-light.png" width="140"> | <img src="docs/screenshots/12-student-grades-light.png" width="140"> | <img src="docs/screenshots/14-student-schedule-light.png" width="140"> | <img src="docs/screenshots/11-student-attendance-light.png" width="140"> | <img src="docs/screenshots/15-student-notifications-light.png" width="140"> |
| <img src="docs/screenshots/10-student-home-dark.png" width="140"> | <img src="docs/screenshots/12-student-grades-dark.png" width="140"> | <img src="docs/screenshots/14-student-schedule-dark.png" width="140"> | <img src="docs/screenshots/11-student-attendance-dark.png" width="140"> | <img src="docs/screenshots/15-student-notifications-dark.png" width="140"> |

### Sign in

| Role selection | Login | Forgot password | Profile |
| --- | --- | --- | --- |
| <img src="docs/screenshots/1-roles-light.png" width="160"> | <img src="docs/screenshots/2-login-light.png" width="160"> | <img src="docs/screenshots/3-forgot-light.png" width="160"> | <img src="docs/screenshots/5-profile-light.png" width="160"> |
| <img src="docs/screenshots/1-roles-dark.png" width="160"> | <img src="docs/screenshots/2-login-dark.png" width="160"> | <img src="docs/screenshots/3-forgot-dark.png" width="160"> | <img src="docs/screenshots/5-profile-dark.png" width="160"> |

## Features

- **Role selection.** The user chooses Student, Teacher or Employee before signing in.
- **Login.** Validation runs in the view model, server errors come back in Azerbaijani, and the last used email is remembered.
- **Forgot password.** A sheet with three steps: email → 6-digit code → new password.
- **Session persistence.** The token is stored in the Keychain and restored on launch through `/auth/me`. Expired tokens are removed.
- **Student home.** Shows the next lesson from the schedule, attendance and the latest announcements, all loaded in parallel with `async let`. The attendance card opens the full attendance history.
- **Grades (student).** A plain list, by month, of the task and exam scores the teacher has entered. Nothing is calculated: no averages, no module totals.
- **Schedule (student).** Upcoming or past lessons grouped by day, with time and room.
- **Notifications (student).** Announcements for all students and for the student's own group.
- **Profile.** Shows the user's details, lets the user choose the appearance (System, Light or Dark), changes the password and signs out (with confirmation) through `/auth/logout`.
- **Employee home.** An academy card, the number of active students, teachers, groups and announcements, and the latest announcements with a link to all of them.
- **Students (employee).** Search by name, email or group, filter by status (All / Active / Inactive) and by course, see each student's group and course, open details, and activate or deactivate an account.
- **Groups (employee).** Search and filter by course, see study progress, open a group to see its students, and create or edit a group in a sheet: course, teacher, up to 2 mentors, start date and an end date picked in a calendar. Names are limited to 20 characters, and closing a form with unsaved changes asks for confirmation. If new dates leave lessons outside the group, the app asks before they are removed; an exam with uploaded scores cannot be left outside.
- **Excel import.** Pick an `.xlsx`, `.xls` or `.csv` file (up to 5 MB) with `first_name, last_name, email` columns. It is uploaded as multipart form data. The import is all or nothing: the screen shows how many rows were added, or the error for each invalid row. Finished groups cannot be imported into.
- **Group schedule (employee).** Open **Dərs cədvəli** in a group to see its upcoming and past lessons by day, and upload the schedule from an Excel file with `date, starts_at, ends_at, title, room, description` columns. Dates can be `2026-10-20` or `20.10.2026` (or real Excel date cells), times `09:00`. The file is checked as a whole: lessons must fall within the group's dates and must not overlap each other or an exam. A valid file replaces only the lessons between its first and last date, so the schedule can be uploaded month by month and a month is corrected by uploading it again; a lesson at the same date and time keeps its cancellation. The lessons belong to the group's teacher, so students and the teacher see them in their own schedule right away. Employees can also cancel or restore a lesson from here (swipe or long-press it).
- **Teachers (employee).** Filter by position (teacher / mentor) and specialty, see the group count, open a teacher to see the groups they teach or mentor, and deactivate or reactivate their account.
- **Announcements (employee).** Publish, edit and delete announcements with a title, a message (up to 500 characters), a priority (low / medium / high, each with its own colour), an audience (everyone, students, or teachers and mentors) and up to 3 links.
- **Teacher and mentor home.** The number of groups, students, upcoming exams and the next five lessons that are not cancelled. A mentor gets the same tools as the teacher, but only in the groups they mentor.
- **Cancel a lesson (teacher, mentor, employee).** Swipe or long-press a lesson, choose a reason (*Müəllim xəstədir*, *Bayram*, *Qeyri-iş günü* or *Digər* with a note) and confirm. The lesson stays in the schedule crossed out with its reason, and the group's students get a notice. A cancelled lesson can be restored. Past lessons cannot be changed.
- **Monthly attendance (teacher, mentor).** Upload an Excel file with an `email` column and one column per lesson date; cells are `+` (present), `-` (absent), `g` (late) or `ü` (excused). Dates must be within the group and not in the future, and when the month has a schedule, they must be lesson days. Finished groups still accept the last month's uploads. The screen shows each student's attendance for the chosen month, and the student's attendance percentage changes right away.
- **Monthly task scores (teacher, mentor).** Choose a month (within the group's dates, not in the future) and upload a file with an `email` column and one column per task (scores 0–100). A new file for the same month replaces that month's scores.
- **Exams (teacher, mentor).** Schedule an exam (title, date, time, room): it appears in the students' schedule and they get a notice. After the exam, upload a file with `email` and `score` columns.
- **For students.** Cancelled lessons and exams are marked in the schedule, the next-lesson card skips cancelled lessons, notices for their group appear in notifications, and **Qiymətlər** shows monthly task and exam scores.
- **Paging.** The students, groups, teachers and announcements lists load 20 items at a time as you scroll. Search waits for typing to pause, and responses that arrive out of order are ignored.
- **Dark mode.** Every color comes from the asset catalog and has a dark variant. In the profile, every user can follow the phone's setting or always use the light or dark look; the choice is saved and applied to the whole app.
- **Screen sizes.** Checked on iPhone SE (4.7") up to iPhone 17 Pro and on iPad. On iPhone the app runs in portrait; on iPad it supports every orientation.
- **Loading, error and empty states.** Every screen uses one shared `AsyncContentView` driven by a `ViewState` enum, with retry on error and pull-to-refresh.

## Tech stack

| Area | Used |
| --- | --- |
| UI | SwiftUI, custom Manrope font |
| Architecture | MVVM + Services, protocol-based dependency injection |
| State management | Observation (`@Observable`, `@State`, `@Bindable`, `@Environment`) |
| Networking | `URLSession` with `async/await`, generic `NetworkService`, typed `Endpoint`s, bearer token injection, multipart upload |
| Navigation | `NavigationStack` with value-based `navigationDestination`, `sheet`, `TabView`, `confirmationDialog`, `fileImporter`, `searchable` |
| Persistence | Keychain (auth token), `UserDefaults` (last login email, chosen appearance) |
| Testing | Swift Testing (unit tests), XCTest / XCUITest (UI tests) |
| CI | GitHub Actions: every push and pull request runs all tests |

## Architecture

```
View  ──▶  ViewModel  ──▶  Service (protocol)  ──▶  NetworkService  ──▶  REST API
                │
                └──▶  AuthenticationState  ──▶  SecureStorage (Keychain)
```

- **Views** only render state and forward user actions. They have no business logic, networking or validation.
- **ViewModels** (`@Observable`, `@MainActor`) hold screen state, validate input and call services.
- **Services** describe API operations behind protocols: `AuthService`, `PasswordResetService`, `EmployeeDashboardService`, `StudentDirectoryService`, `TeacherService`, `GroupService`, `AnnouncementService`, `TeachingService` and `LessonService`. Employee and teacher screens read the group schedule through the shared `GroupScheduleSource` protocol. `Default…` types implement them with the `NetworkService`.
- **TokenStore** holds the access token. Endpoints marked `requiresAuthorization` get the `Bearer` header from the network service, so views and view models never deal with tokens.
- **AuthenticationState** is the single source of truth for the signed-in user. It is shared through the SwiftUI environment.
- **AppDependencies** is the composition root. It builds the live services. When the app is launched with `-ui-testing`, it uses in-memory stub services instead.

```
abb_campus/
├── App/            # App entry point, AppDependencies, UI-testing stubs
├── Core/           # Networking, Keychain, UserDefaults, auth state, paging and search helpers, extensions
├── Models/         # Codable API models
├── Services/       # Service protocols and their API implementations (auth, student, employee)
├── ViewModels/     # One view model per screen
├── Features/       # Screens grouped by feature, with their own components
├── Shared/         # Reusable UI components (PrimaryButton, IconCircleView, ProgressBar…)
├── Root/           # RootView: decides between login, loading and the main app
└── Resources/      # Fonts
abb_campusTests/    # Unit tests + mocks
abb_campusUITests/  # UI tests
```

## Tests

- **Unit tests** (`abb_campusTests`, 212 tests) cover the auth view models (`LoginViewModel`, `ForgotPasswordViewModel`, `RoleSelectionViewModel`), `ProfileViewModel`, all student view models (home with next-lesson selection, grades by month, schedule grouping, attendance, notifications), all employee view models (dashboard, students, teachers and groups lists and details, create and edit group, student and schedule Excel import, group schedule, create, edit and delete announcements), all teacher view models (home, groups, schedule, cancelling and restoring lessons, monthly attendance and task scores with month switching, exams and the exam form), the student's monthly scores, `AuthenticationState`, `ValidationHelper`, paging and request building for `EmployeeEndpoint`, `TeachingEndpoint` and `LessonEndpoint`. They check both success and error cases. Every service is replaced by a mock through its protocol, so the tests never call the real API.
- **Concurrency and network tests** check that a slow, older response never overwrites a newer one, that a cancelled refresh keeps the data on screen, and that server errors, timeouts, offline mode and invalid JSON show a clear message. The network tests use a stubbed `URLProtocol` instead of the real server.
- **UI tests** (`abb_campusUITests`) cover the login flow (role selection, the validation error, the wrong password error, a successful login → home → logout, and opening the forgot password sheet) the student flow (home → attendance, grades → the teacher's scores, switching between dark and light in the profile, checked on the screen's pixels) and the employee flow (dashboard → students → Inactive filter → student details, group → import screen, and group → schedule → schedule import), the teacher flow (cancelling a lesson with a reason, scheduling an exam, opening the attendance upload), plus two navigation stress tests (20 push/back cycles, rapid tab switching and returning from the background). The app starts with `-ui-testing`, so the tests use stub services.

Run all tests from the terminal:

```bash
xcodebuild test \
  -project abb_campus.xcodeproj \
  -scheme abb_campus \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Or run them in Xcode with **⌘U**.

## How to run

Requirements:
- Xcode 26 or newer
- iOS 17.0+ simulator or device

Steps:
1. `git clone https://github.com/Ceyhun1999/abb_campus.git`
2. Open `abb_campus.xcodeproj`.
3. Select the `abb_campus` scheme and a simulator, then press **⌘R**.

Demo accounts:

| Role | Email | Password |
| --- | --- | --- |
| Student | `student@abb.local` | `Password123!` |
| Employee | `employee@abb.local` | `abc12345` |
| Teacher | `teacher@abb.local` | `Password123!` |

To try the Excel imports, drag the files from [`docs/demo`](docs/demo) onto the simulator and save them in Files. Both imports are all or nothing.

- **Students:** open a group, choose **Excel-dən tələbə idxal et** and pick a file. [`telebeler.xlsx`](docs/demo/telebeler.xlsx) is valid and adds 6 students (including `student@abb.local`), while [`telebeler_sehvli.xlsx`](docs/demo/telebeler_sehvli.xlsx) has 3 invalid rows, so nothing is imported and the errors are listed.
- **Teacher uploads:** sign in as `teacher@abb.local` (an employee must first make this account the teacher of a group with the students from `telebeler.xlsx`). In a group, [`davamiyyet.xlsx`](docs/demo/davamiyyet.xlsx) is attendance for 5, 7, 9 and 12 October (lesson days of `cedvel.xlsx`), [`tapsiriq_ballari.xlsx`](docs/demo/tapsiriq_ballari.xlsx) has 3 tasks for October, and [`imtahan_ballari.xlsx`](docs/demo/imtahan_ballari.xlsx) has exam scores (open a past exam → **Balları yüklə**).
- **Schedule:** open a group that has a teacher and covers October 2026, choose **Dərs cədvəli → Excel-dən cədvəl idxal et**. [`cedvel.xlsx`](docs/demo/cedvel.xlsx) adds 12 evening lessons (Mon/Wed/Fri, 05.10–30.10.2026), while [`cedvel_sehvli.xlsx`](docs/demo/cedvel_sehvli.xlsx) has a wrong date, an end time before the start time and an overlapping lesson, so the schedule stays as it was.

## Backend

The app talks to a Laravel 12 REST API. For the employee screens these endpoints were added: `GET /employee/dashboard`, `GET /students`, `GET /students/{id}`, `GET /teachers`, `GET /teachers/{id}`, `PATCH /users/{id}/status`, creating and editing groups, student and schedule Excel import (`POST /groups/{id}/students/import`, `GET /groups/{id}/schedule`, `POST /groups/{id}/schedule/import`), and creating, editing and deleting announcements. Lists support search, filters and paging. For teachers and mentors: `POST /lessons/{id}/cancel` and `/restore` (also for employees), `POST /groups/{id}/attendance/import`, `GET /groups/{id}/attendance/summary`, `POST /groups/{id}/tasks/import`, `GET /groups/{id}/assessments`, `POST /groups/{id}/exams` and `POST /exams/{id}/scores/import`; students get `GET /student/assessments`, and notices for their own group in `GET /my/announcements`. While building the student screens, three existing backend bugs were fixed: attendance was always 0%, ungraded modules lowered the average, and the group students list returned a 500 error. Everything is covered by PHPUnit feature tests (129 tests). Logins (5 a minute), password resets (6 a minute) and API requests (120 a minute per user) are rate limited.
