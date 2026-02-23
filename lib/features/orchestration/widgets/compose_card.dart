import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/data/models/docker_models.dart';
import 'package:onepanelapp_app/features/orchestration/providers/compose_provider.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';

class ComposeCard extends StatelessWidget {
  final ComposeProject compose;

  const ComposeCard({super.key, required this.compose});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final provider = context.read<ComposeProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        compose.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        compose.status ?? 'Unknown',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: compose.status?.toLowerCase().contains('running') == true
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (compose.createTime != null)
                  Text(
                    compose.createTime!,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (compose.services != null && compose.services!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Services: ${compose.services!.join(", ")}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => provider.upCompose(int.parse(compose.id)),
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  label: Text(l10n.commonStart),
                ),
                TextButton.icon(
                  onPressed: () => provider.downCompose(int.parse(compose.id)),
                  icon: const Icon(Icons.arrow_downward, size: 18),
                  label: Text(l10n.commonStop),
                ),
                TextButton.icon(
                  onPressed: () => provider.restartCompose(int.parse(compose.id)),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.commonRestart),
                ),
                // Logs action would typically open a dialog or navigate to a logs page
                IconButton(
                  onPressed: () {
                    // TODO: Implement logs view
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logs feature coming soon')),
                    );
                  },
                  icon: const Icon(Icons.article_outlined),
                  tooltip: l10n.commonLogs,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
