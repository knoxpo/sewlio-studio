# ADR
## ADR-027 Use Layer Hierarchy

**Title:** Use Layer Hierarchy  
**Status:** Accepted

---

# Context

The studio MVP started with a flat document object list.

That shape is no longer enough for:

- layers
- nested groups
- visibility and lock inheritance
- hierarchy-based selection
- hierarchy-aware rendering and stitch generation

The current `.embproj` MVP file is also versioned JSON, so a hierarchy change is a schema change.

---

# Decision

Adopt a real hierarchy in the editable document:

- layers are top-level only
- groups may nest inside layers or other groups
- objects remain immutable embroidery leaves
- ordering is defined by hierarchy child order, not by a flat object list

Visibility and lock state are inherited from ancestors.

Hidden nodes do not render and do not participate in stitch generation.

Locked nodes still render, but cannot be selected or edited.

Groups are hierarchy containers only.

They are not geometry objects and do not own independent transform state.

Moving a group or multi-selection applies transforms directly to descendant objects.

The `.embproj` schema is bumped from `1` to `2`.

Version `1` projects are intentionally unsupported after this change.

No migration path is implemented in this pass.

---

# Consequences

- Document, selection, rendering, and export preview all consume flattened visible hierarchy order.
- Commands must manipulate hierarchy state instead of assuming a flat object array.
- Canvas and layer-panel selection must support multiple selected hierarchy refs.
- Old v1 projects fail fast at load time.

---

# Alternatives Considered

- Keep the flat list and fake grouping in Flutter state
- Add layers only and defer nested groups
- Migrate v1 projects automatically into a default layer

These were rejected because they either split source of truth, undercut the requested feature, or add migration scope the current pass does not need.

---

# Implementation Notes

- Layers own ordering only and stay top-level.
- Cross-layer grouping is disallowed.
- Persistence stores:
  - object registry
  - object leaf state
  - top-level layers
  - group registry
- Tests must cover nested grouping, effective visibility/lock, and v2 persistence.

---

# Related Documents

```text
docs/02-architecture/005-document-model.md
docs/02-architecture/006-project-format.md
docs/04-ui/502-layer-panel.md
docs/01-product/functional-requirements/100-workspace.md
docs/01-product/functional-requirements/200-vector-editor.md
```
