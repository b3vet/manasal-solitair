import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/engine/engine.dart';

import 'helpers.dart';

void main() {
  group('serde', () {
    test('bölüm JSON gidiş-dönüşü aynı dağıtımı verir', () {
      final level = miniLevel();
      final json =
          jsonDecode(jsonEncode(Serde.levelToJson(level)))
              as Map<String, dynamic>;
      final restored = Serde.levelFromJson(json);
      final a = Serde.stateToJson(GameState.deal(level)).toString();
      final b = Serde.stateToJson(GameState.deal(restored)).toString();
      expect(a, b);
      expect(restored.moveLimit, level.moveLimit);
      expect(restored.totalCategories, level.totalCategories);
    });

    test('hamle listesi JSON gidiş-dönüşü', () {
      final moves = miniSolution();
      final json =
          jsonDecode(jsonEncode(Serde.movesToJson(moves))) as List<dynamic>;
      final restored = Serde.movesFromJson(json);
      expect(restored.length, moves.length);
      // Replay ile aynı sonuç.
      final s1 = GameSession.replay(miniLevel(), moves);
      final s2 = GameSession.replay(miniLevel(), restored);
      expect(
        Serde.stateToJson(s1.state).toString(),
        Serde.stateToJson(s2.state).toString(),
      );
      expect(s2.state.status, GameStatus.won);
    });

    test('resume: hamlelerden durum yeniden kurulur (replay determinizmi)', () {
      final level = miniLevel();
      final session = GameSession.start(level);
      for (final m in miniSolution().take(4)) {
        session.play(m);
      }
      final savedMoves = Serde.movesToJson(session.moves);
      // Yeniden yükle
      final reloaded = GameSession.replay(
        level,
        Serde.movesFromJson(savedMoves),
      );
      expect(
        Serde.stateToJson(reloaded.state).toString(),
        Serde.stateToJson(session.state).toString(),
      );
    });
  });
}
