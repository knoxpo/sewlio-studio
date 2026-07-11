import 'package:flutter_test/flutter_test.dart';
import 'package:studio/src/dock/dock_controller.dart';
import 'package:studio/src/dock/dock_layout.dart';

const ids = ['stitches', 'layers', 'properties'];

void main() {
  group('DockLayout', () {
    test('defaults: one group with every panel, first tab active', () {
      final layout = DockLayout.defaults(ids);
      expect(layout.groups, hasLength(1));
      expect(layout.groups.single.panelIds, ids);
      expect(layout.groups.single.activeId, 'stitches');
      expect(layout.width, DockLayout.defaultWidth);
    });

    test('encode/decode round-trip', () {
      final layout = DockLayout(
        width: 340,
        hidden: {'stitches'},
        groups: [
          DockGroup(panelIds: ['layers'], flex: 2, collapsed: true),
          DockGroup(panelIds: ['properties']),
        ],
      );
      final decoded = DockLayout.decode(layout.encode());
      expect(decoded.width, 340);
      expect(decoded.hidden, {'stitches'});
      expect(decoded.groups, hasLength(2));
      expect(decoded.groups.first.panelIds, ['layers']);
      expect(decoded.groups.first.flex, 2);
      expect(decoded.groups.first.collapsed, isTrue);
      expect(decoded.groups.last.activeId, 'properties');
    });

    test('normalize drops unknown ids and empty groups', () {
      final layout = DockLayout(groups: [
        DockGroup(panelIds: ['gone', 'layers']),
        DockGroup(panelIds: ['obsolete']),
      ]);
      layout.normalize(ids);
      expect(layout.groups, hasLength(1));
      // Missing registered panels are appended to the last group.
      expect(
          layout.groups.single.panelIds, ['layers', 'stitches', 'properties']);
    });

    test('normalize appends newly registered panels', () {
      final layout = DockLayout(groups: [
        DockGroup(panelIds: ['stitches', 'layers']),
      ]);
      layout.normalize([...ids, 'history']);
      expect(layout.groups.single.panelIds,
          ['stitches', 'layers', 'properties', 'history']);
    });

    test('normalize respects hidden panels and fixes bad active/width', () {
      final layout = DockLayout(
        width: 9999,
        hidden: {'properties', 'unknown'},
        groups: [
          DockGroup(panelIds: ['stitches', 'layers'], activeId: 'stitches'),
        ],
      );
      layout.groups.single.activeId = 'properties'; // not in this group
      layout.normalize(ids);
      expect(layout.hidden, {'properties'});
      expect(layout.groups.single.panelIds, ['stitches', 'layers']);
      expect(layout.groups.single.activeId, 'stitches');
      expect(layout.width, DockLayout.maxWidth);
    });

    test('normalize dedups a panel placed in two groups', () {
      final layout = DockLayout(groups: [
        DockGroup(panelIds: ['layers', 'stitches']),
        DockGroup(panelIds: ['layers', 'properties']),
      ]);
      layout.normalize(ids);
      expect(layout.groups[0].panelIds, ['layers', 'stitches']);
      expect(layout.groups[1].panelIds, ['properties']);
    });
  });

  group('DockController', () {
    DockController make() => DockController.memory(panelIds: ids);

    test('selectTab activates within its group', () {
      final dock = make();
      dock.selectTab('layers');
      expect(dock.layout.groups.single.activeId, 'layers');
    });

    test('movePanel reorders within a group (index adjusts on removal)', () {
      final dock = make();
      final group = dock.layout.groups.single;
      dock.movePanel('stitches', group: group, tabIndex: 3);
      expect(group.panelIds, ['layers', 'properties', 'stitches']);
      expect(group.activeId, 'stitches');
    });

    test('splitOut tears a tab into its own group', () {
      final dock = make();
      dock.splitOut('layers', groupIndex: 1);
      expect(dock.layout.groups, hasLength(2));
      expect(dock.layout.groups[0].panelIds, ['stitches', 'properties']);
      expect(dock.layout.groups[1].panelIds, ['layers']);
    });

    test('movePanel back into another group drops the emptied group', () {
      final dock = make();
      dock.splitOut('layers', groupIndex: 1);
      dock.movePanel('layers', group: dock.layout.groups.first, tabIndex: 0);
      expect(dock.layout.groups, hasLength(1));
      expect(dock.layout.groups.single.panelIds,
          ['layers', 'stitches', 'properties']);
    });

    test('splitOut of a lone panel repositions its group', () {
      final dock = make();
      dock.splitOut('stitches',
          groupIndex: 1); // groups: [layers+props][stitches]
      dock.splitOut('stitches', groupIndex: 0); // move above
      expect(dock.layout.groups[0].panelIds, ['stitches']);
      expect(dock.layout.groups[1].panelIds, ['layers', 'properties']);
      expect(dock.layout.groups, hasLength(2));
    });

    test('togglePanel hides and reshows via the last group', () {
      final dock = make();
      dock.togglePanel('properties');
      expect(dock.isVisible('properties'), isFalse);
      expect(dock.layout.hidden, {'properties'});
      dock.togglePanel('properties');
      expect(dock.isVisible('properties'), isTrue);
      expect(dock.layout.groups.last.activeId, 'properties');
    });

    test('hiding every panel empties the dock without crashing', () {
      final dock = make();
      for (final id in ids) {
        dock.togglePanel(id);
      }
      expect(dock.layout.groups, isEmpty);
      dock.togglePanel('layers');
      expect(dock.layout.groups.single.panelIds, ['layers']);
    });

    test('resetToDefault restores the factory layout', () {
      final dock = make();
      dock.splitOut('layers', groupIndex: 1);
      dock.togglePanel('stitches');
      dock.resizeWidth(400);
      dock.resetToDefault();
      expect(dock.layout.groups.single.panelIds, ids);
      expect(dock.layout.hidden, isEmpty);
      expect(dock.layout.width, DockLayout.defaultWidth);
    });

    test('resizeWidth clamps to bounds', () {
      final dock = make();
      dock.resizeWidth(10);
      expect(dock.layout.width, DockLayout.minWidth);
      dock.resizeWidth(2000);
      expect(dock.layout.width, DockLayout.maxWidth);
    });
  });
}
