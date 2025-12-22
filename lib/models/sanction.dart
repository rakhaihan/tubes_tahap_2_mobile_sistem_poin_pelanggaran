//lib/models/sanction.dart
class Sanction {
  /// id disamakan dengan document ID di Firestore (string)
  final String? id;
  final String tingkat;
  final String keterangan;
  final int minPoin;
  final int maxPoin;

  Sanction({
    this.id,
    required this.tingkat,
    required this.keterangan,
    required this.minPoin,
    required this.maxPoin,
  });

  Sanction copyWith({
    String? id,
    String? tingkat,
    String? keterangan,
    int? minPoin,
    int? maxPoin,
  }) {
    return Sanction(
      id: id ?? this.id,
      tingkat: tingkat ?? this.tingkat,
      keterangan: keterangan ?? this.keterangan,
      minPoin: minPoin ?? this.minPoin,
      maxPoin: maxPoin ?? this.maxPoin,
    );
  }

  factory Sanction.fromJson(Map<String, dynamic> json) {
    return Sanction(
      id: json['id']?.toString(),
      tingkat: json['tingkat']?.toString() ?? '',
      keterangan: json['keterangan']?.toString() ?? '',
      minPoin: (json['minPoin'] as num?)?.toInt() ?? 0,
      maxPoin: (json['maxPoin'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tingkat': tingkat,
        'keterangan': keterangan,
        'minPoin': minPoin,
        'maxPoin': maxPoin,
      };
}
