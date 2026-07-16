/// Oyun ekranı: HUD + tahta + kazanma/kayıp/duraklat akışı + meta entegrasyonu
/// (kredi cüzdanı, ilerleme kaydı, devam etme).
library;

import 'package:flutter/material.dart';

import '../../engine/engine.dart';
import '../audio/sound_service.dart';
import '../meta/meta_scope.dart';
import '../meta/meta_service.dart';
import '../theme/app_theme.dart';
import 'game_board.dart';
import 'game_controller.dart';
import 'widgets/dialogs.dart';
import 'widgets/hud.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.levels,
    required this.startIndex,
    this.resumeMoves,
  });

  final List<LevelDef> levels;
  final int startIndex;
  final List<Move>? resumeMoves;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;
  late int _index;
  bool _handlingEnd = false;
  bool _firstTry = true;

  MetaService get _meta => MetaScope.read(context);

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    _controller = GameController(widget.levels[_index]);
    if (widget.resumeMoves != null && widget.resumeMoves!.isNotEmpty) {
      _controller.loadReplay(widget.levels[_index], widget.resumeMoves!);
    }
    _controller.addListener(_onChange);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  void _onChange() {
    final s = _controller.state;
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
      action = await showWinDialog(
        context,
        movesLeft: s.movesLeft,
        creditsAwarded: awarded,
        hasNext: _index < widget.levels.length - 1,
      );
    } else {
      _firstTry = false;
      action = await showLoseDialog(
        context,
        status: s.status,
        canUndoContinue: _meta.credits > 0 && _controller.canUndo,
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
  }

  void _useUndo() {
    if (_meta.credits > 0 && _controller.canUndo) {
      if (_controller.undo()) _meta.spendUndoCredit();
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
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }

  Future<void> _pause() async {
    final action = await showPauseDialog(context);
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
                haptics: meta.haptics,
                reduceMotion: _reduceMotion(context, meta.reducedMotion),
              ),
            ),
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
