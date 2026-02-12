import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/config/app_router.dart';
import 'package:onepanelapp_app/core/services/app_settings_controller.dart';
import 'package:onepanelapp_app/core/theme/app_theme.dart';
import 'package:onepanelapp_app/l10n/generated/app_localizations.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettingsController()..load(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsController>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: '1Panel Open',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightTheme(),
          darkTheme: AppTheme.getDarkTheme(),
          themeMode: settings.themeMode,
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRoutes.splash,
        );
      },
    );
  }
}
