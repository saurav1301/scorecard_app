// 📄 File: lib/screens/review_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../services/offline_queue_service.dart';
import 'package:open_filex/open_filex.dart';

class ReviewScreen extends StatefulWidget {
  final Map<String, dynamic> formData;

  const ReviewScreen({super.key, required this.formData});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  Future<void> _exportPdf() async {
    final File pdfFile = await PDFService.generatePdf(widget.formData);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated. Opening...')),
      );
      await OpenFilex.open(pdfFile.path);
    }
  }

  Future<void> _submitToApi() async {
    const endpoint = 'https://httpbin.org/post';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(widget.formData),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Form submitted to server.')),
          );
        }
      } else {
        throw Exception('Failed to submit.');
      }
    } catch (e) {
      // On failure (likely due to no internet), save to offline queue
      await OfflineQueueService.addToQueue(widget.formData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet. Saved to pending queue.')),
        );
      }
    }
  }

  Widget _buildMetaSection(Map<String, dynamic> meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: meta.entries.map((e) {
        final value = (e.value ?? '').toString();
        return Text('${e.key}: ${value.isNotEmpty ? value : "Not provided"}');
      }).toList(),
    );
  }

  Widget _buildStationTable(List<dynamic> scores) {
    List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(color: Colors.grey.shade300),
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Parameter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Remark',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      ...scores.map(
        (e) => TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(e['parameter'] ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text((e['score'] ?? '').toString()),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(e['remark'] ?? ''),
            ),
          ],
        ),
      ),
    ];

    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: rows,
    );
  }

  Widget _buildCoachTable(List<dynamic> scores) {
    final parameters = [
      "Condition of Toilet",
      "Availability of Water",
      "Cleanliness of Floor",
      "Odour inside Coach",
      "Dustbins Condition",
    ];

    List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(color: Colors.grey.shade300),
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Coach', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...parameters.map(
            (p) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                p,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      ...scores.expand((entry) {
        final coach = entry['coach_number'] ?? 'Unknown';
        final scoreMap = entry['scores'] as Map<String, dynamic>;
        final remarkMap = entry['remarks'] as Map<String, dynamic>;

        return [
          TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(8.0), child: Text(coach)),
              ...parameters.map(
                (p) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(scoreMap[p]?.toString() ?? ''),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Remarks'),
              ),
              ...parameters.map(
                (p) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(remarkMap[p]?.toString() ?? ''),
                ),
              ),
            ],
          ),
        ];
      }),
    ];

    return Table(
      border: TableBorder.all(color: Colors.grey),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  Widget _buildScoresSection(List<dynamic> scores, String type) {
    if (type == 'station') {
      return _buildStationTable(scores);
    } else if (type == 'coach') {
      return _buildCoachTable(scores);
    }
    return const Text('No scores to display.');
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.formData['meta'] as Map<String, dynamic>;
    final type = widget.formData['type'];
    final timestamp = widget.formData['timestamp'];
    final scores = widget.formData['scores'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Submission')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Type: ${type.toString().toUpperCase()}'),
            Text('Saved on: ${DateTime.parse(timestamp).toLocal()}'),
            const SizedBox(height: 12),
            const Text(
              'Metadata:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildMetaSection(meta),
            const SizedBox(height: 12),
            const Text(
              'Scores & Remarks:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildScoresSection(scores, type),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitToApi,
              icon: const Icon(Icons.send),
              label: const Text('Submit to Server'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _exportPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export as PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
