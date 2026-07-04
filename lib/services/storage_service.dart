import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences providing typed helpers for
/// storing JSON-serialisable lists/maps. All persistence in this app
/// (favorites, wrong answers, progress, settings) goes through here so
/// there is a single, swappable storage boundary.
class StorageService {
  static const _kFavorites = 'favorites_v1';
  static const _kAttempts = 'attempts_v1';
  static const _kSectionProgress = 'section_progress_v1';
  static const _kDarkMode = 'dark_mode_v1';
  static const _kWrongAnswers = 'wrong_answers_v1';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    final p = _prefs;
    if (p == null) {
      throw StateError('StorageService.init() must be called before use.');
    }
    return p;
  }

  // ---- Generic JSON list helpers -----------------------------------

  List<dynamic> _readJsonList(String key) {
    final raw = _p.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeJsonList(String key, List<dynamic> value) async {
    await _p.setString(key, jsonEncode(value));
  }

  // ---- Favorites ------------------------------------------------------
  // Stored as a simple set of question uids ("courseId::questionId").

  Set<String> getFavorites() =>
      _readJsonList(_kFavorites).map((e) => e.toString()).toSet();

  Future<void> setFavorites(Set<String> favorites) =>
      _writeJsonList(_kFavorites, favorites.toList());

  // ---- Wrong answers ---------------------------------------------------
  // Stored as a set of question uids the user most recently got wrong.
  // Correctly re-answering a question removes it from this set.

  Set<String> getWrongAnswers() =>
      _readJsonList(_kWrongAnswers).map((e) => e.toString()).toSet();

  Future<void> setWrongAnswers(Set<String> wrong) =>
      _writeJsonList(_kWrongAnswers, wrong.toList());

  // ---- Attempts (history for statistics) -------------------------------

  List<Map<String, dynamic>> getAttempts() =>
      _readJsonList(_kAttempts).cast<Map<String, dynamic>>();

  Future<void> addAttempt(Map<String, dynamic> attempt) async {
    final list = getAttempts();
    list.add(attempt);
    // Keep history bounded to avoid unbounded local storage growth.
    final trimmed = list.length > 5000 ? list.sublist(list.length - 5000) : list;
    await _writeJsonList(_kAttempts, trimmed);
  }

  Future<void> clearAttempts() => _writeJsonList(_kAttempts, []);

  // ---- Section progress -------------------------------------------------

  Map<String, dynamic> getSectionProgressMap() {
    final raw = _p.getString(_kSectionProgress);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> setSectionProgressMap(Map<String, dynamic> map) async {
    await _p.setString(_kSectionProgress, jsonEncode(map));
  }

  // ---- Settings ---------------------------------------------------------

  bool getDarkMode({bool defaultValue = true}) =>
      _p.getBool(_kDarkMode) ?? defaultValue;

  Future<void> setDarkMode(bool value) => _p.setBool(_kDarkMode, value);
}
