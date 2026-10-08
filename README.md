# O2 Clinic - Healthcare Management Application 🏥

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

**O2 Clinic** is a state-of-the-art, cross-platform healthcare management and appointment booking application built with Flutter. Designed with user experience in mind, it bridges the gap between healthcare providers and patients by offering a seamless, intuitive, and highly responsive mobile experience.

## ✨ Key Features

### 🧑‍⚕️ Comprehensive Appointment Booking
- **Multi-Service Booking:** Book appointments for specialized doctors, radiology centers, and cosmetic services.
- **Flexible Modes:** Support for both in-clinic visits and online consultations.
- **Smart Scheduling:** Real-time availability, dynamic time slots, and smart calendar integration.

### 🌓 Modern UI/UX & Theming
- **Dynamic Theming:** Full support for Light and Dark modes, offering a comfortable viewing experience at any time of day.
- **Premium Aesthetics:** Clean typography, glassmorphism elements, and highly polished UI components that rival top-tier global applications.
- **Responsive Layouts:** Perfectly adapted for various screen sizes, ensuring a native feel on both iOS and Android.

### 🌍 Localization (i18n)
Fully localized to serve a diverse user base, supporting:
- 🇺🇸 English (en)
- 🇸🇦 Arabic (ar) - Right-to-Left (RTL) support
- 🇮🇱 Hebrew (he) - Right-to-Left (RTL) support

### 🔐 Authentication & Roles
- **Patient Portal:** Seamless onboarding, profile management, and appointment tracking.
- **Doctor/Staff Portal:** Dedicated interfaces for healthcare providers to manage schedules and patient records securely.
- **Firebase Auth Integration:** Secure authentication handling.

### ⚡ Architecture & Performance
- **GetX State Management:** Utilizing GetX for high-performance, reactive state management, dependency injection, and route handling.
- **Scalable Folder Structure:** Feature-based architecture ensuring high maintainability and scalable code separation.
- **Real-time Data:** Integrated with Firebase Firestore for real-time synchronization of bookings, chat support, and notifications.

## 🛠 Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **Language:** [Dart](https://dart.dev/)
* **State Management:** [GetX](https://pub.dev/packages/get)
* **Backend/Database:** Firebase (Auth, Cloud Firestore, Cloud Storage)
* **Localization:** `flutter_localizations` & ARB files

## 📂 Project Structure

The project follows a modular, feature-first architecture to ensure clean code boundaries:

```text
lib/
├── common/             # Reusable UI widgets, buttons, inputs, and layouts
├── core/               # Core configurations, App Colors, Fonts, Routing, and Utilities
├── features/           # Independent modules (Domain-driven)
│   ├── appointments/   # Appointment history, status tracking, and details
│   ├── auth/           # Login, Registration, and role-based authentication
│   ├── booking/        # Scheduling logic for radiology, cosmetic, and clinics
│   ├── dashboard/      # Main home screen, banners, and quick actions
│   ├── doctors/        # Doctor profiles and directories
│   └── chat_support/   # Real-time customer support chat
├── l10n/               # Localization ARB files (en, ar, he)
└── main.dart           # Application Entry Point
```

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites
* Flutter SDK (Latest Stable Version)
* Dart SDK
* Android Studio / Xcode (for emulation and building)

### Installation

1. **Clone the repo**
   ```sh
   git clone https://github.com/MahmoudAshraf19/o2-clinic.git
   ```
2. **Navigate to the project directory**
   ```sh
   cd o2_clinic
   ```
3. **Install dependencies**
   ```sh
   flutter pub get
   ```
4. **Run the application**
   ```sh
   flutter run
   ```

## 🤝 Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🛡️ License
Distributed under the MIT License. See `LICENSE` for more information.

---
*Built with ❤️ for a healthier tomorrow.*
