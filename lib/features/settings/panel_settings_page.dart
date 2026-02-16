import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/core/theme/app_design_tokens.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/features/settings/settings_provider.dart';

class PanelSettingsPage extends StatelessWidget {
  const PanelSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final provider = context.watch<SettingsProvider>();
    final settings = provider.data.systemSettings;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.panelSettingsTitle)),
      body: ListView(
        padding: AppDesignTokens.pagePadding,
        children: [
          _buildSectionTitle(context, l10n.panelSettingsBasicInfo, theme),
          Card(
            child: Column(
              children: [
                _buildListTile(l10n.panelSettingsPanelName, settings?.panelName ?? '-'),
                _buildListTile(l10n.panelSettingsVersion, settings?.systemVersion ?? '-'),
                _buildListTile(l10n.panelSettingsPort, settings?.port ?? '-'),
                _buildListTile(l10n.panelSettingsBindAddress, settings?.bindAddress ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          _buildSectionTitle(context, l10n.panelSettingsInterface, theme),
          Card(
            child: Column(
              children: [
                _buildListTile(l10n.panelSettingsTheme, settings?.theme ?? 'default'),
                _buildListTile(l10n.panelSettingsLanguage, settings?.language ?? 'zh'),
                _buildListTile(l10n.panelSettingsMenuTabs, settings?.menuTabs ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          _buildSectionTitle(context, l10n.panelSettingsAdvanced, theme),
          Card(
            child: Column(
              children: [
                _buildListTile(
                  l10n.panelSettingsDeveloperMode,
                  settings?.developerMode == 'true' ? l10n.systemSettingsEnabled : l10n.systemSettingsDisabled,
                ),
                _buildListTile(
                  l10n.panelSettingsIpv6,
                  settings?.ipv6 == 'true' ? l10n.systemSettingsEnabled : l10n.systemSettingsDisabled,
                ),
                _buildListTile(
                  l10n.panelSettingsSessionTimeout,
                  l10n.panelSettingsMinutes(settings?.sessionTimeout ?? '30'),
                ),
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
}
