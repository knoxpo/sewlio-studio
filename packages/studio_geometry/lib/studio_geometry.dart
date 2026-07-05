/// Geometry model: points, paths, curves, transforms, bounds.
///
/// Units are **millimeters** throughout; coordinates are doubles.
/// Determinism policy (risk R2): comparisons use [epsilon]; anything
/// serialized (goldens, project files) goes through [roundCoord], which
/// rounds to [coordPrecision] decimals so output is byte-stable across
/// platforms.
library;

export 'src/bounds.dart';
export 'src/path.dart';
export 'src/point.dart';
export 'src/transform.dart';
