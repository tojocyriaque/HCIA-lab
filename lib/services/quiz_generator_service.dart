import 'dart:math';

import '../models/chapter_model.dart';
import '../models/course_model.dart';
import '../models/question_model.dart';

/// Builds quiz sessions by selecting questions from the pre-authored
/// `quiz_bank.json` question pool — questions are never hardcoded in Dart.
///
/// Each question in quiz_bank.json is already linked to a chapter/section,
/// and every section in knowledge.json exposes the categories the task
/// requires (learning_objectives, definitions, key_concepts, comparisons,
/// numbers, advantages, disadvantages, limitations, best_practices,
/// exam_traps, common_confusions). [coverageTagsFor] inspects those
/// categories for the section a question belongs to and returns which of
/// them are non-empty, so the UI can visibly show which knowledge
/// dimensions a quiz is drawing from — without ever inventing new
/// question text of its own.
class QuizGeneratorService {
  final Random _random = Random();

  List<Question> practiceSet({
    required List<Question> pool,
    required int chapterId,
    int? sectionId,
    int limit = 20,
  }) {
    var filtered = pool.where((q) => q.chapterId == chapterId);
    if (sectionId != null) {
      filtered = filtered.where((q) => q.sectionId == sectionId);
    }
    final list = filtered.toList();
    list.shuffle(_random);
    return list.take(limit).toList();
  }

  List<Question> examSet({
    required List<Question> pool,
    int? chapterId,
    int limit = 50,
  }) {
    final list = chapterId == null
        ? List<Question>.from(pool)
        : pool.where((q) => q.chapterId == chapterId).toList();
    list.shuffle(_random);
    return list.take(min(limit, list.length)).toList();
  }

  List<Question> randomQuiz({
    required List<Question> pool,
    int limit = 15,
  }) {
    final list = List<Question>.from(pool);
    list.shuffle(_random);
    return list.take(min(limit, list.length)).toList();
  }

  List<Question> wrongAnswersDeck({
    required List<Question> pool,
    required Set<String> wrongUids,
  }) {
    return pool.where((q) => wrongUids.contains(q.uid)).toList();
  }

  List<Question> favoritesDeck({
    required List<Question> pool,
    required Set<String> favoriteUids,
  }) {
    return pool.where((q) => favoriteUids.contains(q.uid)).toList();
  }

  /// Returns the set of knowledge-category tags (from knowledge.json) that
  /// are populated for the section backing [question], purely for display
  /// purposes ("This question draws on: Definitions, Exam Traps...").
  List<String> coverageTagsFor(Question question, KnowledgeBase kb) {
    final chapter = kb.chapterById(question.chapterId);
    final section = chapter?.sectionById(question.sectionId);
    if (section == null) return [];

    final tags = <String>[];
    void addIf(bool cond, String label) {
      if (cond) tags.add(label);
    }

    addIf(section.learningObjectives.isNotEmpty, 'Learning Objectives');
    addIf(section.definitions.isNotEmpty, 'Definitions');
    addIf(section.keyConcepts.isNotEmpty, 'Key Concepts');
    addIf(section.comparisons.isNotEmpty, 'Comparisons');
    addIf(section.numbers.isNotEmpty, 'Numbers');
    addIf(section.advantages.isNotEmpty, 'Advantages');
    addIf(section.disadvantages.isNotEmpty, 'Disadvantages');
    addIf(section.limitations.isNotEmpty, 'Limitations');
    addIf(section.bestPractices.isNotEmpty, 'Best Practices');
    addIf(section.examTraps.isNotEmpty, 'Exam Traps');
    addIf(section.commonConfusions.isNotEmpty, 'Common Confusions');
    return tags;
  }

  /// Simple full text search across chapters/sections (title + content).
  List<Section> searchSections(KnowledgeBase kb, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final matches = <Section>[];
    for (final chapter in kb.chapters) {
      for (final section in chapter.sections) {
        if (section.searchableText.contains(q)) {
          matches.add(section);
        }
      }
    }
    return matches;
  }

  /// Search questions by their text/explanation content.
  List<Question> searchQuestions(List<Question> pool, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return pool
        .where((question) =>
            question.question.toLowerCase().contains(q) ||
            question.explanation.toLowerCase().contains(q))
        .toList();
  }
}
