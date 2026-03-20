import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/highlight_item.dart';

class HighlightsService {
  HighlightsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<HighlightItem>> streamHighlights() {
    return _firestore
        .collection('highlights')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(HighlightItem.fromFirestore)
              .where((item) => item.mediaUrl.isNotEmpty && !item.isExpired)
              .toList();
        });
  }
}
