# Tasks

- [x] **Task 1: Fix App Management UI**
    - [x] Update `InstalledAppCard` to use `AppIcon` widget with `appKey` and `appId`.
    - [x] Update `InstalledAppsView` navigation logic to pass valid `AppItem` to `AppDetailPage`.
    - [x] Add `ScaffoldMessenger` toasts for Start/Stop/Restart actions in `InstalledAppsView`.
    - [x] Verify fix by running the app and checking Installed Apps list.

- [x] **Task 2: Implement Container Management Core**
    - [x] Create `lib/api/v2/container_v2.dart` with methods: `listContainers`, `startContainer`, `stopContainer`, `restartContainer`, `removeContainer`, `inspectContainer`, `getContainerLogs`, `getContainerStats`.
    - [x] Create `lib/data/models/container_models.dart` (Container, ContainerStats, Mount, Port, etc.) matching API analysis.
    - [x] Create `lib/features/container/providers/container_provider.dart`.
    - [x] Register provider in `main.dart` or `MultiProvider` scope.

- [x] **Task 3: Implement Container Management UI**
    - [x] Create `lib/features/container/container_page.dart` (List view).
    - [x] Create `lib/features/container/widgets/container_card.dart`.
    - [x] Create `lib/features/container/container_detail_page.dart` with Tabs (Info, Logs, Stats, Terminal).
    - [x] Implement `ContainerLogsView` (using `flutter_markdown` or `SelectableText` with auto-scroll).
    - [x] Implement `ContainerStatsView` (simple text or basic charts).
    - [x] *Note: Terminal view might be complex; implement basic placeholder or simple text input first.*

- [x] **Task 4: Implement Container Orchestration Core**
    - [x] Create `lib/api/v2/compose_v2.dart` (Compose projects).
    - [x] Create `lib/api/v2/docker_v2.dart` (Images, Networks, Volumes).
    - [x] Create corresponding models in `lib/data/models/docker_models.dart`.
    - [x] Create `ComposeProvider`, `ImageProvider`, `NetworkProvider`, `VolumeProvider`.

- [x] **Task 5: Implement Container Orchestration UI**
    - [x] Create `lib/features/orchestration/compose_page.dart`.
    - [x] Create `lib/features/orchestration/image_page.dart`.
    - [x] Create `lib/features/orchestration/network_page.dart`.
    - [x] Create `lib/features/orchestration/volume_page.dart`.
    - [x] Create a `OrchestrationHomePage` or TabView to host these pages.

- [x] **Task 6: Integration & Verification**
    - [x] Verify all new pages load without errors.
    - [x] Verify API calls match `app_api_analysis.json` and other API docs.
    - [x] Run `flutter analyze` and fix lint errors.
