// 📄 File: lib/screens/coach_form_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/offline_queue_service.dart';
import 'package:http/http.dart' as http;
import 'review_screen.dart';

class CoachFormScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  const CoachFormScreen({super.key, required this.onSubmit});

  @override
  State<CoachFormScreen> createState() => _CoachFormScreenState();
}

class _CoachFormScreenState extends State<CoachFormScreen> {
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

  final Map<String, Map<String, int>> scores = {};
  final Map<String, Map<String, String>> remarks = {};

  final _formKey = GlobalKey<FormState>();
  final Map<String, String> meta = {
    'Name of Contractor': '',
    'Depot': '',
    'Train No': '',
    'Start Time': '',
    'Completion Time': '',
  };

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    for (var coach in coaches) {
      scores[coach] = {};
      remarks[coach] = {};
      for (var param in parameters) {
        scores[coach]![param] = 0;
        remarks[coach]![param] = '';
      }
    }
    await _loadDraft();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('coach_form_draft');
    if (draft != null) {
      final data = jsonDecode(draft);
      if (data is Map<String, dynamic>) {
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
        setState(() {});
      }
    }
  }

  Future<void> _saveDraft() async {
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

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('coach_form_draft');
  }

  void _navigateToReview() {
    if (_formKey.currentState!.validate()) {
      final form = {
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReviewScreen(formData: form)),
      );
    }
  }

  Future<void> _pickTime(String key) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        meta[key] = picked.format(context);
        _saveDraft();
      });
    }
  }

  Widget _buildCoachSection(String coach) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Text('Coach $coach'),
        children: parameters.map((param) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  param,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    DropdownButton<int>(
                      value: scores[coach]![param],
                      items: List.generate(
                        11,
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text(i.toString()),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          scores[coach]![param] = val!;
                          _saveDraft();
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: remarks[coach]![param],
                        onChanged: (val) {
                          remarks[coach]![param] = val;
                          _saveDraft();
                        },
                        decoration: const InputDecoration(labelText: 'Remark'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Train Coach Inspection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Draft',
            onPressed: () async {
              await _clearDraft();
              await _initializeForm();
              setState(() {});
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...meta.keys.map((key) {
              if (key == 'Start Time' || key == 'Completion Time') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (meta[key] ?? '').isNotEmpty
                                  ? meta[key]!
                                  : 'Not selected',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _pickTime(key),
                            child: const Text('Pick Time'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return TextFormField(
                  decoration: InputDecoration(labelText: key),
                  initialValue: meta[key],
                  onChanged: (val) {
                    meta[key] = val;
                    _saveDraft();
                  },
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                );
              }
            }),
            const SizedBox(height: 16),
            const Text(
              'Coach Scores & Remarks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...coaches.map((c) => _buildCoachSection(c)).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToReview,
              child: const Text('Review & Export'),
            ),
          ],
        ),
      ),
    );
  }
}
