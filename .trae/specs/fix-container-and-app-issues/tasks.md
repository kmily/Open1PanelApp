# Tasks

- [x] Task 1: Create reproduction test for Docker API parsing issue
  - [x] Create `test/api_client/docker_api_fix_test.dart` simulating the Map response.
- [x] Task 2: Fix `DockerV2Api` response parsing
  - [x] Modify `listImages`, `listNetworks`, `listVolumes` in `lib/api/v2/docker_v2.dart`.
  - [x] Verify with the reproduction test.
- [x] Task 3: Fix App Management Layout
  - [x] Remove `MainLayout` from `lib/features/apps/apps_page.dart`.
- [x] Task 4: Fix App Card Styling
  - [x] Update `lib/features/apps/widgets/installed_app_card.dart` to improve visual boundaries.
- [x] Task 5: Enhance App Store API handling
  - [x] Modify `lib/api/v2/app_v2.dart` to add logging and robust null/type checks for `response.data`.
  - [x] Verify `installApp` request payload structure against API analysis.
- [x] Task 6: Verify all fixes
  - [x] Run `test/api_client/app_api_test.dart` (mocked or real if env available).
  - [x] Run `test/api_client/docker_api_fix_test.dart`.
