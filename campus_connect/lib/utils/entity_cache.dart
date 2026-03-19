import 'package:cloud_firestore/cloud_firestore.dart';

class EntityCache {
  // Stores previously downloaded organization profiles in local memory
  static final Map<String, Map<String, dynamic>> _memoryCache = {};

  static Future<Map<String, dynamic>> getEntityData(String id) async {
    if (_memoryCache.containsKey(id)) return _memoryCache[id]!;

    try {
      var doc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(id)
          .get();
      if (doc.exists && doc.data() != null) {
        _memoryCache[id] = doc.data()!;
        return doc.data()!;
      }

      doc = await FirebaseFirestore.instance
          .collection('departments')
          .doc(id)
          .get();
      if (doc.exists && doc.data() != null) {
        _memoryCache[id] = doc.data()!;
        return doc.data()!;
      }

      doc = await FirebaseFirestore.instance
          .collection('administrations')
          .doc(id)
          .get();
      if (doc.exists && doc.data() != null) {
        _memoryCache[id] = doc.data()!;
        return doc.data()!;
      }
    } catch (e) {
      return {};
    }
    return {};
  }
}
