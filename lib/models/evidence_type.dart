//lib/models/evidence_type.dart
enum EvidenceType { image, file }

extension EvidenceTypeExt on EvidenceType {
  String get label {
    switch (this) {
      case EvidenceType.image:
        return "Foto";
      case EvidenceType.file:
        return "File";
    }
  }

  static EvidenceType fromString(String str) {
    switch (str.toLowerCase()) {
      case "image":
        return EvidenceType.image;
      case "file":
        return EvidenceType.file;
      default:
        return EvidenceType.image;
    }
  }
}
