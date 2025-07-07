import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coach_form_provider.dart';
import 'review_screen.dart';

class CoachFormScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onSubmit;
  const CoachFormScreen({super.key, required this.onSubmit});

  Future<void> _pickTime(BuildContext context, String key) async {
    final provider = Provider.of<CoachFormProvider>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      provider.updateTime(key, picked.format(context));
    }
  }

  void _navigateToReview(BuildContext context) {
    final provider = Provider.of<CoachFormProvider>(context, listen: false);
    final form = provider.generateForm();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReviewScreen(formData: form)),
    );
  }

  Widget _buildCoachSection(BuildContext context, String coach) {
    final provider = Provider.of<CoachFormProvider>(context);
    final scores = provider.scores[coach]!;
    final remarks = provider.remarks[coach]!;
    final parameters = provider.parameters;

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
                      value: scores[param],
                      items: List.generate(
                        11,
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text(i.toString()),
                        ),
                      ),
                      onChanged: (val) {
                        provider.updateScore(coach, param, val!);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: remarks[param],
                        onChanged: (val) =>
                            provider.updateRemark(coach, param, val),
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
    final provider = Provider.of<CoachFormProvider>(context);
    final meta = provider.meta;
    final coaches = provider.coaches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Train Coach Inspection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Draft',
            onPressed: () async {
              await provider.clearDraft();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                onPressed: () => _pickTime(context, key),
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
                      onChanged: (val) => provider.updateMeta(key, val),
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
                ...coaches.map((c) => _buildCoachSection(context, c)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _navigateToReview(context),
                  child: const Text('Review & Export'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
