/// Records the outcome of a single answered question, kept in local
/// storage so wrong-answers review and statistics can work offline.
class QuestionAttempt {
  final String questionUid; // "<courseId>::<questionId>"
  final bool wasCorrect;
  final DateTime answeredAt;
  final String mode; // "learning" | "practice" | "exam" | "random"

  QuestionAttempt({
    required this.questionUid,
    required this.wasCorrect,
    required this.answeredAt,
    required this.mode,
  });

  Map<String, dynamic> toJson() => {
        'questionUid': questionUid,
        'wasCorrect': wasCorrect,
        'answeredAt': answeredAt.toIso8601String(),
        'mode': mode,
      };

  factory QuestionAttempt.fromJson(Map<String, dynamic> json) {
    return QuestionAttempt(
      questionUid: json['questionUid'] as String,
      wasCorrect: json['wasCorrect'] as bool,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      mode: json['mode'] as String? ?? 'practice',
    );
  }
}

/// Tracks per-section completion progress within a course, so the Section
/// list screen can show a progress ring/percentage.
class SectionProgress {
  final String courseId;
  final int chapterId;
  final int sectionId;
  final int questionsAttempted;
  final int questionsCorrect;
  final bool markedComplete;

  SectionProgress({
    required this.courseId,
    required this.chapterId,
    required this.sectionId,
    required this.questionsAttempted,
    required this.questionsCorrect,
    required this.markedComplete,
  });

  String get key => '$courseId::$chapterId::$sectionId';

  double get accuracy =>
      questionsAttempted == 0 ? 0 : questionsCorrect / questionsAttempted;

  SectionProgress copyWith({
    int? questionsAttempted,
    int? questionsCorrect,
    bool? markedComplete,
  }) {
    return SectionProgress(
      courseId: courseId,
      chapterId: chapterId,
      sectionId: sectionId,
      questionsAttempted: questionsAttempted ?? this.questionsAttempted,
      questionsCorrect: questionsCorrect ?? this.questionsCorrect,
      markedComplete: markedComplete ?? this.markedComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'courseId': courseId,
        'chapterId': chapterId,
        'sectionId': sectionId,
        'questionsAttempted': questionsAttempted,
        'questionsCorrect': questionsCorrect,
        'markedComplete': markedComplete,
      };

  factory SectionProgress.fromJson(Map<String, dynamic> json) {
    return SectionProgress(
      courseId: json['courseId'] as String,
      chapterId: json['chapterId'] as int,
      sectionId: json['sectionId'] as int,
      questionsAttempted: json['questionsAttempted'] as int? ?? 0,
      questionsCorrect: json['questionsCorrect'] as int? ?? 0,
      markedComplete: json['markedComplete'] as bool? ?? false,
    );
  }
}

/// Result summary shown at the end of a practice/exam/random session.
class QuizSessionResult {
  final int total;
  final int correct;
  final Duration timeTaken;
  final String mode;

  QuizSessionResult({
    required this.total,
    required this.correct,
    required this.timeTaken,
    required this.mode,
  });

  double get scorePercent => total == 0 ? 0 : (correct / total) * 100;
}
