# UI API Gap Review (UI-first parallel mode)

## Scope
- Source of truth: `docs/1PanelOpenAPI/1PanelV2OpenAPI.json`
- This document only tracks APIs needed by the revamped UI.
- Non-UI compile/test issues are intentionally out of scope for this review.

## Gap Table

| Module | Page Path | User Action | Required API | OpenAPI Path | Request Fields | Response Fields | Current Client Status | Temporary UI Degradation | Joint Acceptance Criteria |
|---|---|---|---|---|---|---|---|---|---|
| Server Metrics | `/home` -> Servers tab | Pull to refresh server cards | Load current metrics | `/dashboard/current/{ioOption}/{netOption}` | `ioOption`, `netOption` (path) | `current`, `avg`, `max`, `min`, metric points | `dashboard_v2.dart` exists; UI aggregator not wired | Show cards with config only and metric placeholders | After wiring, CPU/Memory/Load/Disk values visible in server cards |
| Server System Info | `/server-detail` | Open server details | Load server OS/base info | `/dashboard/base/os` | none | os/system detail fields | `dashboard_v2.dart` exists; page not wired | Show URL/name and module grid | Server detail header displays API-based system info |
| File Browser | `/home` -> Files tab | Enter directory, list files | Search/list files | `/files/search` | `FileSearch` payload (`path`, `containSub`, etc.) | `[]FileInfo` | `file_v2.dart` has list/search methods; UI not wired | Placeholder list and actions | Path navigation + file list load from API |
| File Operations | `/home` -> Files tab | Upload/new file/new folder | Upload/create operations | `/files/upload`, `/files/create`, `/files/mkdir` (see OpenAPI) | operation payloads | operation result | partial client methods available | Buttons keep no-op placeholders | Button actions invoke API and render success/failure feedback |
| Dynamic Verification (MFA load) | `/home` -> Verification tab | Tap "Load MFA info" | Load MFA secret/QR | `/core/settings/mfa` | `code`, `interval`, `secret` (`dto.MfaCredential`) | `qrImage`, `secret` (`mfa.Otp`) | missing in `setting_v2.dart` | Mock adapter returns local secret and empty qr | Real QR/secret loaded and rendered from API |
| Dynamic Verification (MFA bind) | `/home` -> Verification tab | Tap "Bind MFA" | Bind MFA | `/core/settings/mfa/bind` | `code`, `interval`, `secret` (`dto.MfaCredential`) | common success response | missing in `setting_v2.dart` | Mock adapter returns success immediately | API bind succeeds and UI status changes to enabled |
| Auth MFA Login | future login flow | Submit MFA code during login | MFA login | `/core/auth/mfalogin` | `dto.MFALogin` | login token/user info | already in `user_v2.dart` and `auth_v2.dart` | not consumed by UI revamp pages | End-to-end login with MFA available when auth UI is upgraded |

## OpenAPI Notes Used in This Review
- `"/core/settings/mfa"` and `"/core/settings/mfa/bind"` definitions are present in V2 OpenAPI.
- `dto.MfaCredential` requires `code`, `interval`, `secret`.
- `mfa.Otp` exposes `qrImage` and `secret`.

## Implementation Contract for API Adapter Phase
- Keep `SecurityVerificationRepository` as the stable UI boundary.
- Implement a real repository adapter that maps:
  - `loadMfaInfo()` -> `/core/settings/mfa`
  - `bindMfa()` -> `/core/settings/mfa/bind`
- Do not change the UI page contract when replacing mock adapter; only replace repository binding.
