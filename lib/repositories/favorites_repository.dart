import '../services/storage_service.dart';

/// Manages the favorited-question set (starred questions) and the
/// wrong-answers set (most-recently-missed questions), both stored simply
/// as sets of question uids ("<courseId>::<questionId>").
class FavoritesRepository {
  final StorageService _storage;
  FavoritesRepository(this._storage);

  Set<String> _favorites = {};
  Set<String> _wrong = {};

  Future<void> load() async {
    _favorites = _storage.getFavorites();
    _wrong = _storage.getWrongAnswers();
  }

  Set<String> get favorites => Set.unmodifiable(_favorites);
  Set<String> get wrongAnswers => Set.unmodifiable(_wrong);

  bool isFavorite(String uid) => _favorites.contains(uid);

  Future<void> toggleFavorite(String uid) async {
    if (_favorites.contains(uid)) {
      _favorites.remove(uid);
    } else {
      _favorites.add(uid);
    }
    await _storage.setFavorites(_favorites);
  }

  /// Called after every answered question: adds to the wrong-answers set
  /// if incorrect, and removes from it if the user has now answered
  /// correctly (so mastered questions naturally drop out of review).
  Future<void> recordResult(String uid, bool wasCorrect) async {
    if (wasCorrect) {
      _wrong.remove(uid);
    } else {
      _wrong.add(uid);
    }
    await _storage.setWrongAnswers(_wrong);
  }

  Future<void> clearWrongAnswers() async {
    _wrong.clear();
    await _storage.setWrongAnswers(_wrong);
  }
}
