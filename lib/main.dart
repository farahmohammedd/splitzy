import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/error/global_error_handlers.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // The only place Crashlytics collection is decided (no manifest setting).
  // Set on every launch: the plugin persists the value, so debug and release
  // builds on one device would otherwise share it.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );
  final container = InjectionContainer.create();
  // After Firebase (Crashlytics needs it) and before runApp, so every error
  // from the app's first frame on reaches the reporter.
  installGlobalErrorHandlers(container.errorReporter);
  runApp(
    ProviderScope(overrides: container.overrides, child: const SplitzyApp()),
  );
}
