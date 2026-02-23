# Tasks

- [x] Task 1: Documentation & Analysis Update
    - [x] SubTask 1.1: Update `docs/development/modules/应用管理/app_module_index.md` with correct links.
    - [x] SubTask 1.2: Update `docs/development/modules/应用管理/app_module_architecture.md` with accurate API list from analysis.

- [x] Task 2: API Client & Model Verification
    - [x] SubTask 2.1: Review `lib/api/v2/app_v2.dart` against `app_api_analysis.md`. Add missing endpoints (e.g. `GET /apps/detail/...` variants if needed).
    - [x] SubTask 2.2: Create `test/api_client/app_api_test.dart` and implement integration tests for all major endpoints (Search, List, Install check, etc.).
    - [x] SubTask 2.3: Fix any model discrepancies found during testing.

- [x] Task 3: State Management Refactor
    - [x] SubTask 3.1: Refactor `AppsProvider` to manage App Store state (search, filter).
    - [x] SubTask 3.2: Implement `InstalledAppsProvider` (or extend `AppsProvider`) for polling and management.

- [x] Task 4: UI Implementation - App Store
    - [x] SubTask 4.1: Implement `AppStorePage` with SearchBar and Filter chips.
    - [x] SubTask 4.2: Implement `AppDetailPage` with Markdown rendering for description.
    - [x] SubTask 4.3: Implement `AppInstallDialog` with basic and advanced configuration (Ports, Env).

- [x] Task 5: UI Implementation - Installed Apps
    - [x] SubTask 5.1: Implement `InstalledAppsPage` with status indicators and quick actions.
    - [x] SubTask 5.2: Implement `InstalledAppDetailPage` (Status, Config, Logs).
    - [x] SubTask 5.3: Implement Operations (Start/Stop/Restart/Uninstall) with feedback.

- [x] Task 6: Final Polish & Verification
    - [x] SubTask 6.1: Ensure MD3 compliance (colors, typography, elevation).
    - [x] SubTask 6.2: Verify all flows on simulator/device.
    - [x] SubTask 6.3: Run all tests.
