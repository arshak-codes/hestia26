import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleEvent {
  ScheduleEvent({
    required this.id,
    required this.name,
    required this.stage,
    required this.time,
    required this.order,
  });

  final String id;
  final String name;
  final String stage;
  final String time;
  final int order;

  factory ScheduleEvent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ScheduleEvent(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      stage: (data['stage'] as String?) ?? '',
      time: (data['time'] as String?) ?? '',
      order: _parseOrder(data['order']),
    );
  }

  static int _parseOrder(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
