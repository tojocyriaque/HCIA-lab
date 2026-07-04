import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../widgets/animated_page_wrapper.dart';
import '../widgets/stat_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final kb = appState.selectedKnowledgeBase!;
    final courseId = appState.selectedCourseId!;
    final byMode = appState.attemptsByMode();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: AnimatedPageWrapper(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  AccuracyRing(value: appState.overallAccuracy, size: 160),
                  const SizedBox(height: 8),
                  Text(
                    'Overall Accuracy',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Answered',
                    value: '${appState.totalAttempts}',
                    icon: Icons.fact_check_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Total Correct',
                    value: '${appState.totalCorrect}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('By Mode', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (byMode.isEmpty)
              const Text('No quiz activity yet.')
            else
              ...byMode.entries.map(
                (e) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: Text(_labelForMode(e.key)),
                    trailing: Text('${e.value}'),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text('By Chapter', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ...kb.chapters.map((chapter) {
              final progresses = appState.progressRepository
                  .allForCourse(courseId)
                  .where((p) => p.chapterId == chapter.chapterId);
              final attempted = progresses.fold<int>(0, (s, p) => s + p.questionsAttempted);
              final correct = progresses.fold<int>(0, (s, p) => s + p.questionsCorrect);
              final accuracy = attempted == 0 ? 0.0 : correct / attempted;

              return Card(
                child: ListTile(
                  title: Text(chapter.title),
                  subtitle: Text('$attempted answered'),
                  trailing: Text(
                    attempted == 0 ? '—' : '${(accuracy * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _labelForMode(String mode) {
    switch (mode) {
      case 'practice':
        return 'Practice Mode';
      case 'exam':
        return 'Exam Mode';
      case 'random':
        return 'Random Quiz';
      case 'wrong':
        return 'Wrong Answers Review';
      case 'favorites':
        return 'Favorites Review';
      default:
        return mode;
    }
  }
}
