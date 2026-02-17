import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/experience_model.dart';
import '../providers/cv_provider.dart';

class AddExperienceScreen extends StatefulWidget {
  @override
  _AddExperienceScreenState createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeige,
      appBar: AppBar(title: Text("Add Experience"), backgroundColor: kNavy),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _customTextField("Job Title", "e.g. Software Engineer", titleController),
            SizedBox(height: 15),
            _customTextField("Company", "e.g. Google", companyController),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _customTextField("Start Date", "MM/YYYY", startController)),
                SizedBox(width: 10),
                Expanded(child: _customTextField("End Date", "MM/YYYY", endController)),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () async {
                final exp = ExperienceModel(
                  jobTitle: titleController.text,
                  companyName: companyController.text,
                  startDate: startController.text,
                  endDate: endController.text,
                );
                await Provider.of<CVProvider>(context, listen: false).addNewExperience(exp);
                Navigator.pop(context);
              },
              child: Text("Save Experience", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: kNavy)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}