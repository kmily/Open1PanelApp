# App Management API Fixes and Consistency Refactor

## Why
Users reported API parsing exceptions (e.g., "unexpected end of JSON input", "NetworkException") and mismatches between the App Management module and the API definition (`app_api_analysis.json`). The current implementation lacks robustness against backend errors and may have field/type inconsistencies.

## What Changes
- **Refactor `AppV2Api`**: Ensure strict alignment with `app_api_analysis.json` paths and parameters. Fix duplicate parameter naming in `getAppDetail`.
- **Refactor Models**: Review `AppItem`, `AppInstall`, `AppInstallCreateRequest` for consistency.
- **Update UI**: Enhance `AppDetailPage`, `AppIcon`, `AppStoreView`, `AppCard` to strictly use the defined models and handle null/error states gracefully.
- **Enhanced Testing**:
  - Update `test/api_client/app_api_test.dart` and `test/verify_icon_endpoint.dart`.
  - Add edge cases: Empty URL, 404, Large File, Timeout, Missing Fields, Invalid JSON.
  - Map failed tests to code fixes.

## Impact
- **Affected Specs**: `app-management-icon-and-tests`
- **Affected Code**:
  - `lib/api/v2/app_v2.dart`
  - `lib/data/models/app_models.dart`
  - `lib/features/apps/app_detail_page.dart`
  - `lib/features/apps/widgets/app_icon.dart`
  - `lib/features/apps/widgets/app_store_view.dart`
  - `lib/shared/widgets/app_card.dart`
  - `test/api_client/app_api_test.dart`
  - `test/verify_icon_endpoint.dart`

## ADDED Requirements
### Requirement: API Consistency
- **WHEN** calling any App API endpoint
- **THEN** the request parameters and response parsing SHALL strictly match `app_api_analysis.json` (correcting for obvious typos like duplicate `version`).

### Requirement: Robust Error Handling
- **WHEN** the backend returns 500, 404, or malformed JSON (e.g., "unexpected end of JSON input")
- **THEN** the app SHALL NOT crash.
- **THEN** the UI SHALL display a user-friendly error or partial data.

### Requirement: Comprehensive Boundary Testing
- **WHEN** running tests
- **THEN** scenarios including 404, timeout, invalid JSON, and missing fields MUST be covered and pass.

## MODIFIED Requirements
### Requirement: App Icon Logic
- **WHEN** fetching app icon
- **THEN** the system SHALL try `appKey` first (based on practical usage) and fallback to `appId` if `app_api_analysis.json` implies strict `appId`. (Actually, `app_api_analysis.json` says `appId` but we will support both for robustness as confirmed by user intent for "fixing" issues).
