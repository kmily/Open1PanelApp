# Fix Files Provider Scope Spec

## Why
Users are experiencing "Provider<FilesProvider> not found" errors when navigating to sub-pages like "File Content Search" (`FileContentSearchPage`) from the Files page. This is because `FilesProvider` is scoped to `FilesPage` (using `ChangeNotifierProvider`), but when a new route is pushed using `Navigator.push`, the new page is in a different branch of the widget tree that does not have access to the `FilesProvider` from `FilesPage`.

## What Changes
- Wrap the destination pages in `Navigator.push` with `ChangeNotifierProvider.value` to pass the existing `FilesProvider` instance to the new route.
- Affected pages:
    - `FileContentSearchPage`
    - `UploadHistoryPage`
    - `MountsPage`
    - `FavoritesPage`
    - `RecycleBinPage`
    - `TransferManagerPage` (if it depends on `FilesProvider`, check needed)

## Impact
- **Affected code**: `lib/features/files/files_page.dart`
- **Behavior**: Sub-pages will correctly access the `FilesProvider` state and methods without crashing.

## ADDED Requirements
### Requirement: Provider Access
The system SHALL ensure that all sub-pages navigated from `FilesPage` can access the `FilesProvider` instance.

#### Scenario: Navigate to Content Search
- **WHEN** user taps "Content Search" in the more menu
- **THEN** the `FileContentSearchPage` opens without error
- **AND** the search function works using the `FilesProvider`

#### Scenario: Navigate to Mounts
- **WHEN** user taps "Mounts" in the more menu
- **THEN** the `MountsPage` opens without error
- **AND** the mount info is loaded using the `FilesProvider`

## MODIFIED Requirements
### Requirement: Navigation Logic
Update `_showMoreOptions` and other navigation methods in `FilesPage` to wrap destination widgets with `ChangeNotifierProvider.value`.
