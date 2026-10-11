import 'package:flutter/material.dart';

/// The signed-in home screen. Intentionally minimal for now: the app bar
/// with a log-out action.
///
/// Presentation only: log-out is reported through [onLogOut] and the caller
/// decides what happens.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onLogOut});

  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Splitzy'),
        actions: [
          IconButton(
            onPressed: onLogOut,
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }
}
