<div align="center">

<img src="assets/images/logo.png" width="120" height="120" alt="PrepPilot Logo"/>

<h1>PrepPilot</h1>

<p><strong>Your local-first career preparation manager</strong></p>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-Local--First-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org)
[![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-0065D0?style=for-the-badge)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge&logo=android&logoColor=white)]()
[![Release](https://img.shields.io/github/v/release/sangsaist/PrepPilot?style=for-the-badge&logo=github&color=5C6BC0)](https://github.com/sangsaist/PrepPilot/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/sangsaist/PrepPilot/total?style=for-the-badge&logo=github)](https://github.com/sangsaist/PrepPilot/releases)

<br/>

> **PrepPilot** is a 100% offline, local-first Flutter app that centralizes everything a student needs for placement preparation — tasks, hackathons, certifications, projects, and files — in one focused, minimal interface.

<br/>

[Download APK](#-download) · [Features](#-features) · [Architecture](#-architecture) · [Schema](#-database-schema) · [Tech Stack](#-tech-stack) · [Roadmap](#-roadmap) · [Contributing](#-contributing)

</div>

---

## 📥 Download

<div align="center">

### Latest Release — v1.0.0

<a href="https://github.com/sangsaist/PrepPilot/releases/download/v1.0.0/PrepPilot-v1.0.0.apk">
  <img src="https://img.shields.io/badge/Download%20APK-v1.0.0-5C6BC0?style=for-the-badge&logo=android&logoColor=white" alt="Download APK"/>
</a>

| File | Size | Platform |
|---|---|---|
| [PrepPilot-v1.0.0.apk](https://github.com/sangsaist/PrepPilot/releases/download/v1.0.0/PrepPilot-v1.0.0.apk) | ~18 MB | Android 5.0+ (API 21+) |

**Install instructions:**
1. Download the APK from the link above
2. On your Android device: Settings → Security → Enable "Install from unknown sources"
3. Open the downloaded APK and tap Install
4. No internet connection required — ever

> iOS build coming in v1.1.0

</div>

---

## 🧩 Features

| Module | Description |
|---|---|
| 📅 **Calendar + Tasks** | Central spine of the app. All deadlines, tasks, and activity milestones render as calendar events. |
| 📊 **Dashboard** | Today view with open tasks, active activities, and a live **deadline pressure score**. |
| 🏆 **Activity Tracker** | Single screen for hackathons, certifications, and courses — unified by a `type` field. |
| 🛠 **Project Manager** | Track personal dev projects with tasks linked directly from the tasks table. |
| 🗄 **Storage Vault** | File index that stores metadata + local URIs. No shadow filesystem, no permission hell. |
| 🔔 **Notifications** | Local deadline alerts and resume reminder triggers — all generated on-device. |
| 📄 **PDF Export** | One-page achievement summary: projects, certs, hackathons, open tasks. |
| 📤 **CSV Export** | Export tasks and activities as CSV for external use. |

---

## 🏛 Architecture

PrepPilot follows a **local-first, offline-only** architecture. No network calls. No backend. No cloud dependency.

```
┌─────────────────────────────────────────────────┐
│                  Flutter UI Layer                │
│                                                 │
│   Dashboard  │  Calendar+Tasks  │  Activity     │
│   (Today)    │  (Core Spine)    │  Tracker      │
│              │                  │               │
│   Project    │  Storage Vault   │  Notifications│
│   Manager    │  (File Index)    │  (Local)      │
└──────────────────────┬──────────────────────────┘
                       │ Riverpod Providers
┌──────────────────────▼──────────────────────────┐
│              Repository Layer                    │
│   TaskRepo │ ActivityRepo │ ProjectRepo          │
│   NoteRepo │ FileRepo     │ ReminderRepo         │
└──────────────────────┬──────────────────────────┘
                       │ sqflite DAOs
┌──────────────────────▼──────────────────────────┐
│           SQLite Database (on-device)            │
│  tasks │ activities │ projects │ notes           │
│  file_index │ reminders                          │
└─────────────────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│           Device File System                     │
│   /files │ /images │ /exports                   │
└─────────────────────────────────────────────────┘
```

### Module Dependency Map

```mermaid
graph TD
    CAL[📅 Calendar + Tasks\nCore Spine]:::purple
    DASH[📊 Dashboard\nToday View + Score]:::teal
    ACT[🏆 Activity Tracker\nHackathons · Certs · Courses]:::teal
    PROJ[🛠 Project Manager\nDev Projects]:::teal
    VAULT[🗄 Storage Vault\nFile Metadata Index]:::gray
    NOTIF[🔔 Notifications\nDeadline · Resume Alerts]:::gray
    DB[(SQLite\nLocal Only)]:::db

    CAL --> DASH
    ACT --> CAL
    PROJ --> CAL
    VAULT --> CAL
    CAL --> NOTIF
    DB --> CAL
    DB --> VAULT
    DB --> NOTIF

    classDef purple fill:#5C6BC0,stroke:#3949AB,color:#fff
    classDef teal fill:#26A69A,stroke:#00897B,color:#fff
    classDef gray fill:#78909C,stroke:#546E7A,color:#fff
    classDef db fill:#37474F,stroke:#263238,color:#fff
```

---

## 🗄 Database Schema

All data is stored in a single SQLite database on the device. Uses a **polymorphic FK pattern** (`linked_type` + `linked_id`) so notes, files, and reminders attach to any entity without extra join tables.

```mermaid
erDiagram
    TASKS {
        integer task_id PK
        text title
        text date
        text time
        integer priority
        text status
        text linked_type
        integer linked_id
    }
    ACTIVITIES {
        integer activity_id PK
        text type
        text name
        text platform
        text deadline
        integer progress
        text notes
    }
    PROJECTS {
        integer project_id PK
        text name
        text description
        text status
        text repo_url
    }
    NOTES {
        integer note_id PK
        text linked_type
        integer linked_id
        text text_content
        text image_uri
        text created_at
    }
    FILE_INDEX {
        integer file_id PK
        text linked_type
        integer linked_id
        text label
        text local_uri
        text file_type
        text created_at
    }
    REMINDERS {
        integer reminder_id PK
        text linked_type
        integer linked_id
        text trigger_type
        text scheduled_at
        integer fired
    }

    TASKS ||--o{ NOTES : "has"
    TASKS ||--o{ REMINDERS : "triggers"
    ACTIVITIES ||--o{ NOTES : "has"
    ACTIVITIES ||--o{ FILE_INDEX : "stores"
    ACTIVITIES ||--o{ REMINDERS : "triggers"
    PROJECTS ||--o{ TASKS : "linked to"
    PROJECTS ||--o{ NOTES : "has"
    PROJECTS ||--o{ FILE_INDEX : "stores"
```

---

## 🛠 Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **UI Framework** | Flutter 3.x | Cross-platform mobile UI |
| **Language** | Dart 3.x | App logic |
| **State Management** | Riverpod | Reactive state, no manual rebuilds |
| **Local Database** | sqflite + path_provider | SQLite on-device storage |
| **Calendar** | table_calendar | Calendar view with event markers |
| **Notifications** | flutter_local_notifications | On-device deadline alerts |
| **File Picker** | file_picker | Attach files to vault |
| **PDF Export** | pdf + printing | Achievement summary export |
| **CSV + Share** | share_plus | Share tasks/activities as CSV |
| **Onboarding** | shared_preferences | Store user name, first-launch flag |
| **File Opening** | open_file | Open vault files |
| **URL Launch** | url_launcher | Open repo links |
| **Speed Dial** | flutter_speed_dial | Multi-action FAB |
| **IDE** | Antigravity IDE | AI-agent assisted development |

---

## 📊 Deadline Pressure Score

The dashboard shows a **pressure score (0–100)** computed from open tasks and upcoming activity deadlines. Purely local arithmetic — no ML, no API.

```dart
int calcPressureScore(List<Task> tasks, List<Activity> activities) {
  final now = DateTime.now();
  int score = 0;
  for (final t in tasks.where((t) => t.status != 'completed')) {
    final diff = t.date.difference(now).inDays;
    if (diff < 0)       score += 3; // overdue
    else if (diff == 0) score += 2; // due today
    else if (diff <= 7) score += 1; // due this week
  }
  for (final a in activities) {
    final diff = a.deadline.difference(now).inDays;
    if (diff < 0)       score += 3;
    else if (diff <= 2) score += 2;
    else if (diff <= 7) score += 1;
  }
  return score.clamp(0, 100);
}
```

| Score | Status | Color |
|---|---|---|
| 0 – 20 | All clear | 🟢 Green |
| 21 – 50 | Moderate load | 🟡 Amber |
| 51 – 100 | High pressure | 🔴 Red |

---

## 🗺 Roadmap

```mermaid
gantt
    title PrepPilot Build Plan
    dateFormat  YYYY-MM-DD
    section Phase 1 — Core Loop
    Flutter + SQLite setup         :done, p1a, 2026-03-16, 3d
    Tasks screen + CRUD            :done, p1b, after p1a, 3d
    Calendar view                  :done, p1c, after p1b, 3d
    Dashboard today view           :done, p1d, after p1c, 2d

    section Phase 2 — Trackers
    Activity Tracker screen        :done, p2a, after p1d, 3d
    Project Manager screen         :done, p2b, after p2a, 3d
    Notes (text + image)           :done, p2c, after p2b, 2d

    section Phase 3 — Storage + Notifications
    File index vault               :done, p3a, after p2c, 2d
    Local notifications            :done, p3b, after p3a, 2d
    Resume reminder trigger        :done, p3c, after p3b, 2d

    section Phase 4 — Polish
    Pressure score + dashboard     :done, p4a, after p3c, 2d
    PDF + CSV export               :done, p4b, after p4a, 3d
    Dark mode + onboarding         :done, p4c, after p4b, 2d
    v1.0.0 release                 :done, p4d, after p4c, 1d
```

---

## 🚀 Getting Started

```bash
# Clone the repo
git clone https://github.com/sangsaist/PrepPilot.git
cd PrepPilot

# Install dependencies
flutter pub get

# Run on device or emulator
flutter run

# Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Requirements:** Flutter 3.x · Dart 3.x · Android SDK 21+ or iOS 13+

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

Please follow the existing folder structure and Riverpod patterns when contributing.

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

<img src="assets/images/logo.png" width="48" height="48" alt="PrepPilot"/>

Built with focus by [sangsaist](https://github.com/sangsaist)

[![GitHub](https://img.shields.io/badge/GitHub-sangsaist-181717?style=flat-square&logo=github)](https://github.com/sangsaist/PrepPilot)

</div>