/// Ayarlar: ses, haptik, animasyon azaltma, hakkında.
///
/// Ses/haptik anahtarları Faz 5'te işlevlenir; seçim bugünden kalıcıdır.
library;

import 'package:flutter/material.dart';

import '../audio/sound_service.dart';
import '../meta/meta_scope.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta = MetaScope.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Ayarlar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              value: meta.sound,
              onChanged: (v) {
                meta.updateSettings(sound: v);
                SoundService.instance.enabled = v;
                if (v) SoundService.instance.play(Sfx.button);
              },
              title: const Text('Ses'),
              activeThumbColor: colors.accent,
            ),
            SwitchListTile(
              value: meta.haptics,
              onChanged: (v) => meta.updateSettings(haptics: v),
              title: const Text('Titreşim'),
              activeThumbColor: colors.accent,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Animasyon',
                style: TextStyle(
                  color: colors.inkSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final opt in const [
              ['system', 'Sistem ayarı'],
              ['on', 'Açık'],
              ['off', 'Kapalı (azalt)'],
            ])
              ListTile(
                title: Text(opt[1]),
                trailing: meta.reducedMotion == opt[0]
                    ? Icon(Icons.check_rounded, color: colors.accent)
                    : null,
                onTap: () => meta.updateSettings(reducedMotion: opt[0]),
              ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: colors.inkSoft),
              title: const Text('Manasal Solitaire'),
              subtitle: Text(
                'Sürüm 1.0.0 · ${meta.totalCategoriesCompleted} '
                'kategori tamamlandı',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
