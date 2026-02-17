import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user_model..dart';
import '../services/firebase_service.dart';
import '../services/pdf_service.dart';
import '../providers/cv_provider.dart';
import '../constants.dart';

class CVPreviewScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeige,
      appBar: AppBar(
        title: const Text("Final CV Preview"),
        backgroundColor: kNavy,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () async {
              Map<String, dynamic>? userData = await _firebaseService.getUserData();

              if (userData != null) {
                UserModel userModel = UserModel(
                  fullName: userData['fullName'],
                  email: userData['email'],
                  phone: userData['phone'],
                );
                PdfService.generateResume(userModel);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No data found to generate PDF")),
                );
              }
            },
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

            const SizedBox(height: 20),
            _sectionTitle("EXPERIENCE"),
            StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getWorkExperienceStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(data['jobTitle'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      subtitle: Text("${data['companyName'] ?? ''}\n${data['startDate'] ?? ''} - ${data['endDate'] ?? ''}"),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 10),
            _sectionTitle("EDUCATION"),
            StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getEducationStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(data['institution'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${data['degree'] ?? ''} | ${data['endYear'] ?? ''}"),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 10),
            _sectionTitle("SKILLS"),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getSkillsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kNavy,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(data['name'] ?? "", style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
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