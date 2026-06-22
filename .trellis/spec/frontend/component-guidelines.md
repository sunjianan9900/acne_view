# Component Guidelines

> How components are built in this project.

---

## Overview

<!--
Document your project's component conventions here.

Questions to answer:
- What component patterns do you use?
- How are props defined?
- How do you handle composition?
- What accessibility standards apply?
-->

(To be filled by the team)

### Convention: Shell-Scoped Detail Panels

**What**: On desktop layouts, feature screens may render their detail/list state inside the shared shell's `rightPanel` slot instead of navigating to a separate full-screen route.

**Why**: This keeps the sidebar stable and makes region-level drilldowns feel like an in-place update rather than a hard page transition.

**Example**:
```dart
DoujiShell(
  rightPanel: selectedRegion == null
      ? const AllSpotsPanel()
      : RegionSpotsContent(region: selectedRegion),
  child: FaceMapCanvas(
    onRegionTap: (region) => setState(() => selectedRegion = region),
  ),
);
```

**Related**: Use the standalone route only for mobile or direct deep links.

### Convention: Reusable Detail Content Widgets

**What**: Extract region/list content into a reusable widget so the same content can be used both in a standalone `Scaffold` screen and inside a shell panel.

**Why**: It prevents divergence between the desktop embedded view and the mobile route view.

**Example**:
```dart
class RegionSpotsContent extends ConsumerWidget { ... }
class RegionSpotsScreen extends ConsumerWidget {
  Widget build(...) => Scaffold(body: RegionSpotsContent(region: region));
}
```

---

## Component Structure

<!-- Standard structure of a component file -->

(To be filled by the team)

---

## Props Conventions

<!-- How props should be defined and typed -->

(To be filled by the team)

---

## Styling Patterns

<!-- How styles are applied (CSS modules, styled-components, Tailwind, etc.) -->

(To be filled by the team)

---

## Accessibility

<!-- A11y requirements and patterns -->

(To be filled by the team)

---

## Common Mistakes

<!-- Component-related mistakes your team has made -->

(To be filled by the team)
