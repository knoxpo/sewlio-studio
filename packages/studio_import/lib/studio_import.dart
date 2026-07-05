/// Raster and vector import + normalization.
///
/// Importers normalize external content into the geometry model
/// (ARCH-015). Raster images become reference assets (bytes +
/// dimensions, decoded by the UI layer for display); vectors become
/// mm-based [Path]s.
library;

export 'src/raster.dart';
export 'src/svg.dart';
