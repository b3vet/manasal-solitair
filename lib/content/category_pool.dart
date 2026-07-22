/// İçerik havuzu modeli: kategoriler ve kelimeleri.
library;

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.words,
    this.softConflicts = const [],
    this.hardConflicts = const [],
  });

  final String id;
  final String name;
  final int difficulty; // 1 bariz .. 3 çetrefilli
  final List<String> words;

  /// Gevşek ilişkili kategoriler — YALNIZCA yüksek seviyede (bilinçli zorluk)
  /// birlikte gelebilir. Örn. Meyveler ↔ Sebzeler.
  final List<String> softConflicts;

  /// Özünde belirsiz (aynı kelime iki kategoriye eşit yakın) kategoriler —
  /// HİÇBİR bölümde birlikte gelmez (seviye fark etmez). Örn. Meyveler ↔ Renkler
  /// ("Nar" ikisine de olur). Adaletin çekirdeği (Spec K7).
  final List<String> hardConflicts;
}

class CategoryPool {
  CategoryPool({required this.version, required this.categories})
    : _byId = {for (final c in categories) c.id: c};

  final int version;
  final List<Category> categories;
  final Map<String, Category> _byId;

  Category? byId(String id) => _byId[id];
  int get length => categories.length;
}
