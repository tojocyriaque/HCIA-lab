import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../widgets/animated_page_wrapper.dart';
import '../widgets/chapter_card.dart';
import 'section_list_screen.dart';

class ChapterListScreen extends StatelessWidget {
  const ChapterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final kb = appState.selectedKnowledgeBase!;
    final courseId = appState.selectedCourseId!;

    return Scaffold(
      appBar: AppBar(title: const Text('Chapters')),
      body: AnimatedPageWrapper(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: kb.chapters.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final chapter = kb.chapters[index];
            final sectionProgresses =
                appState.progressRepository.allForCourse(courseId).where(
                      (p) => p.chapterId == chapter.chapterId,
                    );
            final total = chapter.sections.length;
            final completed =
                sectionProgresses.where((p) => p.markedComplete).length;
            final progress = total == 0 ? 0.0 : completed / total;

            return ChapterCard(
              chapter: chapter,
              progress: progress,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SectionListScreen(chapter: chapter),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
