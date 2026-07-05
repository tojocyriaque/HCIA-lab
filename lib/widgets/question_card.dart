import 'package:flutter/material.dart';
import '../models/question_model.dart';

/// Renders a single question with selectable options, showing correctness
/// feedback once [submitted] is true. Supports both single- and
/// multiple-choice questions via [question.isMultiSelect].
class QuestionCard extends StatelessWidget {
  final Question question;
  final Set<String> selectedLetters;
  final bool submitted;
  final bool isFavorite;
  final ValueChanged<String> onSelectLetter;
  final VoidCallback onToggleFavorite;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedLetters,
    required this.submitted,
    required this.isFavorite,
    required this.onSelectLetter,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final correctSet = question.correctAnswers.map((e) => e.toUpperCase()).toSet();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Card(
        key: ValueKey(question.uid),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      question.question,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.amber : scheme.onSurfaceVariant,
                    ),
                    onPressed: onToggleFavorite,
                  ),
                ],
              ),
              if (question.isMultiSelect)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 6),
                  child: Text(
                    'Select all that apply',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.primary, fontStyle: FontStyle.italic),
                  ),
                ),
              const SizedBox(height: 8),
              ...question.options.map((option) {
                final letter = Question.letterOf(option);
                final isSelected = selectedLetters.contains(letter);
                final isCorrectOption = correctSet.contains(letter);

                Color? tileColor;
                IconData? trailingIcon;
                Color? trailingColor;

                if (submitted) {
                  if (isCorrectOption) {
                    tileColor = scheme.primaryContainer.withValues(alpha: 0.5);
                    trailingIcon = Icons.check_circle;
                    trailingColor = scheme.primary;
                  } else if (isSelected && !isCorrectOption) {
                    tileColor = scheme.errorContainer.withValues(alpha: 0.5);
                    trailingIcon = Icons.cancel;
                    trailingColor = scheme.error;
                  }
                } else if (isSelected) {
                  tileColor = scheme.secondaryContainer.withValues(alpha: 0.6);
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    title: Text(option),
                    leading: question.isMultiSelect
                        ? Icon(isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank)
                        : Icon(isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off),
                    trailing:
                        trailingIcon != null ? Icon(trailingIcon, color: trailingColor) : null,
                    onTap: submitted ? null : () => onSelectLetter(letter),
                  ),
                );
              }),
              if (submitted) ...[
                const Divider(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: scheme.tertiary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.explanation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
