# Tasks

- [x] Task 1: Fix Widget Tests (`file_list_item_test.dart`)
  - [x] SubTask 1.1: Update `file_list_item_test.dart` to import `package:onepanelapp_app/l10n/generated/app_localizations.dart`.
  - [x] SubTask 1.2: Configure `MaterialApp` in the test to use `AppLocalizations.delegate` and `GlobalMaterialLocalizations.delegate`.
  - [x] SubTask 1.3: Verify `file_list_item_test.dart` passes.

- [x] Task 2: Polish `UploadHistoryPage` UI (MD3)
  - [x] SubTask 2.1: Refactor `_buildBody` signature to use strong typing for `l10n`.
  - [x] SubTask 2.2: Replace the AppBar bottom `TextField` with a cleaner search UI (e.g., `SearchBar` widget or a styled `TextField` with `BorderRadius.circular(24)`).
  - [x] SubTask 2.3: Improve list item styling (typography, spacing) to match `TransferManagerPage`.

- [x] Task 3: Fix and Expand Integration Tests (`file_api_test.dart`)
  - [x] SubTask 3.1: Investigate and fix the "Target path does not exist" error (likely by adding a `mkdir` step or using a guaranteed existing path like `/tmp` if allowed, or checking server config).
  - [x] SubTask 3.2: Implement tests for `POST /files/mount`, `POST /files/batch/operate`, `POST /files/properties`, `POST /files/link/create`.
  - [x] SubTask 3.3: Run all tests to ensure green suite.

- [x] Task 4: Final Verification
  - [x] SubTask 4.1: Review all file management pages for MD3 compliance.
  - [x] SubTask 4.2: Verify no "phantom" buttons exist.
