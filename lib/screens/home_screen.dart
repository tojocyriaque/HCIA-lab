import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../widgets/animated_page_wrapper.dart';
import '../widgets/stat_card.dart';
import 'chapter_list_screen.dart';
import 'favorites_screen.dart';
import 'quiz_session_screen.dart';
import 'search_screen.dart';
import 'statistics_screen.dart';
import 'wrong_answers_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final kb = appState.selectedKnowledgeBase;
    final courses = appState.knowledgeRepository.courses;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Hub'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            tooltip: appState.darkMode ? 'Light mode' : 'Dark mode',
            icon: Icon(appState.darkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => appState.toggleDarkMode(),
          ),
        ],
      ),
      body: kb == null
          ? const Center(child: Text('No course selected'))
          : AnimatedPageWrapper(
              child: RefreshIndicator(
                onRefresh: () => appState.knowledgeRepository.reload(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (courses.length > 1) ...[
                      _CourseSelector(
                        courseIds: courses.map((c) => c.courseId).toList(),
                        selected: appState.selectedCourseId!,
                        onSelect: appState.selectCourse,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Card(
                      color: scheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kb.course.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'v${kb.course.version} · ${kb.chapters.length} chapters · '
                              '${kb.totalSections} sections',
                              style: TextStyle(color: scheme.onPrimaryContainer),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Questions Answered',
                            value: '${appState.totalAttempts}',
                            icon: Icons.fact_check_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Overall Accuracy',
                            value: '${(appState.overallAccuracy * 100).round()}%',
                            icon: Icons.insights_outlined,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Study', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.menu_book,
                      title: 'Chapters & Learning Mode',
                      subtitle: 'Browse chapters, sections and study material',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChapterListScreen()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Quiz', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.shuffle,
                      title: 'Random Quiz',
                      subtitle: 'A quick shuffled quiz across the whole course',
                      onTap: () {
                        final qs = appState.quizRepository
                            .randomQuiz(appState.selectedCourseId!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizSessionScreen(
                              questions: qs,
                              mode: 'random',
                              title: 'Random Quiz',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.timer,
                      title: 'Exam Mode',
                      subtitle: 'Timed, full-length exam across the whole course',
                      onTap: () {
                        final qs = appState.quizRepository
                            .examSet(appState.selectedCourseId!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizSessionScreen(
                              questions: qs,
                              mode: 'exam',
                              title: 'Exam Mode',
                              timeLimit: const Duration(minutes: 60),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.star,
                      title: 'Favorites',
                      subtitle: 'Review the questions you starred',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.replay,
                      title: 'Wrong Answers Review',
                      subtitle: 'Practice the questions you missed',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WrongAnswersScreen()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Insights', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.bar_chart,
                      title: 'Statistics',
                      subtitle: 'Track your learning progress over time',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CourseSelector extends StatelessWidget {
  final List<String> courseIds;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CourseSelector({
    required this.courseIds,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courseIds.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final id = courseIds[index];
          final isSelected = id == selected;
          return ChoiceChip(
            label: Text(id),
            selected: isSelected,
            onSelected: (_) => onSelect(id),
          );
        },
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          child: Icon(icon, color: scheme.onSecondaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
