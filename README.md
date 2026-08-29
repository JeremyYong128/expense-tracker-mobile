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

### Notes

- Credit cards
    - Out of scope: Category-specific multipliers (only flat rate supported).
    - Out of scope: Sign-up bonuses or caps.
    - Out of scope: Custom statement periods (tracking is by calendar month).
    - Out of scope: Historical rate changes (rewards use current rate).

### Priority Changes
- Notification item design

### Future

- Horizontal display
- Swipe left then click to delete stuff (instead of dedicated buttons in the edit forms)
- Credit cards
    - Need some indication in the history and recurring cards when an expense is tagged with a credit card
- Custom dropdowns (including date and time pickers)
- Redesign modal for pending approvals
- Need a way for users to reorder things in the "Manage" tab
- Transaction list should have more info, show associated recurring expense/credit card
    - Will need to implement UI info update mechanism, or else the card will bug out when the recurring transaction related to a transaction is deleted, and then a user tries to edit it.
- Possible changes to consider:
    - Dashboard previous month 0 to current month nonzero: 100% or null for percentage change?
    - Currently when editing the recurring transaction intervals, if the start date/time or the interval is changed, it calculates the next due date starting from the latest recorded individual transaction, or the new start date, whichever is later. Is this too confusing?