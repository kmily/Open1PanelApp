import 'package:flutter/material.dart';
import '../../widgets/main_layout.dart';
import 'widgets/app_store_view.dart';
import 'widgets/installed_apps_view.dart';

class AppsPage extends StatelessWidget {
  final int initialTabIndex;

  const AppsPage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1,
      child: DefaultTabController(
        length: 2,
        initialIndex: initialTabIndex,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('应用管理'),
            bottom: const TabBar(
              tabs: [
                Tab(text: '已安装'),
                Tab(text: '应用商店'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              InstalledAppsView(),
              AppStoreView(),
            ],
          ),
        ),
      ),
    );
  }
}
