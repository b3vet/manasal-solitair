import 'package:flutter_test/flutter_test.dart';
import 'package:manasal_solitaire/engine/engine.dart';

import 'helpers.dart';

/// Bir durumun tüm yapısal değişmezlerini doğrular.
void checkInvariants(GameState s, int initialTotal, int removed) {
  // 1) Kart id'leri benzersiz.
  final ids = <String>[];
  void collect(GameCard c) => ids.add(c.id);
  for (final col in s.columns) {
    col.faceDown.forEach(collect);
    col.faceUp.forEach(collect);
  }
  s.stock.forEach(collect);
  s.waste.forEach(collect);
  for (final slot in s.slots) {
    if (slot is ActiveSlot) {
      collect(slot.card); // slottaki kategori kartı da mevcut
      slot.collected.forEach(collect);
    }
  }
  expect(ids.toSet().length, ids.length, reason: 'yinelenen kart id');

  // 2) Kart korunumu: mevcut + tamamlanmada yok olan == başlangıç.
  expect(ids.length + removed, initialTotal, reason: 'kart sayısı korunmuyor');

  // 3) Açık bölge tek kategorili; kategori kartı yalnızca en üstte.
  for (final col in s.columns) {
    if (col.faceUp.isEmpty) continue;
    final cat = col.faceUp.first.categoryId;
    for (var i = 0; i < col.faceUp.length; i++) {
      final card = col.faceUp[i];
      expect(card.categoryId, cat, reason: 'açık bölge tek kategorili olmalı');
      if (card is CategoryCard) {
        expect(
          i,
          col.faceUp.length - 1,
          reason: 'kategori kartı yalnızca en üstte',
        );
      }
    }
  }

  // 4) Toplanan sayısı toplamı geçmez.
  for (final slot in s.slots) {
    if (slot is ActiveSlot) {
      expect(slot.collected.length, lessThanOrEqualTo(slot.total));
    }
  }

  // 5) Slot sayısı sabit.
  expect(s.slots.length, s.level.slotCount);
}

void main() {
  test('fuzz: rastgele legal hamleler altında değişmezler korunur', () {
    const games = 400;
    const maxSteps = 300;
    for (var g = 0; g < games; g++) {
      final level = randomLevel(g * 2654435761 + 1);
      final session = GameSession.fromState(GameState.deal(level));
      final initialTotal = level.totalCards;
      var removed = 0;
      final rng = Prng(g + 777);
      var prevMoves = session.state.movesLeft;

      for (var step = 0; step < maxSteps; step++) {
        if (!session.state.isPlaying) break;
        final legal = Analysis.legalMoves(session.state);
        if (legal.isEmpty) break;
        final move = legal[rng.nextInt(legal.length)];
        final r = session.play(move);
        expect(r, isA<Ok<List<GameEvent>, RuleViolation>>());
        final events = (r as Ok<List<GameEvent>, RuleViolation>).data;
        for (final e in events) {
          if (e is CategoryCompletedEvent) {
            final total = level.categories
                .firstWhere((c) => c.categoryId == e.categoryId)
                .totalWords;
            removed += total + 1; // kelimeler + kategori kartı yok olur
          }
        }
        // Hamle başına movesLeft tam olarak 1 azalır.
        expect(session.state.movesLeft, prevMoves - 1);
        prevMoves = session.state.movesLeft;
        checkInvariants(session.state, initialTotal, removed);
      }
    }
  });

  test('fuzz: bazı rastgele bölümler kazanılabilir (kazanma yolu var)', () {
    // Kazanmanın hiç gerçekleşmediği bir motor hatasını yakalamak için
    // greedy bir oynatıcıyla en az bir kazanma bulmayı dene.
    var anyWin = false;
    for (var g = 0; g < 60 && !anyWin; g++) {
      final level = randomLevel(g + 5);
      final session = GameSession.fromState(GameState.deal(level));
      final rng = Prng(g);
      for (var step = 0; step < 2000; step++) {
        if (!session.state.isPlaying) break;
        final legal = Analysis.legalMoves(session.state);
        if (legal.isEmpty) break;
        // Süpürme/toplama hamlelerini önceliklendir.
        legal.sort((a, b) => _priority(b).compareTo(_priority(a)));
        final top = legal
            .where((m) => _priority(m) == _priority(legal.first))
            .toList();
        session.play(top[rng.nextInt(top.length)]);
      }
      if (session.state.isWon) anyWin = true;
    }
    expect(
      anyWin,
      isTrue,
      reason: 'greedy oynatıcı hiç kazanamadı — motor şüphesi',
    );
  });
}

int _priority(Move m) {
  if (m is PlaceMove && m.target is FoundationTargetRef) return 3;
  if (m is PlaceMove) return 2;
  if (m is DrawMove) return 1;
  return 0;
}
