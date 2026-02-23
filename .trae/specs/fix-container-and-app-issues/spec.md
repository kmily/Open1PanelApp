# Fix Container and App Issues Spec

## Why
1. **Container Management Crash**: The Container Management pages (Containers, Images, Networks, Volumes) crash with `type '_Map<String, dynamic>' is not a subtype of type 'List<dynamic>?'` due to incorrect API response parsing in `DockerV2Api`.
2. **App Management Layout**: The "App Management" page shows an unexpected bottom tab bar because it's wrapped in `MainLayout` which duplicates the main navigation structure inside a sub-page or tab.
3. **App Store Errors**: The App Store fails to install apps (Server Error) and fails to load app details (`unexpected end of JSON input`) due to fragile API response handling or incorrect request parameters.
4. **UI Styling**: The "Installed Apps" cards have blurred boundaries, affecting visual quality.

## What Changes
1. **Fix `DockerV2Api` Response Parsing**:
   - Update `listImages`, `listNetworks`, `listVolumes` in `lib/api/v2/docker_v2.dart` to correctly extract the list from the `data` field of the response map, instead of casting the entire response map to a list.
2. **Fix `AppsPage` Layout**:
   - Remove `MainLayout` wrapper from `lib/features/apps/apps_page.dart` to prevent the double bottom navigation bar.
3. **Enhance `AppV2Api` Error Handling**:
   - Add robust checks for `response.data` in `lib/api/v2/app_v2.dart` (especially `installApp` and `getAppDetail`).
   - Log detailed error information when JSON parsing fails or response is unexpected.
   - Verify request parameters for `installApp`.
4. **Fix `InstalledAppCard` Styling**:
   - Improve the `Card` or `Container` decoration in `lib/features/apps/widgets/installed_app_card.dart` to ensure clear boundaries.

## Impact
- **Affected Specs**: Container Management, App Management.
- **Affected Code**:
  - `lib/api/v2/docker_v2.dart`
  - `lib/features/apps/apps_page.dart`
  - `lib/api/v2/app_v2.dart`
  - `lib/features/apps/widgets/installed_app_card.dart`

## ADDED Requirements
### Requirement: Robust API Parsing
The system SHALL correctly parse 1Panel API responses where the list data is wrapped in a `data` field (Map), preventing type cast errors.

### Requirement: Clean App Management Layout
The App Management page SHALL NOT display the main application bottom navigation bar when it is not a top-level tab in the main layout.

### Requirement: App Store Reliability
The system SHALL gracefully handle API errors and empty responses in the App Store, providing meaningful error messages instead of crashing with JSON errors.

## MODIFIED Requirements
### Requirement: Docker API Client
**Reason**: Current implementation assumes response data is a List, but it is a Map containing a List.
**Modification**: Parse `response.data['data']` as List.

### Requirement: App Card UI
**Reason**: Boundaries are blurred.
**Modification**: Enhance border/shadow styling.
