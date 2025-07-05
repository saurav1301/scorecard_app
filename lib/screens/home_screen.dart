// 📄 File: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'coach_inspection_form.dart';
import 'station_inspection_form.dart';
import 'pending_submissions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleSubmit(BuildContext context, Map<String, dynamic> form) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form submitted or saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Railway Inspection Forms')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CoachFormScreen(
                      onSubmit: (form) => _handleSubmit(context, form),
                    ),
                  ),
                );
              },
              child: const Text('Train Coach Inspection'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StationFormScreen(
                      onSubmit: (form) => _handleSubmit(context, form),
                    ),
                  ),
                );
              },
              child: const Text('Railway Station Inspection'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Pending Submissions'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PendingSubmissionsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
