# Tasks
- [x] Task 1: Remove `FileContentSearchPage` and associated code.
  - [x] SubTask 1.1: Delete `lib/features/files/file_content_search_page.dart`.
  - [x] SubTask 1.2: Remove "Content Search" navigation from `FilesPage` (`lib/features/files/files_page.dart`).
  - [x] SubTask 1.3: Remove `FileContentSearchPage` import in `FilesPage`.

- [x] Task 2: Remove API and Provider support for content search.
  - [x] SubTask 2.1: Remove `searchInFiles` from `FilesProvider` (`lib/features/files/files_provider.dart`).
  - [x] SubTask 2.2: Remove `searchInFiles` from `FilesService` (`lib/features/files/files_service.dart`).
  - [x] SubTask 2.3: Remove `searchInFiles` from `FileV2Api` (`lib/api/v2/file_v2.dart`).
  - [x] SubTask 2.4: Remove `FileSearchInRequest` and `FileSearchResult` models (`lib/data/models/file/file_search_content.dart`).

- [ ] Task 3: Clean up tests and documentation.
  - [x] SubTask 3.1: Remove content search test case from `test/api_client/file_api_test.dart`.
  - [x] SubTask 3.2: Verify no other files reference `FileSearchInRequest`.
  - [x] SubTask 3.3: Run `build_runner` to clean up mocks.
  - [ ] SubTask 3.4: Restore missing `FilePreviewRequest` model to fix build errors.
