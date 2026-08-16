# expense_tracker_mobile

A mobile application that allows users to seamlessly log, track, and analyse their expenses. Built with a scalable architecture, this project features a manual-entry Minimum Viable Product (MVP) designed to easily integrate an autonomous AI receipt parsing engine in the future.

---

## 🏗️ System Architecture

This repository contains the mobile application built with Flutter, utilising a local-first architecture where all data is stored on the device.

```
expense_tracker_mobile/
├── lib/               # Flutter Application (Mobile UI & Client Logic)
├── ios/               # iOS native code
└── android/           # Android native code
```

1. **Frontend (Flutter):** Captures user manual input (and future receipt uploads) and provides an interactive UI.
2. **Local Database (SQLite):** Persists all expense data and categories directly on the device, ensuring privacy and offline availability.

## 🛠️ Technology Stack

### Mobile Frontend

- **Framework:** Flutter
- **Language:** Dart

### Local Storage

- **Database:** SQLite (via `sqflite`)

### Future Infrastructure

- **Deployment:** App Store & Google Play
- **AI Engine:** To be determined

## 📈 Dashboard Core Statistics

The application transforms raw financial data into actionable insights through a centralised dashboard tracking:

- **Total Monthly Spend:** Prominent visual tracking of current month vs. previous month.
- **Category Breakdown:** A breakdown of spending categories (Groceries, Dining, Bills) using interactive charts.
- **Spending Over Time:** Historical line/bar graphs tracking spending velocity.

## 🚀 Local Development Setup

To run this project locally, ensure you have the Flutter SDK installed and a device/simulator running.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- iOS Simulator or Android Emulator

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd expense_tracker_mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

Start the application on your connected device or emulator:

To see a list of all currently running simulators and connected devices, along with their IDs:

```bash
flutter devices
```

To start the application on a specific device, use its ID:

```bash
flutter run -d <DEVICE_ID>
```

If you only have one device running, you can simply use:

```bash
flutter run
```

## Data Prerequisites

- For dashboard main card, previous month statistics, if not available, should default to zero. If the previous month is zero, the percentage change should be null.
- For analytics page, date ranges should be queried locally. Data ranges should be sorted by start date, with older weeks appearing first. If a week has no expenses, it should still be included with an empty items array.
- First day of the week is Monday.

## Decisions

## Dev tracking
- Home tab: analytics.
- For pending approvals, redesign modal.
- Change theme colours, possibly add a setting to set custom themes.
- For lower casing: should user-typed strings be forced to lower case too?