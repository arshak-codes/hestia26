import 'package:cloud_firestore/cloud_firestore.dart';

class HighlightItem {
  HighlightItem({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    required this.message,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String mediaUrl;
  final String mediaType;
  final String message;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  bool get isExpired {
    final expiresAt = this.expiresAt;
    if (expiresAt == null) {
      return false;
    }
    return expiresAt.isBefore(DateTime.now());
  }

  bool get isVideo {
    final normalizedType = mediaType.toLowerCase();
    if (normalizedType == 'raw' || normalizedType == 'video') {
      return true;
    }

    final lowerUrl = mediaUrl.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.webm') ||
        lowerUrl.contains('/video/upload/');
  }

  String get relativeCreatedLabel {
    final createdAt = this.createdAt;
    if (createdAt == null) {
      return 'Just now';
    }

    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) {
      return 'Just now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }

  factory HighlightItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return HighlightItem(
      id: doc.id,
      mediaUrl: (data['mediaUrl'] as String?) ?? '',
      mediaType: (data['mediaType'] as String?) ?? '',
      message: (data['message'] as String?) ?? '',
      createdAt: _toDateTime(data['createdAt']),
      expiresAt: _toDateTime(data['expiresAt']),
    );
  }

  static DateTime? _toDateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}
