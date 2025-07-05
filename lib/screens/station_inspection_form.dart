// 📄 File: lib/screens/station_form_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/offline_queue_service.dart';
import 'package:http/http.dart' as http;
import 'review_screen.dart';

class StationFormScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  const StationFormScreen({super.key, required this.onSubmit});

  @override
  State<StationFormScreen> createState() => _StationFormScreenState();
}

class _StationFormScreenState extends State<StationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {
    'station': '',
    'date': '',
    'section': '',
    'entries': [],
  };

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

  final Map<String, int> scores = {};
  final Map<String, String> remarks = {};

  @override
  void initState() {
    super.initState();
    for (var p in parameters) {
      scores[p] = 0;
      remarks[p] = '';
    }
    _loadDraft();
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = {
      'station': formData['station'],
      'date': formData['date'],
      'section': formData['section'],
      'scores': scores,
      'remarks': remarks,
    };
    await prefs.setString('station_form_draft', jsonEncode(draft));
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('station_form_draft');
    if (draft != null) {
      final data = jsonDecode(draft);
      formData['station'] = data['station'];
      formData['date'] = data['date'];
      formData['section'] = data['section'];
      Map<String, dynamic> loadedScores = Map<String, dynamic>.from(
        data['scores'],
      );
      Map<String, dynamic> loadedRemarks = Map<String, dynamic>.from(
        data['remarks'],
      );
      for (var p in parameters) {
        scores[p] = loadedScores[p];
        remarks[p] = loadedRemarks[p];
      }
      setState(() {});
    }
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('station_form_draft');
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        formData['date'] = picked.toIso8601String().split('T').first;
        _saveDraft();
      });
    }
  }

  void _handleReview() {
    if (_formKey.currentState!.validate()) {
      final form = {
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

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReviewScreen(formData: form)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Inspection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Draft',
            onPressed: () async {
              await _clearDraft();
              setState(() => _loadDraft());
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Station Name'),
              initialValue: formData['station'],
              onChanged: (val) {
                formData['station'] = val;
                _saveDraft();
              },
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formData['date'].isNotEmpty
                        ? 'Date: ${formData['date']}'
                        : 'Select Date',
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectDate,
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Section'),
              initialValue: formData['section'],
              onChanged: (val) {
                formData['section'] = val;
                _saveDraft();
              },
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            ...parameters.map(
              (p) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      DropdownButton<int>(
                        value: scores[p],
                        items: List.generate(
                          11,
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text(i.toString()),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            scores[p] = val!;
                            _saveDraft();
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: remarks[p],
                          onChanged: (val) {
                            remarks[p] = val;
                            _saveDraft();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Remark',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleReview,
              child: const Text('Review & Export'),
            ),
          ],
        ),
      ),
    );
  }
}
