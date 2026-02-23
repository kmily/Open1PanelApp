# Fix App Management UI and Provider Spec

## Why
Users reported UI crashes (ProviderNotFoundException), layout overflows in the App Store and Detail pages, and missing app icons. The current implementation lacks robustness in error handling and UI adaptability.

## What Changes
- **Add Global Provider**: Register `AppService` in `main.dart` so it can be accessed anywhere (fixing the crash).
- **Fix App Store Layout**: Adjust `AppStoreView` grid item constraints to prevent "Bottom Overflowed by 18 pixels".
- **Fix App Detail Page**:
  - Implement authenticated app icon loading (using `AppService` to fetch bytes).
  - Make the error view scrollable to prevent overflow when displaying stack traces.
  - Ensure `AppInstallDialog` is invoked correctly.
- **Testing**: Add a widget test for `AppDetailPage` to verify provider access and UI rendering.

## Impact
- **Affected Specs**: `app-management-implementation` (refining UI).
- **Affected Code**:
  - `lib/main.dart`
  - `lib/features/apps/app_detail_page.dart`
  - `lib/features/apps/widgets/app_store_view.dart`
  - `test/widget_test/app_detail_page_test.dart` (New)

## MODIFIED Requirements
### Requirement: App Detail View
- **WHEN** user opens App Detail Page
- **THEN** it should load without crashing.
- **THEN** it should display the app icon (if available).
- **THEN** if an error occurs, the error message should be scrollable and not overflow.

### Requirement: App Store List
- **WHEN** user views the App Store
- **THEN** app cards should accommodate content (title, tags, buttons) without overflow on standard mobile screens.

## ADDED Requirements
### Requirement: App Icon Support
- The system SHALL fetch app icons using the authenticated API (`/apps/icon/:key`) or `AppService`.
- Icons SHALL be displayed in `AppDetailPage` and `AppStoreView` (optional for store, required for detail).
