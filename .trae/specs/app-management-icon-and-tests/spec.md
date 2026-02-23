# App Management Icons and Comprehensive Testing

## Why
Users reported missing app icons and incomplete test coverage for the App Management module. The current implementation uses `appId` for icon fetching which fails for some apps (should use `appKey`), and the `AppCard` widget lacks icon support. Additionally, `AppDetailPage` fails completely when backend returns a "docker-compose" error, preventing users from seeing any info.

## What Changes
- **App Icons**: Implement `AppIcon` widget that handles fetching icons by `key` (primary) or `id` (fallback) and caches them.
- **App Store UI**: Update `AppCard` and `AppStoreView` to display app icons.
- **App Detail Page**:
  - Update to use `AppIcon`.
  - Handle `getAppDetail` failures gracefully (show partial info from list item if detailed fetch fails).
- **Testing**: Expand `app_api_test.dart` to strictly follow the "Module Adaptation Workflow":
  - Cover all 32 endpoints.
  - Print full request/response bodies.
  - Test parameter boundaries.
  - Verify `getAppIcon` with both ID and Key.

## Impact
- **Affected Specs**: `app-management-implementation`
- **Affected Code**:
  - `lib/features/apps/widgets/app_icon.dart` (New)
  - `lib/shared/widgets/app_card.dart`
  - `lib/features/apps/widgets/app_store_view.dart`
  - `lib/features/apps/app_detail_page.dart`
  - `test/api_client/app_api_test.dart`

## ADDED Requirements
### Requirement: App Icon Display
- **WHEN** user views the App Store or App Detail page
- **THEN** the app icon SHALL be displayed using the app's `key` (e.g., "openresty").
- **THEN** if the icon fetch fails, a default placeholder icon SHALL be shown.

### Requirement: Resilient Detail Loading
- **WHEN** `getAppDetail` fails (e.g., backend error)
- **THEN** the App Detail page SHALL display the available information from the list item (name, description, tags).
- **THEN** a warning/error message SHALL be displayed, but the page should NOT be empty or broken.

## MODIFIED Requirements
### Requirement: Comprehensive API Testing
- All 32 App Management endpoints MUST be covered in `app_api_test.dart`.
- Tests MUST log request/response bodies for verification.
