// Etkileşimli öğretici denetleyicisi: doğru hamlelerde adım ilerler, yanlış
// türde hamlede ilerlemez, "geç" her an tamamlar. Öğretici bölümünün (elle
// kurulu) 4 adımlık betikle uyumlu çözülebilir olduğunu da doğrular.
import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/app/game/game_controller.dart';
import 'package:manasal_solitaire/app/game/tutorial.dart';
import 'package:manasal_solitaire/app/game/tutorial_level.dart';
import 'package:manasal_solitaire/engine/engine.dart';

void main() {
  group('TutorialController', () {
    test('doğru hamlelerle 4 adım sırayla ilerler ve tamamlanır', () {
      final game = GameController(tutorialLevel());
      var completed = false;
      final tut = TutorialController(
        game: game,
        onComplete: () => completed = true,
      );
      addTearDown(tut.dispose);

      expect(tut.index, 0);
      expect(tut.total, 4);

      // Adım 1: kategori kartı (sütun 0) → boş slot 0.
      expect(
        game.place(
          const ColumnUnitRef(column: 0, startIndex: 0),
          const FoundationTargetRef(0),
        ),
        isTrue,
      );
      expect(tut.index, 1);

      // Adım 2: "Elma" (sütun 1) → aktif slot 0.
      expect(
        game.place(
          const ColumnUnitRef(column: 1, startIndex: 0),
          const FoundationTargetRef(0),
        ),
        isTrue,
      );
      expect(tut.index, 2);

      // Adım 3: desteden çek → "Kiraz" atığa.
      expect(game.draw(), isTrue);
      expect(tut.index, 3);

      // Adım 4: "Kiraz" (atık) → slot 0 → kategori tamam → zafer.
      expect(
        game.place(const WasteUnitRef(), const FoundationTargetRef(0)),
        isTrue,
      );
      expect(completed, isTrue);
      expect(tut.isActive, isFalse);
      expect(tut.current, isNull);
      expect(game.state.isWon, isTrue);
    });

    test('yanlış türde hamle adımı ilerletmez (yumuşak yönlendirme)', () {
      final game = GameController(tutorialLevel());
      final tut = TutorialController(game: game, onComplete: () {});
      addTearDown(tut.dispose);

      // "Elma"yı boş sütun 2'ye taşı: geçerli ama SlotActivatedEvent üretmez.
      expect(
        game.place(
          const ColumnUnitRef(column: 1, startIndex: 0),
          const ColumnTargetRef(2),
        ),
        isTrue,
      );
      expect(
        tut.index,
        0,
        reason: 'adım 1 yalnız slot aktifleşince ilerlemeli',
      );
      expect(tut.isActive, isTrue);
    });

    test('"geç" her an öğreticiyi tamamlar ve tekrar tetiklenmez', () {
      final game = GameController(tutorialLevel());
      var completeCount = 0;
      final tut = TutorialController(
        game: game,
        onComplete: () => completeCount += 1,
      );
      addTearDown(tut.dispose);

      tut.skip();
      expect(completeCount, 1);
      expect(tut.isActive, isFalse);

      // Geçtikten sonraki hamleler onComplete'i yeniden tetiklemez.
      game.place(
        const ColumnUnitRef(column: 0, startIndex: 0),
        const FoundationTargetRef(0),
      );
      expect(completeCount, 1);
    });
  });
}
