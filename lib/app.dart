import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/router/app_router.dart';
import 'package:splitzy/core/theme/app_theme.dart';

/// The Splitzy application root: app-level configuration only. Routes and
/// navigation live in `core/router/`.
class SplitzyApp extends ConsumerWidget {
  const SplitzyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Splitzy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
