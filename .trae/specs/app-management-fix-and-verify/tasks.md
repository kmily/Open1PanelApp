# Tasks

- [ ] Task 1: Fix Compilation Errors
    - [ ] SubTask 1.1: Fix import in `lib/features/apps/providers/installed_apps_provider.dart`.
    - [ ] SubTask 1.2: Fix import in `lib/features/apps/app_detail_page.dart`.
    - [ ] SubTask 1.3: Run `flutter analyze` to confirm no more compilation errors in `lib/features/apps`.

- [ ] Task 2: Backend Source Analysis
    - [ ] SubTask 2.1: Read `docs/OpenSource/1Panel/agent/app/api/v2/app.go` and `app_install.go` to list actual endpoints.
    - [ ] SubTask 2.2: Read `docs/OpenSource/1Panel/agent/app/dto/request/app.go` and `docs/OpenSource/1Panel/agent/app/dto/response/app.go` to verify data structures.
    - [ ] SubTask 2.3: Compare with `lib/api/v2/app_v2.dart` and `lib/data/models/app_models.dart`, listing discrepancies.

- [ ] Task 3: API Client & Model Update
    - [ ] SubTask 3.1: Update `lib/data/models/app_models.dart` to match backend DTOs (Request/Response).
    - [ ] SubTask 3.2: Update `lib/api/v2/app_v2.dart` to match confirmed endpoints and types.

- [ ] Task 4: Integration Testing & Verification
    - [ ] SubTask 4.1: Run `flutter test test/api_client/app_api_test.dart` against the test server.
    - [ ] SubTask 4.2: Fix any test failures by adjusting models or client code.
    - [ ] SubTask 4.3: Verify all 32 endpoints (or however many actual endpoints exist) are covered or at least verified manually if automation is hard for some.

- [ ] Task 5: Final Code Quality Check
    - [ ] SubTask 5.1: Check file lengths (ensure < 1000 lines).
    - [ ] SubTask 5.2: Ensure proper error handling and logging.
