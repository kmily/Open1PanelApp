# Tasks

- [x] Task 1: Create `AppIcon` Widget
  - [x] SubTask 1.1: Create `lib/features/apps/widgets/app_icon.dart` with `AppIcon` stateless widget.
  - [x] SubTask 1.2: Implement `getAppIcon` logic in `AppIcon` using `AppService` (pass `appKey` and `appId`).
  - [x] SubTask 1.3: Add fallback to `AppCard`'s default icon behavior.

- [x] Task 2: Integrate `AppIcon` into `AppCard` and `AppStoreView`
  - [x] SubTask 2.1: Update `lib/shared/widgets/app_card.dart` to accept an `icon` parameter (widget or key/id).
  - [x] SubTask 2.2: Update `lib/features/apps/widgets/app_store_view.dart` to pass `AppIcon(app: app)` to `AppCard`.

- [x] Task 3: Enhance `AppDetailPage` Resilience
  - [x] SubTask 3.1: Update `lib/features/apps/app_detail_page.dart` to use `AppIcon`.
  - [x] SubTask 3.2: Modify `_loadDetail` to catch exceptions but still allow partial rendering (use `_app` from list item).
  - [x] SubTask 3.3: Show a warning banner if `getAppDetail` fails but partial info is shown.

- [x] Task 4: Comprehensive API Testing
  - [x] SubTask 4.1: Update `test/api_client/app_api_test.dart` to include all 32 endpoints (from `app_api_analysis.json`).
  - [x] SubTask 4.2: Ensure all tests log full request/response bodies.
  - [x] SubTask 4.3: Add specific tests for `getAppIcon` (with ID and Key) and `getAppDetail` (with error cases).

- [ ] Task 5: Force Refactor & Edge Case Testing
  - [ ] SubTask 5.1: Review and refactor `AppV2Api` to strictly match `app_api_analysis.json` paths and params.
  - [ ] SubTask 5.2: Refactor `AppItem` and related models in `app_models.dart` to ensure field consistency.
  - [ ] SubTask 5.3: Update `AppDetailPage`, `AppIcon`, `AppStoreView`, `AppCard` to match model changes.
  - [ ] SubTask 5.4: Enhance `app_api_test.dart` and `verify_icon_endpoint.dart` with edge cases (404, timeout, invalid JSON, etc.).
  - [ ] SubTask 5.5: Run tests and fix any discovered issues.
