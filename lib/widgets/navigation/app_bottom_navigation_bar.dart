import 'package:flutter/material.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.destinationKeys,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlobalKey>? destinationKeys;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final safeIndex = currentIndex.clamp(0, 3);

    return NavigationBar(
      selectedIndex: safeIndex,
      onDestinationSelected: onTap,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.dns_outlined, key: _destinationKey(0)),
          selectedIcon: Icon(Icons.dns, key: _destinationKey(0)),
          label: l10n.navServer,
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined, key: _destinationKey(1)),
          selectedIcon: Icon(Icons.folder, key: _destinationKey(1)),
          label: l10n.navFiles,
        ),
        NavigationDestination(
          icon: Icon(Icons.verified_user_outlined, key: _destinationKey(2)),
          selectedIcon: Icon(Icons.verified_user, key: _destinationKey(2)),
          label: l10n.navSecurity,
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined, key: _destinationKey(3)),
          selectedIcon: Icon(Icons.settings, key: _destinationKey(3)),
          label: l10n.navSettings,
        ),
      ],
    );
  }

  Key? _destinationKey(int index) {
    if (destinationKeys == null || destinationKeys!.length <= index) {
      return null;
    }
    return destinationKeys![index];
  }
}
