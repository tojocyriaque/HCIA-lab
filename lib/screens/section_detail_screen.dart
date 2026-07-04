import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../models/chapter_model.dart';
import '../widgets/animated_page_wrapper.dart';
import 'quiz_session_screen.dart';

/// "Learning mode": shows the raw knowledge.json content for a section
/// (learning objectives, definitions, key concepts, comparisons, numbers,
/// advantages, disadvantages, limitations, best practices, exam traps and
/// common confusions) in a readable, organized layout.
class SectionDetailScreen extends StatelessWidget {
  final Chapter chapter;
  final Section section;

  const SectionDetailScreen({
    super.key,
    required this.chapter,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final courseId = appState.selectedCourseId!;
    final progress = appState.progressRepository
        .progressFor(courseId, chapter.chapterId, section.sectionId);
    final isComplete = progress?.markedComplete ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(section.title),
        actions: [
          IconButton(
            tooltip: isComplete ? 'Mark as incomplete' : 'Mark as complete',
            icon: Icon(isComplete ? Icons.check_circle : Icons.check_circle_outline),
            onPressed: () => appState.progressRepository.markSectionComplete(
              courseId,
              chapter.chapterId,
              section.sectionId,
              !isComplete,
            ),
          ),
        ],
      ),
      body: AnimatedPageWrapper(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (section.learningObjectives.isNotEmpty)
              _SectionBlock(
                title: 'Learning Objectives',
                icon: Icons.flag_outlined,
                children: section.learningObjectives
                    .map((e) => _BulletText(e))
                    .toList(),
              ),
            if (section.definitions.isNotEmpty)
              _SectionBlock(
                title: 'Definitions',
                icon: Icons.menu_book_outlined,
                children: section.definitions
                    .map((d) => _DefinitionTile(term: d.term, definition: d.definition))
                    .toList(),
              ),
            if (section.keyConcepts.isNotEmpty)
              _SectionBlock(
                title: 'Key Concepts',
                icon: Icons.lightbulb_outline,
                children: section.keyConcepts.map((e) => _BulletText(e)).toList(),
              ),
            if (section.comparisons.isNotEmpty)
              _SectionBlock(
                title: 'Comparisons',
                icon: Icons.compare_arrows,
                children: section.comparisons.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.feature, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ...c.attributes.entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Text('${_titleCase(e.key)}: ${e.value}'),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (section.numbers.isNotEmpty)
              _SectionBlock(
                title: 'Key Numbers',
                icon: Icons.numbers,
                children: section.numbers
                    .map((n) => _BulletText('${n.value} ${n.unit} — ${n.context}'))
                    .toList(),
              ),
            if (section.advantages.isNotEmpty)
              _SectionBlock(
                title: 'Advantages',
                icon: Icons.thumb_up_outlined,
                children: section.advantages.map((e) => _BulletText(e)).toList(),
              ),
            if (section.disadvantages.isNotEmpty)
              _SectionBlock(
                title: 'Disadvantages',
                icon: Icons.thumb_down_outlined,
                children: section.disadvantages.map((e) => _BulletText(e)).toList(),
              ),
            if (section.limitations.isNotEmpty)
              _SectionBlock(
                title: 'Limitations',
                icon: Icons.block,
                children: section.limitations.map((e) => _BulletText(e)).toList(),
              ),
            if (section.bestPractices.isNotEmpty)
              _SectionBlock(
                title: 'Best Practices',
                icon: Icons.verified_outlined,
                children: section.bestPractices.map((e) => _BulletText(e)).toList(),
              ),
            if (section.examTraps.isNotEmpty)
              _SectionBlock(
                title: 'Exam Traps',
                icon: Icons.warning_amber_outlined,
                accentColor: Colors.orange,
                children: section.examTraps.map((e) => _BulletText(e)).toList(),
              ),
            if (section.commonConfusions.isNotEmpty)
              _SectionBlock(
                title: 'Common Confusions',
                icon: Icons.help_outline,
                accentColor: Colors.deepPurple,
                children: section.commonConfusions.map((e) => _BulletText(e)).toList(),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Practice this section'),
              onPressed: () {
                final qs = appState.quizRepository.practiceSet(
                  courseId,
                  chapter.chapterId,
                  sectionId: section.sectionId,
                );
                if (qs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No questions available for this section yet.')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizSessionScreen(
                      questions: qs,
                      mode: 'practice',
                      title: 'Practice · ${section.title}',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static String _titleCase(String snake) {
    return snake
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? accentColor;

  const _SectionBlock({
    required this.title,
    required this.icon,
    required this.children,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accentColor ?? scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _DefinitionTile extends StatelessWidget {
  final String term;
  final String definition;
  const _DefinitionTile({required this.term, required this.definition});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(term, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(definition),
        ],
      ),
    );
  }
}
