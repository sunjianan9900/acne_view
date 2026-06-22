# 痘痘地图页面右侧内容切换

## Goal

On the desktop shell, clicking a face region on the acne map should not navigate to a full-screen region list page. The left navigation should remain visible while the right content area updates to show the selected region's spots.

## What I already know

* The feature lives in `lib/features/face_map/face_map_screen.dart` and currently uses `context.push('/region/:regionId')` when a region is tapped.
* The app shell is `DoujiShell` in `lib/shared/widgets/douji_shell.dart`; on desktop it keeps a persistent left sidebar and a main content panel.
* `lib/app.dart` currently exposes a standalone `/region/:regionId` route that renders `RegionSpotsScreen` as a full page.
* The region spot list UI already exists in `lib/features/face_map/region_spots_screen.dart`.
* Existing desktop behavior already supports a `rightPanel` slot in `DoujiShell`, which can be reused for the selected region detail.

## Assumptions (temporary)

* This change is primarily for desktop layouts where the shell/sidebar is visible.
* Mobile behavior can keep the existing full-screen navigation if needed.
* The right panel can show either an all-spots list or a region-specific list depending on selection.

## Open Questions

* None blocking.

## Requirements (evolving)

* Keep the left sidebar visible on desktop when a region is tapped.
* Replace the right-side content with the selected region's spot list instead of opening a new full-screen page.
* Preserve the current face map display and spot creation flow.
* Keep the existing standalone region route working unless it becomes unused.

## Acceptance Criteria (evolving)

* [ ] On desktop, tapping a face region updates the right panel inside the shell.
* [ ] The left navigation remains visible during region selection.
* [ ] The user can return from a region view to the all-spots view without leaving the shell.
* [ ] Tests cover the desktop shell behavior.

## Definition of Done

* Tests added/updated.
* Lint / typecheck / CI green.
* Behavior change documented in task notes if needed.

## Out of Scope

* Redesigning the face map artwork or region hit testing.
* Removing the standalone region route unless it becomes dead code as a follow-up.

## Technical Notes

* Relevant files: `lib/features/face_map/face_map_screen.dart`, `lib/features/face_map/region_spots_screen.dart`, `lib/shared/widgets/douji_shell.dart`, `lib/app.dart`, `test/widget_test.dart`.
* Existing shell already has a `rightPanel` slot suitable for this interaction.
