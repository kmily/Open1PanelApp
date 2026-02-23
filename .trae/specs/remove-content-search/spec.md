# Remove Content Search Feature Spec

## Why
The "Content Search" feature (searching for text *inside* files) was implemented in the frontend based on an assumption of an API endpoint `POST /files/search/in`. However, verification of the backend OpenAPI spec (`1PanelV2OpenAPI.json`) and actual API behavior confirmed that this endpoint **does not exist**.
To prevent crashes and user confusion, this feature must be completely removed from the codebase.

## What Changes
- **Remove UI**:
  - Delete `FileContentSearchPage` (`lib/features/files/file_content_search_page.dart`).
  - Remove entry point in `FilesPage` (popup menu item).
- **Remove Logic**:
  - Remove `searchInFiles` method from `FilesProvider`, `FilesService`, and `FileV2Api`.
  - Delete `FileSearchInRequest` and `FileSearchResult` models (`lib/data/models/file/file_search_content.dart`).
- **Remove Tests**:
  - Remove the test case for `POST /files/search/in` in `test/api_client/file_api_test.dart`.

## Impact
- **Affected specs**: File Management module.
- **Affected code**: `FilesPage`, `FilesProvider`, `FileV2Api`, `file_api_test.dart`.
- **User Experience**: Users will no longer see a "Content Search" option. They can still search for files by name.

## REMOVED Requirements
### Requirement: Content Search
**Reason**: Backend API endpoint `POST /files/search/in` does not exist.
**Migration**: None. Feature is removed.
