import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageHeader extends StatelessWidget {
  const PageHeader(
      {super.key,
      required this.title,
      this.subtitle = "",
      this.back = false,
      this.onBack,
      this.backText = "Back"});

  final String title;
  final String subtitle;
  final bool back;

  final VoidCallback? onBack;
  final String backText;

  @override
  Widget build(BuildContext context) {
    VoidCallback onBack = () => GoRouter.of(context).pop();
    if (this.onBack != null) {
      onBack = this.onBack!;
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.primary,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              back
                  ? ElevatedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(backText))
                  : const SizedBox.shrink(),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ))
            ],
          )
        ],
      ),
    );
  }
}
