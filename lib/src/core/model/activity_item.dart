

class ActivityItem {
  final String event;
  final String userOrDocument;
  final DateTime time;
  final bool success;

  ActivityItem({
    required this.event,
    required this.userOrDocument,
    required this.time,
    required this.success,
  });

  /// Example: convert from a Firestore document to ActivityItem.
  /// Adjust the fields to match your Firestore schema.
  factory ActivityItem.fromMap(Map<String, dynamic> map) {
    return ActivityItem(
      event: map['event'] as String,
      userOrDocument: map['userOrDocument'] as String,
      // If stored as a Timestamp, you might convert it:
      time: (map['time'] as DateTime?) ?? DateTime.now(),
      success: map['success'] as bool? ?? false,
    );
  }

  /// Convert this model to a Map for Firestore or JSON.
  Map<String, dynamic> toMap() {
    return {
      'event': event,
      'userOrDocument': userOrDocument,
      'time': time.toIso8601String(), // or store as Timestamp
      'success': success,
    };
  }
}
