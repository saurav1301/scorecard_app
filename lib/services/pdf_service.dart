// 📄 File: lib/services/pdf_service.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PDFService {
  static Future<File> generatePdf(Map<String, dynamic> form) async {
    final pdf = pw.Document();

    final meta = form['meta'] as Map<String, dynamic>;
    final type = form['type'];
    final scores = form['scores'] as List;
    final timestamp = form['timestamp'];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Text(
            'Inspection Scorecard - ${type.toUpperCase()}',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Timestamp: $timestamp'),
          pw.SizedBox(height: 10),
          pw.Text(
            'Metadata:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ...meta.entries.map((e) => pw.Text('${e.key}: ${e.value}')),
          pw.SizedBox(height: 10),
          if (type == 'coach')
            _buildCoachPdfTable(scores)
          else
            _buildStationPdfTable(scores),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/scorecard_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildStationPdfTable(List scores) {
    final headers = ['Parameter', 'Score', 'Remark'];
    final dataRows = scores
        .map((e) => [e['parameter'], e['score'].toString(), e['remark'] ?? ''])
        .toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: dataRows,
      border: pw.TableBorder.all(),
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  static pw.Widget _buildCoachPdfTable(List scores) {
    final parameters = [
      "Condition of Toilet",
      "Availability of Water",
      "Cleanliness of Floor",
      "Odour inside Coach",
      "Dustbins Condition",
    ];

    final coachHeaders = scores.map((entry) {
      final coachMap = entry as Map<String, dynamic>;
      return (coachMap['coach_number'] ?? 'Unknown').toString();
    }).toList();

    final tableHeaders = ['Parameter'] + coachHeaders;

    final rows = <List<String>>[];
    for (var param in parameters) {
      final scoreRow = <String>['$param (Score)'];
      final remarkRow = <String>['$param (Remark)'];

      for (var coach in scores) {
        final coachMap = coach as Map<String, dynamic>;
        final score =
            (coachMap['scores'] as Map<String, dynamic>)[param]?.toString() ??
            '';
        final remark =
            (coachMap['remarks'] as Map<String, dynamic>)[param]?.toString() ??
            '';
        scoreRow.add(score);
        remarkRow.add(remark);
      }

      rows.add(scoreRow);
      rows.add(remarkRow);
    }

    return pw.Table.fromTextArray(
      headers: tableHeaders,
      data: rows,
      border: pw.TableBorder.all(),
      cellAlignment: pw.Alignment.center,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellPadding: const pw.EdgeInsets.all(6),
      columnWidths: {0: const pw.FixedColumnWidth(150)},
    );
  }
}
