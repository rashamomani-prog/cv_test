class SkillModel {
  String? id;
  String? name;
  double rating; // من 1.0 إلى 5.0

  SkillModel({this.id, this.name, this.rating = 3.0});

  factory SkillModel.fromMap(Map<String, dynamic> data, String documentId) {
    return SkillModel(
      id: documentId,
      name: data['name'],
      rating: (data['rating'] ?? 3.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
    };
  }
}