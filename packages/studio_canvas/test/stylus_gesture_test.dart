import 'package:flutter_test/flutter_test.dart';
import 'package:studio_canvas/studio_canvas.dart';

void main() {
  late List<String> log;
  late StylusGestureHandler handler;

  setUp(() {
    log = [];
    handler = StylusGestureHandler(
      onTap: (p) => log.add('tap ${p.dx},${p.dy}'),
      onDragStart: (p, pressure) => log.add('start ${p.dx},${p.dy} $pressure'),
      onDragUpdate: (p, pressure) =>
          log.add('update ${p.dx},${p.dy} $pressure'),
      onDragEnd: () => log.add('end'),
    );
  });

  test('down/up within slop is a tap at the down position', () {
    handler.down(const Offset(10, 10), 0.5);
    handler.move(const Offset(12, 11), 0.5); // within 6px slop
    handler.up(const Offset(12, 11));
    expect(log, ['tap 10.0,10.0']);
  });

  test(
      'movement past slop starts a drag at the down position with '
      'contact pressure', () {
    handler.down(const Offset(10, 10), 0.3);
    handler.move(const Offset(20, 10), 0.6);
    handler.move(const Offset(25, 10), 0.9);
    handler.up(const Offset(25, 10));
    expect(log, [
      'start 10.0,10.0 0.3',
      'update 20.0,10.0 0.6',
      'update 25.0,10.0 0.9',
      'end',
    ]);
  });

  test('cancel mid-drag ends the drag without a tap', () {
    handler.down(const Offset(0, 0), 1);
    handler.move(const Offset(30, 0), 1);
    handler.cancel();
    expect(log, ['start 0.0,0.0 1.0', 'update 30.0,0.0 1.0', 'end']);
    expect(handler.isActive, isFalse);
  });

  test('cancel before drag emits nothing', () {
    handler.down(const Offset(0, 0), 1);
    handler.cancel();
    expect(log, isEmpty);
  });

  test('move/up without down are ignored', () {
    handler.move(const Offset(5, 5), 1);
    handler.up(const Offset(5, 5));
    expect(log, isEmpty);
  });
}
