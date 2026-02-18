class UserModel {
  String? id;
  String? fullName;
  String? email;
  String? phone;
  String? location;
  String? photoUrl;
  String? experience;
  String? skills;
  String? education;
  String? profileImagePath;
  String? summary;
  String? languages;
  String? jobTitle;
  UserModel({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.location,
    this.photoUrl,
    this.experience,
    this.skills,
    this.education,
    this.profileImagePath,
    this.summary,
    this.languages,
    this.jobTitle
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      fullName: data['fullName'],
      email: data['email'],
      phone: data['phone'],
      location: data['location'],
      photoUrl: data['photoUrl'],
      experience: data['experience'],
      skills: data['skills'],
      education: data['education'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'photoUrl': photoUrl,
      'experience': experience,
      'skills': skills,
      'education': education,
    };
  }
}