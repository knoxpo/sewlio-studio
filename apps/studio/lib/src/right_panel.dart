import 'package:flutter/material.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

/// Right inspector: stitch list per object + total. Rows select
/// objects; counts come from the real generators.
class StitchListPanel extends StatelessWidget {
  const StitchListPanel({
    super.key,
    required this.document,
    required this.selectedId,
    required this.onSelect,
  });

  final Document document;
  final Id? selectedId;
  final void Function(Id id) onSelect;

  int? _count(EmbroideryObject object) {
    try {
      return generateStitches(object).length;
    } on UnimplementedError {
      return null; // satin/fill pending
    }
  }

  @override
  Widget build(BuildContext context) {
    final counts = [for (final o in document.objects) (o, _count(o))];
    final total = counts.fold<int>(0, (sum, entry) => sum + (entry.$2 ?? 0));
    return StudioPanel(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppTokens.background,
              border: Border(bottom: BorderSide(color: AppTokens.border)),
            ),
            child: Row(
              children: [
                _tab('Stitches', active: true),
                _tab('Layers'),
                _tab('Objects'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: const [
                SizedBox(width: 20, child: Text('#', style: _headerStyle)),
                SizedBox(width: 28, child: Text('Color', style: _headerStyle)),
                Expanded(child: Text('Stitch Type', style: _headerStyle)),
                Text('Stitches', style: _headerStyle),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: counts.length,
              itemBuilder: (context, index) {
                final (object, count) = counts[index];
                final selected = object.id == selectedId;
                return InkWell(
                  onTap: () => onSelect(object.id),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppTokens.surfaceHigh : null,
                      border: selected
                          ? Border.all(color: AppTokens.primary)
                          : null,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 20,
                            child: Text('${index + 1}',
                                style: const TextStyle(
                                    color: AppTokens.textMuted, fontSize: 10))),
                        SizedBox(
                          width: 28,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppTokens.accentGreen,
                              border: Border.all(color: AppTokens.border),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            switch (object) {
                              RunningStitchObject() => 'Running Stitch',
                              SatinObject() => 'Satin Stitch',
                              FillObject() => 'Fill Stitch',
                            },
                            style: TextStyle(
                              color: selected
                                  ? AppTokens.primary
                                  : AppTokens.textPrimary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(count?.toString() ?? '—',
                            style: const TextStyle(
                                color: AppTokens.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTokens.background,
              border: Border(top: BorderSide(color: AppTokens.border)),
            ),
            child: Text('Total Stitches: $total',
                style:
                    const TextStyle(color: AppTokens.textMuted, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  static const _headerStyle =
      TextStyle(color: AppTokens.textMuted, fontSize: 10);

  Widget _tab(String label, {bool active = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTokens.surfaceHigh : null,
          border: Border(
            bottom: BorderSide(
              color: active ? AppTokens.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? AppTokens.primary : AppTokens.textMuted,
            fontWeight: active ? FontWeight.w500 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
