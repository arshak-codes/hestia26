import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/slider_image.dart';

class SliderService {
  SliderService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<SliderImage>> streamSliders() {
    return _firestore.collection('sliders').snapshots().map((snapshot) {
      return snapshot.docs
          .map(SliderImage.fromFirestore)
          .where((item) => item.link.isNotEmpty)
          .toList();
    });
  }
}
