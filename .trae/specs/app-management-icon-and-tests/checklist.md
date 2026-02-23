# Checklist

- [x] **App Icon Support**:
  - [x] `AppIcon` widget implemented with caching and key/ID fallback.
  - [x] `AppCard` displays correct icon.
  - [x] `AppDetailPage` displays correct icon.
  - [x] `AppStoreView` grid items display correct icon.

- [x] **UI Resilience**:
  - [x] `AppDetailPage` handles `getAppDetail` failures gracefully (shows partial data).
  - [x] No `Bottom Overflowed` errors in `AppStoreView` or `AppDetailPage`.

- [x] **API Integration & Testing**:
  - [x] All 32 endpoints in `app_api_analysis.json` are covered in `test/api_client/app_api_test.dart` (except `Ignore/Cancel Update` skipped due to API scope validation issue).
  - [x] Tests log full JSON request/response bodies.
  - [x] Install/Uninstall flow verified (including `operate: delete`).
  - [x] `checkAppUninstall` verified.
