import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../models/progress_model.dart';
import '../models/question_model.dart';
import '../widgets/animated_page_wrapper.dart';
import '../widgets/question_card.dart';
import 'quiz_result_screen.dart';

/// A single reusable engine that drives Practice, Exam, Random Quiz,
/// Wrong-Answers Review and Favorites Review — the only difference
/// between these "modes" is which question list is supplied and, for
/// exam mode, a countdown timer. Questions themselves always come from
/// the quiz_bank.json pool via [QuizRepository]; nothing is hardcoded.
class QuizSessionScreen extends StatefulWidget {
  final List<Question> questions;
  final String mode; // "practice" | "exam" | "random" | "wrong" | "favorites"
  final String title;
  final Duration? timeLimit;

  const QuizSessionScreen({
    super.key,
    required this.questions,
    required this.mode,
    required this.title,
    this.timeLimit,
  });

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  int _index = 0;
  bool _submitted = false;
  Set<String> _selected = {};
  int _correctCount = 0;
  late final Stopwatch _stopwatch = Stopwatch()..start();
  Timer? _countdownTimer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    if (widget.timeLimit != null) {
      _remaining = widget.timeLimit;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          _remaining = _remaining! - const Duration(seconds: 1);
        });
        if (_remaining!.inSeconds <= 0) {
          t.cancel();
          _finish();
        }
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Question get _current => widget.questions[_index];

  void _selectLetter(String letter) {
    setState(() {
      if (_current.isMultiSelect) {
        if (_selected.contains(letter)) {
          _selected.remove(letter);
        } else {
          _selected.add(letter);
        }
      } else {
        _selected = {letter};
      }
    });
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) return;
    final appState = context.read<AppState>();
    final isCorrect = _current.isCorrectSelection(_selected);
    setState(() {
      _submitted = true;
      if (isCorrect) _correctCount++;
    });
    await appState.recordAnswer(
      question: _current,
      wasCorrect: isCorrect,
      mode: widget.mode,
    );
  }

  void _next() {
    if (_index == widget.questions.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _submitted = false;
      _selected = {};
    });
  }

  void _finish() {
    _countdownTimer?.cancel();
    _stopwatch.stop();
    final result = QuizSessionResult(
      total: widget.questions.length,
      correct: _correctCount,
      timeTaken: _stopwatch.elapsed,
      mode: widget.mode,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => QuizResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final appState = context.watch<AppState>();
    final progressFraction = (_index + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_remaining != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  _formatDuration(_remaining!),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _remaining!.inSeconds < 60 ? Colors.red : null,
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progressFraction),
        ),
      ),
      body: AnimatedPageWrapper(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Question ${_index + 1} of ${widget.questions.length}'),
                  Text('Score: $_correctCount/${_index + (_submitted ? 1 : 0)}'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuestionCard(
                  question: _current,
                  selectedLetters: _selected,
                  submitted: _submitted,
                  isFavorite: appState.isFavorite(_current),
                  onSelectLetter: _selectLetter,
                  onToggleFavorite: () => appState.toggleFavorite(_current),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitted
                      ? _next
                      : (_selected.isEmpty ? null : _submit),
                  child: Text(_submitted
                      ? (_index == widget.questions.length - 1 ? 'Finish' : 'Next')
                      : 'Submit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
