import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18next/i18next.dart';
import 'package:untense/core/constants/app_constants.dart';
import 'package:untense/core/localization/app_localizations.dart';
import 'package:untense/core/routing/app_router.dart';
import 'package:untense/di/service_locator.dart';
import 'package:untense/presentation/bloc/settings/settings_bloc.dart';
import 'package:untense/presentation/bloc/settings/settings_event.dart';
import 'package:untense/presentation/bloc/settings/settings_state.dart';
import 'package:untense/presentation/bloc/tension/tension_bloc.dart';
import 'package:untense/theme.dart';

/// Root application widget.
/// Provides BLoC instances and handles theme/locale switching.
/// Uses [GoRouter] via [MaterialApp.router] for declarative routing.
class UntenseApp extends StatelessWidget {
  const UntenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TensionBloc>(create: (_) => sl<TensionBloc>()),
        BlocProvider<SettingsBloc>(
          create: (_) => sl<SettingsBloc>()..add(const LoadSettings()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          // Determine current theme and locale from settings
          final themeMode = settingsState is SettingsLoaded
              ? settingsState.config.themeMode
              : ThemeMode.system;

          final localeString = settingsState is SettingsLoaded
              ? settingsState.config.locale
              : AppConstants.localeDe;

          final locale = AppLocalizations.localeFromString(localeString);

          return MaterialApp.router(
            title: 'Untense',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              I18NextLocalizationDelegate(
                locales: AppLocalizations.supportedLocales,
                dataSource: AppLocalizations.dataSource,
              ),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
