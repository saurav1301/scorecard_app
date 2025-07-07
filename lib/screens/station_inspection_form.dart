import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/station_form_provider.dart';
import 'review_screen.dart';

class StationFormScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onSubmit;
  const StationFormScreen({super.key, required this.onSubmit});

  void _handleReview(BuildContext context) {
    final provider = Provider.of<StationFormProvider>(context, listen: false);
    final form = provider.generateForm();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReviewScreen(formData: form)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StationFormProvider>(context);
    final form = provider.formData;
    final params = provider.parameters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Inspection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Draft',
            onPressed: () => provider.clearDraft(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Station Name'),
            initialValue: form['station'],
            onChanged: (val) => provider.updateField('station', val),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  form['date'].isNotEmpty
                      ? 'Date: ${form['date']}'
                      : 'Select Date',
                ),
              ),
              ElevatedButton(
                onPressed: () => provider.updateDate(context),
                child: const Text('Pick Date'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Section'),
            initialValue: form['section'],
            onChanged: (val) => provider.updateField('section', val),
          ),
          const SizedBox(height: 16),
          ...params.map(
            (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    DropdownButton<int>(
                      value: provider.scores[p],
                      items: List.generate(
                        11,
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text(i.toString()),
                        ),
                      ),
                      onChanged: (val) => provider.updateScore(p, val!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: provider.remarks[p],
                        onChanged: (val) => provider.updateRemark(p, val),
                        decoration: const InputDecoration(labelText: 'Remark'),
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
            onPressed: () => _handleReview(context),
            child: const Text('Review & Export'),
          ),
        ],
      ),
    );
  }
}
