import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sanction.dart';

class SanctionService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('sanctions');

  /// Stream seluruh data sanksi, diurutkan berdasarkan minPoin.
  Stream<List<Sanction>> streamSanctions() {
    return _col.orderBy('minPoin').snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Sanction.fromJson(data);
      }).toList();
    });
  }

  Future<void> addSanction(Sanction s) async {
    await _col.add({
      'tingkat': s.tingkat,
      'keterangan': s.keterangan,
      'minPoin': s.minPoin,
      'maxPoin': s.maxPoin,
    });
  }

  Future<void> updateSanction(Sanction s) async {
    if (s.id == null) return;
    await _col.doc(s.id.toString()).update({
      'tingkat': s.tingkat,
      'keterangan': s.keterangan,
      'minPoin': s.minPoin,
      'maxPoin': s.maxPoin,
    });
  }

  Future<void> deleteSanction(String id) async {
    await _col.doc(id).delete();
  }
}




