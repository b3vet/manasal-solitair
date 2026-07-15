/// Oyun denetleyicisi: GameSession'ı UI'a köprüler.
library;

import 'package:flutter/foundation.dart';

import '../../engine/engine.dart';

class GameController extends ChangeNotifier {
  GameController(LevelDef level) : _session = GameSession.start(level);

  GameSession _session;
  LevelDef get level => _session.state.level;
  GameState get state => _session.state;
  bool get canUndo => _session.canUndo;
  int get moveCount => _session.moveCount;

  /// UI'ın oynatacağı son olaylar (animasyon ipuçları).
  List<GameEvent> lastEvents = const [];

  /// Gösterilecek ipucu hamlesi (null = ipucu yok).
  Move? hintMove;

  void showHint(Move move) {
    hintMove = move;
    notifyListeners();
  }

  void clearHint() {
    if (hintMove == null) return;
    hintMove = null;
    notifyListeners();
  }

  bool draw() => _play(const DrawMove());
  bool recycle() => _play(const RecycleMove());
  bool place(UnitRef unit, TargetRef target) =>
      _play(PlaceMove(unit: unit, target: target));

  bool _play(Move move) {
    final r = _session.play(move);
    switch (r) {
      case Ok(:final data):
        lastEvents = data;
        hintMove = null;
        notifyListeners();
        return true;
      case Err():
        lastEvents = const [];
        return false;
    }
  }

  bool undo() {
    if (_session.undo()) {
      lastEvents = const [];
      hintMove = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  void restart() {
    _session = GameSession.start(level);
    lastEvents = const [];
    hintMove = null;
    notifyListeners();
  }

  void loadLevel(LevelDef level) {
    _session = GameSession.start(level);
    lastEvents = const [];
    hintMove = null;
    notifyListeners();
  }

  /// Replay'den oturumu yeniden kurar (resume).
  void loadReplay(LevelDef level, List<Move> moves) {
    _session = GameSession.replay(level, moves);
    lastEvents = const [];
    hintMove = null;
    notifyListeners();
  }

  List<Move> get moves => _session.moves;

  /// Bir kategori birimi için en uygun hedefi bulup otomatik taşır
  /// (çift dokunuş). Önce boş toplama slotu (süpürme), sonra eşleşen sütun.
  bool autoPlaceCategory(UnitRef unit) {
    final resolved = Rules.resolveUnit(state, unit);
    if (resolved is! Ok<MovableUnit, RuleViolation>) return false;
    final u = resolved.data;
    if (u is! CategoryUnit) return false;

    // Boş slot?
    for (var i = 0; i < state.slots.length; i++) {
      if (state.slots[i].isEmpty) {
        return place(unit, FoundationTargetRef(i));
      }
    }
    // Eşleşen zincirli sütun?
    for (var c = 0; c < state.columns.length; c++) {
      final col = state.columns[c];
      if (!col.isLocked && !col.isEmpty && col.topCategory == u.categoryId) {
        if (Rules.validatePlace(state, u, ColumnTargetRef(c), source: unit) ==
            null) {
          return place(unit, ColumnTargetRef(c));
        }
      }
    }
    return false;
  }
}
