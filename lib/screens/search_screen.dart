import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../models/chapter_model.dart';
import '../models/question_model.dart';
import '../services/quiz_generator_service.dart';
import '../widgets/animated_page_wrapper.dart';
import 'section_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final QuizGeneratorService _generator = QuizGeneratorService();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final kb = appState.selectedKnowledgeBase!;
    final courseId = appState.selectedCourseId!;

    final sectionResults = _generator.searchSections(kb, _query);
    final questionResults =
        _generator.searchQuestions(appState.knowledgeRepository.questionsFor(courseId), _query);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search sections & questions...',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      body: AnimatedPageWrapper(
        child: _query.trim().isEmpty
            ? const Center(child: Text('Start typing to search the course content.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (sectionResults.isNotEmpty) ...[
                    Text('Sections (${sectionResults.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...sectionResults.map((s) => _SectionResultTile(section: s, kb: kb)),
                    const SizedBox(height: 20),
                  ],
                  if (questionResults.isNotEmpty) ...[
                    Text('Questions (${questionResults.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...questionResults.map((q) => _QuestionResultTile(question: q)),
                  ],
                  if (sectionResults.isEmpty && questionResults.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('No results found.')),
                    ),
                ],
              ),
      ),
    );
  }
}

class _SectionResultTile extends StatelessWidget {
  final Section section;
  final dynamic kb;
  const _SectionResultTile({required this.section, required this.kb});

  @override
  Widget build(BuildContext context) {
    Chapter? parentChapter;
    for (final c in kb.chapters) {
      if (c.sections.contains(section)) {
        parentChapter = c;
        break;
      }
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.menu_book_outlined),
        title: Text(section.title),
        subtitle: parentChapter != null ? Text(parentChapter.title) : null,
        onTap: parentChapter == null
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SectionDetailScreen(
                      chapter: parentChapter!,
                      section: section,
                    ),
                  ),
                ),
      ),
    );
  }
}

class _QuestionResultTile extends StatelessWidget {
  final Question question;
  const _QuestionResultTile({required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.help_outline),
        title: Text(question.question, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('Chapter ${question.chapterId} · Section ${question.sectionId}'),
      ),
    );
  }
}
