/// Meta oyun durumu: ilerleme, cüzdan (geri alma kredisi), başarımlar,
/// devam etme (resume) ve ayarlar. SharedPreferences ile kalıcı.
///
/// Kredi ekonomisi Spec §10.2 / K17: başlangıç 3, İlk zafer +2, Verimli +1,
/// Seri +1, Koleksiyoncu +1/+2/+3. Değerler tuning verisidir.
// Yapıcı, alan adlarından farklı adlı parametreleri initializer list'te atar;
// bu bilinçli (yalnızca load() kurar).
// ignore_for_file: prefer_initializing_formals
library;

import 'package:flutter/foundation.dart';

import '../../engine/engine.dart';
import '../../persistence/store.dart';

class MetaService extends ChangeNotifier {
  MetaService({
    required Store store,
    required int highestCompleted,
    required Set<int> completed,
    required Map<int, int> bestMovesLeft,
    required int totalCategoriesCompleted,
    required int balance,
    required List<Map<String, dynamic>> txLog,
    required Set<String> achievements,
    required int streakFirstTry,
    required this.sound,
    required this.haptics,
    required this.reducedMotion,
    required this.themeMode,
    required int? resumeLevelId,
    required List<Move> resumeMoves,
  }) : _store = store,
       _highestCompleted = highestCompleted,
       _completed = completed,
       _bestMovesLeft = bestMovesLeft,
       _totalCategories = totalCategoriesCompleted,
       _balance = balance,
       _txLog = txLog,
       _achievements = achievements,
       _streak = streakFirstTry,
       _resumeLevelId = resumeLevelId,
       _resumeMoves = resumeMoves;

  final Store _store;

  int _highestCompleted;
  final Set<int> _completed;
  final Map<int, int> _bestMovesLeft;
  int _totalCategories;

  int _balance;
  final List<Map<String, dynamic>> _txLog;
  final Set<String> _achievements;
  int _streak;

  bool sound;
  bool haptics;
  String reducedMotion; // 'system' | 'on' | 'off'
  String themeMode; // 'system' | 'light' | 'dark'

  int? _resumeLevelId;
  List<Move> _resumeMoves;

  // --- Getter'lar ---
  int get highestCompleted => _highestCompleted;
  int get unlockedUpTo => _highestCompleted + 1; // sıradaki bölüm açık
  Set<int> get completed => _completed;
  int bestMovesLeft(int levelId) => _bestMovesLeft[levelId] ?? 0;
  int get totalCategoriesCompleted => _totalCategories;
  int get credits => _balance;
  int? get resumeLevelId => _resumeLevelId;
  List<Move> get resumeMoves => List.unmodifiable(_resumeMoves);
  bool isCompleted(int levelId) => _completed.contains(levelId);

  // Başarım durumu (başarım ekranı için).
  bool hasAchievement(String id) => _achievements.contains(id);
  int get streak => _streak;
  int get levelsCompleted => _completed.length;
  int efficientCount() =>
      _achievements.where((a) => a.startsWith('efficient:')).length;

  // --- Kredi (cüzdan) ---

  bool spendUndoCredit() {
    if (_balance <= 0) return false;
    _balance -= 1;
    _pushTx(-1, 'undo');
    _saveWallet();
    notifyListeners();
    return true;
  }

  void _credit(int amount, String source) {
    if (amount <= 0) return;
    _balance += amount;
    _pushTx(amount, source);
  }

  void _pushTx(int amount, String source) {
    _txLog.add({'a': amount, 's': source});
    while (_txLog.length > 50) {
      _txLog.removeAt(0);
    }
  }

  // --- Kazanma kaydı + başarımlar ---

  /// Bir bölüm kazanıldığında çağrılır. Kazanılan kredi sayısını döndürür
  /// (kazanma diyaloğunda gösterilir). Yalnızca YENİ tamamlanan bölümler
  /// kredi/başarım kazandırır (tekrar oynama saymaz — Spec §13.1).
  int recordWin({
    required int levelId,
    required int movesLeft,
    required int moveLimit,
    required int categoriesInLevel,
    required bool firstTry,
  }) {
    final prevBest = _bestMovesLeft[levelId] ?? 0;
    if (movesLeft > prevBest) _bestMovesLeft[levelId] = movesLeft;

    final newlyCompleted = !_completed.contains(levelId);
    var awarded = 0;

    if (newlyCompleted) {
      _completed.add(levelId);
      _totalCategories += categoriesInLevel;
      if (levelId > _highestCompleted) _highestCompleted = levelId;

      // İlk zafer
      if (_achievements.add('first_win')) awarded += 2;

      // Verimli: hamle limitinin ≤%60'ını harcadıysa (kalan ≥ %40)
      if (movesLeft >= (moveLimit * 0.4) &&
          _achievements.add('efficient:$levelId')) {
        awarded += 1;
      }

      // Seri: art arda 3 bölüm ilk denemede
      if (firstTry) {
        _streak += 1;
        if (_streak % 3 == 0) awarded += 1;
      } else {
        _streak = 0;
      }

      // Koleksiyoncu
      for (final entry in const [
        [25, 1],
        [50, 2],
        [100, 3],
      ]) {
        final threshold = entry[0];
        final reward = entry[1];
        if (_totalCategories >= threshold &&
            _achievements.add('collector:$threshold')) {
          awarded += reward;
        }
      }

      _credit(awarded, 'achievement');
    }

    clearResume();
    _saveProgress();
    _saveAchievements();
    _saveWallet();
    notifyListeners();
    return awarded;
  }

  // --- Devam etme (resume) ---

  void saveResume(int levelId, List<Move> moves) {
    _resumeLevelId = levelId;
    _resumeMoves = List.of(moves);
    _store.writeDoc('resume', {
      'schemaVersion': 1,
      'levelId': levelId,
      'moves': Serde.movesToJson(moves),
    });
  }

  void clearResume() {
    if (_resumeLevelId == null && _resumeMoves.isEmpty) return;
    _resumeLevelId = null;
    _resumeMoves = [];
    _store.remove('resume');
  }

  // --- Ayarlar ---

  void updateSettings({
    bool? sound,
    bool? haptics,
    String? reducedMotion,
    String? themeMode,
  }) {
    if (sound != null) this.sound = sound;
    if (haptics != null) this.haptics = haptics;
    if (reducedMotion != null) this.reducedMotion = reducedMotion;
    if (themeMode != null) this.themeMode = themeMode;
    _store.writeDoc('settings', {
      'schemaVersion': 1,
      'sound': this.sound,
      'haptics': this.haptics,
      'reducedMotion': this.reducedMotion,
      'themeMode': this.themeMode,
    });
    notifyListeners();
  }

  // --- Kalıcılaştırma ---

  void _saveProgress() {
    _store.writeDoc('progress', {
      'schemaVersion': 1,
      'highestCompleted': _highestCompleted,
      'completed': _completed.toList(),
      'bestMovesLeft': _bestMovesLeft.map((k, v) => MapEntry('$k', v)),
      'totalCategories': _totalCategories,
    });
  }

  void _saveWallet() {
    _store.writeDoc('wallet', {
      'schemaVersion': 1,
      'balance': _balance,
      'txLog': _txLog,
    });
  }

  void _saveAchievements() {
    _store.writeDoc('achievements', {
      'schemaVersion': 1,
      'granted': _achievements.toList(),
      'streakFirstTry': _streak,
    });
  }

  // --- Yükleme ---

  static MetaService load(Store store) {
    final progress = store.readDoc('progress');
    final wallet = store.readDoc('wallet');
    final ach = store.readDoc('achievements');
    final settings = store.readDoc('settings');
    final resume = store.readDoc('resume');

    // İlk açılış: cüzdan yoksa "Hoş geldin" 3 kredi.
    final firstLaunch = wallet == null;

    List<Move> resumeMoves = const [];
    int? resumeLevelId;
    if (resume != null) {
      resumeLevelId = resume['levelId'] as int?;
      final m = resume['moves'];
      if (m is List) resumeMoves = Serde.movesFromJson(m);
    }

    final service = MetaService(
      store: store,
      highestCompleted: (progress?['highestCompleted'] as int?) ?? 0,
      completed: {
        for (final v in (progress?['completed'] as List? ?? const [])) v as int,
      },
      bestMovesLeft: {
        for (final e
            in (progress?['bestMovesLeft'] as Map? ?? const {}).entries)
          int.parse(e.key as String): e.value as int,
      },
      totalCategoriesCompleted: (progress?['totalCategories'] as int?) ?? 0,
      balance: (wallet?['balance'] as int?) ?? 3,
      txLog: [
        for (final t in (wallet?['txLog'] as List? ?? const []))
          (t as Map).cast<String, dynamic>(),
      ],
      achievements: {
        for (final v in (ach?['granted'] as List? ?? const [])) v as String,
      },
      streakFirstTry: (ach?['streakFirstTry'] as int?) ?? 0,
      sound: (settings?['sound'] as bool?) ?? true,
      haptics: (settings?['haptics'] as bool?) ?? true,
      reducedMotion: (settings?['reducedMotion'] as String?) ?? 'system',
      themeMode: (settings?['themeMode'] as String?) ?? 'system',
      resumeLevelId: resumeLevelId,
      resumeMoves: resumeMoves,
    );

    if (firstLaunch) {
      service._achievements.add('welcome');
      service._pushTx(3, 'achievement:welcome');
      service._saveWallet();
      service._saveAchievements();
    }
    return service;
  }
}
