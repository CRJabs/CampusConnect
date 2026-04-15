import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogger {
  static Future<void> log(
    String message, {
    String? source,
    String? targetId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'message': message,
        'source': source,
        'target_id': targetId,
        'metadata': metadata ?? <String, dynamic>{},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Never block primary user actions when activity logging fails.
    }
  }
}
