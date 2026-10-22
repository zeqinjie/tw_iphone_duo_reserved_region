## 1.0.1

- Expanded the English and Simplified Chinese documentation with detailed integration guides and diagrams comparing `SafeArea` with reserved regions and illustrating occlusion avoidance.
- Clarified that the plugin returns only active `occlusion` regions, excluding `division` regions, device posture, and hinge state.
- Documented result semantics, window-coordinate conversion, intersection checks, lifecycle refreshes, stale-request handling, and error fallbacks.
- Detailed the shared Swift Package Manager and CocoaPods implementation, build and runtime requirements, architecture, method-channel contract, and verification steps.
- Added Flutter CI checks for static analysis and tests, plus example launch configurations.

## 1.0.0

- Added active iPhone Duo reserved-region queries on supported iOS versions.
- Added `TwIphoneDuoReservedRegionBridge` for lifecycle-aware refreshes.
- Added `TwIphoneDuoReservedRegionProvider` for subtree access to logical-coordinate regions.
- Added safe fallbacks for unsupported platforms, unavailable native capabilities, and invalid payloads.
- Added package documentation, automated tests, and a runnable example application.
- Added Swift Package Manager support while retaining CocoaPods compatibility.
