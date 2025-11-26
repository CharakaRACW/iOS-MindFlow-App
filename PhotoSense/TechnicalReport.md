# PhotoSense - Technical Report

## 1. Purpose & Target Audience

**Purpose.** PhotoSense is an iOS app that performs on-device image classification for photos captured with the camera or imported from the photo library. It aims to give users quick, private insights about what is in their images.

**Problem solved.** Many users want AI-powered photo understanding without sending personal images to remote servers. PhotoSense demonstrates a privacy-friendly approach using Core ML directly on the device.

**Target users.**
- iOS users interested in trying local AI features.
- Developers and students exploring SwiftUI, Core ML, and Core Data.
- Designers evaluating modern dashboard and history flows for media apps.

## 2. Design Decisions

### Why Core ML

- **On-device inference.** Core ML allows classification to run entirely on device, reducing latency and protecting user privacy.
- **Tight OS integration.** Vision + Core ML provide convenient APIs for image preprocessing (orientation, cropping) and model execution.
- **Energy and performance.** Apple-supplied models like MobileNetV2 are optimized for real-time performance on iOS hardware.

### UI/UX choices

- **Three main tabs.** Home, Camera, and History map cleanly to the primary user flows.
- **Dashboard first.** Home presents high-level stats, quick actions, recent items, and tips to communicate value at a glance.
- **Progressive disclosure.** Details about a classification (confidence, timestamp, sharing, deletion) live in a dedicated detail view.
- **Visual feedback.** Animated confidence meters, cards, and haptics reinforce that work is happening and has completed.

### Architecture rationale

- **MVVM.** ViewModels encapsulate state and business logic; Views focus on layout and user interaction. This improves testability and separation of concerns.
- **Services.** CoreDataManager and ImageClassifier are reusable services that can be injected wherever needed, decoupling persistence and ML logic from views.
- **Core Data.** Provides mature, performant persistence with integration into SwiftUI via `@FetchRequest`.

## 3. Implementation Details

### Key features

- **Camera & library integration.** A `UIViewControllerRepresentable` wrapper exposes `UIImagePickerController` to SwiftUI. A `CameraViewModel` coordinates permissions, image selection, and classification.
- **Image classification.** `ImageClassifier` loads a Core ML model, creates a Vision request, and returns the top classification result and confidence via an async API.
- **Persistence.** `CoreDataManager` runs inserts and deletes on a background context while exposing async methods for saving and fetching `ClassifiedPhoto` objects.
- **History & analytics.** `HistoryView` groups photos into sections by relative date and supports search, pull-to-refresh, and deletion. `HomeViewModel` computes totals, most frequent classification, average confidence, and daily counts.

### Technical challenges

1. **Threading and Core Data.** Ensuring writes occur on a background context while reads update SwiftUI-bound state on the main actor.
2. **Vision/Core ML integration.** Handling image orientation correctly and mapping Vision results into simple, app-friendly models.
3. **SwiftUI navigation and state.** Coordinating NavigationStacks inside a TabView while keeping view models and Core Data contexts consistent.

### Solutions implemented

- A `PersistenceController` encapsulates `NSPersistentContainer`, a main view context, and a reusable background context.
- `CoreDataManager` wraps background work with `withCheckedThrowingContinuation` to expose `async` methods.
- `ImageClassifier` translates `UIImage.Orientation` into `CGImagePropertyOrientation` and runs Vision requests on a background queue.
- Each tab hosts its own `NavigationStack`, while `PhotoSenseApp` injects the shared managed object context at the root.

## 4. Testing

### Manual testing

- Camera flow on device: capture photo → classify → save → verify history entry.
- Photo library flow: pick from library → classify → save → open detail view.
- History operations: search, swipe-to-delete, section grouping, detail delete.
- Dark mode and Dynamic Type: verified with system appearance and text size changes.

### Edge cases handled

- No selected image when user taps "Classify" or "Save".
- Permission denied for camera or photo library.
- Devices without a camera (simulator) can still use the library and see a helpful message.
- Classification or save failures surface user-friendly errors.

### Known limitations

- Assumes a single Core ML classification model bundled in the app.
- No automated unit/UI tests are included; testing is manual.
- History fetches all records; batch fetching could be introduced for very large datasets.

## 5. Challenges & Solutions

- **Time constraints.** Focus was placed on building a coherent vertical slice (camera → classify → save → history) rather than advanced features like editing or sharing templates.
- **Complex state in SwiftUI.** View models were introduced for camera, home, and history to keep views declarative and reduce state duplication.
- **Error surfaces.** A small error-handling layer with custom error enums and user-facing messages was added to avoid exposing low-level errors directly to users.

## 6. Future Work

- **Custom models.** Support importing or downloading domain-specific Core ML models and letting the user choose between them.
- **Cloud sync.** Use CloudKit or a backend API to sync classification history across devices.
- **Richer analytics.** Add longer-term trends, filters, and export options.
- **Automation.** Provide Shortcuts or background classification flows for new photos.

## 7. Reflection

**What went well.**
- MVVM structure kept views straightforward and easy to reason about.
- Core ML and Vision integrate cleanly into SwiftUI via async services.
- SwiftUI made it quick to experiment with modern card-based layouts and dark mode support.

**What could improve.**
- Adding unit and snapshot tests for services and key views.
- Extracting a dedicated theming layer so that colors and typography can be swapped easily.
- Introducing a proper error reporting/logging mechanism for debugging.

**Skills demonstrated.**
- Building a SwiftUI app with Core ML and Core Data.
- Applying MVVM and service-oriented patterns.
- Designing reusable SwiftUI components and a lightweight design system.
- Reasoning about concurrency and data flows across the app lifecycle.
