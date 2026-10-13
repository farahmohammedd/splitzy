import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/core/router/app_routes.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';
import 'package:splitzy/features/expenses/domain/money/balances.dart';
import 'package:splitzy/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splitzy/features/expenses/presentation/screens/add_expense_page.dart';
import 'package:splitzy/features/expenses/presentation/screens/group_details_page.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/presentation/providers/group_providers.dart';
import 'package:splitzy/features/groups/presentation/screens/create_group_page.dart';
import 'package:splitzy/features/groups/presentation/screens/groups_page.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_balance_text.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_home_cards.dart';
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
        onPressed: () => context.push(AppRoutes.addExpense),
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
/// features: Home shows the signed-in user's name, their groups, and their
/// balance across those groups' expenses.
class HomeRoute extends ConsumerWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Briefly null while signing out, before the redirect leaves Home.
    final user = ref.watch(authStateProvider).value;
    final groups = user == null ? null : ref.watch(groupsProvider(user.id));
    // While loading again after a failure, Home shows loading.
    final failed = groups != null && groups.hasError && !groups.isLoading;
    final loaded = failed ? null : groups?.value;
    final hasGroups = loaded != null && loaded.isNotEmpty;

    final balances = user == null
        ? _noBalances
        : _watchGroupBalances(ref, loaded ?? const [], user.id);
    final balanceLoading =
        groups == null || (loaded == null && !failed) || balances.loading;
    final balanceFailed = failed || balances.failed;
    final hasExpenses = balances.byGroup.values.any((b) => b.hasExpenses);
    final overall = overallBalance([
      for (final balance in balances.byGroup.values) balance.amount,
    ]);

    return HomeScreen(
      name: user?.nameToShow ?? '',
      // No expenses yet: the card shows its own empty state.
      balance: hasExpenses ? (owed: overall.owed, owe: overall.owe) : null,
      balanceLoading: balanceLoading && !balanceFailed,
      balanceFailed: balanceFailed,
      onAddExpense: () => context.push(AppRoutes.addExpense),
      onNewGroup: () => context.push(AppRoutes.newGroup),
      // No groups yet: Home shows its own empty state.
      groups: loaded != null && !hasGroups
          ? null
          : GroupHomeCards(
              groups: loaded,
              errorMessage: failed ? messageFor(groups.error) : null,
              balances: balances.byGroup,
              onOpenGroup: (group) =>
                  context.push(AppRoutes.groupDetails(group.id)),
            ),
      onSeeAllGroups: hasGroups ? () => context.go(AppRoutes.groups) : null,
    );
  }
}

/// The user's balance in each group whose expenses are loaded, by group id,
/// and whether any group's expenses are still loading or failed to load.
typedef _GroupBalances = ({
  Map<String, GroupBalance> byGroup,
  bool loading,
  bool failed,
});

const _GroupBalances _noBalances = (byGroup: {}, loading: false, failed: false);

/// Watches each of [groups]' expenses and works out [userId]'s balance in
/// each, with the expenses feature's balance rules. The app root connects
/// the groups and expenses features here.
_GroupBalances _watchGroupBalances(
  WidgetRef ref,
  List<Group> groups,
  String userId,
) {
  final byGroup = <String, GroupBalance>{};
  var loading = false;
  var failed = false;
  for (final group in groups) {
    final expenses = ref.watch(groupExpensesProvider(group.id));
    final list = expenses.value;
    if (expenses.hasError && !expenses.isLoading) {
      failed = true;
    } else if (list == null) {
      loading = true;
    } else {
      final memberIds = [for (final member in group.members) member.id];
      byGroup[group.id] = (
        amount: balancesOf(list, memberIds)[userId] ?? 0,
        hasExpenses: list.isNotEmpty,
      );
    }
  }
  return (byGroup: byGroup, loading: loading, failed: failed);
}

/// Connects [GroupsPage] to the signed-in user (the app root may connect
/// features) and opens New Group and each group's page.
class GroupsRoute extends ConsumerWidget {
  const GroupsRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    // Signed out: the redirect is about to leave this tab.
    if (user == null) return const SizedBox.shrink();
    final groups = ref.watch(groupsProvider(user.id)).value ?? const [];

    return GroupsPage(
      ownerId: user.id,
      balances: _watchGroupBalances(ref, groups, user.id).byGroup,
      onNewGroup: () => context.push(AppRoutes.newGroup),
      onOpenGroup: (group) => context.push(AppRoutes.groupDetails(group.id)),
    );
  }
}

/// Connects [CreateGroupPage] to the signed-in user (the app root may
/// connect features) and closes it on Back or once the group is created.
class NewGroupRoute extends ConsumerWidget {
  const NewGroupRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    // Signed out: the redirect is about to leave this screen.
    if (user == null) return const SizedBox.shrink();

    return CreateGroupPage(
      ownerId: user.id,
      ownerName: user.nameToShow,
      onBack: () => _close(context),
      onCreated: () => _close(context),
    );
  }

  /// Returns to the screen underneath, or to Groups when there is none (e.g.
  /// the screen was opened directly).
  static void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.groups);
    }
  }
}

/// Connects [AddExpensePage] to the signed-in user and their groups (the app
/// root may connect features), and closes it on Back or once the expense is
/// saved.
class AddExpenseRoute extends ConsumerWidget {
  const AddExpenseRoute({super.key, this.initialGroupId});

  /// The group chosen at first (e.g. when opened from a group's page).
  final String? initialGroupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    // Signed out: the redirect is about to leave this screen.
    if (user == null) return const SizedBox.shrink();
    final groups = ref.watch(groupsProvider(user.id));
    // While loading again after a failure, the screen shows loading.
    final failed = groups.hasError && !groups.isLoading;

    return AddExpensePage(
      groups: failed ? null : groups.value,
      groupsErrorMessage: failed ? messageFor(groups.error) : null,
      ownerId: user.id,
      initialGroupId: initialGroupId,
      onBack: () => _close(context),
      onSaved: () => _close(context),
      onNewGroup: () => context.push(AppRoutes.newGroup),
    );
  }

  /// Returns to the screen underneath, or to Home when there is none (e.g.
  /// the screen was opened directly).
  static void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }
}

/// Connects [GroupDetailsPage] to the signed-in user and the group [groupId]
/// from their groups (the app root may connect features). Shows loading
/// until the group is known, and a message when it is not one of theirs.
class GroupDetailsRoute extends ConsumerWidget {
  const GroupDetailsRoute({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    // Signed out: the redirect is about to leave this screen.
    if (user == null) return const SizedBox.shrink();
    final groups = ref.watch(groupsProvider(user.id));
    Group? group;
    for (final candidate in groups.value ?? const <Group>[]) {
      if (candidate.id == groupId) group = candidate;
    }

    if (group == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: groups.isLoading
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    groups.hasError
                        ? messageFor(groups.error)
                        : 'This group is not available.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
        ),
      );
    }

    return GroupDetailsPage(
      group: group,
      ownerId: user.id,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.groups);
        }
      },
      onAddExpense: () => context.push(AppRoutes.addExpenseTo(groupId)),
    );
  }
}

/// TEMPORARY: the page of a tab whose feature is not built yet (Activity).
/// Replaced by its real page in its own phase.
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
