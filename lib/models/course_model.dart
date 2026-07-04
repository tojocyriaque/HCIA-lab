import 'chapter_model.dart';

/// Represents the root `course` metadata block of a knowledge.json file.
class CourseInfo {
  final String title;
  final String version;
  final int totalPages;

  CourseInfo({
    required this.title,
    required this.version,
    required this.totalPages,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      title: json['title'] as String? ?? 'Untitled Course',
      version: json['version']?.toString() ?? '1.0',
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
    );
  }
}

class LearningManifest {
  final List<String> recommendedLearningOrder;
  final int estimatedDifficulty;
  final int estimatedQuestionsToGenerate;
  final List<String> prerequisites;
  final List<String> dependencies;
  final String estimatedStudyTime;

  LearningManifest({
    required this.recommendedLearningOrder,
    required this.estimatedDifficulty,
    required this.estimatedQuestionsToGenerate,
    required this.prerequisites,
    required this.dependencies,
    required this.estimatedStudyTime,
  });

  factory LearningManifest.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LearningManifest(
        recommendedLearningOrder: [],
        estimatedDifficulty: 0,
        estimatedQuestionsToGenerate: 0,
        prerequisites: [],
        dependencies: [],
        estimatedStudyTime: '',
      );
    }
    return LearningManifest(
      recommendedLearningOrder:
          (json['recommended_learning_order'] as List?)?.cast<String>() ?? [],
      estimatedDifficulty: (json['estimated_difficulty'] as num?)?.toInt() ?? 0,
      estimatedQuestionsToGenerate:
          (json['estimated_questions_to_generate'] as num?)?.toInt() ?? 0,
      prerequisites: (json['prerequisites'] as List?)?.cast<String>() ?? [],
      dependencies: (json['dependencies'] as List?)?.cast<String>() ?? [],
      estimatedStudyTime: json['estimated_study_time'] as String? ?? '',
    );
  }
}

/// A full knowledge base for a single course (e.g. HCIA-Cloud), identified
/// by a stable [courseId] derived from its asset subfolder name
/// (assets/data/<courseId>/knowledge.json). This id is used everywhere
/// downstream (progress keys, favorites keys, quiz bank lookup) so that
/// multiple courses can coexist without collisions.
class KnowledgeBase {
  final String courseId;
  final CourseInfo course;
  final List<Chapter> chapters;
  final LearningManifest manifest;

  KnowledgeBase({
    required this.courseId,
    required this.course,
    required this.chapters,
    required this.manifest,
  });

  factory KnowledgeBase.fromJson(String courseId, Map<String, dynamic> json) {
    return KnowledgeBase(
      courseId: courseId,
      course: CourseInfo.fromJson(
          (json['course'] as Map<String, dynamic>?) ?? const {}),
      chapters: (json['chapters'] as List? ?? [])
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      manifest: LearningManifest.fromJson(
          json['learning_manifest'] as Map<String, dynamic>?),
    );
  }

  Chapter? chapterById(int id) {
    for (final c in chapters) {
      if (c.chapterId == id) return c;
    }
    return null;
  }

  int get totalSections =>
      chapters.fold(0, (sum, c) => sum + c.sections.length);
}
