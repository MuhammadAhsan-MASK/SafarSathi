# HostelBook Technical Documentation

This document outlines the technologies, tools, and components used in the **HotelBook** application. This information is intended for use in the Software Requirements Specification (SRS) and Software Design Specification (SDS).

## 1. Core Technology Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Language** | [Dart](https://dart.dev/) (SDK ^3.8.1) | Strongly typed language optimized for client-side development. |
| **Framework** | [Flutter](https://flutter.dev/) | UI toolkit for building natively compiled applications for mobile, web, and desktop. |
| **Backend** | [Firebase](https://firebase.google.com/) | Provides backend services including authentication, database, and hosting. |
| **Environment** | Windows/Linux/macOS | Multi-platform support for Android, iOS, Web, and Desktop. |

## 2. Integrated Services & Libraries

### Backend Services (Firebase)
*   **Firebase Authentication**: Managed user sign-up, login, and secure session management.
*   **Cloud Firestore**: NoSQL document database used for real-time data storage (Preferences, Hostel details, etc.).
*   **Firebase Core**: Essential plugin to initialize Firebase services.

### State Management
*   **Provider**: A wrapper around InheritedWidget to make widgets easy to reuse and manage state efficiently across the app.

### Key Dependencies
*   **google_maps_flutter**: Integration of Google Maps for location-based services (hostel/restaurant mapping).
*   **shared_preferences**: Local persistent storage for small data (user preferences, session flags).
*   **google_fonts**: Access to a wide range of custom typography for a premium UI.
*   **http**: Facilitates making HTTP requests to external APIs.
*   **intl**: Internationalization and localization support, including date and number formatting.

## 3. Project Architecture

The project follows a **Feature-First Architecture**, ensuring modularity and scalability.

### Directory Structure (`lib/`)
*   `core/`: Contains shared utilities, constants, and common widgets used across the entire app.
*   `features/`: Organized by functional modules:
    *   `auth/`: Sign-up, Sign-in, and Password Reset screens.
    *   `home/`: Main dashboard and navigation logic.
    *   `hotels/`: Hostel/Hotel search, filters, and booking details.
    *   `restaurants/`: Discovery of local dining options.
    *   `transport/`: Local transport routes and information.
    *   `attractions/`: Tourist spots and local sightseeing.
    *   `budget/`: Expense tracking and financial management.
    *   `profile/`: User account management and settings.

## 4. UI/UX Design Principles
*   **Responsive Design**: Layouts are designed to adapt to various screen sizes.
*   **Premium Aesthetics**: Use of custom fonts, smooth transitions, and a consistent color palette (Deep Purple/Orange) to provide a high-end user experience.
*   **Material Design**: Adherence to Material Design guidelines for consistent and intuitive navigation.

## 5. Development Tools
*   **Flutter SDK**: The primary build tool.
*   **Android Studio / VS Code**: Recommended IDEs for development.
*   **Git**: Version control system for tracking changes.
