// 📄 File: lib/services/offline_queue_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OfflineQueueService {
  static const _key = 'offline_queue';

  /// Add a failed form to local queue
  static Future<void> addToQueue(Map<String, dynamic> form) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final List<Map<String, dynamic>> queue = raw != null
        ? List<Map<String, dynamic>>.from(jsonDecode(raw))
        : [];
    queue.add(form);
    await prefs.setString(_key, jsonEncode(queue));
  }

  /// Get all pending submissions
  static Future<List<Map<String, dynamic>>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  /// Clear queue (or update it after successful retry)
  static Future<void> saveQueue(List<Map<String, dynamic>> queue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(queue));
  }

  /// Retry all queued submissions
  static Future<List<Map<String, dynamic>>> retryQueue() async {
    final queue = await getQueue();
    final List<Map<String, dynamic>> stillFailed = [];

    for (var form in queue) {
      try {
        final res = await http.post(
          Uri.parse('https://httpbin.org/post'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(form),
        );
        if (res.statusCode != 200) {
          stillFailed.add(form);
        }
      } catch (_) {
        stillFailed.add(form);
      }
    }

    await saveQueue(stillFailed);
    return stillFailed;
  }

  /// Clear everything manually
  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
