// lib/models/user_role.dart
enum UserRole {
  student,
  teacher,
  admin,
  parent,
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
      case UserRole.parent:
        return "Orang Tua";
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
      case UserRole.parent:
        return "parent";
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
      case "parent":
      case "orangtua":
        return UserRole.parent;
      default:
        return UserRole.student;
    }
  }
}
