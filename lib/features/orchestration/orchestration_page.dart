import 'package:flutter/material.dart';
import 'package:onepanelapp_app/features/orchestration/compose_page.dart';
import 'package:onepanelapp_app/features/orchestration/image_page.dart';
import 'package:onepanelapp_app/features/orchestration/network_page.dart';
import 'package:onepanelapp_app/features/orchestration/volume_page.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';

class OrchestrationPage extends StatelessWidget {
  const OrchestrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.orchestrationTitle),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.orchestrationCompose),
              Tab(text: l10n.orchestrationImages),
              Tab(text: l10n.orchestrationNetworks),
              Tab(text: l10n.orchestrationVolumes),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ComposePage(),
            ImagePage(),
            NetworkPage(),
            VolumePage(),
          ],
        ),
      ),
    );
  }
}
