# Tasks

- [x] Task 1: Fix Provider Scope and Global Injection
  - [x] SubTask 1.1: Add `Provider<AppService>(create: (_) => AppService())` to `MultiProvider` in `lib/main.dart`.
  - [x] SubTask 1.2: Verify `AppService` import path in `main.dart`.

- [x] Task 2: Fix App Store UI Overflow
  - [x] SubTask 2.1: Modify `lib/features/apps/widgets/app_store_view.dart` to increase `mainAxisExtent` or use a flexible grid delegate.
  - [x] SubTask 2.2: Verify `AppCard` content fits within the new constraints.

- [x] Task 3: Enhance App Detail Page
  - [x] SubTask 3.1: Update `lib/features/apps/app_detail_page.dart` to use `context.read<AppService>()` correctly (already there, but Task 1 enables it).
  - [x] SubTask 3.2: Implement `_loadIcon` using `AppService.getAppIcon` (fetching bytes) and display using `Image.memory`.
  - [x] SubTask 3.3: Wrap the error display in `SingleChildScrollView` to prevent overflow.

- [x] Task 4: Verification and Testing
  - [x] SubTask 4.1: Create `test/widget_test/app_detail_page_test.dart` to mock `AppService` and verify page rendering.
  - [x] SubTask 4.2: Run the test to ensure no `ProviderNotFoundException`.
