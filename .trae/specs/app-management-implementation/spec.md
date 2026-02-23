# App Management Module Spec

## Why
The "App Management" module is a core P0 feature of Open1PanelApp. Currently, it exists only as a basic framework with incomplete UI and logic. Users need a fully functional App Store to browse, install, manage, and configure applications on their 1Panel servers. This module must be brought up to the same standard as the recently completed "File Management" module.

## What Changes

### 1. API Client & Models (`lib/api/v2/app_v2.dart`, `lib/data/models/app_models.dart`)
- **Verify & Complete**: Ensure all endpoints identified in `docs/development/modules/应用管理/app_api_analysis.md` are implemented.
- **Type Safety**: Ensure strict typing for all requests and responses.
- **Refactor**: Align method names with the API paths for clarity.

### 2. State Management (`lib/features/apps/apps_provider.dart`)
- **Separation of Concerns**: Split into `AppStoreProvider` (browsing, searching) and `InstalledAppsProvider` (management, status polling).
- **Status Polling**: Implement polling for app installation progress and status changes.
- **Error Handling**: Standardized error handling using `Result` pattern or `runGuarded`.

### 3. UI Implementation (`lib/features/apps/`)
- **App Store Page**:
    - Search bar and Tag filtering.
    - Grid/List view of available apps.
    - App Detail Page (Markdown description, version selection).
    - Install Wizard (Basic config, Advanced config: ports, env, volumes).
- **Installed Apps Page**:
    - List view with status indicators (Running, Stopped, Installing, Error).
    - Quick actions: Start, Stop, Restart, Web UI.
    - Detail Page: Status, Resources, Config, Logs, Backups.
- **MD3 Compliance**: Ensure all UI components follow Material Design 3.

### 4. Testing
- **Integration Tests**: `test/api_client/app_api_test.dart` covering all endpoints.
- **Unit Tests**: Model serialization/deserialization.
- **Widget Tests**: Key flows (Install wizard, App list).

## Impact
- **Affected Specs**: `docs/development/modules/应用管理/app_module_index.md`, `app_module_architecture.md`.
- **Affected Code**: `lib/features/apps/`, `lib/api/v2/app_v2.dart`, `lib/data/models/app_models.dart`.

## ADDED Requirements

### Requirement: App Store
The system SHALL provide a searchable and filterable list of applications available for installation.
#### Scenario: Install App
- **WHEN** user selects an app and clicks "Install"
- **THEN** a configuration wizard appears allowing customization of name, version, and advanced settings (ports, env).
- **WHEN** installation starts
- **THEN** the user is redirected to the "Installed Apps" list with a progress indicator.

### Requirement: App Management
The system SHALL allow managing the lifecycle of installed applications.
#### Scenario: Operate App
- **WHEN** user clicks "Stop" on a running app
- **THEN** the app status changes to "Stopping" and then "Stopped".
- **WHEN** user clicks "Config"
- **THEN** a configuration editor appears allowing modification of the app's `docker-compose.yml` or `.env`.

## MODIFIED Requirements
### Requirement: Existing Framework
The existing `AppsPage` and `AppsProvider` will be heavily refactored to support the above requirements.
