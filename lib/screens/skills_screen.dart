import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/skill_model.dart';
import '../constants.dart';

class SkillsScreen extends StatefulWidget {
  @override
  _SkillsScreenState createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final skillController = TextEditingController();
  double currentRating = 3.0;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeige,
      appBar: AppBar(title: Text("Skills & Proficiency"), backgroundColor: kNavy),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              color: kWhite,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: skillController,
                      decoration: InputDecoration(labelText: "Skill Name (e.g. Flutter)"),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Proficiency: "),
                        Expanded(
                          child: Slider(
                            value: currentRating,
                            min: 1, max: 5, divisions: 4,
                            activeColor: kNavy,
                            label: currentRating.round().toString(),
                            onChanged: (val) => setState(() => currentRating = val),
                          ),
                        ),
                        Text("${currentRating.toInt()}/5"),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (skillController.text.isNotEmpty) {
                          await _firebaseService.addSkill(
                              SkillModel(name: skillController.text, rating: currentRating)
                          );
                          skillController.clear();
                        }
                      },
                      child: Text("Add Skill"),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getSkillsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    SkillModel skill = SkillModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

                    return Dismissible(
                      key: Key(skill.id!),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        await _firebaseService.deleteSkill(skill.id!);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(skill.name ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) => Icon(
                              i < skill.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            )),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}