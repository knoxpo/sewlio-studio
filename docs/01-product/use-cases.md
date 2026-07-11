# Use Cases
## Sewlio Studio

**Version:** 1.0.0  
**Status:** Draft  
**Owner:** Product Management / UX Architecture  
**Related Documents:**  
- `00-overview/vision.md`
- `00-overview/philosophy.md`
- `01-product/prd.md`
- `01-product/personas.md`
- `01-product/functional-requirements.md`
- `01-product/non-functional-requirements.md`

---

# 1. Purpose

This document defines the primary use cases for Sewlio Studio.

A use case describes a concrete workflow that a user performs to achieve a goal. These use cases should guide:

- Product design
- UI design
- Functional requirements
- Test planning
- AI-agent implementation tasks
- End-to-end QA scenarios
- Documentation and tutorials

Every major feature should map to at least one use case.

---

# 2. Use Case Priority

| Priority | Meaning |
|---|---|
| P0 | Required for MVP |
| P1 | Required for first public alpha |
| P2 | Required for professional workflow maturity |
| P3 | Future / advanced |

---

# 3. Primary Actors

| Actor | Description |
|---|---|
| Hobbyist | Casual embroidery creator |
| Professional Digitizer | Commercial embroidery file creator |
| Etsy Seller | Small business seller creating repeatable designs |
| Apparel Designer | Designer converting artwork into embroidery |
| Embroidery Shop | Small production business |
| Teacher | Instructor teaching embroidery |
| AI Agent | Engineering agent implementing or testing features |

---

# 4. MVP Use Cases

---

## UC-001 Create a New Project

**Priority:** P0  
**Primary Actor:** All users  
**Goal:** Start a new embroidery design project.

### Preconditions

- Application is installed or opened in browser.
- User has access to local storage.

### Flow

1. User selects **New Project**.
2. App asks for project name.
3. User selects hoop size or default machine profile.
4. App creates `.swl`.
5. App opens editor workspace.

### Acceptance Criteria

- Project opens successfully.
- Default hoop is visible.
- Project can be saved locally.
- Project metadata is initialized.
- Undo history starts empty.

---

## UC-002 Open an Existing Project

**Priority:** P0  
**Primary Actor:** All users  
**Goal:** Continue editing an existing `.swl`.

### Flow

1. User selects **Open Project**.
2. User chooses `.swl`.
3. App validates project package.
4. App loads project database, assets, layers, and viewport.
5. Editor displays restored project.

### Acceptance Criteria

- Valid project opens.
- Invalid project shows readable error.
- Missing assets are reported.
- Previous viewport may be restored.
- No project data is modified during open unless migration is approved.

---

## UC-003 Save Project

**Priority:** P0  
**Primary Actor:** All users  
**Goal:** Persist current work locally.

### Flow

1. User modifies project.
2. User selects **Save** or autosave triggers.
3. App writes changes to local project package.
4. Save state updates.

### Acceptance Criteria

- Save completes without blocking UI.
- User sees save status.
- Project can be reopened with changes intact.
- Failure displays actionable message.

---

## UC-004 Import SVG Artwork

**Priority:** P0  
**Primary Actor:** Designer, Digitizer, Etsy Seller  
**Goal:** Bring vector artwork into the project.

### Flow

1. User selects **Import SVG**.
2. User chooses SVG file.
3. App parses SVG.
4. App converts supported SVG elements into vector objects.
5. Unsupported features are reported.
6. Imported artwork appears on canvas.

### Acceptance Criteria

- Basic paths import correctly.
- Shapes import correctly.
- Groups are preserved where feasible.
- Unsupported elements do not crash import.
- Imported objects can be selected and edited.

---

## UC-005 Draw Basic Vector Shape

**Priority:** P0  
**Primary Actor:** All users  
**Goal:** Create artwork directly in the editor.

### Flow

1. User selects shape tool.
2. User draws on canvas.
3. App creates vector object.
4. Object appears in layer panel.
5. User can transform it.

### Acceptance Criteria

- Rectangle, ellipse, and line are supported in MVP.
- Object can be selected.
- Object can be moved, scaled, rotated.
- Action is undoable.

---

## UC-006 Select and Transform Object

**Priority:** P0  
**Primary Actor:** All users  
**Goal:** Modify object placement and size.

### Flow

1. User selects object.
2. Bounding box appears.
3. User moves/scales/rotates object.
4. Inspector updates values.
5. User confirms or releases pointer.

### Acceptance Criteria

- Transform is visually previewed.
- Final transform is saved.
- Undo restores previous transform.
- Precision values are shown in inspector.

---

## UC-007 Convert Path to Running Stitch

**Priority:** P0  
**Primary Actor:** Digitizer, Hobbyist  
**Goal:** Convert vector path into running stitch.

### Flow

1. User selects open or closed path.
2. User chooses **Convert to Running Stitch**.
3. User sets stitch spacing.
4. Rust digitizer generates stitch sequence.
5. Stitch object appears in canvas and layer panel.

### Acceptance Criteria

- Output is deterministic.
- Stitch spacing is respected.
- Direction follows path direction.
- Stitch count is shown.
- Operation is undoable.
- Output can be previewed and exported.

---

## UC-008 Convert Closed Shape to Fill Stitch

**Priority:** P0  
**Primary Actor:** Digitizer, Etsy Seller  
**Goal:** Generate fill stitches from a closed vector region.

### Flow

1. User selects closed shape.
2. User chooses **Convert to Fill Stitch**.
3. User configures density and angle.
4. App generates fill stitch object.
5. Preview updates.

### Acceptance Criteria

- Closed shape requirement is validated.
- Open paths show helpful error.
- Density affects output.
- Stitch angle affects output.
- Fill object remains editable through properties.

---

## UC-009 Preview Stitch Output

**Priority:** P0  
**Primary Actor:** All users  
**Goal:** See how embroidery stitches will look.

### Flow

1. User switches to Preview mode.
2. App renders stitch objects.
3. User zooms and pans.
4. User reviews thread path.

### Acceptance Criteria

- Stitches render clearly.
- Zoom and pan remain smooth.
- Hoop boundary remains visible.
- Stitch count and color count are shown.

---

## UC-010 Export DST File

**Priority:** P0  
**Primary Actor:** Digitizer, Shop, Hobbyist  
**Goal:** Export machine-readable DST file.

### Flow

1. User selects **Export**.
2. User chooses DST.
3. App validates design.
4. Rust format engine writes DST.
5. User chooses destination.
6. Export completes.

### Acceptance Criteria

- DST file is generated.
- Export errors are actionable.
- File opens in external embroidery viewer.
- Stitch order is preserved.
- Basic jumps/color changes are represented where supported.

---

## UC-011 Reopen Exported Project and Continue Editing

**Priority:** P0  
**Primary Actor:** All users  
**Goal:** Ensure `.swl` remains editable source of truth.

### Flow

1. User exports DST.
2. User closes project.
3. User reopens `.swl`.
4. User modifies vectors/stitches.
5. User exports again.

### Acceptance Criteria

- Export does not replace project source.
- Project remains editable.
- Machine file is treated as generated artifact.

---

## UC-012 Recover After Crash

**Priority:** P0  
**Primary Actor:** All users  
**Goal:** Recover unsaved work after failure.

### Flow

1. App crashes or closes unexpectedly.
2. User reopens app.
3. App detects recovery data.
4. User chooses recover or discard.
5. Project opens recovered state.

### Acceptance Criteria

- Recovery prompt appears.
- Recovered project is valid.
- User can save recovered project.
- No silent data loss.

---

# 5. Public Alpha Use Cases

---

## UC-101 Import Image as Reference

**Priority:** P1  
**Primary Actor:** Hobbyist, Designer  
**Goal:** Use bitmap image as drawing reference.

### Flow

1. User imports PNG/JPG.
2. Image appears on canvas as reference layer.
3. User adjusts opacity.
4. User traces using vector tools.

### Acceptance Criteria

- Image can be moved/scaled.
- Image layer can be locked.
- Image is saved inside project assets.

---

## UC-102 Trace Artwork Manually

**Priority:** P1  
**Primary Actor:** Designer, Hobbyist  
**Goal:** Create clean vector paths over reference artwork.

### Flow

1. User imports image.
2. User selects pen/pencil tool.
3. User traces artwork.
4. User hides reference image.
5. User digitizes traced vectors.

### Acceptance Criteria

- Tracing workflow is smooth.
- Reference layers do not export as stitches.
- User can lock image layer.

---

## UC-103 Edit Vector Nodes

**Priority:** P1  
**Primary Actor:** Digitizer, Designer  
**Goal:** Refine vector paths before digitizing.

### Flow

1. User selects vector object.
2. User enters node editing mode.
3. User moves nodes and handles.
4. Path updates.
5. Digitized preview updates after regeneration.

### Acceptance Criteria

- Nodes are selectable.
- Bezier handles are editable.
- Changes are undoable.
- Invalid path states are prevented or reported.

---

## UC-104 Manage Layers

**Priority:** P1  
**Primary Actor:** All users  
**Goal:** Organize complex designs.

### Flow

1. User opens Layers panel.
2. User creates layer.
3. User moves objects between layers.
4. User hides/locks layers.
5. Canvas updates.

### Acceptance Criteria

- Layers can be created, renamed, reordered, hidden, locked.
- Hidden layers do not render.
- Locked layers cannot be edited.
- Layer state persists.

---

## UC-105 Use Thread Colors

**Priority:** P1  
**Primary Actor:** Digitizer, Shop  
**Goal:** Assign realistic embroidery thread colors.

### Flow

1. User selects stitch object.
2. User opens thread color selector.
3. User chooses color from library.
4. Object preview updates.
5. Export records color sequence where supported.

### Acceptance Criteria

- Thread color has name/code/RGB.
- Color is not represented only visually.
- Thread changes affect simulation.

---

## UC-106 Use Machine Profile

**Priority:** P1  
**Primary Actor:** Shop, Hobbyist  
**Goal:** Validate design against target machine.

### Flow

1. User selects machine profile.
2. App applies hoop and format constraints.
3. User receives warnings for unsupported conditions.
4. Export uses preferred machine format.

### Acceptance Criteria

- Hoop boundary updates.
- Supported formats are shown.
- Warnings are understandable.
- Profile persists in project.

---

## UC-107 View Stitch Statistics

**Priority:** P1  
**Primary Actor:** Digitizer, Shop  
**Goal:** Understand production characteristics.

### Statistics

- Stitch count
- Color changes
- Estimated run time
- Jump count
- Trim count
- Design size
- Thread usage estimate

### Acceptance Criteria

- Statistics update after changes.
- Values are visible in inspector/status panel.
- Expensive calculations run asynchronously.

---

## UC-108 Animate Stitch Simulation

**Priority:** P1  
**Primary Actor:** All users  
**Goal:** Watch embroidery sequence before exporting.

### Flow

1. User opens simulation timeline.
2. User presses Play.
3. Needle path animates.
4. User pauses/scrubs timeline.
5. User identifies issues.

### Acceptance Criteria

- Play/pause works.
- Scrubbing works.
- Color changes are visible.
- Simulation can be disabled for reduced motion.

---

## UC-109 Save As Duplicate Project

**Priority:** P1  
**Primary Actor:** Etsy Seller, Shop  
**Goal:** Reuse existing design as template.

### Flow

1. User opens project.
2. User selects **Save As**.
3. App creates duplicate `.swl`.
4. User edits duplicate.

### Acceptance Criteria

- Original remains unchanged.
- Assets are copied or referenced safely.
- Duplicate opens independently.

---

## UC-110 Export Project Preview Image

**Priority:** P1  
**Primary Actor:** Etsy Seller, Designer  
**Goal:** Create preview image for customer or listing.

### Flow

1. User selects **Export Preview**.
2. User chooses PNG/JPG.
3. App renders preview.
4. User saves file.

### Acceptance Criteria

- Preview includes design.
- Optional hoop/background can be toggled.
- Export resolution configurable.

---

# 6. Professional Workflow Use Cases

---

## UC-201 Create Satin Stitch Column

**Priority:** P2  
**Primary Actor:** Professional Digitizer  
**Goal:** Create satin stitch lettering or borders.

### Acceptance Criteria

- Satin columns support width, direction, density.
- Column validates maximum width.
- Underlay options available.
- Output preview is accurate.

---

## UC-202 Add Underlay

**Priority:** P2  
**Primary Actor:** Professional Digitizer  
**Goal:** Stabilize embroidery output.

### Underlay Types

- Center walk
- Edge walk
- Zigzag
- Double zigzag

### Acceptance Criteria

- Underlay is generated before top stitch.
- Underlay visibility can be toggled.
- Underlay settings are saved.

---

## UC-203 Adjust Pull Compensation

**Priority:** P2  
**Primary Actor:** Professional Digitizer  
**Goal:** Compensate for fabric distortion.

### Acceptance Criteria

- Compensation can be configured per object.
- Preview updates.
- Values are unit-aware.
- Settings persist.

---

## UC-204 Reorder Stitch Sequence

**Priority:** P2  
**Primary Actor:** Digitizer, Shop  
**Goal:** Optimize machine execution.

### Flow

1. User opens stitch sequence panel.
2. User drags objects to reorder.
3. Simulation updates.
4. Export uses new order.

### Acceptance Criteria

- Order is explicit.
- Color changes update.
- Undo supported.
- Invalid order warnings shown.

---

## UC-205 Optimize Jumps and Trims

**Priority:** P2  
**Primary Actor:** Professional Digitizer  
**Goal:** Reduce inefficient machine movement.

### Acceptance Criteria

- App identifies long jumps.
- App suggests reorder or trims.
- User can apply optimization manually.
- Export reflects changes.

---

## UC-206 Use Multiple Hoops / Artboards

**Priority:** P2  
**Primary Actor:** Advanced Users  
**Goal:** Prepare large or multi-part designs.

### Acceptance Criteria

- Multiple hoop areas can exist.
- Each hoop can export separately.
- Design boundaries are clear.

---

# 7. Tablet Use Cases

---

## UC-301 Draw With Apple Pencil

**Priority:** P1  
**Primary Actor:** Tablet User  
**Goal:** Create artwork naturally using stylus.

### Flow

1. User selects pencil tool.
2. User draws with Apple Pencil.
3. App creates vector path.
4. Pressure may influence stroke preview.
5. User refines path.

### Acceptance Criteria

- Drawing feels responsive.
- Palm rejection works where supported.
- Stylus input does not conflict with touch gestures.
- Path smoothing is configurable.

---

## UC-302 Use Touch Gestures

**Priority:** P1  
**Primary Actor:** Tablet User  
**Goal:** Navigate canvas efficiently.

### Gestures

- Pinch to zoom
- Two-finger pan
- Two-finger tap undo
- Long press context menu
- Drag handles for transform

### Acceptance Criteria

- Gestures do not conflict with drawing.
- Alternatives exist for accessibility.
- Gesture behavior is documented.

---

## UC-303 Use Floating Inspector

**Priority:** P1  
**Primary Actor:** Tablet User  
**Goal:** Edit object properties without desktop-style panels.

### Acceptance Criteria

- Inspector can collapse.
- Inspector does not block canvas excessively.
- Works in landscape and portrait.
- Large touch targets.

---

## UC-304 Continue Work Across Devices via Synced Folder

**Priority:** P1  
**Primary Actor:** Cross-device User  
**Goal:** Work on iPad and desktop using same project file.

### Flow

1. User saves `.swl` in iCloud Drive / Google Drive.
2. Sync provider syncs file.
3. User opens same project on another device.
4. App validates and opens project.

### Acceptance Criteria

- App does not require own cloud backend.
- Project remains portable.
- Conflicting external sync states show warning.

---

# 8. Phone Companion Use Cases

Phones are not the primary production environment.

---

## UC-401 View Project on Phone

**Priority:** P2  
**Primary Actor:** Seller, Shop  
**Goal:** Review design away from desktop/tablet.

### Acceptance Criteria

- Project preview opens.
- Stitch stats visible.
- Full editing is not required.

---

## UC-402 Review Thread Colors

**Priority:** P2  
**Primary Actor:** Shop  
**Goal:** Check required thread colors.

### Acceptance Criteria

- Thread list is readable.
- Manufacturer codes shown.
- Colors are searchable.

---

## UC-403 Share Preview With Customer

**Priority:** P2  
**Primary Actor:** Etsy Seller  
**Goal:** Send design preview.

### Acceptance Criteria

- Exported preview can be shared through platform share sheet.
- Project source is not shared unless user chooses.

---

# 9. Educational Use Cases

---

## UC-501 Demonstrate Stitch Generation

**Priority:** P2  
**Primary Actor:** Teacher  
**Goal:** Teach digitizing concepts.

### Flow

1. Teacher creates simple vector.
2. Converts to stitches.
3. Adjusts spacing/density.
4. Shows simulation.

### Acceptance Criteria

- Differences are visually clear.
- Settings are easy to explain.
- Simulation can be slowed down.

---

## UC-502 Use Sample Projects

**Priority:** P2  
**Primary Actor:** Student  
**Goal:** Learn from examples.

### Acceptance Criteria

- Sample projects can be opened offline.
- Projects include notes or tutorial metadata.
- Students can duplicate samples.

---

# 10. AI Agent Use Cases

---

## UC-901 Generate Implementation Ticket

**Priority:** P0  
**Primary Actor:** Claude Code  
**Goal:** Convert requirement into coding task.

### Flow

1. Agent reads PRD and use case.
2. Agent identifies relevant package.
3. Agent creates task with acceptance criteria.
4. Local coding agent implements.

### Acceptance Criteria

- Ticket references requirement IDs.
- Scope is small.
- Tests are specified.
- Architecture boundaries are explicit.

---

## UC-902 Implement Isolated Feature

**Priority:** P0  
**Primary Actor:** Local Coding Agent  
**Goal:** Implement a feature without architectural drift.

### Acceptance Criteria

- Agent reads relevant docs.
- Agent modifies only assigned package.
- Tests are added.
- Summary explains changes.

---

## UC-903 Review Implementation

**Priority:** P0  
**Primary Actor:** Claude Code / Review Agent  
**Goal:** Validate quality and architecture compliance.

### Acceptance Criteria

- Diff is reviewed.
- Tests pass.
- Package boundaries respected.
- Documentation updated if needed.

---

# 11. Error and Recovery Use Cases

---

## UC-1001 Unsupported SVG Element

**Priority:** P0  
**Primary Actor:** User  
**Goal:** Handle import limitations safely.

### Acceptance Criteria

- App imports supported elements.
- Unsupported items are listed.
- App does not crash.
- User can continue.

---

## UC-1002 Export Validation Failure

**Priority:** P0  
**Primary Actor:** User  
**Goal:** Explain why export cannot complete.

### Acceptance Criteria

- Error message identifies issue.
- Recommended fix is provided.
- No partial corrupt export is produced.

---

## UC-1003 Missing Asset

**Priority:** P1  
**Primary Actor:** User  
**Goal:** Recover from moved/deleted asset.

### Acceptance Criteria

- Missing asset is shown in project report.
- User can relink or remove reference.
- Project remains openable.

---

## UC-1004 Project Migration

**Priority:** P1  
**Primary Actor:** Returning User  
**Goal:** Open older `.swl` version.

### Acceptance Criteria

- Migration preview shown.
- Backup created before migration.
- Migration is logged.
- Failure leaves original untouched.

---

# 12. Use Case to MVP Mapping

| Use Case | MVP |
|---|---|
| UC-001 Create Project | Yes |
| UC-002 Open Project | Yes |
| UC-003 Save Project | Yes |
| UC-004 Import SVG | Yes |
| UC-005 Draw Shape | Yes |
| UC-006 Transform Object | Yes |
| UC-007 Running Stitch | Yes |
| UC-008 Fill Stitch | Yes |
| UC-009 Preview | Yes |
| UC-010 Export DST | Yes |
| UC-011 Reopen Project | Yes |
| UC-012 Crash Recovery | Yes |
| UC-101 Import Image | Alpha |
| UC-103 Node Editing | Alpha |
| UC-105 Thread Colors | Alpha |
| UC-106 Machine Profile | Alpha |
| UC-108 Simulation Animation | Alpha |
| UC-301 Apple Pencil | Alpha |
| UC-304 Synced Folder Workflow | Alpha |

---

# 13. Definition of Done for Use Cases

A use case is implementation-ready when it has:

- Primary actor
- Goal
- Priority
- Preconditions
- Main flow
- Edge cases
- Acceptance criteria
- Related functional requirements
- Test scenarios
- UX notes
- Architecture notes

---

# 14. Future Use Cases

Future documents should expand:

- Auto digitizing from image
- AI-assisted cleanup
- Plugin installation
- Custom machine profile creation
- Batch export
- Server-side conversion
- Cloud project sharing
- Real-time collaboration
- Marketplace templates
- Machine transfer over USB/WiFi
- Print worksheet generation
- Production run estimation
- Fabric-specific presets

---

# 15. Document Maintenance

This document must be updated when:

- A major feature is added
- A persona changes
- A workflow changes
- A platform is added
- MVP scope changes
- AI-agent workflow changes

Every use case should eventually map to one or more functional requirements and at least one test scenario.
