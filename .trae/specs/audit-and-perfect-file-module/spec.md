# Audit and Perfect File Management Module Spec

## Why
The "File Management" module requires final polish to ensure stability, UI consistency (MD3), and test coverage. Recent audits revealed missing integration tests, some UI inconsistencies in `UploadHistoryPage`, and a failing widget test due to localization setup issues. The user demands a "perfect" implementation without "phantom" features.

## What Changes

### 1. Test Fixes
- **Widget Tests**: Fix `test/features/files/widgets/file_list_item_test.dart` by correctly importing and mocking the generated `AppLocalizations` (from `package:onepanelapp_app/l10n/generated/app_localizations.dart`) instead of the manual wrapper.
- **Integration Tests**: Fix `test/api_client/file_api_test.dart`.
    - Resolve "Target path does not exist" errors by ensuring test directories exist or using a valid path on the test environment (e.g., `/opt/1panel/tmp` or similar, if accessible).
    - Add missing test cases for `mount`, `batch/operate`, `properties`, and `link/create`.

### 2. UI Polish (MD3)
- **UploadHistoryPage**:
    - Replace the custom `TextField` in AppBar with a proper MD3-style search bar (rounded corners, correct elevation/color).
    - Improve `ListTile` visual hierarchy (use `titleMedium` for name, `bodySmall` for path/size).
    - Ensure consistent use of `context.l10n` (remove `dynamic` typing).

### 3. Code Quality
- **Type Safety**: Ensure strict typing in `UploadHistoryPage` (remove `dynamic l10n`).
- **Consistency**: Ensure `TransferManagerPage` and `UploadHistoryPage` share similar design patterns (e.g., empty states, error handling).

## Impact
- **Affected Files**:
    - `test/features/files/widgets/file_list_item_test.dart`
    - `test/api_client/file_api_test.dart`
    - `lib/features/files/upload_history_page.dart`
- **Risk**: Low. Mostly test and UI polish.

## Requirements
- **Integration Tests**: Must pass for all documented API endpoints.
- **UI**: Must be strictly MD3 compliant (use `Theme.of(context).colorScheme`).
- **No Phantom Features**: Ensure all UI actions have corresponding backend logic.
