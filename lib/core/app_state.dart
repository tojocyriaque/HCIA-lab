import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../models/progress_model.dart';
import '../models/question_model.dart';
import '../repositories/favorites_repository.dart';
import '../repositories/knowledge_repository.dart';
import '../repositories/progress_repository.dart';
import '../repositories/quiz_repository.dart';
import '../services/storage_service.dart';

/// Central application state. Wires together all repositories and exposes
/// a simple, screen-friendly API. Kept intentionally light (no business
/// logic duplicated here) — it mostly just coordinates repositories and
/// notifies listeners.
class AppState extends ChangeNotifier {
  final StorageService storage = StorageService();
  late final KnowledgeRepository knowledgeRepository;
  late final ProgressRepository progressRepository;
  late final FavoritesRepository favoritesRepository;
  late final QuizRepository quizRepository;

  bool isLoading = true;
  String? loadError;
  bool darkMode = true;

  String? _selectedCourseId;

  AppState() {
    knowledgeRepository = KnowledgeRepository();
    progressRepository = ProgressRepository(storage);
    favoritesRepository = FavoritesRepository(storage);
    quizRepository = QuizRepository(knowledgeRepository: knowledgeRepository);
  }

  String? get selectedCourseId => _selectedCourseId;

  KnowledgeBase? get selectedKnowledgeBase =>
      _selectedCourseId == null ? null : knowledgeRepository.knowledgeBase(_selectedCourseId!);

  List<Question> get selectedCourseQuestions =>
      _selectedCourseId == null ? [] : knowledgeRepository.questionsFor(_selectedCourseId!);

  Future<void> bootstrap() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      await storage.init();
      darkMode = storage.getDarkMode();
      await knowledgeRepository.load();
      await progressRepository.load();
      await favoritesRepository.load();

      if (knowledgeRepository.courses.isNotEmpty) {
        _selectedCourseId = knowledgeRepository.courses.first.courseId;
      }
    } catch (e) {
      loadError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCourse(String courseId) {
    _selectedCourseId = courseId;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    darkMode = !darkMode;
    await storage.setDarkMode(darkMode);
    notifyListeners();
  }

  Future<void> toggleFavorite(Question q) async {
    await favoritesRepository.toggleFavorite(q.uid);
    notifyListeners();
  }

  bool isFavorite(Question q) => favoritesRepository.isFavorite(q.uid);

  Future<void> clearWrongAnswers() async {
    await favoritesRepository.clearWrongAnswers();
    notifyListeners();
  }

  /// Call after every answered question in any quiz mode to keep
  /// progress, wrong-answers and history in sync across the app.
  Future<void> recordAnswer({
    required Question question,
    required bool wasCorrect,
    required String mode,
  }) async {
    await progressRepository.recordAnswer(
      courseId: question.courseId,
      chapterId: question.chapterId,
      sectionId: question.sectionId,
      wasCorrect: wasCorrect,
    );
    await favoritesRepository.recordResult(question.uid, wasCorrect);
    await progressRepository.recordAttemptHistory(QuestionAttempt(
      questionUid: question.uid,
      wasCorrect: wasCorrect,
      answeredAt: DateTime.now(),
      mode: mode,
    ));
    notifyListeners();
  }

  // ---- Derived statistics ----------------------------------------------

  int get totalAttempts => progressRepository.history().length;

  int get totalCorrect =>
      progressRepository.history().where((a) => a.wasCorrect).length;

  double get overallAccuracy =>
      totalAttempts == 0 ? 0 : totalCorrect / totalAttempts;

  Map<String, int> attemptsByMode() {
    final map = <String, int>{};
    for (final a in progressRepository.history()) {
      map[a.mode] = (map[a.mode] ?? 0) + 1;
    }
    return map;
  }
}
