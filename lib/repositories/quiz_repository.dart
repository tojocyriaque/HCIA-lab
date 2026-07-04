import '../models/question_model.dart';
import '../services/quiz_generator_service.dart';
import 'knowledge_repository.dart';

class QuizRepository {
  final KnowledgeRepository knowledgeRepository;
  final QuizGeneratorService generator;

  QuizRepository({
    required this.knowledgeRepository,
    QuizGeneratorService? generator,
  }) : generator = generator ?? QuizGeneratorService();

  List<Question> practiceSet(String courseId, int chapterId, {int? sectionId}) {
    return generator.practiceSet(
      pool: knowledgeRepository.questionsFor(courseId),
      chapterId: chapterId,
      sectionId: sectionId,
    );
  }

  List<Question> examSet(String courseId, {int? chapterId, int limit = 50}) {
    return generator.examSet(
      pool: knowledgeRepository.questionsFor(courseId),
      chapterId: chapterId,
      limit: limit,
    );
  }

  List<Question> randomQuiz(String courseId, {int limit = 15}) {
    return generator.randomQuiz(
      pool: knowledgeRepository.questionsFor(courseId),
      limit: limit,
    );
  }

  List<Question> wrongAnswersDeck(String courseId, Set<String> wrongUids) {
    return generator.wrongAnswersDeck(
      pool: knowledgeRepository.questionsFor(courseId),
      wrongUids: wrongUids,
    );
  }

  List<Question> favoritesDeck(String courseId, Set<String> favoriteUids) {
    return generator.favoritesDeck(
      pool: knowledgeRepository.questionsFor(courseId),
      favoriteUids: favoriteUids,
    );
  }
}
