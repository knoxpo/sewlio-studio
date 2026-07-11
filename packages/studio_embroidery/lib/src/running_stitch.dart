import 'dart:math' as math;

import 'package:studio_geometry/studio_geometry.dart';

import 'fill.dart';
import 'objects.dart';
import 'satin.dart';
import 'stitch_ir.dart';

/// Generates stitch ops for one object. Dispatches on object type
/// (ADR-042: satin and fill generators are implemented).
List<StitchOp> generateStitches(EmbroideryObject object) => switch (object) {
      RunningStitchObject(:final path, :final stitchLength) =>
        generateRunningStitch(path, stitchLength: stitchLength),
      TextObject(:final outlines, :final stitchLength) =>
        _outlineRuns(outlines, stitchLength),
      SatinObject(:final path, :final width) =>
        generateSatin(path, width: width),
      FillObject(:final path, :final holes, :final spacing) =>
        generateFill([path, ...holes], spacing: spacing),
    };

/// Running stitch over each contour, joined by trim + jump — text
/// glyph outlines stitch as outline lettering (ADR-028; satin
/// lettering arrives with the satin generator).
List<StitchOp> _outlineRuns(List<Path> outlines, double stitchLength) {
  final ops = <StitchOp>[];
  for (final outline in outlines) {
    final run = generateRunningStitch(outline, stitchLength: stitchLength);
    if (run.isEmpty) continue;
    if (ops.isNotEmpty) {
      ops
        ..add(StitchOp(StitchKind.trim, ops.last.position))
        ..add(StitchOp.jump(run.first.position));
    }
    ops.addAll(run);
  }
  return ops;
}

/// Single-vertex direction change (radians) that always gets a needle
/// point: a sharp corner in the drawn geometry (DOM-212 cornering).
const _cornerRad = math.pi / 6; // 30°

/// Accumulated turning since the last stitch that forces a needle
/// point on a curve — every ~10° of arc keeps letterform bowls
/// ('o', 'p', 'n') visually round: chord error stays ≤ r·(1−cos 5°)
/// ≈ 0.4 % of the curve radius, in line with the ~0.05–0.1 mm chord
/// tolerance commercial digitizers use for curve tracing.
const _curveRad = math.pi / 18; // 10°

/// Curve pins closer than this to the previous stitch are dropped
/// (machine-unfriendly micro stitches); sharp corners always pin.
const _minPinMm = 0.3;

/// Tight-feature tier (small-lettering counter ends, stem fillets,
/// ~0.2–1 mm radii): once the path has turned this much since the last
/// stitch, pins are allowed down to [_tightPinMm] instead of
/// [_minPinMm], so tiny caps and elbows render round instead of as a
/// couple of long chords.
const _tightTurnRad = math.pi / 12; // 15°

// ponytail: 0.12 mm stitches are at the machine's lower limit — the
// machine compiler can merge/filter micro stitches per profile later.
const _tightPinMm = 0.12;

/// Chord-sag trigger (mm): a stitch is pinned once its estimated sag
/// (≈ turn·length/8) reaches this. Catches gentle large-radius curves
/// whose turn stays under [_curveRad] between full-length stitches.
/// Pins land on flattening vertices, so the realized sag can overshoot
/// by one vertex step — with the 0.005 mm flattening tolerance the
/// effective ceiling is ≈ 0.02 mm: at any on-screen zoom the stitch
/// chords visually hug the drawn outline.
const _maxSagMm = 0.015;

/// Resamples [path] into stitches of ~[stitchLength] mm, pinning a
/// stitch on every sharp corner and roughly every 15° of curve turn so
/// the stitched shape follows the drawn geometry instead of chording
/// across it.
///
/// Deterministic: same path + params → same ops. The last stitch
/// always lands exactly on the path end.
List<StitchOp> generateRunningStitch(
  Path path, {
  double stitchLength = 2.5,
  // Finer than the renderer's 0.01: sag pins land on flattening
  // vertices, so vertex spacing bounds how tightly chords can follow
  // a curve.
  double tolerance = 0.005,
}) {
  if (stitchLength <= 0) {
    throw ArgumentError.value(stitchLength, 'stitchLength', 'must be > 0 mm');
  }
  final polyline = path.toPolyline(tolerance: tolerance);
  final ops = <StitchOp>[StitchOp.stitch(polyline.first)];
  var last = polyline.first;
  var carried = 0.0; // distance already walked toward the next stitch
  var turned = 0.0; // |direction change| accumulated since last pin
  for (var i = 1; i < polyline.length; i++) {
    final target = polyline[i];
    var span = last.distanceTo(target);
    var from = last;
    while (carried + span >= stitchLength) {
      final t = (stitchLength - carried) / span;
      final p = from.lerp(target, t);
      ops.add(StitchOp.stitch(p));
      span -= stitchLength - carried;
      carried = 0;
      turned = 0; // pinning measures turn since the last needle point
      from = p;
    }
    carried += span;
    last = target;
    // Corner/curvature pinning at this vertex.
    if (i + 1 < polyline.length) {
      final turn = _turnAt(polyline[i - 1], target, polyline[i + 1]);
      turned += turn;
      final dist = ops.last.position.distanceTo(target);
      final sharp = turn >= _cornerRad;
      // Worst-case chord sag for the accumulated turn: θ·L/4 (turn
      // concentrated mid-chord); a uniform arc is θ·L/8. Using the
      // worst case keeps sub-corner bends (stem→fillet transitions)
      // from cutting visibly inside the outline.
      final curved =
          (turned >= _curveRad || turned * carried / 4 >= _maxSagMm) &&
              dist >= _minPinMm;
      // Tight feature: fast accumulated turn on a tiny radius — allow
      // short pins so caps and fillets stay round.
      final tightCap = turned >= _tightTurnRad && dist >= _tightPinMm;
      if ((sharp || curved || tightCap) &&
          !ops.last.position.almostEquals(target, tolerance: 1e-6)) {
        ops.add(StitchOp.stitch(target));
        carried = 0;
        turned = 0;
      }
    }
  }
  // Close out on the exact path end (skip if it coincides with the
  // previous stitch).
  if (!ops.last.position.almostEquals(last, tolerance: 1e-6)) {
    ops.add(StitchOp.stitch(last));
  }
  return ops;
}

/// Absolute direction change at vertex [v] between segments [a]→[v]
/// and [v]→[b]; zero for degenerate (zero-length) segments.
double _turnAt(Point a, Point v, Point b) {
  final ix = v.x - a.x, iy = v.y - a.y;
  final ox = b.x - v.x, oy = b.y - v.y;
  final cross = ix * oy - iy * ox;
  final dot = ix * ox + iy * oy;
  if (cross == 0 && dot == 0) return 0;
  return math.atan2(cross, dot).abs();
}
