# Library Management App

A modern Flutter application for managing library operations, built with Firebase for real-time data and authentication.

## Features

*   **User Authentication**:
    *   Secure Email & Password Login/Registration.
    *   Google Sign-In integration.
    *   **Persistent Login**: Users stay logged in across app restarts.
*   **Dashboard**:
    *   View current check-in status.
    *   Digital Library ID card with QR Code.
    *   View currently issued books and their due dates.
*   **Profile Management**:
    *   Update personal details (Name, Enrollment, Department, Semester).
    *   Logout functionality.
*   **Book Tracking**:
    *   Real-time tracking of borrowed books.
    *   Visual indicators for overdue books.

## Tech Stack

*   **Frontend**: Flutter (Dart)
*   **Backend**: Firebase (Core, Auth, Cloud Firestore)
*   **State Management**: `StreamBuilder` & `setState`
*   **Key Packages**:
    *   `firebase_auth`: Authentication
    *   `cloud_firestore`: Database
    *   `google_sign_in`: Google Auth support
    *   `qr_flutter`: QR Code generation
    *   `slide_to_act`: Interactive UI elements

## Getting Started

### Prerequisites

*   Flutter SDK installed.
*   Firebase project configured.

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/library_management_app.git
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```

## Project Structure

```
lib/
├── main.dart           # Entry point & Auth State listener
├── LoginPage.dart      # Login & Registration UI
├── HomePage.dart       # Main Dashboard
├── profile.dart        # User Profile & Settings
├── BooksPage.dart      # Books listing (if applicable)
└── services/
    └── auth_service.dart # Centralized Authentication Logic
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
