// 📄 File: lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = 'pending_forms';

  /// Save a form JSON object to the local pending list
  static Future<void> saveForm(Map<String, dynamic> form) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_key) ?? [];
    existing.add(jsonEncode(form));
    await prefs.setStringList(_key, existing);
  }

  /// Retrieve all locally stored forms
  static Future<List<Map<String, dynamic>>> getPendingForms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_key) ?? [];
    return rawList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  /// Clear all saved forms (optional)
  static Future<void> clearAllForms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Delete a specific form (by index)
  static Future<void> deleteFormAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> forms = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < forms.length) {
      forms.removeAt(index);
      await prefs.setStringList(_key, forms);
    }
  }
}
