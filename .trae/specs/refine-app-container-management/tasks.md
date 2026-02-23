# Tasks

- [x] **Task 1: Fix Routing & Navigation**
    - [x] Update `AppRouter`: Map `/containers` to `OrchestrationPage`.
    - [x] Update `ServerDetailPage`: Ensure module click navigates to correct route.
    - [x] Update `InstalledAppCard`: Navigate to `/installed-app-detail` with `appId` and `appKey`.

- [x] **Task 2: Implement InstalledAppDetailPage**
    - [x] Create/Update `lib/features/apps/installed_app_detail_page.dart`.
    - [x] Implement `InstalledAppProvider` or extend `AppService` to fetch both install info and store detail.
    - [x] UI: Header with Status and Actions (Start/Stop/Restart/WebUI/Container).
    - [x] UI: "Container" button navigates to `/container-detail` (requires resolving container ID from name or ID).
    - [x] UI: "Overview" tab displaying README (using `flutter_markdown`).
    - [x] UI: "Configuration" tab displaying ports, envs, compose file.

- [x] **Task 3: Enhance InstalledAppCard**
    - [x] Add `Container Name`, `Ports`, `Web UI` link (if available) to the card.
    - [x] Improve layout to accommodate new info.

- [x] **Task 4: Localization**
    - [x] Add keys: `containerManagement`, `orchestration`, `images`, `networks`, `volumes`, `ports`, `env`, `viewContainer`, `webUI`, `readme`.
    - [x] Apply to all new pages.

- [x] **Task 5: Fix API/Log Errors**
    - [x] Investigate `unsupported protocol scheme` error. Check if `AppIcon` or `AppService` is trying to load a non-http URL.
    - [x] Fix image loading or file reading logic if necessary.

- [x] **Task 6: Verification**
    - [x] Verify navigation flow: Server -> Containers -> Orchestration.
    - [x] Verify App flow: Installed List -> Installed Detail -> Container Detail.
    - [x] Verify README loading.
