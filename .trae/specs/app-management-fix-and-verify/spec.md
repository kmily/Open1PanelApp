# App Management Fix and Verify Spec

## Why
The "App Management" module currently has compilation errors due to incorrect imports and missing type definitions. Additionally, the user has requested verification of the API endpoints against the actual backend source code and a live test server to ensure accuracy, as the previous analysis might be flawed.

## What Changes

### 1. Fix Compilation Errors
- **`lib/features/apps/providers/installed_apps_provider.dart`**: Fix import path for `app_models.dart`. It should be `../../../data/models/app_models.dart`.
- **`lib/features/apps/app_detail_page.dart`**: Import `widgets/app_install_dialog.dart` to resolve `AppInstallDialog`.
- **Verify other files**: Check for similar import issues in `app_store_provider.dart` etc.

### 2. Verify API Endpoints against Backend Source
- **Analyze Backend Code**: Read `docs/OpenSource/1Panel/agent/app/api/v2/*.go` and `dto/**/*.go` to confirm:
    - Endpoint paths (e.g., `/apps/search` vs `/apps/list`).
    - Request/Response structures (Fields, Types).
- **Update API Client (`lib/api/v2/app_v2.dart`)**: Align with backend source.
- **Update Models (`lib/data/models/app_models.dart`)**: Align with backend DTOs.

### 3. Verify against Test Server
- **Run Integration Tests**: Execute `flutter test test/api_client/app_api_test.dart` against the environment configured in `.env`.
- **Fix Failures**: Adjust code based on actual server responses.

### 4. Code Quality
- **Refactor**: Ensure no file exceeds 1000 lines. Split `app_v2.dart` or `app_models.dart` if they become too large.

## Impact
- **Affected Specs**: `docs/development/modules/应用管理/app_module_index.md`.
- **Affected Code**: `lib/features/apps/`, `lib/api/v2/app_v2.dart`, `lib/data/models/app_models.dart`.

## ADDED Requirements
- **Strict Type Checking**: All API responses must be strictly typed and validated against the backend DTOs.
- **Error Handling**: Graceful handling of API mismatches (e.g., missing fields).

## MODIFIED Requirements
- **API Client**: Must match the actual backend implementation, not just the OpenAPI spec (which might be outdated).
