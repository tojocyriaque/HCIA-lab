import '../models/course_model.dart';
import '../models/question_model.dart';
import '../services/asset_loader_service.dart';

/// Repository exposing knowledge bases and question pools to the rest of
/// the app. This is the ONLY place that talks to [AssetLoaderService],
/// keeping screens/widgets fully decoupled from asset/file details.
class KnowledgeRepository {
  final AssetLoaderService _loader;

  List<LoadedCourse> _courses = [];
  bool _loaded = false;

  KnowledgeRepository({AssetLoaderService? loader})
      : _loader = loader ?? AssetLoaderService();

  bool get isLoaded => _loaded;

  List<LoadedCourse> get courses => List.unmodifiable(_courses);

  Future<void> load() async {
    if (_loaded) return;
    _courses = await _loader.loadAllCourses();
    _loaded = true;
  }

  Future<void> reload() async {
    _loaded = false;
    await load();
  }

  KnowledgeBase? knowledgeBase(String courseId) {
    for (final c in _courses) {
      if (c.courseId == courseId) return c.knowledgeBase;
    }
    return null;
  }

  List<Question> questionsFor(String courseId) {
    for (final c in _courses) {
      if (c.courseId == courseId) return c.questions;
    }
    return [];
  }

  /// All questions across all installed courses, each tagged with its
  /// courseId, so random-quiz/search can span multiple courses safely.
  List<Question> allQuestions() {
    return _courses.expand((c) => c.questions).toList();
  }

  Question? findQuestion(String courseId, int id) {
    final list = questionsFor(courseId);
    for (final q in list) {
      if (q.id == id) return q;
    }
    return null;
  }

  Question? findByUid(String uid) {
    for (final q in allQuestions()) {
      if (q.uid == uid) return q;
    }
    return null;
  }
}
