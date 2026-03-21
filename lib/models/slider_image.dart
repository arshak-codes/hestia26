import 'package:cloud_firestore/cloud_firestore.dart';

class SliderImage {
  SliderImage({required this.id, required this.link});

  final String id;
  final String link;

  factory SliderImage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return SliderImage(
      id: doc.id,
      link: (data['link'] as String?)?.trim() ?? '',
    );
  }
}
