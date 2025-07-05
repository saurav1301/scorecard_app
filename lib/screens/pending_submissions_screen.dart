// 📄 File: lib/screens/pending_submissions_screen.dart

import 'package:flutter/material.dart';
import 'package:scorecard_app/services/offline_queue_service.dart';
import 'dart:convert';

class PendingSubmissionsScreen extends StatefulWidget {
  const PendingSubmissionsScreen({super.key});

  @override
  State<PendingSubmissionsScreen> createState() =>
      _PendingSubmissionsScreenState();
}

class _PendingSubmissionsScreenState extends State<PendingSubmissionsScreen> {
  List<Map<String, dynamic>> _queue = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    final q = await OfflineQueueService.getQueue();
    setState(() {
      _queue = q;
      _loading = false;
    });
  }

  Future<void> _retryAll() async {
    setState(() => _loading = true);
    final failed = await OfflineQueueService.retryQueue();
    setState(() {
      _queue = failed;
      _loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed.isEmpty
              ? 'All submissions sent!'
              : 'Some submissions still failed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Submissions'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _retryAll),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _queue.isEmpty
          ? const Center(child: Text('No pending submissions'))
          : ListView.builder(
              itemCount: _queue.length,
              itemBuilder: (context, index) {
                final item = _queue[index];
                final time = item['timestamp'] ?? 'Unknown';
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Form Type: ${item['type']}'),
                    subtitle: Text('Saved: $time'),
                    trailing: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        try {
                          final res = await OfflineQueueService.retryQueue();
                          setState(() => _queue = res);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Retry failed: $e')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
