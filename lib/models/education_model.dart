class EducationModel {
  String? id;
  String? institution;
  String? degree;
  String? endYear;

  EducationModel({this.id, this.institution, this.degree, this.endYear});

  factory EducationModel.fromMap(Map<String, dynamic> data, String documentId) {
    return EducationModel(
      id: documentId,
      institution: data['institution'],
      degree: data['degree'],
      endYear: data['endYear'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'institution': institution,
      'degree': degree,
      'endYear': endYear,
    };
  }
}