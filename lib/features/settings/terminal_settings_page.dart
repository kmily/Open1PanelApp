import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/core/theme/app_design_tokens.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/features/settings/settings_provider.dart';

class TerminalSettingsPage extends StatelessWidget {
  const TerminalSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final provider = context.watch<SettingsProvider>();
    final terminal = provider.data.terminalSettings;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.terminalSettingsTitle)),
      body: ListView(
        padding: AppDesignTokens.pagePadding,
        children: [
          _buildSectionTitle(context, l10n.terminalSettingsDisplay, theme),
          Card(
            child: Column(
              children: [
                _buildListTile(l10n.terminalSettingsCursorStyle, terminal?.cursorStyle ?? '-'),
                _buildListTile(l10n.terminalSettingsCursorBlink, terminal?.cursorBlink ?? '-'),
                _buildListTile(l10n.terminalSettingsFontSize, terminal?.fontSize ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          _buildSectionTitle(context, l10n.terminalSettingsScroll, theme),
          Card(
            child: Column(
              children: [
                _buildListTile(l10n.terminalSettingsScrollSensitivity, terminal?.scrollSensitivity ?? '-'),
                _buildListTile(l10n.terminalSettingsScrollback, terminal?.scrollback ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          _buildSectionTitle(context, l10n.terminalSettingsStyle, theme),
          Card(
            child: Column(
              children: [
                _buildListTile(l10n.terminalSettingsLineHeight, terminal?.lineHeight ?? '-'),
                _buildListTile(l10n.terminalSettingsLetterSpacing, terminal?.letterSpacing ?? '-'),
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
