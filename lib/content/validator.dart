/// İçerik havuzu doğrulayıcısı (Spec §12.2).
library;

import 'category_pool.dart';
import 'tr_text.dart';

class ContentIssue {
  const ContentIssue(this.severity, this.message);
  final String severity; // 'error' | 'warn'
  final String message;

  @override
  String toString() => '[$severity] $message';
}

class ContentValidator {
  const ContentValidator._();

  static const int minWordsPerCategory = 18;

  static List<ContentIssue> validate(CategoryPool pool) {
    final issues = <ContentIssue>[];

    // 1) id benzersizliği.
    final ids = <String>{};
    for (final c in pool.categories) {
      if (!ids.add(c.id)) {
        issues.add(ContentIssue('error', 'Yinelenen kategori id: ${c.id}'));
      }
    }

    // 2) Kategori içi kelime benzersizliği + hacim + boşluk.
    for (final c in pool.categories) {
      final seen = <String>{};
      for (final wRaw in c.words) {
        final w = wRaw.trim();
        if (w.isEmpty) {
          issues.add(ContentIssue('error', '${c.id}: boş kelime'));
          continue;
        }
        final key = TrText.normalizeKey(w);
        if (!seen.add(key)) {
          issues.add(
            ContentIssue(
              'error',
              '${c.id}: kategori içi yinelenen kelime "$w"',
            ),
          );
        }
      }
      if (c.words.length < minWordsPerCategory) {
        issues.add(
          ContentIssue(
            'warn',
            '${c.id}: yalnızca ${c.words.length} kelime (< $minWordsPerCategory)',
          ),
        );
      }
      if (c.difficulty < 1 || c.difficulty > 3) {
        issues.add(
          ContentIssue('error', '${c.id}: geçersiz difficulty ${c.difficulty}'),
        );
      }
    }

    // 3) Kategoriler arası sert çakışma (aynı kelime iki kategoride).
    final wordOwner = <String, String>{};
    for (final c in pool.categories) {
      for (final w in c.words) {
        final key = TrText.normalizeKey(w);
        final prev = wordOwner[key];
        if (prev != null && prev != c.id) {
          issues.add(
            ContentIssue(
              'error',
              'Sert çakışma: "$w" hem "$prev" hem "${c.id}" kategorisinde',
            ),
          );
        } else {
          wordOwner[key] = c.id;
        }
      }
    }

    // 4) softConflicts geçerli id'lere işaret etmeli.
    for (final c in pool.categories) {
      for (final sc in c.softConflicts) {
        if (pool.byId(sc) == null) {
          issues.add(
            ContentIssue('warn', '${c.id}: softConflict bilinmeyen id "$sc"'),
          );
        }
      }
    }

    return issues;
  }

  /// softConflicts ilişkisini simetrik hale getirir (a→b varsa b→a ekler).
  static Map<String, Set<String>> symmetricSoftConflicts(CategoryPool pool) {
    final map = <String, Set<String>>{
      for (final c in pool.categories) c.id: {...c.softConflicts},
    };
    for (final c in pool.categories) {
      for (final sc in c.softConflicts) {
        map[sc]?.add(c.id);
      }
    }
    return map;
  }
}
