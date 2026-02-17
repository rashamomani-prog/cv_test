import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model..dart';
import '../providers/cv_provider.dart';
import '../constants.dart';
import 'education_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<CVProvider>(context, listen: false).currentUser;
      if (user != null) {
        nameController.text = user.fullName ?? "";
        emailController.text = user.email ?? "";
        phoneController.text = user.phone ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cvProvider = Provider.of<CVProvider>(context);

    return Scaffold(
      backgroundColor: kBeige,
      appBar: AppBar(
        title: Text(cvProvider.currentUser?.fullName ?? "My CV Project"),
        backgroundColor: kNavy,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(nameController, "Full Name", Icons.person),
              const SizedBox(height: 10),
              _buildTextField(emailController, "Email Address", Icons.email),
              const SizedBox(height: 10),
              _buildTextField(phoneController, "Phone Number", Icons.phone),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    UserModel updatedUser = UserModel(
                      fullName: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                    );

                    await cvProvider.updatePersonalInfo(updatedUser);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data Saved Successfully!")),
                    );
                  }
                },
                child: const Text("Save & Update", style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EducationScreen()));
                },
                child: const Text("Next: Education"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kNavy),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (val) => val!.isEmpty ? "Required" : null,
      onChanged: (val) {
        setState(() {});
      },
    );
  }
}