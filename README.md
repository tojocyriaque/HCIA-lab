# HCIA/HCIP Study Hub

An offline-first Flutter (Material 3) study & quiz app for Huawei HCIA/HCIP
certification prep, driven entirely by two JSON data files per course:
`knowledge.json` (learning content) and `quiz_bank.json` (question pool).

## Why this architecture

The brief requires that `knowledge.json` never be hand-modified, that its
schema stay stable so it can later be **regenerated automatically by
Gemini**, and that the JSON be swappable **without touching any Dart code**.
To achieve that:

- All parsing lives behind typed model classes (`lib/models/`) that mirror
  the JSON schema field-for-field. As long as Gemini keeps producing the
  same field names, nothing else in the app needs to change.
- Questions are **never hardcoded** — every quiz (learning, practice, exam,
  random, wrong-answer review, favorites) is assembled at runtime by
  selecting from `quiz_bank.json` via `QuizGeneratorService`.
- Courses are discovered **dynamically at runtime** from
  `assets/data/<course_id>/knowledge.json` +
  `assets/data/<course_id>/quiz_bank.json`, using Flutter's
  `AssetManifest.json`. Adding a new HCIA/HCIP course (e.g. HCIP-Datacom)
  is just:
  1. Create `assets/data/hcip_datacom/`
  2. Drop in `knowledge.json` + `quiz_bank.json` with the same schema
  3. Add one line to `pubspec.yaml`'s `assets:` list (or declare the whole
     `assets/data/` folder up front, as this project already does) and run
     `flutter pub get`
  4. **No Dart code changes required.**

## Clean architecture layout

```
lib/
  core/
    app_state.dart        # ChangeNotifier wiring all repositories together
    theme/app_theme.dart  # Material 3 light/dark theme
    constants/            # App-wide constants
  models/                 # Pure data classes mirroring the JSON schema
    course_model.dart
    chapter_model.dart
    question_model.dart
    progress_model.dart
  services/               # Stateless/low-level infrastructure
    asset_loader_service.dart   # Discovers & loads JSON from assets/
    quiz_generator_service.dart# Selects/shapes quiz sessions from quiz_bank.json
    storage_service.dart       # SharedPreferences persistence
  repositories/           # App-facing data access, one per concern
    knowledge_repository.dart
    quiz_repository.dart
    progress_repository.dart
    favorites_repository.dart
  widgets/                # Reusable, presentation-only widgets
  screens/                # One file per screen/route
```

## Features implemented

- Material 3 UI with dynamic light/dark theming (seeded color scheme)
- Home page with quick stats, course switcher (multi-course ready)
- Chapter list → Section list → Section detail (Learning Mode)
- Learning Mode: renders every knowledge category (learning objectives,
  definitions, key concepts, comparisons, numbers, advantages,
  disadvantages, limitations, best practices, exam traps, common
  confusions) for a section
- Practice Mode (per chapter or per section, untimed, from quiz_bank.json)
- Exam Mode (full-length, 60-minute countdown timer)
- Random Quiz (shuffled across the whole course)
- Favorites (star any question, review them anytime)
- Wrong Answers Review (auto-tracked; clears once you answer correctly)
- Global Search (sections + questions, offline full-text)
- Progress tracking (per-section accuracy + completion, persisted locally)
- Statistics screen (overall accuracy, breakdown by mode and by chapter)
- Local persistence via `shared_preferences` (fully offline, no network
  calls anywhere in the app)
- Smooth animations (fade/slide page transitions, animated progress bars,
  animated accuracy rings, animated option selection feedback)
- Responsive layout (ListView/Card-based, works across phone/tablet widths)

## Data files

- `assets/data/hcia_cloud/knowledge.json` — **unmodified copy** of the
  provided `knowledge.json`
- `assets/data/hcia_cloud/quiz_bank.json` — **unmodified copy** of the
  provided `quiz_bank.json`

Both files are byte-for-byte identical to what was supplied (verified via
checksum during the build of this project).

## Running the app

```bash
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

> Note: `android/local.properties` contains placeholder SDK paths
> (`sdk.dir` / `flutter.sdk`). Flutter tooling normally regenerates this
> file automatically the first time you open the project in your own
> environment / run `flutter pub get` — update the paths there if it
> doesn't.

## Adding a new course later

1. Create a new folder: `assets/data/<new_course_id>/`
2. Add `knowledge.json` and `quiz_bank.json` (same schema as the HCIA-Cloud
   files) inside it
3. Make sure `pubspec.yaml` still declares `assets/data/` (already done) —
   if your Flutter version requires per-folder declarations, add
   `assets/data/<new_course_id>/` as an extra line
4. Run `flutter pub get`

The Home screen will automatically show a course switcher once more than
one course is detected — no Dart code changes needed.
