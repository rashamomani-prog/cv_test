class UserModel {
  String? id;
  String? fullName;
  String? email;
  String? phone;
  String? location;
  String? photoUrl;
  UserModel({this.id, this.fullName, this.email, this.phone, this.location, this.photoUrl});
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      fullName: data['fullName'],
      email: data['email'],
      phone: data['phone'],
      location: data['location'],
      photoUrl: data['photoUrl'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'photoUrl': photoUrl,
    };
  }
}