import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/education_model.dart';
import '../constants.dart';
import 'cv_preview_screen.dart';

class EducationScreen extends StatefulWidget {
  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final institutionController = TextEditingController();
  final degreeController = TextEditingController();
  final yearController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeige,
      appBar: AppBar(title: Text("Education"), backgroundColor: kNavy),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(controller: institutionController, decoration: InputDecoration(labelText: "University/School")),
                    TextField(controller: degreeController, decoration: InputDecoration(labelText: "Degree/Major")),
                    TextField(controller: yearController, decoration: InputDecoration(labelText: "Graduation Year")),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (institutionController.text.isNotEmpty) {
                          await _firebaseService.addEducation(EducationModel(
                            institution: institutionController.text,
                            degree: degreeController.text,
                            endYear: yearController.text,
                          ));
                          institutionController.clear();
                          degreeController.clear();
                          yearController.clear();
                        }
                      },
                      child: Text("Add Education"),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getEducationStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    EducationModel edu = EducationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    return Dismissible(
                      key: Key(edu.id!),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _firebaseService.deleteEducation(edu.id!),
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.school, color: kNavy),
                          title: Text(edu.institution ?? "", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${edu.degree} | ${edu.endYear}"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: kNavy,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CVPreviewScreen()),
                );
              },
              child: const Text(
                "Preview CV",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}