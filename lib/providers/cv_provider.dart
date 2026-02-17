import 'package:flutter/material.dart';
import '../models/experience_model.dart';
import '../models/user_model..dart';
import '../services/firebase_service.dart';

class CVProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userDataMap = await _firebaseService.getUserData();

      if (userDataMap != null) {
        _currentUser = UserModel.fromMap(userDataMap, _firebaseService.uid);
      }
    } catch (e) {
      print("Error loading user data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
  Future<void> updatePersonalInfo(UserModel user) async {
    try {
      await _firebaseService.saveUserData(user.toMap());
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      print("Error updating info: $e");
    }
  }
  Future<void> addNewExperience(ExperienceModel exp) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.addExperience(exp);
    } catch (e) {
      print("Error adding experience: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}