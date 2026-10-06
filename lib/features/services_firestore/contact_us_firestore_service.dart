import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_paths.dart';
import 'models/contact_us_model.dart';

class ContactUsFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ContactUsModel?> getContactUsData() async {
    try {
      final docSnapshot = await _firestore
          .collection(FirestorePaths.appConstants)
          .doc('ContactUs')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return ContactUsModel.fromMap(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<ContactUsModel?> watchContactUsData() {
    return _firestore
        .collection(FirestorePaths.appConstants)
        .doc('ContactUs')
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return ContactUsModel.fromMap(snapshot.data()!);
          }
          return null;
        });
  }
}
