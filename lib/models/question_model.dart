enum QuestionType { singleChoice, multipleChoice, unknown }

QuestionType _parseType(String? raw) {
  switch (raw) {
    case 'single_choice':
      return QuestionType.singleChoice;
    case 'multiple_choice':
      return QuestionType.multipleChoice;
    default:
      return QuestionType.unknown;
  }
}

/// A single quiz question exactly as authored in quiz_bank.json.
/// `courseId` is attached at load time (not present in the raw JSON) so
/// questions from multiple courses can be merged safely in memory.
class Question {
  final String courseId;
  final int id;
  final int chapterId;
  final int sectionId;
  final QuestionType type;
  final String question;
  final List<String> options;
  final List<String> correctAnswers; // letters, e.g. ["B"] or ["B", "C"]
  final String explanation;

  Question({
    required this.courseId,
    required this.id,
    required this.chapterId,
    required this.sectionId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswers,
    required this.explanation,
  });

  factory Question.fromJson(String courseId, Map<String, dynamic> json) {
    final rawAnswer = json['answer'];
    final List<String> answers;
    if (rawAnswer is List) {
      answers = rawAnswer.map((e) => e.toString()).toList();
    } else if (rawAnswer != null) {
      answers = [rawAnswer.toString()];
    } else {
      answers = [];
    }

    return Question(
      courseId: courseId,
      id: (json['id'] as num?)?.toInt() ?? 0,
      chapterId: (json['chapter_id'] as num?)?.toInt() ?? 0,
      sectionId: (json['section_id'] as num?)?.toInt() ?? 0,
      type: _parseType(json['question_type'] as String?),
      question: json['question']?.toString() ?? '',
      options: (json['options'] as List? ?? []).map((e) => e.toString()).toList(),
      correctAnswers: answers,
      explanation: json['explanation']?.toString() ?? '',
    );
  }

  /// Unique key across courses, used for favorites / wrong-answer tracking.
  String get uid => '$courseId::$id';

  bool get isMultiSelect => type == QuestionType.multipleChoice;

  /// Extracts just the leading letter (A/B/C/D) from an option string
  /// like "B. Complete real-name authentication...".
  static String letterOf(String option) {
    final trimmed = option.trim();
    if (trimmed.isEmpty) return '';
    final match = RegExp(r'^([A-Za-z])[\.\)]').firstMatch(trimmed);
    if (match != null) return match.group(1)!.toUpperCase();
    return trimmed.substring(0, 1).toUpperCase();
  }

  bool isCorrectSelection(Set<String> selectedLetters) {
    final correct = correctAnswers.map((e) => e.toUpperCase()).toSet();
    return selectedLetters.length == correct.length &&
        selectedLetters.every(correct.contains);
  }
}
