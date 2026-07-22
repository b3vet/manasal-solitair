/// Öğretici için elle kurulmuş, deterministik küçük bölüm.
///
/// Her adımın "doğru hamlesi" tek ve bariz olsun diye üç sütun, tek kategori
/// (Meyveler / 2 kelime) kullanır. Gerçek ilerlemeye SAYILMAZ (id: 0); kredi ya
/// da başarım kazandırmaz — sadece mekaniği yaptırarak öğretir.
///
/// Akış (öğretici betiğiyle eşleşir, bkz. tutorial.dart):
///   1) Kategori kartını (Meyveler) boş slota taşı  → slot aktifleşir.
///   2) Eşleşen kelimeyi (Elma) slota topla          → 1/2 toplandı.
///   3) Desteden kart çek (Kiraz açığa çıkar)        → atıkta Kiraz.
///   4) Son kelimeyi (Kiraz) slota topla             → kategori tamam → zafer.
library;

import '../../engine/engine.dart';

/// Öğretici bölümünün sabit kimliği (gerçek bölümlerden ayırt etmek için 0).
const int kTutorialLevelId = 0;

LevelDef tutorialLevel() => const LevelDef(
  id: kTutorialLevelId,
  seed: 0,
  columnCount: 3,
  slotCount: 3,
  moveLimit: 20, // bol; öğreticide hamle bitmesi olmasın
  categories: [
    LevelCategory(categoryId: 'meyveler', name: 'Meyveler', totalWords: 2),
  ],
  columns: [
    // Sütun 0: yalnız kategori kartı — doğrudan slota sürüklenebilir.
    ColumnDeal(
      faceDown: [],
      faceUp: [
        CategoryCard(
          id: 'c:meyveler',
          categoryId: 'meyveler',
          name: 'Meyveler',
          totalInLevel: 2,
        ),
      ],
    ),
    // Sütun 1: ilk eşleşen kelime.
    ColumnDeal(
      faceDown: [],
      faceUp: [
        WordCard(id: 'w:meyveler:1', word: 'Elma', categoryId: 'meyveler'),
      ],
    ),
    // Sütun 2: boş (öğreticide kullanılmaz, sadeliğe bırakılır).
    ColumnDeal(faceDown: [], faceUp: []),
  ],
  // İkinci kelime destede — "kart çek" adımını öğretmek için.
  stock: [WordCard(id: 'w:meyveler:2', word: 'Kiraz', categoryId: 'meyveler')],
);
