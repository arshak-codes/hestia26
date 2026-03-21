import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/schedule_event.dart';

class ScheduleService {
  ScheduleService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _scheduleCollection =>
      _firestore.collection('schedule');

  Stream<List<String>> streamScheduleDays() {
    return _scheduleCollection.snapshots().map((snapshot) {
      final days =
          snapshot.docs.map((doc) => doc.id.trim()).where((day) => day.isNotEmpty).toList();

      days.sort(_compareDayKeys);
      return days;
    });
  }

  Stream<List<ScheduleEvent>> streamEventsForDay(String dayId) {
    return _scheduleCollection
        .doc(dayId)
        .collection('events')
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs.map(ScheduleEvent.fromFirestore).toList();
          events.sort((left, right) => left.order.compareTo(right.order));
          return events;
        });
  }

  static int _compareDayKeys(String left, String right) {
    final leftDate = _parseDayKey(left);
    final rightDate = _parseDayKey(right);

    if (leftDate != null && rightDate != null) {
      return leftDate.compareTo(rightDate);
    }
    if (leftDate != null) {
      return -1;
    }
    if (rightDate != null) {
      return 1;
    }
    return left.compareTo(right);
  }

  static DateTime? _parseDayKey(String value) {
    final normalized = value.trim().toLowerCase();
    final match = RegExp(r'^([a-z]{3})(\d{1,2})$').firstMatch(normalized);
    if (match == null) {
      return null;
    }

    const monthMap = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    final month = monthMap[match.group(1)];
    final day = int.tryParse(match.group(2) ?? '');
    if (month == null || day == null) {
      return null;
    }

    return DateTime(DateTime.now().year, month, day);
  }
}
