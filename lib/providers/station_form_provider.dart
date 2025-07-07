import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StationFormProvider extends ChangeNotifier {
  final List<String> parameters = [
    'Cleanliness of Platform Surface',
    'Dustbins Availability & Condition',
    'Condition of Toilets/Urinals',
    'Water Booth Functionality',
    'Condition of Waiting Room',
    'Condition of Seating Arrangements',
    'Lighting & Electrical Fittings',
    'Overall Cleanliness',
  ];

  final Map<String, dynamic> formData = {
    'station': '',
    'date': '',
    'section': '',
  };

  final Map<String, int> scores = {};
  final Map<String, String> remarks = {};

  StationFormProvider() {
    for (var p in parameters) {
      scores[p] = 0;
      remarks[p] = '';
    }
    _loadDraft();
  }

  void updateField(String key, String value) {
    formData[key] = value;
    _saveDraft();
    notifyListeners();
  }

  void updateScore(String parameter, int value) {
    scores[parameter] = value;
    _saveDraft();
    notifyListeners();
  }

  void updateRemark(String parameter, String value) {
    remarks[parameter] = value;
    _saveDraft();
    notifyListeners();
  }

  Future<void> updateDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      formData['date'] = picked.toIso8601String().split('T').first;
      _saveDraft();
      notifyListeners();
    }
  }

  Map<String, dynamic> generateForm() {
    return {
      'type': 'station',
      'timestamp': DateTime.now().toIso8601String(),
      'meta': {
        'Station Name': formData['station'],
        'Date': formData['date'],
        'Section': formData['section'],
      },
      'scores': parameters
          .map(
            (p) => {'parameter': p, 'score': scores[p], 'remark': remarks[p]},
          )
          .toList(),
    };
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = {...formData, 'scores': scores, 'remarks': remarks};
    await prefs.setString('station_form_draft', jsonEncode(draft));
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('station_form_draft');
    if (draft != null) {
      final data = jsonDecode(draft);
      formData['station'] = data['station'] ?? '';
      formData['date'] = data['date'] ?? '';
      formData['section'] = data['section'] ?? '';
      final loadedScores = Map<String, dynamic>.from(data['scores']);
      final loadedRemarks = Map<String, dynamic>.from(data['remarks']);
      for (var p in parameters) {
        scores[p] = loadedScores[p] ?? 0;
        remarks[p] = loadedRemarks[p] ?? '';
      }
      notifyListeners();
    }
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('station_form_draft');
    for (var key in formData.keys) {
      formData[key] = '';
    }
    for (var p in parameters) {
      scores[p] = 0;
      remarks[p] = '';
    }
    notifyListeners();
  }
}
