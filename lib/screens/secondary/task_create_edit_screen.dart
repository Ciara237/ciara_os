import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Add/Edit Task — stub until Tasks milestone; saves route to Today.
class TaskCreateEditScreen extends StatelessWidget {
  const TaskCreateEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        actions: [
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Save'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Task form — coming soon.'),
      ),
    );
  }
}
