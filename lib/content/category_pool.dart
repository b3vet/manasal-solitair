/// İçerik havuzu modeli: kategoriler ve kelimeleri.
library;

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.words,
    this.softConflicts = const [],
  });

  final String id;
  final String name;
  final int difficulty; // 1 bariz .. 3 çetrefilli
  final List<String> words;
  final List<String> softConflicts;
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
