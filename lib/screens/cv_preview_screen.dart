import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model..dart';
import '../services/firebase_service.dart';
import '../services/pdf_service.dart';
import '../constants.dart';

class CVPreviewScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _handleGeneratePdf(BuildContext context) async {
    try {
      Map<String, dynamic>? userData = await _firebaseService.getUserData();
      if (userData == null) return;
      QuerySnapshot skillsSnap = await _firebaseService.getSkillsStream().first;
      String skillsString = skillsSnap.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['name'] ?? "")
          .join(", ");
      QuerySnapshot expSnap = await _firebaseService.getWorkExperienceStream().first;
      String expString = expSnap.docs.map((doc) {
        var d = doc.data() as Map<String, dynamic>;
        return "${d['jobTitle']} في ${d['companyName']} (${d['startDate']} - ${d['endDate']})";
      }).join("\n");
      QuerySnapshot eduSnap = await _firebaseService.getEducationStream().first;
      String eduString = eduSnap.docs.map((doc) {
        var d = doc.data() as Map<String, dynamic>;
        return "${d['degree']} من ${d['institution']} (تخرج: ${d['endYear']})";
      }).join("\n");
      UserModel userModel = UserModel(
        fullName: userData['fullName'],
        email: userData['email'],
        phone: userData['phone'],
        location: userData['location'],
        profileImagePath: userData['profileImagePath'],
        skills: skillsString,
        experience: expString,
        education: eduString,
      );
      await PdfService.generateAndShareResume(userModel);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء تجميع البيانات: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeige,
      appBar: AppBar(
        title: const Text("Final CV Preview"),
        backgroundColor: kNavy,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _handleGeneratePdf(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: _firebaseService.getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                if (!snapshot.hasData || snapshot.data == null) return const Center(child: Text("No info found"));

                var user = snapshot.data!;
                return Column(
                  children: [
                    if (user['profileImagePath'] != null && File(user['profileImagePath']).existsSync())
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(File(user['profileImagePath'])),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(user['fullName'] ?? "Your Name",
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kNavy)),
                    ),
                    Center(
                      child: Text("${user['email'] ?? ''} | ${user['phone'] ?? ''}",
                          style: const TextStyle(color: Colors.black54)),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: kNavy, thickness: 2),
                  ],
                );
              },
            ),
            _sectionTitle("EXPERIENCE"),
            _buildExperienceStream(),
            _sectionTitle("EDUCATION"),
            _buildEducationStream(),
            _sectionTitle("SKILLS"),
            _buildSkillsStream(),
          ],
        ),
      ),
    );
  }
  Widget _buildExperienceStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseService.getWorkExperienceStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return Column(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(data['jobTitle'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${data['companyName'] ?? ''}\n${data['startDate'] ?? ''} - ${data['endDate'] ?? ''}"),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSkillsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseService.getSkillsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return Wrap(
          spacing: 10,
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Chip(label: Text(data['name'] ?? ""), backgroundColor: kNavy, labelStyle: TextStyle(color: Colors.white));
          }).toList(),
        );
      },
    );
  }

  Widget _buildEducationStream() { return SizedBox(); }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kNavy, fontSize: 20)),
        const Divider(color: kNavy, thickness: 1.5),
      ],
    );
  }
}