import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/core/router/app_routes.dart';
import 'package:splitzy/core/router/home_shell.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/presentation/screens/login_page.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';
import 'package:splitzy/features/auth/presentation/screens/profile_page.dart';
import 'package:splitzy/features/auth/presentation/screens/sign_up_page.dart';
import 'package:splitzy/features/splash/presentation/screens/launch_screen.dart';
import 'package:splitzy/features/splash/presentation/screens/splash_screen.dart';

part 'app_router.g.dart';

/// The app's single [GoRouter].
///
/// Flow: Launch --(replace)--> Splash --(push)--> Login <--(push/pop)--> Sign Up.
/// Signed-in users are redirected to Home, the first of the signed-in tabs
/// (see [HomeShell] and [authRedirect]).
///
/// Kept alive for the whole app lifetime: recreating the router would reset
/// the navigation stack. It therefore *listens* to the auth state and
/// re-runs its redirect instead of being rebuilt.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.launch,
    redirect: (context, state) =>
        authRedirect(ref.read(authStateProvider), state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.launch,
        builder: (context, state) =>
            LaunchScreen(onLoaded: () => context.go(AppRoutes.splash)),
      ),
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _fadePage(
          context,
          state,
          SplashScreen(onGetStarted: () => context.push(AppRoutes.login)),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        // Forgot Password is intentionally a no-op until its feature is
        // built.
        builder: (context, state) => LoginPage(
          onBack: () => _back(context),
          onForgotPassword: () {},
          onSignUp: () => context.push(AppRoutes.signUp),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => SignUpPage(
          onBack: () => _back(context),
          onSignIn: () => _backTo(context, AppRoutes.login),
        ),
      ),
      // The signed-in tabs. Each branch keeps its own navigation stack.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeRoute(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.groups,
                builder: (context, state) => const GroupsRoute(),
              ),
            ],
          ),
          // TEMPORARY: Activity shows ComingSoonTab until its feature is
          // built.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.activity,
                builder: (context, state) =>
                    const ComingSoonTab(title: 'Activity'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      // Outside the shell, so they cover the tabs and hide the bottom bar.
      GoRoute(
        path: AppRoutes.newGroup,
        builder: (context, state) => const NewGroupRoute(),
      ),
      GoRoute(
        path: AppRoutes.addExpense,
        builder: (context, state) =>
            AddExpenseRoute(initialGroupId: state.uri.queryParameters['group']),
      ),
      GoRoute(
        path: AppRoutes.groupDetailsPattern,
        builder: (context, state) =>
            GroupDetailsRoute(groupId: state.pathParameters['groupId'] ?? ''),
      ),
    ],
  );
  // Sign-in, sign-out and profile changes re-run the redirect.
  ref.listen(authStateProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
}

/// Screens only for signed-out users; signed-in users are sent to Home.
const _signedOutLocations = {
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.signUp,
};

/// The signed-in screens; signed-out users are sent to Splash.
const _signedInLocations = {
  AppRoutes.home,
  AppRoutes.groups,
  AppRoutes.activity,
  AppRoutes.profile,
  AppRoutes.newGroup,
  AppRoutes.addExpense,
};

/// Whether [location] is a signed-in screen: one of [_signedInLocations] or
/// a group's page.
bool _isSignedInLocation(String location) =>
    _signedInLocations.contains(location) ||
    location.startsWith(AppRoutes.groupDetails(''));

/// Where to send the user from [location], or `null` to stay.
///
/// - Launch always plays; afterwards it goes to Splash, which sends signed-in
///   users on to Home.
/// - While the auth state is unknown (loading or failed), nobody is moved.
/// - Signed-in users on a signed-out screen go to Home; signed-out users on
///   a signed-in tab go to Splash.
///
/// The two target groups do not overlap, so a redirect never loops.
@visibleForTesting
String? authRedirect(AsyncValue<AppUser?> authState, String location) {
  if (location == AppRoutes.launch || !authState.hasValue) return null;

  final signedIn = authState.value != null;
  if (signedIn && _signedOutLocations.contains(location)) return AppRoutes.home;
  if (!signedIn && _isSignedInLocation(location)) {
    return AppRoutes.splash;
  }
  return null;
}

/// Pops the current route if possible.
void _back(BuildContext context) {
  if (context.canPop()) context.pop();
}

/// Returns to [location]: pops when there is a route underneath (the usual
/// case, e.g. Login → Sign Up → Sign In), otherwise navigates there directly
/// (e.g. when the screen was opened via a deep link).
void _backTo(BuildContext context, String location) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(location);
  }
}

/// Cross-fades to the page; instant when the platform asks to reduce motion.
Page<void> _fadePage(BuildContext context, GoRouterState state, Widget child) {
  final duration = MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 400);

  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    child: child,
  );
}
