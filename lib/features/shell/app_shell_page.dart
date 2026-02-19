import 'package:flutter/material.dart';
import 'package:onepanelapp_app/features/files/files_page.dart';
import 'package:onepanelapp_app/features/security/security_verification_page.dart';
import 'package:onepanelapp_app/features/server/server_list_page.dart';
import 'package:onepanelapp_app/pages/settings/settings_page.dart';
import 'package:onepanelapp_app/widgets/navigation/app_bottom_navigation_bar.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ServerListPage(),
      const FilesPage(),
      const SecurityVerificationPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
      ),
    );
  }
}
