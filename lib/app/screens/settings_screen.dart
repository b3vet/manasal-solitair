/// Ayarlar (Kilim yönü): ses, titreşim, hareketi azalt, tema, hakkında.
library;

import 'package:flutter/material.dart';

import '../audio/sound_service.dart';
import '../meta/meta_scope.dart';
import '../meta/meta_service.dart';
import '../theme/app_theme.dart';
import '../theme/kilim.dart';
import '../theme/tokens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta = MetaScope.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: kilimAppBar(context, 'Ayarlar'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Anahtar grubu.
            _group(colors, [
              _switchRow(
                colors,
                label: 'Ses',
                value: meta.sound,
                onChanged: (v) {
                  meta.updateSettings(sound: v);
                  SoundService.instance.enabled = v;
                  if (v) SoundService.instance.play(Sfx.button);
                },
              ),
              _divider(colors),
              _switchRow(
                colors,
                label: 'Titreşim',
                value: meta.haptics,
                onChanged: (v) => meta.updateSettings(haptics: v),
              ),
              _divider(colors),
              _switchRow(
                colors,
                label: 'Hareketi azalt',
                subtitle: 'Animasyonları sadeleştirir',
                value: meta.reducedMotion == 'off',
                onChanged: (v) =>
                    meta.updateSettings(reducedMotion: v ? 'off' : 'on'),
              ),
            ]),
            const SizedBox(height: 22),
            _sectionLabel(colors, 'TEMA'),
            const SizedBox(height: 8),
            _Segmented(
              value: meta.themeMode,
              options: const [
                ('light', 'Açık'),
                ('dark', 'Koyu'),
                ('system', 'Sistem'),
              ],
              onSelect: (v) => meta.updateSettings(themeMode: v),
            ),
            const SizedBox(height: 22),
            _aboutCard(colors, meta),
          ],
        ),
      ),
    );
  }

  Widget _group(GameColors colors, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Dim.panelRadius),
        border: Border.all(color: colors.cardEdge),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(GameColors colors) => Divider(
    height: 1,
    thickness: 1,
    color: colors.cardEdge.withValues(alpha: 0.6),
    indent: 18,
    endIndent: 18,
  );

  Widget _switchRow(
    GameColors colors, {
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: TextStyle(color: colors.inkSoft, fontSize: 12.5),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.onAccent,
            activeTrackColor: colors.accent,
            inactiveThumbColor: colors.surface,
            inactiveTrackColor: colors.slotEmpty,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(GameColors colors, String text) => Padding(
    padding: const EdgeInsets.only(left: 6),
    child: Text(
      text,
      style: TextStyle(
        color: colors.inkSoft,
        fontSize: 12,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _aboutCard(GameColors colors, MetaService meta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Dim.panelRadius),
        border: Border.all(color: colors.cardEdge),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: FittedBox(child: KilimLogo(width: 40, colors: colors)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manasal Solitaire',
                  style: TextStyle(
                    color: colors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Sürüm 1.0.0 · ${meta.totalCategoriesCompleted} '
                  'kategori tamamlandı',
                  style: TextStyle(color: colors.inkSoft, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Segment seçici (Açık/Koyu/Sistem): seçili segment kabarık krem hap.
class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.options,
    required this.onSelect,
  });

  final String value;
  final List<(String, String)> options;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.slotEmpty.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Dim.pill),
      ),
      child: Row(
        children: [
          for (final (key, label) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: value == key ? colors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(Dim.pill),
                    boxShadow: value == key
                        ? [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: value == key ? colors.ink : colors.inkSoft,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
