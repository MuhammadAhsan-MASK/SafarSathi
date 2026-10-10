import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFService {
  static Future<void> generateItineraryPDF({
    required String destination,
    required List<Map<String, dynamic>> activities,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Trip Itinerary: $destination', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            ...activities.map((activity) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(activity['title'] as String, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                        pw.Text(activity['time'] as String, style: const pw.TextStyle(color: PdfColors.grey)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(activity['desc'] as String, style: const pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 5),
                    pw.Text('Cost: PKR ${activity['cost']}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.green)),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'itinerary_$destination.pdf',
    );
  }
}
