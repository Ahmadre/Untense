import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untense/core/routing/route_paths.dart';
import 'package:untense/presentation/pages/add_entry_page.dart';
import 'package:untense/presentation/pages/history_page.dart';
import 'package:untense/presentation/pages/home_page.dart';
import 'package:untense/presentation/pages/main_shell_page.dart';
import 'package:untense/presentation/pages/settings_page.dart';

/// Central GoRouter configuration for the Untense app.
///
/// Uses [StatefulShellRoute] for bottom-navigation with separate
/// navigation stacks per tab, enabling state preservation across tabs.
class AppRouter {
  AppRouter._();

  /// Navigator keys for each branch
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _homeNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'home',
  );
  static final _historyNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'history',
  );
  static final _settingsNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'settings',
  );

  /// The singleton GoRouter instance
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: false,
    routes: [
      // ===== Shell Route with Bottom Navigation =====
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Home Tab
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: 'home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomePage()),
              ),
            ],
          ),
          // History Tab
          StatefulShellBranch(
            navigatorKey: _historyNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.history,
                name: 'history',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HistoryPage()),
              ),
            ],
          ),
          // Settings Tab
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.settings,
                name: 'settings',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsPage()),
              ),
            ],
          ),
        ],
      ),

      // ===== Full-Screen Routes (pushed over shell) =====
      GoRoute(
        path: RoutePaths.addEntry,
        name: 'addEntry',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          // Optional: pre-set timestamp passed via extra
          final presetTimestamp = state.extra as DateTime?;
          return AddEntryPage(presetTimestamp: presetTimestamp);
        },
      ),
      GoRoute(
        path: RoutePaths.editEntry,
        name: 'editEntry',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          return AddEntryPage(editEntryId: entryId);
        },
      ),
    ],
  );
}
