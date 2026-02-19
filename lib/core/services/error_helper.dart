import 'package:flutter/material.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/core/services/error_handler_service.dart';
import 'package:onepanelapp_app/core/theme/app_design_tokens.dart';

/// 错误处理辅助类
/// 
/// 提供常用的错误处理UI组件和方法，简化各个功能模块的错误处理代码
class ErrorHelper {
  /// 显示加载失败的视图
  static Widget buildErrorView({
    required BuildContext context,
    required String error,
    required VoidCallback onRetry,
    dynamic originalError,
    String? title,
    IconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    // 获取友好的错误消息
    final friendlyError = originalError != null
        ? ErrorHandlerService.getErrorMessage(context, originalError)
        : error;

    // 根据错误类型提供相应的提示
    String? tip = _getTipForError(context, friendlyError);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppDesignTokens.spacingLg),
            Text(
              title ?? l10n.commonLoadFailedTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDesignTokens.spacingSm),
            Text(
              friendlyError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (tip != null) ...[
              const SizedBox(height: AppDesignTokens.spacingMd),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacingMd,
                  vertical: AppDesignTokens.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tip,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDesignTokens.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (originalError != null)
                  OutlinedButton.icon(
                    onPressed: () => _showErrorDetails(context, error, originalError),
                    icon: const Icon(Icons.info_outline),
                    label: Text(l10n.errorDetailTitle),
                  ),
                if (originalError != null) const SizedBox(width: AppDesignTokens.spacingMd),
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

  /// 显示空数据视图
  static Widget buildEmptyView({
    required BuildContext context,
    required String title,
    required String description,
    IconData icon = Icons.inbox_outlined,
    Widget? action,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDesignTokens.spacingLg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDesignTokens.spacingSm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppDesignTokens.spacingLg),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// 显示错误SnackBar
  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
  }) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Theme.of(context).colorScheme.error,
        action: action != null
            ? SnackBarAction(
                label: l10n.commonRetry,
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: action,
              )
            : null,
      ),
    );
  }

  /// 显示成功SnackBar
  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 显示加载状态视图
  static Widget buildLoadingView({
    required BuildContext context,
    String? message,
  }) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppDesignTokens.spacingMd),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            const SizedBox(height: AppDesignTokens.spacingMd),
            Text(
              l10n.commonLoading,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 根据错误类型获取提示信息
  static String? _getTipForError(BuildContext context, String error) {
    final l10n = context.l10n;

    if (error.contains(l10n.errorConnectionTimeout) ||
        error.contains(l10n.errorNetworkUnreachable)) {
      return l10n.errorTipCheckNetwork;
    } else if (error.contains(l10n.errorUnauthorized)) {
      return l10n.errorTipCheckServer;
    } else if (error.contains(l10n.errorInternalServerError)) {
      return l10n.errorTipRetryLater;
    } else if (error.contains(l10n.errorConnectionRefused)) {
      return l10n.errorTipCheckServerStatus;
    }
    return null;
  }

  /// 显示错误详情对话框
  static void _showErrorDetails(BuildContext context, String error, dynamic originalError) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 8),
            Text(l10n.errorDetailTitle),
          ],
        ),
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
                Text(
                  l10n.errorDetailStackTrace,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

  /// 处理异步操作的通用方法
  static Future<T?> handleAsyncOperation<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String? loadingMessage,
    bool showErrorDialog = true,
  }) async {
    if (loadingMessage != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(loadingMessage),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      final result = await operation();
      if (loadingMessage != null && context.mounted) {
        Navigator.of(context).pop();
      }
      return result;
    } catch (e) {
      if (loadingMessage != null && context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted && showErrorDialog) {
        await ErrorHandlerService.showErrorDialog(
          context: context,
          title: context.l10n.errorOperationFailed,
          message: ErrorHandlerService.getErrorMessage(context, e),
        );
      }

      return null;
    }
  }
}
