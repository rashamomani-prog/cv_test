import 'package:cv_test/screens/skills_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/experience_model.dart';
import '../constants.dart';
import 'add_experience_screen.dart';

class WorkExperienceScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeige,
      appBar: AppBar(
        title: Text("Work Experience Overview"),
        backgroundColor: kNavy,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getWorkExperienceStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No experience added yet."));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    ExperienceModel exp = ExperienceModel.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id);

                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Icon(Icons.business, color: kNavy),
                        title: Text(exp.jobTitle ?? "", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${exp.companyName} | ${exp.startDate} - ${exp.isCurrent ? 'Present' : exp.endDate}"),
                        trailing: Icon(Icons.edit, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExperienceScreen()),
              );
            },
            icon: Icon(Icons.add_circle_outline, color: kNavy),
            label: Text("Add another job", style: TextStyle(color: kNavy)),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              side: BorderSide(color: kNavy),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SkillsScreen()),
              );
              },
              child: Text("Next", style: TextStyle(color: kWhite)),
            ),
          ),
        ],
      ),
    );
  }
}