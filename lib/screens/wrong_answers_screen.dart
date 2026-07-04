import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../widgets/animated_page_wrapper.dart';
import 'quiz_session_screen.dart';

class WrongAnswersScreen extends StatelessWidget {
  const WrongAnswersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final courseId = appState.selectedCourseId!;
    final wrong = appState.favoritesRepository.wrongAnswers;
    final questions = appState.quizRepository.wrongAnswersDeck(courseId, wrong);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wrong Answers'),
        actions: [
          if (questions.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => appState.clearWrongAnswers(),
            ),
        ],
      ),
      body: AnimatedPageWrapper(
        child: questions.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No missed questions right now — nice work!\n'
                    'Questions you answer incorrectly will show up here until '
                    'you get them right.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text('Review ${questions.length} missed questions'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizSessionScreen(
                              questions: questions,
                              mode: 'wrong',
                              title: 'Wrong Answers Review',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: questions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.error_outline, color: Colors.redAccent),
                            title: Text(q.question, maxLines: 2, overflow: TextOverflow.ellipsis),
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
