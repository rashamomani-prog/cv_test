import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user_model..dart';
import '../providers/cv_provider.dart';
import '../constants.dart';
import 'education_screen.dart';
import '../services/ai_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final jobTitleController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final summaryController = TextEditingController();
  final languagesController = TextEditingController();
  final skillsController = TextEditingController();
  final experienceController = TextEditingController();

  File? _imageFile;
  bool _isLoadingAi = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<CVProvider>(context, listen: false).currentUser;
      if (user != null) {
        nameController.text = user.fullName ?? "";
        jobTitleController.text = user.jobTitle ?? "";
        emailController.text = user.email ?? "";
        phoneController.text = user.phone ?? "";
        locationController.text = user.location ?? "";
        summaryController.text = user.summary ?? "";
        languagesController.text = user.languages ?? "";
        skillsController.text = user.skills ?? "";
        experienceController.text = user.experience ?? "";
        if (user.profileImagePath != null) {
          setState(() {
            _imageFile = File(user.profileImagePath!);
          });
        }
      }
    });
  }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  Future<void> _fetchAiSuggestion(String type) async {
    if (jobTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال المسمى الوظيفي أولاً للحصول على اقتراحات")),
      );
      return;
    }
    print("AI Request -> Job: ${jobTitleController.text}, Type: $type");
    setState(() => _isLoadingAi = true);
    try {
      String result = await AiService.getSuggestions(jobTitleController.text, type);
      print("AI Response -> $result");
      setState(() {
        if (type == 'summary') summaryController.text = result;
        if (type == 'skills') skillsController.text = result;
        if (type == 'exp') experienceController.text = result;
      });
    } catch (e) {
      print("Error in AI Screen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في جلب الاقتراحات: $e")),
      );
    } finally {
      setState(() => _isLoadingAi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeige,
      appBar: AppBar(
        title: const Text("Personal Info & Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: kNavy,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? Icon(Icons.person, size: 55, color: kNavy.withOpacity(0.3))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          backgroundColor: kNavy,
                          radius: 18,
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              _buildSectionTitle("Contact Details"),
              _buildTextField(nameController, "Full Name", Icons.person),
              const SizedBox(height: 10),
              _buildTextField(jobTitleController, "Job Title (e.g. Developer)", Icons.work, color: Colors.blue[50]),
              const SizedBox(height: 10),
              _buildTextField(emailController, "Email Address", Icons.email),
              const SizedBox(height: 10),
              _buildTextField(phoneController, "Phone Number", Icons.phone),
              const SizedBox(height: 10),
              _buildTextField(locationController, "Location (City, Country)", Icons.location_on),

              const SizedBox(height: 25),
              _buildAiHeader("Professional Summary", () => _fetchAiSuggestion('summary')),
              _buildTextField(summaryController, "A brief description of you", Icons.description, maxLines: 3),

              const SizedBox(height: 20),
              _buildSectionTitle("Languages"),
              _buildTextField(languagesController, "e.g. Arabic, English", Icons.language),
              const SizedBox(height: 20),
              _buildAiHeader("Professional Skills", () => _fetchAiSuggestion('skills')),
              _buildTextField(skillsController, "Your technical skills", Icons.star, maxLines: 3),
              const SizedBox(height: 20),

              _buildAiHeader("Work Experience", () => _fetchAiSuggestion('exp')),
              _buildTextField(experienceController, "Previous job responsibilities", Icons.history, maxLines: 4),

              const SizedBox(height: 35),

              if (_isLoadingAi)
                const Center(child: CircularProgressIndicator(color: Colors.purple))
              else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kNavy,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saveData,
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: kNavy),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EducationScreen())),
                  child: Text("Next: Education", style: TextStyle(color: kNavy)),
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      UserModel updatedUser = UserModel(
        fullName: nameController.text,
        jobTitle: jobTitleController.text,
        email: emailController.text,
        phone: phoneController.text,
        location: locationController.text,
        summary: summaryController.text,
        languages: languagesController.text,
        skills: skillsController.text,
        experience: experienceController.text,
        profileImagePath: _imageFile?.path,
      );
      await Provider.of<CVProvider>(context, listen: false).updatePersonalInfo(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved Successfully!")));
    }
  }

  Widget _buildAiHeader(String title, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
          label: const Text("AI Suggest", style: TextStyle(color: Colors.purple, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kNavy)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, Color? color}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kNavy),
        filled: true,
        fillColor: color ?? Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      validator: (val) => val!.isEmpty ? "Required" : null,
    );
  }
}