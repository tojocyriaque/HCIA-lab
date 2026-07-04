import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../widgets/animated_page_wrapper.dart';
import 'quiz_session_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final courseId = appState.selectedCourseId!;
    final favorites = appState.favoritesRepository.favorites;
    final questions = appState.quizRepository.favoritesDeck(courseId, favorites);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: AnimatedPageWrapper(
        child: questions.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No favorites yet.\nTap the star on any question to save it here.',
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
                        label: Text('Review ${questions.length} favorites'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizSessionScreen(
                              questions: questions,
                              mode: 'favorites',
                              title: 'Favorites Review',
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
                            title: Text(q.question, maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: IconButton(
                              icon: const Icon(Icons.star, color: Colors.amber),
                              onPressed: () => appState.toggleFavorite(q),
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
