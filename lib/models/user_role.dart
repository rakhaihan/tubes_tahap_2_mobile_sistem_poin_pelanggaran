// lib/models/user_role.dart
enum UserRole {
  student,
  teacher,
  admin,
}

extension UserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.student:
        return "Murid";
      case UserRole.teacher:
        return "Guru";
      case UserRole.admin:
        return "Admin BK";
    }
  }

  String get raw {
    switch (this) {
      case UserRole.student:
        return "student";
      case UserRole.teacher:
        return "teacher";
      case UserRole.admin:
        return "admin";
    }
  }

  static UserRole fromString(String str) {
    switch (str.toLowerCase()) {
      case "student":
        return UserRole.student;
      case "teacher":
        return UserRole.teacher;
      case "admin":
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}
