import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_model..dart';

class PdfService {
  static Future<void> generateAndShareResume(UserModel user) async {
    final pdf = pw.Document();
    final primaryBlack = PdfColor.fromInt(0xFF1A1A1A);
    final accentGold = PdfColor.fromInt(0xFFD4AF37);
    final lightGrey = PdfColor.fromInt(0xFFF9F9F9);
    pw.MemoryImage? profileImage;
    if (user.profileImagePath != null && File(user.profileImagePath!).existsSync()) {
      profileImage = pw.MemoryImage(File(user.profileImagePath!).readAsBytesSync());
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Row(
                children: [
                  pw.Expanded(flex: 2, child: pw.Container(color: PdfColors.white)),
                  pw.Expanded(flex: 1, child: pw.Container(color: lightGrey)),
                ],
              ),
              pw.Column(
                children: [
                  pw.Container(
                    height: 160,
                    child: pw.Stack(
                      alignment: pw.Alignment.topCenter,
                      children: [
                        pw.Container(
                          height: 130,
                          width: double.infinity,
                          decoration: pw.BoxDecoration(
                            color: primaryBlack,
                            borderRadius: const pw.BorderRadius.only(
                              bottomLeft: pw.Radius.circular(100),
                              bottomRight: pw.Radius.circular(100),
                            ),
                          ),
                        ),
                        pw.Positioned(
                          top: 30,
                          child: pw.Column(
                            children: [
                              pw.Text(user.fullName?.toUpperCase() ?? "NAME",
                                  style: pw.TextStyle(fontSize: 22, color: accentGold, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 5),
                              pw.Text(user.jobTitle?.toUpperCase() ?? "PROFESSIONAL",
                                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Transform.translate(
                    offset: const PdfPoint(0, 20),
                    child: pw.Container(
                      width: 90,
                      height: 90,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: PdfColors.white, width: 3),
                        color: PdfColors.grey300,
                        image: profileImage != null
                            ? pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover)
                            : null,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 30),
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 30),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            flex: 2,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildTitleBox("SUMMARY"),
                                pw.Text(user.summary ?? "", style: const pw.TextStyle(fontSize: 10, height: 1.4)),
                                pw.SizedBox(height: 20),
                                _buildTitleBox("EXPERIENCE"),
                                _buildContentText(user.experience, accentGold),
                                pw.SizedBox(height: 20),
                                _buildTitleBox("EDUCATION"),
                                _buildContentText(user.education, accentGold),
                              ],
                            ),
                          ),

                          pw.SizedBox(width: 30),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildRightTitle("CONTACT"),
                                _buildInfoText(user.email, Icons.email),
                                _buildInfoText(user.phone, Icons.phone),
                                _buildInfoText(user.location, Icons.location_on),

                                pw.SizedBox(height: 20),
                                _buildRightTitle("LANGUAGES"),
                                pw.Text(user.languages ?? "", style: const pw.TextStyle(fontSize: 9)),

                                pw.SizedBox(height: 20),
                                _buildRightTitle("SKILLS"),
                                _buildSkillsList(user.skills, accentGold),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Resume_${user.fullName}.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'My Resume');
  }
  static pw.Widget _buildTitleBox(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(5),
      margin: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
      child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
    );
  }

  static pw.Widget _buildRightTitle(String title) {
    return pw.Container(
      width: double.infinity,
      color: PdfColors.black,
      padding: const pw.EdgeInsets.all(4),
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _buildInfoText(String? text, dynamic icon) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(text ?? "", style: const pw.TextStyle(fontSize: 8)),
    );
  }

  static pw.Widget _buildContentText(String? content, PdfColor color) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(width: 2, height: 40, color: color, margin: const pw.EdgeInsets.only(right: 8)),
        pw.Expanded(child: pw.Text(content ?? "", style: const pw.TextStyle(fontSize: 9, height: 1.3))),
      ],
    );
  }

  static pw.Widget _buildSkillsList(String? skills, PdfColor color) {
    if (skills == null) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: skills.split(',').map((s) => pw.Bullet(text: s.trim(), style: const pw.TextStyle(fontSize: 8), bulletColor: color)).toList(),
    );
  }
}