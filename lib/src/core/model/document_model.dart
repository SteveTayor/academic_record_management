import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for dashboard statistics (total documents and weekly retrievals)
  Stream<DocumentSnapshot> getDashboardStats() {
    return _firestore.collection('stats').doc('dashboard').snapshots();
  }

  // Stream for recent document access (last 10 documents)
  Stream<QuerySnapshot> getRecentDocuments() {
    return _firestore
        .collection('documents')
        .orderBy('last_accessed', descending: true)
        .limit(10)
        .snapshots();
  }
}