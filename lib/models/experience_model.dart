class ExperienceModel {
  String? id;
  String? jobTitle;
  String? companyName;
  String? location;
  String? startDate;
  String? endDate;
  bool isCurrent;

  ExperienceModel({
    this.id,
    this.jobTitle,
    this.companyName,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ExperienceModel(
      id: documentId,
      jobTitle: data['jobTitle'],
      companyName: data['companyName'],
      location: data['location'],
      startDate: data['startDate'],
      endDate: data['endDate'],
      isCurrent: data['isCurrent'] ?? false,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'jobTitle': jobTitle,
      'companyName': companyName,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'isCurrent': isCurrent,
    };
  }
}