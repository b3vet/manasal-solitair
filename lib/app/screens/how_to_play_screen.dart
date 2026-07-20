/// Nasıl Oynanır (Kilim yönü) — numaralı adımlar, altın elmas rozetleri.
library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/kilim.dart';
import '../theme/tokens.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const _steps = <(String, String)>[
    (
      'Amaç',
      'Her bölümde kelime kartlarını ait oldukları kategorilere göre topla. '
          'Bir kategori kartını yukarıdaki toplama alanına koyup o kategorinin '
          'tüm kelimelerini üzerine ekleyerek kategoriyi bitir. Destedeki tüm '
          'kategorileri bitirince bölümü kazanırsın.',
    ),
    (
      'Kartları dizme',
      'Bir kelime kartını yalnızca AYNI kategoriden bir kartın üzerine '
          'koyabilirsin. Kartlarda kategori yazmaz — hangi kelimenin nereye '
          'ait olduğunu düşünerek bulman gerekir. Yanlış deneme hamle '
          'harcamaz, kart geri döner.',
    ),
    (
      'Kategori kartları',
      'Kategori kartını, eşleşen bir kelime zincirinin üzerine veya boş bir '
          'sütuna koyabilirsin; koyduğu sütun kilitlenir. Kategori kartını boş '
          'bir toplama slotuna çektiğinde altındaki eşleşen kelimeler de '
          'birlikte toplanır.',
    ),
    (
      'Hamleler',
      'Her hareket, taşıdığın kart sayısından bağımsız 1 hamledir. Desteden '
          'kart çekmek de 1 hamle. Hamle hakkın sınırlıdır — üstteki sayaç '
          'kalan hamleni gösterir ve azalınca uyarı rengine döner.',
    ),
    (
      'Geri alma & kaybetme',
      'Geri alma kredisiyle son hamleni geri sarabilirsin (krediler '
          'başarımlarla kazanılır). Hamle biterse ya da anlamlı hamle kalmazsa '
          'kaybedersin; bölümü istediğin kadar ücretsiz yeniden başlatabilirsin.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: kilimAppBar(context, 'Nasıl Oynanır'),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: _steps.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) =>
              _StepCard(index: i + 1, title: _steps[i].$1, body: _steps[i].$2),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.title,
    required this.body,
  });
  final int index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Dim.panelRadius),
        border: Border.all(color: colors.cardEdge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _numBadge(colors, index),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.ink,
                    fontFamily: Fonts.serif,
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(color: colors.inkSoft, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _numBadge(GameColors colors, int n) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          KilimDiamond(size: 32, color: colors.gold),
          Text(
            '$n',
            style: const TextStyle(
              color: Color(0xFF3A2A18),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
