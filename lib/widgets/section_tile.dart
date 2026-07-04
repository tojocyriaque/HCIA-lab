import 'package:flutter/material.dart';
import '../models/chapter_model.dart';

class SectionTile extends StatelessWidget {
  final Section section;
  final double accuracy; // 0..1, -1 if no attempts
  final bool complete;
  final VoidCallback onTap;

  const SectionTile({
    super.key,
    required this.section,
    required this.accuracy,
    required this.complete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: complete
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          child: Icon(
            complete ? Icons.check : Icons.menu_book_outlined,
            color: complete ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: accuracy < 0
            ? const Text('Not attempted yet')
            : Text('Accuracy: ${(accuracy * 100).round()}%'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
