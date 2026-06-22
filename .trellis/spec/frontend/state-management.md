# State Management

> How state is managed in this project.

---

## Overview

<!--
Document your project's state management conventions here.

Questions to answer:
- What state management solution do you use?
- How is local vs global state decided?
- How do you handle server state?
- What are the patterns for derived state?
-->

(To be filled by the team)

### Convention: Local Selection State for Shell Views

**What**: Use local `State`/`StatefulWidget` selection for desktop-only shell drilldowns when the selection only affects the current screen's right panel.

**Why**: This keeps the interaction lightweight and avoids promoting short-lived UI state into global providers.

**Example**:
```dart
class _FaceMapScreenState extends ConsumerState<FaceMapScreen> {
  FaceRegion? _selectedRegion;
}
```

**Related**: Use Riverpod providers for shared data sources, not for one-screen panel selection.

---

## State Categories

<!-- Local state, global state, server state, URL state -->

(To be filled by the team)

---

## When to Use Global State

<!-- Criteria for promoting state to global -->

(To be filled by the team)

---

## Server State

<!-- How server data is cached and synchronized -->

(To be filled by the team)

---

## Common Mistakes

<!-- State management mistakes your team has made -->

(To be filled by the team)
