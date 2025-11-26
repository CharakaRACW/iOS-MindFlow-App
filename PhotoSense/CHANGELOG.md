# Changelog

All notable changes to **PhotoSense** will be documented in this file.

## [0.1.0] - 2025-11-26
### Added
- Initial SwiftUI + Core Data project setup targeting iOS 17.
- `PersistenceController` with Core Data stack and preview data.
- `ClassifiedPhoto` Core Data entity and model extension.
- MVVM structure with folders for Views, ViewModels, Models, Services, and Utilities.
- `CoreDataManager` service for async CRUD operations on `ClassifiedPhoto`.
- `ImageClassifier` service using Core ML + Vision with MobileNetV2.
- `CameraViewModel` handling image picking, classification, and saving to history.
- `CameraView` UI with image preview, picker integration, classification controls, and result card.
- `HistoryView` with sectioned list, search, pull-to-refresh, swipe-to-delete, and detail navigation.
- `PhotoDetailView` for full-screen image display, confidence meter, sharing, and deletion.
- `HomeView` dashboard with hero section, stats, quick actions, recent photos, and tips.
- Reusable components (buttons, cards, pickers, confidence meters, empty states, loading overlay).
- `DesignSystem` and shared view extensions for card/glass styles and animations.
- `MainTabView` with Home, Camera, and History tabs plus history badge.
- `SplashView` and `PhotoSenseApp` wiring with lifecycle handling and Core Data saving.
- `SettingsView` with about info and a "clear all data" action.
- Documentation files: README, TechnicalReport, and this changelog.

### Notes
- This version is intended as a functional prototype and reference implementation. Future versions may refine the UI, add cloud sync, or adopt a custom ML model.
