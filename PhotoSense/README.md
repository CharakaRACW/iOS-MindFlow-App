# PhotoSense - Intelligent Photo Classification

## Overview
PhotoSense is an iOS app that performs on-device image classification using Core ML. It lets you capture or select photos, runs them through a pre-trained model, and stores the classification history locally so you can review insights over time. Everything runs on device to protect user privacy.

## Features
- ✓ Real-time image classification using Core ML and Vision
- ✓ Core Data persistence for classification history
- ✓ Modern SwiftUI interface with dashboard, camera, and history views
- ✓ Dark mode and dynamic type support
- ✓ Accessibility-conscious design (VoiceOver, large tap targets)

## Screenshots
> _Add screenshots from the running app here (Home, Camera, History, Detail)._ 

## Technical Stack
- SwiftUI
- Core ML & Vision framework (e.g. MobileNetV2 model)
- Core Data with NSPersistentContainer
- MVVM architecture
- iOS 17.0+ (Xcode 15+)

## Architecture
PhotoSense is built using the Model-View-ViewModel (MVVM) pattern:

- **Models**
  - Core Data entities such as `ClassifiedPhoto` represent persisted data.
  - Lightweight extensions and helpers live in the `Models` folder.
- **ViewModels**
  - Contain presentation logic and business rules.
  - Expose `@Published` state to SwiftUI views and orchestrate calls into services.
  - Examples: `CameraViewModel`, `HomeViewModel`.
- **Views**
  - SwiftUI screens and reusable components.
  - Observe view models and render UI based on published state.
  - Handle navigation and user input.
- **Services**
  - Reusable logic for Core Data (`CoreDataManager`) and Core ML (`ImageClassifier`).
  - Run heavy work on background queues and surface results back to the main actor.

## Setup Instructions
1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd PhotoSense
   ```
2. Open the Xcode project:
   ```
   open PhotoSense.xcodeproj
   ```
3. Make sure you are using **Xcode 15+** with the **iOS 17 SDK**.
4. Add the Core ML model (e.g. `MobileNetV2.mlmodel`) to the app target.
5. Build and run on a simulator or device.
6. On first launch, grant **Camera** and **Photo Library** permissions when prompted.

## Project Structure

- `PhotoSenseApp.swift` – App entry point, splash screen, tab navigation, app lifecycle.
- `Views/`
  - `HomeView` – Dashboard with stats, quick actions, recent photos, and tips.
  - `CameraView` – Capture/choose photos, run classification, and save history.
  - `HistoryView` – Sectioned list of classified photos, search, and detail navigation.
  - `PhotoDetailView` – Full-screen detail with confidence and sharing.
  - `Components/` – Reusable UI pieces (buttons, cards, pickers, meters, empty states).
- `ViewModels/`
  - `CameraViewModel` – Manages camera/photo picking, classification, and saving.
  - `HomeViewModel` – Computes statistics and recent items.
  - `ClassificationViewModel` – Generic classification state (if used globally).
- `Models/`
  - `ClassifiedPhoto+CoreData` – NSManagedObject subclass and helpers.
- `Services/`
  - `CoreDataManager` – Core Data CRUD helpers and async APIs.
  - `ImageClassifier` – Vision/Core ML service for image classification.
- `Utilities/`
  - `Persistence` – Core Data stack (`PersistenceController`).
  - `DesignSystem` – Colors, typography, spacing, radii, shadows.
  - `Extensions` – View and color extensions.
  - `AppConstants` – Shared configuration values.

## Key Technologies

### Core ML & Vision

PhotoSense uses **Core ML** together with the **Vision** framework to classify `UIImage` instances:

- The app loads a pre-trained Core ML model (e.g. `MobileNetV2.mlmodel`) and wraps it in a `VNCoreMLModel`.
- A `VNImageRequestHandler` is configured with the input image and orientation.
- A `VNCoreMLRequest` runs on a background queue. The completion handler extracts the top `VNClassificationObservation` and returns its identifier and confidence.
- Results are exposed through `ImageClassifier.ClassificationResult` and consumed by view models.

### Core Data

- Core Data is configured using `NSPersistentContainer` in `PersistenceController`.
- `ClassifiedPhoto` is the main entity, storing:
  - `id`, `imageName`, `classification`, `confidence`, `timestamp`, `imageData`.
- `CoreDataManager` provides async methods to:
  - Save a new classification.
  - Fetch photos sorted by date.
  - Delete an item or clear history.
- SwiftUI views use `@Environment(\.managedObjectContext)` and `@FetchRequest` for live-updating lists.

## Future Enhancements
- Custom ML model training for domain-specific classifications.
- Cloud sync of history across devices (CloudKit or custom backend).
- Richer social sharing templates.
- Basic photo editing and cropping prior to classification.

## AI Assistance
This project was developed with the help of an AI coding assistant (Windsurf AI / Cascade) to:
- Scaffold the initial SwiftUI + Core Data project structure.
- Implement MVVM view models and services for classification and persistence.
- Generate reusable UI components and a design system.
- Provide documentation and technical explanations.

All code has been reviewed and can be iterated on like any regular Swift project.

## License

This project is licensed under the **MIT License**. See `LICENSE` (or add one) for details.
