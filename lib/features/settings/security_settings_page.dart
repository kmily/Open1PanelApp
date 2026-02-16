import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/core/theme/app_design_tokens.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/features/settings/settings_provider.dart';

class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final provider = context.watch<SettingsProvider>();
    final settings = provider.data.systemSettings;
    final mfaStatus = provider.data.mfaStatus;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.securitySettingsTitle)),
      body: ListView(
        padding: AppDesignTokens.pagePadding,
        children: [
          _buildSectionTitle(context, l10n.securitySettingsMfaSection, theme),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.securitySettingsMfaStatus),
                  subtitle: Text(mfaStatus?.enabled == true ? l10n.systemSettingsEnabled : l10n.systemSettingsDisabled),
                  value: mfaStatus?.enabled ?? false,
                  onChanged: (value) {
                    _showMfaDialog(context, value, l10n);
                  },
                ),
                if (mfaStatus?.enabled == true)
                  ListTile(
                    title: Text(l10n.securitySettingsUnbindMfa),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showUnbindMfaDialog(context, l10n),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          _buildSectionTitle(context, l10n.securitySettingsAccessControl, theme),
          Card(
            child: Column(
              children: [
                _buildListTile(l10n.securitySettingsSecurityEntrance, settings?.securityEntrance ?? '-'),
                _buildListTile(l10n.securitySettingsBindDomain, settings?.bindDomain ?? '-'),
                _buildListTile(l10n.securitySettingsAllowIPs, settings?.allowIPs ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          _buildSectionTitle(context, l10n.securitySettingsPasswordPolicy, theme),
          Card(
            child: Column(
              children: [
                _buildListTile(
                  l10n.securitySettingsComplexityVerification,
                  settings?.complexityVerification == 'true' ? l10n.systemSettingsEnabled : l10n.systemSettingsDisabled,
                ),
                _buildListTile(l10n.securitySettingsExpirationDays, settings?.expirationDays ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignTokens.spacingSm),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(value, style: const TextStyle(color: Colors.grey)),
    );
  }

  void _showMfaDialog(BuildContext context, bool enable, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(enable ? l10n.securitySettingsEnableMfa : l10n.securitySettingsDisableMfa),
        content: Text(enable ? l10n.securitySettingsEnableMfaConfirm : l10n.securitySettingsDisableMfaConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }

  void _showUnbindMfaDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.securitySettingsUnbindMfa),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.securitySettingsEnterMfaCode),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.securitySettingsVerifyCode,
                hintText: l10n.securitySettingsMfaCodeHint,
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<SettingsProvider>().unbindMfa(controller.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? l10n.securitySettingsMfaUnbound : l10n.securitySettingsUnbindFailed)),
                );
              }
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }
}
