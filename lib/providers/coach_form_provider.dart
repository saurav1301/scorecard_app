import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachFormProvider extends ChangeNotifier {
  final List<String> coaches = [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
  ];

  final List<String> parameters = [
    "Condition of Toilet",
    "Availability of Water",
    "Cleanliness of Floor",
    "Odour inside Coach",
    "Dustbins Condition",
  ];

  Map<String, Map<String, int>> scores = {};
  Map<String, Map<String, String>> remarks = {};

  Map<String, String> meta = {
    'Name of Contractor': '',
    'Depot': '',
    'Train No': '',
    'Start Time': '',
    'Completion Time': '',
  };

  CoachFormProvider() {
    initializeForm();
  }

  Future<void> initializeForm() async {
    for (var coach in coaches) {
      scores[coach] = {};
      remarks[coach] = {};
      for (var param in parameters) {
        scores[coach]![param] = 0;
        remarks[coach]![param] = '';
      }
    }
    await loadDraft();
  }

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('coach_form_draft');
    if (draft != null) {
      final data = jsonDecode(draft);
      final loadedMeta = data['meta'] as Map<String, dynamic>;
      meta.addAll(
        loadedMeta.map((key, value) => MapEntry(key, value.toString())),
      );

      final loadedScores = data['scores'] as List<dynamic>;
      for (var item in loadedScores) {
        final coach = item['coach_number'];
        final s = Map<String, dynamic>.from(item['scores']);
        final r = Map<String, dynamic>.from(item['remarks']);
        scores[coach] = s.map((k, v) => MapEntry(k, v as int));
        remarks[coach] = r.map((k, v) => MapEntry(k, v.toString()));
      }
    }
    notifyListeners();
  }

  Future<void> saveDraft() async {
    final draft = {
      'meta': meta,
      'scores': coaches
          .map(
            (c) => {
              'coach_number': c,
              'scores': scores[c],
              'remarks': remarks[c],
            },
          )
          .toList(),
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('coach_form_draft', jsonEncode(draft));
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('coach_form_draft');
    await initializeForm();
    notifyListeners();
  }

  void updateMeta(String key, String value) {
    meta[key] = value;
    saveDraft();
    notifyListeners();
  }

  void updateScore(String coach, String parameter, int score) {
    scores[coach]![parameter] = score;
    saveDraft();
    notifyListeners();
  }

  void updateRemark(String coach, String parameter, String remark) {
    remarks[coach]![parameter] = remark;
    saveDraft();
    notifyListeners();
  }

  void updateTime(String key, String timeValue) {
    meta[key] = timeValue;
    saveDraft();
    notifyListeners();
  }

  Map<String, dynamic> generateForm() {
    return {
      'type': 'coach',
      'timestamp': DateTime.now().toIso8601String(),
      'meta': meta,
      'scores': coaches
          .map(
            (c) => {
              'coach_number': c,
              'scores': scores[c],
              'remarks': remarks[c],
            },
          )
          .toList(),
    };
  }
}
