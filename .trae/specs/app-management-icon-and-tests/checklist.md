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
  - [x] All 32 endpoints in `app_api_analysis.json` are covered in `test/api_client/app_api_test.dart`.
  - [x] Tests log full JSON request/response bodies.
  - [x] Install/Uninstall flow verified.
  - [x] `checkAppUninstall` verified.

- [x] **Consistency & Edge Cases**:
  - [x] `AppV2Api` paths/params match `app_api_analysis.json` exactly (with corrected `type` parameter).
  - [x] `AppItem` and other models are consistent with API responses (verified via log/test).
  - [x] Tests cover: Empty Icon URL, 404, Large File, Timeout, Missing Fields, Invalid JSON.
  - [x] No API parsing warnings in logs.
  - [x] "Unexpected end of JSON input" handled gracefully via fallback logic in `installApp`.
