import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';
import 'package:splitzy/features/home/presentation/screens/home_screen.dart';

/// The signed-in area: the current tab ([navigationShell]) above a bottom bar
/// with Home, Groups, Activity and Profile, and an Add button in the middle.
///
/// Part of the app root (like the router): it may connect several features.
/// Each tab keeps its own navigation stack (see `StatefulShellRoute`).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// The tabs in branch order (see the shell route in `app_router.dart`).
  static const List<_Tab> _tabs = [
    _Tab('Home', Icons.home_outlined, Icons.home_rounded),
    _Tab('Groups', Icons.group_outlined, Icons.group_rounded),
    _Tab('Activity', Icons.bar_chart_rounded, Icons.bar_chart_rounded),
    _Tab('Profile', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  void _selectTab(int index) {
    // Tapping the current tab again returns it to its first page.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        // TEMPORARY: replaced by the Add Expense flow in the Expenses phase.
        onPressed: () => _showComingSoon(context),
        tooltip: 'Add expense',
        shape: const CircleBorder(),
        backgroundColor: context.brandColors.primaryDark,
        foregroundColor: scheme.onPrimary,
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        tabs: _tabs,
        currentIndex: navigationShell.currentIndex,
        onSelected: _selectTab,
      ),
    );
  }
}

/// TEMPORARY: tells the user a feature is not built yet. Removed once every
/// button and tab that uses it leads to its real feature.
void _showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('Coming soon')));
}

class _Tab {
  const _Tab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Two tabs on each side of a gap for the docked Add button. Its height
/// follows its content, so labels can grow with the text scale.
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
  });

  /// Room left in the middle for the docked Add button.
  static const double _addButtonGap = 72;

  final List<_Tab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final half = tabs.length ~/ 2;

    Widget item(int index) => Expanded(
      child: _BottomBarItem(
        tab: tabs[index],
        selected: index == currentIndex,
        onTap: () => onSelected(index),
      ),
    );

    return Material(
      color: scheme.surface,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < half; i++) item(i),
              const SizedBox(width: _addButtonGap),
              for (var i = half; i < tabs.length; i++) item(i),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? context.brandColors.primaryDark
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      child: InkResponse(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? tab.selectedIcon : tab.icon, color: color),
              const SizedBox(height: AppSpacing.xs),
              Text(
                tab.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Connects [HomeScreen] to the features it shows. The app root may connect
/// features: Home will gather groups and balances from their own features.
/// For now it shows the signed-in user's name.
class HomeRoute extends ConsumerWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Briefly null while signing out, before the redirect leaves Home.
    final user = ref.watch(authStateProvider).value;

    return HomeScreen(
      name: user?.nameToShow ?? '',
      // TEMPORARY: replaced by the Expenses and Groups flows in their phases.
      onAddExpense: () => _showComingSoon(context),
      onNewGroup: () => _showComingSoon(context),
    );
  }
}

/// TEMPORARY: the page of a tab whose feature is not built yet (Groups,
/// Activity). Each is replaced by its real page in its own phase.
class ComingSoonTab extends StatelessWidget {
  const ComingSoonTab({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Coming soon',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
