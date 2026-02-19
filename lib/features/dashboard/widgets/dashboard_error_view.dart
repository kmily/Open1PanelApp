import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_x.dart';
import '../../../core/services/error_handler_service.dart';

class DashboardErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final dynamic originalError;

  const DashboardErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.originalError,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    // 获取友好的错误消息
    final friendlyError = originalError != null
        ? ErrorHandlerService.getErrorMessage(context, originalError)
        : error;

    // 根据错误类型提供相应的提示
    String? tip;
    if (originalError != null) {
      if (friendlyError.contains(l10n.errorConnectionTimeout) ||
          friendlyError.contains(l10n.errorNetworkUnreachable)) {
        tip = l10n.errorTipCheckNetwork;
      } else if (friendlyError.contains(l10n.errorUnauthorized)) {
        tip = l10n.errorTipCheckServer;
      } else if (friendlyError.contains(l10n.errorInternalServerError)) {
        tip = l10n.errorTipRetryLater;
      } else {
        tip = l10n.errorTipContactSupport;
      }
    } else {
      tip = l10n.errorTipRetryLater;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.dashboardLoadFailedTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              friendlyError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tip!,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showErrorDetails(context),
                  icon: const Icon(Icons.info_outline),
                  label: Text(l10n.errorDetailTitle),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.commonRetry),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDetails(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.errorDetailTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.errorDetailMessage,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                originalError?.toString() ?? error,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              if (originalError != null && originalError.toString().contains('\n')) ...[
                const SizedBox(height: 16),
                const Text(
                  '详细信息',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  originalError.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
