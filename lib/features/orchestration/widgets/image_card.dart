import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/data/models/docker_models.dart';
import 'package:onepanelapp_app/features/orchestration/providers/image_provider.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';

class ImageCard extends StatelessWidget {
  final DockerImage image;

  const ImageCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final provider = context.read<DockerImageProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (image.tags.isNotEmpty)
                        Text(
                          image.tags.first,
                          style: theme.textTheme.titleMedium,
                        )
                      else
                        Text(
                          image.id.substring(0, 12),
                          style: theme.textTheme.titleMedium,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Size: ${(image.size / 1024 / 1024).toStringAsFixed(2)} MB',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'Created: ${image.created}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.commonDelete),
                        content: Text(l10n.commonDeleteConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l10n.commonCancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(l10n.commonConfirm),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await provider.removeImage(image.id);
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: theme.colorScheme.error,
                ),
              ],
            ),
            if (image.tags.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  children: image.tags.skip(1).map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
