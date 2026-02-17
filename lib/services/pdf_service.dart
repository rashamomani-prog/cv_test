import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_model..dart';

class PdfService {
  static Future<void> generateResume(UserModel user) async {
    final pdf = pw.Document();

    final navyColor = PdfColor.fromInt(0xFF000080);
    final beigeColor = PdfColor.fromInt(0xFFF5F5DC);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            color: beigeColor,
            child: pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  color: navyColor,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        user.fullName ?? "No Name",
                        style: pw.TextStyle(fontSize: 26, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(25),
                  child: pw.Column(
                    children: [
                      _buildSection(navyColor, "EDUCATION", "Your University Name"),
                      pw.SizedBox(height: 15),
                      _buildSection(navyColor, "SKILLS", "Flutter, Firebase, Dart"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
  static pw.Widget _buildSection(PdfColor color, String title, String content) {
    return pw.Column(
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 18, color: color, fontWeight: pw.FontWeight.bold)),
        pw.Divider(color: color, thickness: 1),
        pw.Text(content),
      ],
    );
  }
}