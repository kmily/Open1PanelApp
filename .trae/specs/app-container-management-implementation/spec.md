# App & Container Management Implementation Spec

## Why
The App Management module has several UI regressions and missing features (broken icons, navigation issues, lack of user feedback). Additionally, the user requires the implementation of "Container Management" and "Container Orchestration" modules to provide full Docker/Compose capabilities, which are core to the application's value proposition.

## What Changes

### 1. App Management UI Fixes
- **Fix Icons in Installed List**: Update `InstalledAppCard` to use `AppIcon` widget, correctly passing `appKey` and `appId` from `AppInstallInfo` to ensure icons load from the correct source.
- **Fix Navigation**: Update `InstalledAppsView` to correctly construct an `AppItem` from `AppInstallInfo` and navigate to `AppDetailPage`.
- **Add User Feedback**: Implement `ScaffoldMessenger` toasts in `InstalledAppsView` for "Start", "Stop", "Restart" actions (success/failure).
- **Update AppDetailPage**: Ensure it can handle `AppItem` constructed from installation data (handling potential nulls gracefully).

### 2. Container Management Module (New)
- **API Client**: Implement `ContainerV2Api` to handle container operations (list, start, stop, logs, stats, etc.).
- **State Management**: Create `ContainerProvider` for reactive UI updates.
- **UI Implementation**:
    - `ContainerPage`: List of containers with status, usage metrics, and quick actions.
    - `ContainerDetailPage`: Detailed view including:
        - Info tab (Inspection data)
        - Logs tab (Real-time logs)
        - Terminal tab (Web-based shell access)
        - Stats tab (CPU/Memory charts)

### 3. Container Orchestration Module (New)
- **API Client**: Implement `DockerV2Api` and `ComposeV2Api` for network, volume, image, and compose project management.
- **State Management**: Create `ComposeProvider`, `NetworkProvider`, `VolumeProvider`, `ImageProvider`.
- **UI Implementation**:
    - `ComposePage`: List of Docker Compose projects with up/down/restart actions.
    - `NetworkPage`: List and manage Docker networks.
    - `VolumePage`: List and manage Docker volumes.
    - `ImagePage`: List, pull, and delete Docker images.

## Impact
- **Affected Specs**: `app-management-icon-and-tests` (extended), `app-management-fix-and-verify` (superseded).
- **Affected Code**:
    - `lib/features/apps/` (Installed views)
    - `lib/api/v2/` (New APIs)
    - `lib/features/container/` (New directory)
    - `lib/features/orchestration/` (New directory)

## ADDED Requirements

### Requirement: Container Management
The system SHALL provide a full suite of container management tools.
#### Scenario: View Containers
- **WHEN** user navigates to "Containers" tab
- **THEN** display list of running/stopped containers with CPU/RAM usage.

#### Scenario: Container Terminal
- **WHEN** user clicks "Terminal" in container details
- **THEN** open a WebSocket connection to the container's shell.

### Requirement: Orchestration
The system SHALL support Docker Compose, Networks, Volumes, and Images.

## MODIFIED Requirements

### Requirement: Installed App List
The "Installed Apps" list SHALL display icons and allow navigation to details.
#### Scenario: Click Installed App
- **WHEN** user taps an installed app card
- **THEN** navigate to the App Detail page.

#### Scenario: App Actions
- **WHEN** user clicks "Restart"
- **THEN** show "Restarting..." toast, followed by "Success" or "Error".
