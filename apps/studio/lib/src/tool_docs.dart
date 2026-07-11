/// Tool documentation metadata: drives the hover Tool Learning Card
/// and the Learn More dialog. Generic by design — a plugin tool gets
/// the same UI by calling [registerToolDoc]; nothing here is hardcoded
/// to built-ins beyond the seed entries.
final class ToolDoc {
  const ToolDoc({
    required this.id,
    required this.name,
    this.shortcut,
    required this.description,
    this.quickStart = const [],
    this.modifiers = const [],
    this.learnMore = '',
  });

  /// Registry key — the toolbox button's label.
  final String id;

  final String name;
  final String? shortcut;

  /// One–two line purpose statement.
  final String description;

  /// Practical interaction hints, one action per line.
  final List<String> quickStart;

  /// Modifier-key behaviors ("Shift — constrain to 45°").
  final List<String> modifiers;

  /// Longer prose for the Learn More dialog (best practices, tips).
  final String learnMore;
}

/// Registry: seeded with the built-in tools; plugins add theirs via
/// [registerToolDoc] and automatically get the same learning card.
final Map<String, ToolDoc> _toolDocs = {
  for (final doc in _builtinDocs) doc.id: doc,
};

void registerToolDoc(ToolDoc doc) => _toolDocs[doc.id] = doc;

ToolDoc? toolDocFor(String id) => _toolDocs[id];

const _builtinDocs = <ToolDoc>[
  ToolDoc(
    id: 'Move',
    name: 'Move Tool',
    shortcut: 'V',
    description: 'Select, move, resize, and rotate design objects.',
    quickStart: [
      'Click an object to select it.',
      'Drag a selected object to move it.',
      'Drag a corner or edge handle to resize.',
      'Drag the grip above the box to rotate.',
      'Drag on empty canvas for a marquee selection.',
    ],
    modifiers: [
      'Shift — uniform corner scaling / 15° rotation steps.',
      'Alt — scale from the selection center.',
      'Cmd/Ctrl-click — toggle objects in the selection.',
    ],
    learnMore: 'The Move tool is the primary manipulation tool. Every '
        'transform commits as a single undoable step on release, so one '
        'Cmd+Z reverts a whole drag. Double-click a text object to edit '
        'it in place.',
  ),
  ToolDoc(
    id: 'Node',
    name: 'Node Tool',
    shortcut: 'A',
    description: 'Edit the anchor points of an existing path.',
    quickStart: [
      'Click an object to show its anchors.',
      'Drag an anchor to reshape the path.',
    ],
    learnMore: 'Anchor edits replace the object geometry as one '
        'undoable step per drag. Stitches regenerate automatically from '
        'the edited path.',
  ),
  ToolDoc(
    id: 'Hoop',
    name: 'Hoop Tool',
    shortcut: 'D',
    description: 'Edit the hoop size, shape, and fabric.',
    quickStart: ['Click anywhere on the canvas to open Document Setup.'],
    learnMore: 'The hoop is the embroidery artboard: it defines the '
        'machine work area and the fabric preview. Designs must fit '
        'inside it to export.',
  ),
  ToolDoc(
    id: 'Pen',
    name: 'Pen Tool',
    shortcut: 'P',
    description: 'Precisely draw paths, closed shapes, and straight lines that '
        'stitch as running-stitch objects.',
    quickStart: [
      'Click to place the first point.',
      'Click again for straight segments.',
      'Click the first point to close the shape.',
      'Click an existing point to remove it.',
      'Double-click to finish an open path.',
    ],
    modifiers: [
      'Shift/Ctrl — constrain the next point to 45°.',
      'Esc — finish the path (typed points commit).',
    ],
    learnMore: 'The pen has four modes in the options bar: Pen (straight '
        'segments), Smart (fits a smooth curve through your clicks), '
        'Polygon (always closes), and Line (two-point segments). '
        'Activating the pen with an open path selected continues that '
        'path. The cursor badge always announces the next click: '
        '× start, + add, − remove, o close.',
  ),
  ToolDoc(
    id: 'Pencil',
    name: 'Pencil Tool',
    shortcut: 'B',
    description: 'Freehand-draw a path by dragging.',
    quickStart: [
      'Press and drag to draw.',
      'Release to commit the stroke as a path.',
    ],
    learnMore: 'Pencil strokes become running-stitch paths, like pen '
        'paths — use the pen for precision, the pencil for speed.',
  ),
  ToolDoc(
    id: 'Shapes',
    name: 'Shape Tool',
    shortcut: 'M',
    description: 'Draw geometric shapes: rectangles, ellipses, stars…',
    quickStart: [
      'Pick a shape from the flyout.',
      'Drag on the canvas to size it.',
    ],
    modifiers: ['Shift — constrain to a square/circle.'],
    learnMore: 'Shapes commit as closed paths and stitch as outlines '
        'until the fill generator lands.',
  ),
  ToolDoc(
    id: 'Text',
    name: 'Text Tool',
    shortcut: 'T',
    description: 'Type editable text that digitizes into per-glyph stitches.',
    quickStart: [
      'Click for point text, drag for a wrapping frame.',
      'Type directly on the canvas.',
      'Enter commits; Shift+Enter breaks the line.',
      'Click committed text to edit it again.',
    ],
    modifiers: [
      '←/→, Home/End — move the caret.',
      'Backspace/Delete — edit at the caret.',
    ],
    learnMore: 'Text stays one editable object — string, font, size, '
        'and alignment are always re-editable. The Stitches panel can '
        'expand a text object to inspect the stitches generated per '
        'glyph.',
  ),
  ToolDoc(
    id: 'Measure',
    name: 'Measure Tool',
    shortcut: 'R',
    description: 'Measure distances on the canvas in millimeters.',
    quickStart: [
      'Click two points to measure between them.',
    ],
  ),
  ToolDoc(
    id: 'View (Pan)',
    name: 'View Tool',
    shortcut: 'H',
    description: 'Pan the canvas without touching the design.',
    quickStart: ['Drag anywhere to pan the view.'],
  ),
  ToolDoc(
    id: 'Zoom',
    name: 'Zoom Tool',
    shortcut: 'Z',
    description: 'Zoom the view in and out about a point.',
    quickStart: ['Click to zoom in.'],
    modifiers: ['Alt — click to zoom out.'],
  ),
];
