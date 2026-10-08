# O2 Clinic App - Architecture & Folder Structure

This document outlines the architecture and folder structure conventions for the **O2 Clinic** Flutter application, ensuring consistency, scalability, and clean code principles.

## 🏛 Architectural Pattern: Feature-First (Clean Architecture)
The project strictly follows a **Feature-First** architecture. This means the codebase is divided into independent features (e.g., `booking`, `auth`, `appointments`). Each feature is self-contained and manages its own UI, business logic, and data layers.

---

## 📂 Folder Structure Overview

```text
lib/
 ├── core/              # Global shared logic, configurations, and core utilities.
 ├── features/          # Independent application features (e.g., booking, auth).
 ├── common/            # Shared UI components and widgets across features.
 ├── l10n/              # Localization and translation files.
 ├── _deprecated/       # Unused/deprecated files scheduled for future deletion.
 ├── main.dart          # Entry point of the application.
 └── firebase_options.dart 
```

### 1. `core/` (Global Core)
This directory contains everything that is global to the application and **does not depend on any specific feature**.
- `constants/`: Global constants, API endpoints, error messages.
- `theme/`: Colors, typography, and global UI themes (`AppColors`, `AppTextStyles`).
- `utils/`: Global utility classes and helpers.
- `services/`: Global services like network interceptors or local storage initialization.
- `navigation/`: App routing and navigation configurations.

### 2. `features/` (Feature Modules)
Each feature acts as a standalone module containing its own layers:
```text
features/booking/
 ├── data/
 │    ├── models/       # Data models and DTOs (e.g., BookingResult).
 │    └── services/     # Feature-specific services/repositories (e.g., Firestore services).
 │
 ├── presentation/
 │    ├── controllers/  # State management (GetX Controllers).
 │    ├── screens/      # UI Screens (must end with _screen.dart).
 │    ├── widgets/      # Feature-specific UI components.
 │    └── utils/        # Helpers specific to this feature's UI (e.g., booking_helper.dart).
```

---

## 📜 Naming Conventions

### File Names
- All file names must be in `snake_case` (e.g., `clinical_booking_screen.dart`).
- **Screens:** Any file that represents a full page/screen must end with `_screen.dart` (e.g., `online_consultation_booking_screen.dart`).
- **Controllers:** Must end with `_controller.dart` (e.g., `radiology_booking_controller.dart`).
- **Models:** Must end with `_model.dart` or `_models.dart`.

### Class Names
- Class names must be in `PascalCase` and match the file suffix:
  - `class ClinicalBookingScreen extends StatelessWidget`
  - `class RadiologyBookingController extends GetxController`

---

## 🚫 Anti-Patterns to Avoid
1. **Circular Dependencies:** The `core/` folder **must never** import from the `features/` folder. Feature-specific logic belongs inside the feature itself.
2. **Orphaned Files:** Do not place files directly under the `lib/` root folder (except `main.dart` and `firebase_options.dart`).
3. **Redundant Folders:** Avoid creating `pages/` and `screens/` within the same feature. Standardize on `screens/`.
4. **Dead Code:** Any unused files (Models, Controllers, or Screens) should be moved to the `_deprecated/` folder to keep the active codebase clean.
