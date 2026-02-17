import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/education_model.dart';
import '../models/experience_model.dart';
import '../models/skill_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get uid => _auth.currentUser?.uid ?? "guest_user";
  Future<void> addSkill(SkillModel skill) async {
    await _db.collection('users').doc(uid).collection('skills').add(skill.toMap());
  }

  Stream<QuerySnapshot> getSkillsStream() {
    return _db.collection('users').doc(uid).collection('skills').snapshots();
  }
  Future<void> deleteSkill(String id) async {
    await _db.collection('users').doc(uid).collection('skills').doc(id).delete();
  }
  Future<void> addEducation(EducationModel edu) async {
    await _db.collection('users').doc(uid).collection('education').add(edu.toMap());
  }

  Stream<QuerySnapshot> getEducationStream() {
    return _db.collection('users').doc(uid).collection('education').snapshots();
  }

  Future<void> deleteEducation(String id) async {
    await _db.collection('users').doc(uid).collection('education').doc(id).delete();
  }

  Future<void> addExperience(ExperienceModel exp) async {
    await _db.collection('users').doc(uid).collection('experience').add(exp.toMap());
  }

  Stream<QuerySnapshot> getWorkExperienceStream() {
    return _db.collection('users').doc(uid).collection('experience').snapshots();
  }

  Future<void> deleteExperience(String id) async {
    await _db.collection('users').doc(uid).collection('experience').doc(id).delete();
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    var doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }
}