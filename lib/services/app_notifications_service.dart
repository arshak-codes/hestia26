import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';

class AppNotificationsService {
  AppNotificationsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<AppNotification>> streamNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(AppNotification.fromFirestore)
              .where((notification) =>
                  notification.title.isNotEmpty && !notification.isExpired)
              .toList();
        });
  }
}
