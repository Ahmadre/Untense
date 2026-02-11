import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i18next/i18next.dart';
import 'package:untense/core/routing/route_paths.dart';
import 'package:untense/presentation/bloc/tension/tension_bloc.dart';
import 'package:untense/presentation/bloc/tension/tension_event.dart';

/// Width breakpoint for switching from bottom nav to [NavigationRail].
const double _kDesktopBreakpoint = 840;

/// Main shell page with **responsive** navigation.
///
/// * **Mobile / Tablet** (< 840 dp): Liquid-Glass bottom navigation bar
///   rendered via [BackdropFilter] — works on all platforms.
/// * **Desktop** (≥ 840 dp): Material [NavigationRail] on the left.
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

  void _onDestinationSelected(int index) {
    if (index == 0) {
      context.read<TensionBloc>().add(const LoadTodayEntries());
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18Next.of(context);
    final currentIndex = widget.navigationShell.currentIndex;
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth >= _kDesktopBreakpoint) {
      return _buildDesktopLayout(currentIndex, i18n);
    }
    return _buildMobileLayout(currentIndex, i18n);
  }

  // ─── Mobile / Tablet ──────────────────────────────────────────────

  Widget _buildMobileLayout(int currentIndex, I18Next? i18n) {
    return Scaffold(
      // Let the body extend behind the glass bar so content blurs through
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: _GlassBottomNavBar(
        currentIndex: currentIndex,
        onTap: _onDestinationSelected,
        items: _navItems(i18n),
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

  // ─── Desktop ──────────────────────────────────────────────────────

  Widget _buildDesktopLayout(int currentIndex, I18Next? i18n) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: _onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            leading: currentIndex == 0
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FloatingActionButton(
                      onPressed: () => context.push(RoutePaths.addEntry),
                      child: const Icon(Icons.add),
                    ),
                  )
                : const SizedBox(height: 56),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: Text(i18n?.t('nav.home') ?? 'Home'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.history_outlined),
                selectedIcon: const Icon(Icons.history),
                label: Text(i18n?.t('nav.history') ?? 'History'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(i18n?.t('nav.settings') ?? 'Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.navigationShell),
        ],
      ),
      // FAB lives inside the NavigationRail's leading slot on desktop
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  List<_GlassNavItem> _navItems(I18Next? i18n) => [
    _GlassNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: i18n?.t('nav.home') ?? 'Home',
    ),
    _GlassNavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      label: i18n?.t('nav.history') ?? 'History',
    ),
    _GlassNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: i18n?.t('nav.settings') ?? 'Settings',
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
//  Liquid-Glass Bottom Navigation Bar (private to this file)
// ═══════════════════════════════════════════════════════════════════════════

/// Data class for a single navigation item.
class _GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// A frosted-glass bottom navigation bar inspired by iOS 26 Liquid Glass.
///
/// Renders a blurred, semi-transparent pill-shaped bar using Flutter's
/// built-in [BackdropFilter] — works on **all platforms** (Skia / Impeller).
/// Wrapped in [RepaintBoundary] to isolate the compositing layer for
/// optimal rendering performance.
class _GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_GlassNavItem> items;

  const _GlassBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomSafe + 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.06),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.78),
                          Colors.white.withValues(alpha: 0.58),
                        ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.9),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: List.generate(items.length, (i) {
                    return Expanded(
                      child: _GlassNavItemWidget(
                        item: items[i],
                        isSelected: currentIndex == i,
                        onTap: () => onTap(i),
                        primaryColor: primary,
                        isDark: isDark,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single item inside the glass bottom bar with animated selection indicator.
class _GlassNavItemWidget extends StatelessWidget {
  final _GlassNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isDark;

  const _GlassNavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.5);
    final color = isSelected ? primaryColor : inactiveColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
