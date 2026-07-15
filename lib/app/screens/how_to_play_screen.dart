/// Nasıl Oynanır — kuralların kısa özeti.
library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Nasıl Oynanır')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            _Section(
              icon: Icons.category_rounded,
              title: 'Amaç',
              body:
                  'Her bölümde kelime kartlarını ait oldukları kategorilere '
                  'göre topla. Bir kategori kartını yukarıdaki toplama '
                  'alanına koyup o kategorinin tüm kelimelerini üzerine '
                  'ekleyerek kategoriyi bitir. Destedeki tüm kategorileri '
                  'bitirince bölümü kazanırsın.',
            ),
            _Section(
              icon: Icons.link_rounded,
              title: 'Kartları dizme',
              body:
                  'Bir kelime kartını yalnızca AYNI kategoriden bir kartın '
                  'üzerine koyabilirsin. Kartlarda kategori yazmaz — hangi '
                  'kelimenin nereye ait olduğunu düşünerek bulman gerekir. '
                  'Yanlış deneme hamle harcamaz, kart geri döner.',
            ),
            _Section(
              icon: Icons.folder_special_rounded,
              title: 'Kategori kartları',
              body:
                  'Kategori kartını, eşleşen bir kelime zincirinin üzerine '
                  'veya boş bir sütuna koyabilirsin; koyduğu sütun kilitlenir. '
                  'Kategori kartını boş bir toplama slotuna çektiğinde '
                  'altındaki eşleşen kelimeler de birlikte toplanır.',
            ),
            _Section(
              icon: Icons.swipe_rounded,
              title: 'Hamleler',
              body:
                  'Her hareket, taşıdığın kart sayısından bağımsız 1 hamledir. '
                  'Desteden kart çekmek de 1 hamle. Hamle hakkın sınırlıdır — '
                  'üstteki sayaç kalan hamleni gösterir.',
            ),
            _Section(
              icon: Icons.undo_rounded,
              title: 'Geri alma',
              body:
                  'Geri alma kredisiyle son hamleni geri sarabilirsin '
                  '(harcanan hamle iade edilir). Krediler başarımlarla '
                  'kazanılır. Kaybettiğinde kredin varsa "Geri al ve devam et" '
                  'ile oyuna dönebilirsin.',
            ),
            _Section(
              icon: Icons.emoji_events_rounded,
              title: 'Kaybetme',
              body:
                  'İki şekilde kaybedersin: hamle hakkın biterse ya da '
                  'yapılacak anlamlı bir hamle kalmazsa. Bölümü istediğin '
                  'kadar ücretsiz yeniden başlatabilirsin.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.cardEdge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: colors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(color: colors.inkSoft, fontSize: 14, height: 1.45),
          ),
        ],
      ),
    );
  }
}
