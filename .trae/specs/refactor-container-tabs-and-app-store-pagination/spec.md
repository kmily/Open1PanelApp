# Refactor Container Tabs and App Store Pagination Spec

## Why
1.  **Container Management UI Mismatch**: The current mobile app's "Container Management" page lacks several tabs present in the 1Panel Web UI (Overview, Orchestration, Networks, Volumes, Repository, Templates, Configuration) and duplicates functionality (Images) with the "Orchestration" module. The user requested merging these into a single "Container Management" view matching the web experience.
2.  **App Store Usability**: The App Store list only shows the first page of results (limited to ~20 items) while the API returns hundreds. There is no pagination UI.
3.  **App Store Stability**: Users report "unexpected end of JSON input" errors, likely due to unhandled non-JSON responses (e.g., empty body or HTML error pages) from the API.

## What Changes

### Container Management
1.  **Update `ContainersPage`**:
    *   Enable scrollable tabs (`isScrollable: true`).
    *   Expand tabs to match 1Panel Web UI:
        1.  **Overview** (New placeholder)
        2.  **Containers** (Existing `_ContainersTab`)
        3.  **Orchestration** (Import `ComposePage`)
        4.  **Images** (Import `ImagePage`, replace inline `_ImagesTab`)
        5.  **Networks** (Import `NetworkPage`)
        6.  **Volumes** (Import `VolumePage`)
        7.  **Repository** (New placeholder)
        8.  **Templates** (New placeholder)
        9.  **Configuration** (New placeholder)
    *   Remove redundant code (e.g., inline `_ImagesTab` if `ImagePage` is superior).

### App Store
1.  **Update `AppStoreProvider`**:
    *   Add pagination state: `_page`, `_pageSize`, `_total`, `_hasMore`.
    *   Refactor `loadApps` to support `loadMore` and `refresh` modes.
    *   Append new items to `_apps` instead of overwriting when loading more.
2.  **Update `AppStoreView`**:
    *   Add `ScrollController` to `GridView`.
    *   Implement "infinite scroll" logic: trigger `loadMore` when scrolling near the bottom.
    *   Add a bottom loading indicator.
3.  **Enhance `AppV2Api` Error Handling**:
    *   In `searchApps` and `getAppDetail`, specifically catch `FormatException` (JSON parse error) and empty responses, returning a friendly error or empty result instead of crashing.

## Impact
-   **Affected Specs**: Container Management, App Management.
-   **Affected Code**:
    -   `lib/features/containers/containers_page.dart`
    -   `lib/features/apps/providers/app_store_provider.dart`
    -   `lib/features/apps/widgets/app_store_view.dart`
    -   `lib/api/v2/app_v2.dart`

## ADDED Requirements
### Requirement: Container Tabs
The Container Management page SHALL display the following tabs in order: Overview, Containers, Orchestration, Images, Networks, Volumes, Repository, Templates, Configuration.

### Requirement: App Store Pagination
The App Store SHALL support infinite scrolling or "Load More" to display all available apps (not just the first 20).

### Requirement: Robust API Error Handling
The App Store API client SHALL gracefully handle non-JSON responses (e.g., empty body, HTML errors) without throwing "unexpected end of JSON input".

## MODIFIED Requirements
### Requirement: Container Page Layout
**Reason**: Align with 1Panel Web UI.
**Modification**: Change from fixed 2 tabs to scrollable multi-tabs.

### Requirement: App Store Data Loading
**Reason**: Support large datasets.
**Modification**: Implement pagination logic.
