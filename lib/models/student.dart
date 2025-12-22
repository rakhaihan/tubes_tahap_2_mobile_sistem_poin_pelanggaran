//lib/models/student.dart
class Student {
  final String id;
  final String name;
  final String kelas;
  final int totalPoints;
  final String parentName;
  final String parentPhone;
  final String parentEmail;

  Student({
    required this.id,
    required this.name,
    required this.kelas,
    required this.totalPoints,
    required this.parentName,
    required this.parentPhone,
    required this.parentEmail,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json["id"],
      name: json["name"],
      kelas: json["kelas"],
      totalPoints: json["totalPoints"] ?? 0,
      parentName: json["parentName"] ?? "",
      parentPhone: json["parentPhone"] ?? "",
      parentEmail: json["parentEmail"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "kelas": kelas,
        "totalPoints": totalPoints,
        "parentName": parentName,
        "parentPhone": parentPhone,
        "parentEmail": parentEmail,
      };
}
