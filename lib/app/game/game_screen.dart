/// Oyun ekranı: HUD + tahta + kazanma/kayıp/duraklat akışı + meta entegrasyonu
/// (kredi cüzdanı, ilerleme kaydı, devam etme).
library;

import 'package:flutter/material.dart';

import '../../engine/engine.dart';
import '../analytics/analytics_service.dart';
import '../audio/sound_service.dart';
import '../meta/meta_scope.dart';
import '../meta/meta_service.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'game_board.dart';
import 'game_controller.dart';
import 'tutorial.dart';
import 'tutorial_level.dart';
import 'widgets/dialogs.dart';
import 'widgets/hud.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.levels,
    required this.startIndex,
    this.resumeMoves,
    this.tutorial = false,
  });

  final List<LevelDef> levels;
  final int startIndex;
  final List<Move>? resumeMoves;

  /// İlk kez oynayana etkileşimli öğreticiyle başla (gerçek bölümden önce).
  final bool tutorial;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;
  TutorialController? _tutorial;
  late int _index;
  bool _handlingEnd = false;
  bool _firstTry = true;

  MetaService get _meta => MetaScope.read(context);

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    if (widget.tutorial) {
      // Öğretici bölümü (id 0) — gerçek ilerlemeye sayılmaz, analitik yok.
      _controller = GameController(tutorialLevel());
      _tutorial = TutorialController(
        game: _controller,
        onComplete: _finishTutorial,
      );
      _controller.addListener(_onChange);
      return;
    }
    _controller = GameController(widget.levels[_index]);
    if (widget.resumeMoves != null && widget.resumeMoves!.isNotEmpty) {
      final applied = _controller.loadReplay(
        widget.levels[_index],
        widget.resumeMoves!,
      );
      if (!applied) {
        // Bayat kayıt (bölüm yeniden üretilmiş): baştan başladık, kaydı temizle.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _meta.clearResume();
        });
      }
    }
    _controller.addListener(_onChange);
    Analytics.instance.levelStart(widget.levels[_index].id);
  }

  /// Öğretici bittiğinde (tamamlandı ya da geçildi): bayrağı kaydet ve gerçek
  /// Bölüm 1'e geç. Nested notifyListeners'tan kaçınmak için bir sonraki karede.
  void _finishTutorial() {
    _meta.updateSettings(tutorialCompleted: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _tutorial?.dispose();
        _tutorial = null;
        _index = 0;
        _firstTry = true;
        _handlingEnd = false;
        _controller.loadLevel(widget.levels[0]);
      });
      Analytics.instance.levelStart(widget.levels[0].id);
      _snack('Öğretici tamamlandı — Bölüm 1 başlıyor!');
    });
  }

  @override
  void dispose() {
    _tutorial?.dispose();
    _controller
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  void _onChange() {
    final s = _controller.state;
    // Öğretici modunda: ilerleme kaydı yok, kazanma diyaloğu yok — zafer
    // TutorialController.onComplete ile ele alınır.
    if (_tutorial != null) {
      if (mounted) setState(() {});
      return;
    }
    if (s.isPlaying) {
      // Devam etme: her hamlede durumu (replay) kaydet.
      _meta.saveResume(s.level.id, _controller.moves);
    }
    if (!_handlingEnd && (s.isWon || s.isLost)) {
      _handlingEnd = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showEnd());
    }
    if (mounted) setState(() {});
  }

  Future<void> _showEnd() async {
    final s = _controller.state;
    SoundService.instance.play(s.isWon ? Sfx.win : Sfx.lose);
    GameDialogAction? action;
    if (s.isWon) {
      final awarded = _meta.recordWin(
        levelId: s.level.id,
        movesLeft: s.movesLeft,
        moveLimit: s.level.moveLimit,
        categoriesInLevel: s.level.totalCategories,
        firstTry: _firstTry,
      );
      final ml = s.level.moveLimit;
      Analytics.instance.levelComplete(
        s.level.id,
        movesUsed: ml - s.movesLeft,
        stars: starRating(s.movesLeft, ml),
        firstTry: _firstTry,
      );
      action = await showWinDialog(
        context,
        movesLeft: s.movesLeft,
        creditsAwarded: awarded,
        hasNext: _index < widget.levels.length - 1,
        levelId: s.level.id,
        moveLimit: ml,
      );
    } else {
      Analytics.instance.levelFail(
        s.level.id,
        reason: s.status == GameStatus.lostOutOfMoves
            ? 'out_of_moves'
            : 'deadlock',
      );
      _firstTry = false;
      action = await showLoseDialog(
        context,
        status: s.status,
        canUndoContinue: _meta.credits > 0 && _controller.canUndo,
        movesLeft: s.movesLeft,
      );
    }
    if (!mounted) return;
    _handlingEnd = false;
    switch (action) {
      case GameDialogAction.next:
        _loadIndex(_index + 1, freshAttempt: true);
      case GameDialogAction.retry:
        setState(() {
          _firstTry = false;
          _controller.restart();
        });
      case GameDialogAction.levels:
        if (mounted) Navigator.of(context).pop();
      case GameDialogAction.undoContinue:
        if (_meta.credits > 0 && _controller.undo()) {
          _meta.spendUndoCredit();
        }
      case GameDialogAction.resume:
      case null:
        break;
    }
  }

  void _loadIndex(int i, {required bool freshAttempt}) {
    if (i < 0 || i >= widget.levels.length) return;
    setState(() {
      _index = i;
      _firstTry = freshAttempt;
      _controller.loadLevel(widget.levels[i]);
    });
    Analytics.instance.levelStart(widget.levels[i].id);
  }

  void _useUndo() {
    if (_meta.credits > 0 && _controller.canUndo) {
      if (_controller.undo()) {
        _meta.spendUndoCredit();
        Analytics.instance.undoUsed(_controller.state.level.id);
      }
    }
  }

  void _useHint() {
    final meta = _meta;
    if (meta.credits <= 0) {
      _snack('İpucu için kredi gerekli — başarımlarla kazanabilirsin');
      return;
    }
    final move = Analysis.suggestHint(_controller.state);
    if (move == null) {
      _snack('Şu an önerilecek hamle yok');
      return;
    }
    meta.spendUndoCredit();
    SoundService.instance.play(Sfx.button);
    _controller.showHint(move);
    Analytics.instance.hintUsed(_controller.state.level.id);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }

  Future<void> _pause() async {
    final s = _controller.state;
    final action = await showPauseDialog(
      context,
      levelId: s.level.id,
      movesLeft: s.movesLeft,
      completed: s.completedCount,
      totalCategories: s.totalCategories,
    );
    if (!mounted) return;
    switch (action) {
      case GameDialogAction.retry:
        setState(() {
          _firstTry = false;
          _controller.restart();
        });
      case GameDialogAction.levels:
        if (mounted) Navigator.of(context).pop();
      case GameDialogAction.next:
      case GameDialogAction.undoContinue:
      case GameDialogAction.resume:
      case null:
        break;
    }
  }

  bool _reduceMotion(BuildContext context, String setting) => switch (setting) {
    'on' => false,
    'off' => true,
    _ => MediaQuery.of(context).disableAnimations,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta = MetaScope.of(context); // kredi değişince yeniden çiz
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GameBoard(
                controller: _controller,
                tutorial: _tutorial,
                haptics: meta.haptics,
                reduceMotion: _reduceMotion(context, meta.reducedMotion),
              ),
            ),
            if (_tutorial != null)
              _TutorialBar(onSkip: () => _tutorial!.skip(), colors: colors)
            else
              BottomBar(
                levelId: _controller.state.level.id,
                undoCredits: meta.credits,
                canUndo: _controller.canUndo,
                onMenu: _pause,
                onUndo: _useUndo,
                onHint: _useHint,
              ),
          ],
        ),
      ),
    );
  }
}

/// Öğretici sırasındaki alt çubuk: yalnız "Öğreticiyi geç" seçeneği (undo/ipucu
/// yok — ilk deneyimi sade tut).
class _TutorialBar extends StatelessWidget {
  const _TutorialBar({required this.onSkip, required this.colors});
  final VoidCallback onSkip;
  final GameColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Icon(Icons.school_rounded, size: 20, color: colors.accent),
          const SizedBox(width: 8),
          Text(
            'Öğretici',
            style: TextStyle(
              color: colors.inkSoft,
              fontFamily: Fonts.sans,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text(
              'Öğreticiyi geç',
              style: TextStyle(
                color: colors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
