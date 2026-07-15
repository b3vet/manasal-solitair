/// Oyun oturumu: hamle geçmişi + geri alma (undo).
///
/// Motor sınırsız geri almayı destekler; kredi/ekonomi kontrolü UI katmanının
/// işidir (Faz 4). Kayıp durumundan geri almak statüyü tekrar `playing` yapar
/// ("geri al ve devam et" — Spec §9.4).
library;

import 'events.dart';
import 'level.dart';
import 'moves.dart';
import 'reducer.dart';
import 'result.dart';
import 'rules.dart';
import 'state.dart';

class GameSession {
  GameSession._(this._history, this._moves);

  factory GameSession.start(LevelDef level) =>
      GameSession._([GameState.deal(level)], []);

  /// Belirli bir durumdan oturum başlatır (test/özel senaryolar).
  factory GameSession.fromState(GameState state) => GameSession._([state], []);

  /// Bir replay (hamle listesi) üzerinden oturumu yeniden kurar.
  factory GameSession.replay(LevelDef level, List<Move> moves) {
    final session = GameSession.start(level);
    for (final m in moves) {
      final r = session.play(m);
      if (r is Err<List<GameEvent>, RuleViolation>) {
        throw StateError('Replay geçersiz hamle içeriyor: ${r.cause}');
      }
    }
    return session;
  }

  final List<GameState> _history;
  final List<Move> _moves;

  GameState get state => _history.last;
  List<Move> get moves => List.unmodifiable(_moves);
  int get moveCount => _moves.length;
  bool get canUndo => _history.length > 1;

  Result<List<GameEvent>, RuleViolation> play(Move move) {
    final result = Reducer.apply(state, move);
    switch (result) {
      case Ok(:final data):
        _history.add(data.next);
        _moves.add(move);
        return Ok(data.events);
      case Err(:final cause):
        return Err(cause);
    }
  }

  /// Son hamleyi geri alır. Başarılıysa true.
  bool undo() {
    if (!canUndo) return false;
    _history.removeLast();
    _moves.removeLast();
    return true;
  }
}
