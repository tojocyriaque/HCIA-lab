import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/course_model.dart';
import '../models/question_model.dart';

/// Loads knowledge bases and quiz banks straight from the `assets/data/`
/// folder. No course names or file paths are hardcoded beyond the
/// `assets/data/` prefix: courses are discovered dynamically via
/// `AssetManifest.json`, which Flutter regenerates automatically whenever
/// the asset directory declared in pubspec.yaml changes contents.
///
/// This is what makes it possible to add a new HCIA/HCIP course by simply
/// dropping a new subfolder (e.g. `assets/data/hcip_datacom/`) containing
/// `knowledge.json` + `quiz_bank.json` with the SAME schema — no Dart code
/// needs to change.
class AssetLoaderService {
  static const String _dataRoot = 'assets/data/';

  /// Returns the list of course subfolder ids found under assets/data/,
  /// e.g. ["hcia_cloud", "hcip_datacom"].
  Future<List<String>> discoverCourseIds() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);

    final courseIds = <String>{};
    for (final assetPath in manifestMap.keys) {
      if (assetPath.startsWith(_dataRoot) &&
          assetPath.endsWith('knowledge.json')) {
        // assets/data/<courseId>/knowledge.json
        final remainder = assetPath.substring(_dataRoot.length);
        final parts = remainder.split('/');
        if (parts.length >= 2) {
          courseIds.add(parts[0]);
        }
      }
    }
    return courseIds.toList()..sort();
  }

  Future<KnowledgeBase> loadKnowledgeBase(String courseId) async {
    final path = '$_dataRoot$courseId/knowledge.json';
    final raw = await rootBundle.loadString(path);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return KnowledgeBase.fromJson(courseId, decoded);
  }

  Future<List<Question>> loadQuestions(String courseId) async {
    final path = '$_dataRoot$courseId/quiz_bank.json';
    final raw = await rootBundle.loadString(path);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final bank = decoded['quiz_bank'] as Map<String, dynamic>? ?? {};
    final questions = (bank['questions'] as List? ?? [])
        .map((e) => Question.fromJson(courseId, e as Map<String, dynamic>))
        .toList();
    return questions;
  }

  /// Loads every discovered course's knowledge base + questions in one go.
  Future<List<LoadedCourse>> loadAllCourses() async {
    final ids = await discoverCourseIds();
    final result = <LoadedCourse>[];
    for (final id in ids) {
      try {
        final kb = await loadKnowledgeBase(id);
        final questions = await loadQuestions(id);
        result.add(LoadedCourse(knowledgeBase: kb, questions: questions));
      } catch (_) {
        // Skip malformed course folders rather than crashing the whole app.
      }
    }
    return result;
  }
}

class LoadedCourse {
  final KnowledgeBase knowledgeBase;
  final List<Question> questions;
  LoadedCourse({required this.knowledgeBase, required this.questions});

  String get courseId => knowledgeBase.courseId;
}
