import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studio/src/recents.dart';

RecentProject entry(String path, {String? name}) => RecentProject(
      name: name ?? path,
      path: path,
      hoopWidthMm: 100,
      hoopHeightMm: 100,
      lastOpened: DateTime(2026, 7, 10),
    );

void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('recents'));
  tearDown(() => temp.deleteSync(recursive: true));

  test('record upserts by path, most-recent-first, capped at 20', () {
    final store = RecentsStore.memory();
    for (var i = 0; i < 25; i++) {
      store.record(entry('/p/$i.swl'));
    }
    expect(store.entries.length, 20);
    expect(store.entries.first.path, '/p/24.swl');
    store.record(entry('/p/24.swl', name: 'renamed'));
    expect(store.entries.length, 20);
    expect(store.entries.first.name, 'renamed');
  });

  test('remove drops the entry', () {
    final store = RecentsStore.memory()..record(entry('/p/a.swl'));
    store.remove('/p/a.swl');
    expect(store.entries, isEmpty);
  });

  test('round-trips through the JSON file, creating parent dirs', () async {
    final path = '${temp.path}/nested/recents.json';
    RecentsStore(path)
      ..record(entry('/p/a.swl'))
      ..record(entry('/p/b.swl'));
    final reloaded = RecentsStore(path);
    await reloaded.load();
    expect(reloaded.entries.map((e) => e.path), ['/p/b.swl', '/p/a.swl']);
    expect(reloaded.entries.first.hoopWidthMm, 100);
  });

  test('corrupt file loads as empty', () async {
    final path = '${temp.path}/recents.json';
    File(path).writeAsStringSync('not json');
    final store = RecentsStore(path);
    await store.load();
    expect(store.entries, isEmpty);
  });

  test('missing file loads as empty', () async {
    final store = RecentsStore('${temp.path}/absent.json');
    await store.load();
    expect(store.entries, isEmpty);
  });
}
