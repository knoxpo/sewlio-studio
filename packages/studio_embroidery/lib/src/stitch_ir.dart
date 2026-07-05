import 'package:studio_geometry/studio_geometry.dart';

/// Stitch IR schema version. Bump + migrate on breaking change (ADR).
const String stitchIrVersion = '1';

/// What a single operation in a stitch sequence does.
enum StitchKind {
  /// Needle down at [StitchOp.position].
  stitch,

  /// Move to [StitchOp.position] without stitching.
  jump,

  /// Cut thread at the current position.
  trim,

  /// Switch to the next thread in [StitchSequence.threads].
  colorChange,

  /// Machine stop (applique, manual action).
  stop,
}

/// One immutable operation. Position is in mm, design space.
final class StitchOp {
  const StitchOp(this.kind, this.position);

  const StitchOp.stitch(Point p) : this(StitchKind.stitch, p);
  const StitchOp.jump(Point p) : this(StitchKind.jump, p);

  final StitchKind kind;
  final Point position;

  Map<String, dynamic> toJson() => {'k': kind.name, 'p': position.toJson()};

  factory StitchOp.fromJson(Map<String, dynamic> json) => StitchOp(
        StitchKind.values.byName(json['k'] as String),
        Point.fromJson(json['p'] as List),
      );

  @override
  bool operator ==(Object other) =>
      other is StitchOp && other.kind == kind && other.position == position;

  @override
  int get hashCode => Object.hash(kind, position);

  @override
  String toString() => '${kind.name}@$position';
}

/// A thread used by a sequence. Color is `#RRGGBB`.
final class Thread {
  const Thread(this.color, {this.name});

  final String color;
  final String? name;

  Map<String, dynamic> toJson() =>
      {'color': color, if (name != null) 'name': name};

  factory Thread.fromJson(Map<String, dynamic> json) =>
      Thread(json['color'] as String, name: json['name'] as String?);
}

/// The Stitch IR: an immutable, ordered stitch program plus its
/// thread palette.
final class StitchSequence {
  const StitchSequence({required this.threads, required this.ops});

  final List<Thread> threads;
  final List<StitchOp> ops;

  int get stitchCount => ops.where((op) => op.kind == StitchKind.stitch).length;

  Map<String, dynamic> toJson() => {
        'version': stitchIrVersion,
        'threads': [for (final t in threads) t.toJson()],
        'ops': [for (final op in ops) op.toJson()],
      };

  factory StitchSequence.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as String;
    if (version != stitchIrVersion) {
      throw FormatException('Unsupported Stitch IR version: $version');
    }
    return StitchSequence(
      threads: [
        for (final t in json['threads'] as List)
          Thread.fromJson(t as Map<String, dynamic>)
      ],
      ops: [
        for (final op in json['ops'] as List)
          StitchOp.fromJson(op as Map<String, dynamic>)
      ],
    );
  }
}
