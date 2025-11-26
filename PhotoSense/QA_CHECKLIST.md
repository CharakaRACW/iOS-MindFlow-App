# PhotoSense – QA Checklist

This checklist summarizes manual testing scenarios and integration points for the PhotoSense app.

## 1. Environment
- [ ] Xcode 15+ with iOS 17 SDK
- [ ] Core ML model (e.g. `MobileNetV2.mlmodel`) added to the app target
- [ ] Device or simulator with photo library access

---

## 2. Integration / Wiring

### View models
- [ ] `CameraView` uses `@StateObject CameraViewModel`
- [ ] `HomeView` uses `@StateObject HomeViewModel` with shared context
- [ ] `HistoryView` uses `@FetchRequest` bound to `ClassifiedPhoto`
- [ ] All views access Core Data via `@Environment(\.managedObjectContext)`

### Navigation
- [ ] `MainTabView` shows three tabs: **Home**, **Camera**, **History**
- [ ] Each tab hosts its own `NavigationStack`
- [ ] Camera → Save to history → entry appears in History tab
- [ ] History row → `PhotoDetailView` via `NavigationLink`
- [ ] Settings / About / Info views open and dismiss correctly

### Image picker
- [ ] Camera button opens system camera (on device)
- [ ] Library button opens photo library (simulator/device)
- [ ] Picker dismisses when a photo is chosen
- [ ] Picker dismisses when user taps Cancel

---

## 3. Core Data / Classification

- [ ] Classifying a photo saves a `ClassifiedPhoto` with:
  - [ ] Non-nil `id`, `classification`, `timestamp`
  - [ ] Reasonable `confidence` (0–1)
  - [ ] `imageData` present
- [ ] History list updates automatically after save
- [ ] Swipe-to-delete removes an item and persists the change
- [ ] Delete from `PhotoDetailView` removes the item and returns to list
- [ ] Clearing data from Settings removes all history entries

---

## 4. Error Handling & Edge Cases

- [ ] No image selected → classify/save show a friendly error
- [ ] Permission denied (camera) → user sees clear message and app does not crash
- [ ] Permission denied (photo library) → friendly message
- [ ] Device without camera (simulator) → graceful message or camera button disabled
- [ ] Classification failure (e.g. corrupt image) → user-friendly error, app recovers
- [ ] Core Data save failure (simulate low disk / throw) → error handled without crash

---

## 5. UI / UX

### Home
- [ ] Hero text shows:
  - [ ] "Discover what's in your photos"
  - [ ] "AI-powered classification"
  - [ ] "Your personal photo assistant"
- [ ] Stats cards show correct totals / averages after multiple classifications
- [ ] Recent photos carousel shows up to 5 latest entries
- [ ] Empty state text appears when there is no history

### Camera
- [ ] Image preview updates when a new photo is chosen
- [ ] Classification result card appears with confidence meter
- [ ] Loading state shows spinner and disables buttons while classifying
- [ ] "Save" toolbar button is enabled only when a result exists
- [ ] Reset clears image + result

### History
- [ ] List is grouped into Today / Yesterday / This Week / Earlier
- [ ] Search bar filters classifications by label
- [ ] Pull-to-refresh works without duplicating items
- [ ] Empty state (no history) looks correct

### Detail
- [ ] Full-screen image or placeholder icon displays
- [ ] Confidence progress bar and percentage are correct
- [ ] Share button opens system share sheet
- [ ] Delete button removes the item and dismisses the view

---

## 6. Dark Mode & Accessibility

- [ ] App looks correct in **Light** and **Dark** mode
- [ ] Text is readable against backgrounds in both modes
- [ ] Dynamic Type: large text settings do not clip essential content
- [ ] VoiceOver reads:
  - [ ] Buttons with meaningful labels and hints
  - [ ] Cards and list rows as grouped elements
  - [ ] Section headers as headings where appropriate
- [ ] Tap targets are at least 44×44 points

---

## 7. Animations, Haptics, and Loading

- [ ] Splash / launch animation runs once and then shows main tabs
- [ ] Image and classification card animations feel smooth
- [ ] Reduce Motion enabled → major animations are toned down or skipped
- [ ] Haptics:
  - [ ] Light impact on button taps (camera/library/classify)
  - [ ] Success feedback when classification completes
  - [ ] Warning/error feedback on failures and deletes
- [ ] Long-running operations show a spinner or overlay

---

## 8. Performance

- [ ] History list scrolls smoothly with many items
- [ ] Classification runs on background queues (UI stays responsive)
- [ ] Memory usage remains stable after multiple classifications
- [ ] Large images are stored in Core Data without causing hangs (consider JPEG compression)

---

## 9. Testing Scenarios (high level)

- [ ] Fresh install → grant permissions → take photo → classify → save → verify in history
- [ ] Choose from library → classify → save → view in history → delete → confirm removal
- [ ] Perform multiple classifications → verify Home stats and recents update
- [ ] Toggle dark mode → verify all main screens
- [ ] Rotate device (where supported) → layout adapts without glitches
- [ ] Trigger low-confidence classification → UI still shows result clearly
- [ ] Force a classification error (e.g. remove model) → user sees error, no crash

Add timestamps, devices, and OS versions as you execute this checklist for a full QA log.
