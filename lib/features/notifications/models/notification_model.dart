import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final Map<String, String> title;
  final Map<String, String> body;
  final Map<String, dynamic> data;
  final String priority;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.priority,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] is Map 
          ? Map<String, String>.from(map['title']) 
          : {'en': map['title']?.toString() ?? '', 'ar': map['title']?.toString() ?? ''},
      body: map['body'] is Map 
          ? Map<String, String>.from(map['body']) 
          : {'en': map['body']?.toString() ?? '', 'ar': map['body']?.toString() ?? ''},
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      priority: map['priority'] ?? 'normal',
      isRead: map['status']?['read'] ?? false,
      readAt: (map['status']?['readAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String getTitle(String langCode) {
    return title[langCode] ?? title.values.firstOrNull ?? '';
  }

  String getBody(String langCode) {
    return body[langCode] ?? body.values.firstOrNull ?? '';
  }
}
