import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../models/chapter_model.dart';
import '../widgets/animated_page_wrapper.dart';
import '../widgets/section_tile.dart';
import 'quiz_session_screen.dart';
import 'section_detail_screen.dart';

class SectionListScreen extends StatelessWidget {
  final Chapter chapter;
  const SectionListScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final courseId = appState.selectedCourseId!;

    return Scaffold(
      appBar: AppBar(title: Text(chapter.title)),
      body: AnimatedPageWrapper(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.quiz_outlined),
                      label: const Text('Practice this chapter'),
                      onPressed: () {
                        final qs = appState.quizRepository.practiceSet(
                          courseId,
                          chapter.chapterId,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizSessionScreen(
                              questions: qs,
                              mode: 'practice',
                              title: 'Practice · ${chapter.title}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: chapter.sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final section = chapter.sections[index];
                  final progress = appState.progressRepository.progressFor(
                    courseId,
                    chapter.chapterId,
                    section.sectionId,
                  );
                  final accuracy = progress == null || progress.questionsAttempted == 0
                      ? -1.0
                      : progress.accuracy;

                  return SectionTile(
                    section: section,
                    accuracy: accuracy,
                    complete: progress?.markedComplete ?? false,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SectionDetailScreen(
                          chapter: chapter,
                          section: section,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
