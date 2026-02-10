import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i18next/i18next.dart';
import 'package:untense/core/routing/route_paths.dart';
import 'package:untense/presentation/bloc/tension/tension_bloc.dart';
import 'package:untense/presentation/bloc/tension/tension_event.dart';

/// Main shell page with bottom navigation.
///
/// Receives [StatefulNavigationShell] from GoRouter's [StatefulShellRoute]
/// to manage tab state and navigation stacks independently.
class MainShellPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({super.key, required this.navigationShell});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  @override
  void initState() {
    super.initState();
    // Load today's entries when the shell page initializes
    context.read<TensionBloc>().add(const LoadTodayEntries());
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18Next.of(context);
    final currentIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      appBar: AppBar(title: Text(_getTitle(currentIndex, i18n))),
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          // When switching to history tab, reload dates
          if (index == 1) {
            context.read<TensionBloc>().add(const LoadDatesWithEntries());
          }
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: i18n?.t('nav.home') ?? 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: i18n?.t('nav.history') ?? 'History',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: i18n?.t('nav.settings') ?? 'Settings',
          ),
        ],
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RoutePaths.addEntry),
              icon: const Icon(Icons.add),
              label: Text(i18n?.t('home.addEntry') ?? 'Add Entry'),
            )
          : null,
    );
  }

  String _getTitle(int index, I18Next? i18n) {
    switch (index) {
      case 0:
        return i18n?.t('app.name') ?? 'Untense';
      case 1:
        return i18n?.t('history.title') ?? 'History';
      case 2:
        return i18n?.t('settings.title') ?? 'Settings';
      default:
        return 'Untense';
    }
  }
}
