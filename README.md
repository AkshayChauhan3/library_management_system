# Library Management App

A modern, feature-rich Library Management application built with Flutter and Firebase. This app helps students and library administrators manage book transactions, profile information, and library access seamlessly.

## Features

- **Secure Authentication**:
  - Email & Password Login/Registration.
  - **Google Sign-In** integration for quick access.
  - Persistent login session (users stay logged in after app restart).

- **Digital Library Card**:
  - Generates a dynamic **QR Code** for each user containing their details (Name, Enrollment, Department).
  - Used for quick check-ins and book verification at the library counter.

- **Real-Time Dashboard**:
  - View current Check-In status.
  - See active issued books with due dates.
  - Color-coded status for Overdue (Red) vs On-time (Green) books.

- **Profile Management**:
  - View and edit personal details (Name, Enrollment, Department, Semester).
  - Secure Logout functionality.

- **Dark Mode UI**:
  - Sleek, modern dark-themed user interface for better readability and aesthetics.

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Core, Auth, Firestore)
- **State Management**: `setState` & `StreamBuilder` (Real-time data sync)
- **Key Packages**:
  - `firebase_auth`: Authentication
  - `cloud_firestore`: Database
  - `google_sign_in`: Google Auth integration
  - `qr_flutter`: QR Code generation
  - `slide_to_act`: Interactive UI elements

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- Valid `firebase_options.dart` file (configured via `flutterfire configure`).

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/library_management_app.git
    cd library_management_app
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the app**:
    ```bash
    flutter run
    ```

## Project Structure

- `lib/main.dart`: Entry point. Handles auth state checks.
- `lib/LoginPage.dart`: user authentication (Login/Signup).
- `lib/HomePage.dart`: Main dashboard (QR code, Issued books).
- `lib/profile.dart`: User profile management.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements.
