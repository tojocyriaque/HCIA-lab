import 'package:flutter/material.dart';

import '../models/progress_model.dart';
import '../widgets/animated_page_wrapper.dart';
import '../widgets/stat_card.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizSessionResult result;
  const QuizResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final scorePercent = result.scorePercent;
    final passed = scorePercent >= 60;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Session Results'), automaticallyImplyLeading: false),
      body: AnimatedPageWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AccuracyRing(value: scorePercent / 100, size: 140),
                const SizedBox(height: 20),
                Text(
                  passed ? 'Well done!' : 'Keep practicing!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: passed ? Colors.green : scheme.error,
                      ),
                ),
                const SizedBox(height: 6),
                Text('${result.correct} / ${result.total} correct'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Mode',
                        value: result.mode,
                        icon: Icons.category_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Time Taken',
                        value: _formatDuration(result.timeTaken),
                        icon: Icons.timer_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
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
