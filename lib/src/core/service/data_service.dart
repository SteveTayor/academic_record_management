// lib/services/data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/activity_item.dart'; // adjust import path

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch recent activity from Firestore.
  /// For example, from a "activities" collection.
  Future<List<ActivityItem>> fetchRecentActivities() async {
    final querySnapshot = await _firestore
        .collection('activities')
        .orderBy('time', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      // Convert to ActivityItem
      return ActivityItem(
        event: data['event'] ?? 'Unknown',
        userOrDocument: data['userOrDocument'] ?? 'Unknown',
        time: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
        success: data['success'] ?? false,
      );
    }).toList();
  }

  /// Save a new activity in Firestore.
  Future<void> addActivity(ActivityItem item) async {
    await _firestore.collection('activities').add(item.toMap());
  }
}
