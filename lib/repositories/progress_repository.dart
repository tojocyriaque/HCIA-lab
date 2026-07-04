import '../models/progress_model.dart';
import '../services/storage_service.dart';

class ProgressRepository {
  final StorageService _storage;
  ProgressRepository(this._storage);

  Map<String, SectionProgress> _cache = {};

  Future<void> load() async {
    final raw = _storage.getSectionProgressMap();
    _cache = raw.map((key, value) => MapEntry(
        key, SectionProgress.fromJson(Map<String, dynamic>.from(value))));
  }

  SectionProgress? progressFor(String courseId, int chapterId, int sectionId) {
    return _cache['$courseId::$chapterId::$sectionId'];
  }

  List<SectionProgress> allForCourse(String courseId) =>
      _cache.values.where((p) => p.courseId == courseId).toList();

  Future<void> recordAnswer({
    required String courseId,
    required int chapterId,
    required int sectionId,
    required bool wasCorrect,
  }) async {
    final key = '$courseId::$chapterId::$sectionId';
    final existing = _cache[key] ??
        SectionProgress(
          courseId: courseId,
          chapterId: chapterId,
          sectionId: sectionId,
          questionsAttempted: 0,
          questionsCorrect: 0,
          markedComplete: false,
        );
    _cache[key] = existing.copyWith(
      questionsAttempted: existing.questionsAttempted + 1,
      questionsCorrect: existing.questionsCorrect + (wasCorrect ? 1 : 0),
    );
    await _persist();
  }

  Future<void> markSectionComplete(
      String courseId, int chapterId, int sectionId, bool complete) async {
    final key = '$courseId::$chapterId::$sectionId';
    final existing = _cache[key] ??
        SectionProgress(
          courseId: courseId,
          chapterId: chapterId,
          sectionId: sectionId,
          questionsAttempted: 0,
          questionsCorrect: 0,
          markedComplete: false,
        );
    _cache[key] = existing.copyWith(markedComplete: complete);
    await _persist();
  }

  Future<void> recordAttemptHistory(QuestionAttempt attempt) async {
    await _storage.addAttempt(attempt.toJson());
  }

  List<QuestionAttempt> history() {
    return _storage
        .getAttempts()
        .map((e) => QuestionAttempt.fromJson(e))
        .toList();
  }

  Future<void> clearHistory() => _storage.clearAttempts();

  Future<void> _persist() async {
    final map = _cache.map((key, value) => MapEntry(key, value.toJson()));
    await _storage.setSectionProgressMap(map);
  }
}
