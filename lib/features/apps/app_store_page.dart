import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/features/apps/providers/app_store_provider.dart';
import 'package:onepanelapp_app/features/apps/widgets/app_store_view.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';

class AppStorePage extends StatelessWidget {
  const AppStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStoreProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.appStoreTitle),
        ),
        body: const AppStoreView(),
      ),
    );
  }
}
