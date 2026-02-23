# Refine App & Container Management Spec

## Why
User feedback indicates several UX issues and bugs in the recent App/Container implementation:
1.  **Navigation Bug**: Clicking "Containers" in Server Detail returns to the Server List because of incorrect route mapping.
2.  **App Detail UX**: Clicking an installed app goes to the Store Detail (install page) instead of a management view. Users want to see the container, readme, and manage the installed instance.
3.  **Information Density**: App cards and details are missing key info (ports, container name, etc.).
4.  **Localization**: Missing translations for new modules.
5.  **API Errors**: `unsupported protocol scheme` error in logs needs investigation and fix.

## What Changes

### 1. Navigation & Routing
-   **Update `AppRouter`**:
    -   Map `/containers` to `OrchestrationPage` (instead of `AppShellPage`).
    -   Ensure `/installed-app-detail` is correctly wired.
-   **Update `ServerDetailPage`**:
    -   Link "Containers" module to `AppRoutes.orchestration`.

### 2. Installed App Detail Page (`InstalledAppDetailPage`)
-   **New Feature**: Implement a dedicated detail page for installed apps.
-   **Dual Data Source**:
    -   Fetch **Installation Info** (Status, Ports, Container Name, Config).
    -   Fetch **Store Detail** (README, Description) using `appKey`.
-   **UI Layout**:
    -   **Header**: Icon, Name, Version, Status Chip.
    -   **Action Bar**: Start, Stop, Restart, **Web UI** (if applicable), **Container** (Jump to Container Detail), Uninstall.
    -   **Tabs/Sections**:
        -   **Overview**: README (Markdown), Basic Info.
        -   **Configuration**: Ports, Environment Variables, Volumes (if available).
        -   **Compose**: View `docker-compose.yml` content.

### 3. Installed App Card
-   **Enhance**: Add display for exposed ports and container name.

### 4. Container & Orchestration UI
-   **Enhance**: Ensure Container Detail page works and links back correctly.

### 5. Localization
-   **Add Keys**: Add missing translations for container/orchestration terms in `app_zh.arb` and `app_en.arb`.

## Impact
-   **Affected Files**: `AppRouter`, `ServerDetailPage`, `InstalledAppCard`, `InstalledAppDetailPage`, `AppService`, `AppInstallInfo`.

## ADDED Requirements
### Requirement: Installed App Detail
The system SHALL provide a dedicated view for installed apps that combines runtime status with store documentation.
#### Scenario: View Installed App
-   **WHEN** user clicks an app in "Installed" list
-   **THEN** show `InstalledAppDetailPage`.
-   **THEN** show README from store.
-   **THEN** show "Container" button to jump to container logs/stats.

### Requirement: Container Navigation
The system SHALL navigate to Orchestration/Container management from Server Detail.

## MODIFIED Requirements
### Requirement: App Card
The app card SHALL show ports and container name if available.
