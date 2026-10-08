import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../chat_support/models/chat_support_model.dart'; // To reuse ChatMessageKind, ChatAttachment, ChatOption

class DoctorChatRoom {
  final String id;
  final String customerId;
  final String customerName;
  final String customerProfileImage;
  final String doctorId;
  final String doctorName;
  final String doctorProfileImage;
  final String lastMessage;
  final String lastMessageKind;
  final String lastSenderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorChatRoom({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerProfileImage,
    required this.doctorId,
    required this.doctorName,
    required this.doctorProfileImage,
    required this.lastMessage,
    required this.lastMessageKind,
    required this.lastSenderId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayLastMessage {
    if (lastMessage.isNotEmpty) return lastMessage;

    return switch (lastMessageKind) {
      'image' => 'Photo',
      'video' => 'Video',
      'voice' => 'Voice note',
      'options' => 'Options',
      'typing' => 'Typing...',
      _ => 'Tap to start chat',
    };
  }

  factory DoctorChatRoom.fromDoc(String id, Map<String, dynamic>? data) {
    if (data == null) {
      return DoctorChatRoom(
        id: id,
        customerId: '',
        customerName: '',
        customerProfileImage: '',
        doctorId: '',
        doctorName: '',
        doctorProfileImage: '',
        lastMessage: '',
        lastMessageKind: 'text',
        lastSenderId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    DateTime parseTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return DoctorChatRoom(
      id: id,
      customerId: (data['customerId'] ?? '').toString(),
      customerName: (data['customerName'] ?? '').toString(),
      customerProfileImage: (data['customerProfileImage'] ?? '').toString(),
      doctorId: (data['doctorId'] ?? '').toString(),
      doctorName: (data['doctorName'] ?? '').toString(),
      doctorProfileImage: (data['doctorProfileImage'] ?? '').toString(),
      lastMessage: (data['lastMessage'] ?? '').toString(),
      lastMessageKind: (data['lastMessageKind'] ?? 'text').toString(),
      lastSenderId: (data['lastSenderId'] ?? '').toString(),
      createdAt: parseTime(data['createdAt']),
      updatedAt: parseTime(data['updatedAt']),
    );
  }
}

class DoctorChatMessage {
  final String id;
  final String message;
  final ChatMessageKind kind;
  final String receiverId;
  final String senderId;
  final DateTime createdAt;
  final ChatAttachment? attachment;

  const DoctorChatMessage({
    required this.id,
    required this.message,
    required this.kind,
    required this.receiverId,
    required this.senderId,
    required this.createdAt,
    this.attachment,
  });

  bool isMyMessage(String myUid) => senderId == myUid;
  bool get hasAttachment => attachment != null;

  ChatMessage toChatMessage(String myUid) {
    return ChatMessage(
      id: id,
      sender: isMyMessage(myUid) ? ChatSender.user : ChatSender.agent,
      kind: kind,
      text: message,
      createdAt: createdAt,
      attachment: attachment,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'messageType': kind.name,
      'receiverId': receiverId,
      'senderId': senderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'attachment': attachment?.toMap(),
      'attachmentType': hasAttachment ? kind.name : null,
      'url': attachment?.url,
      'videoThumbnail': attachment?.thumbUrl,
    };
  }

  factory DoctorChatMessage.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];
    DateTime createdAt;
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    final kindRaw = (map['messageType'] ?? map['attachmentType'] ?? 'text')
        .toString();
    final kind = switch (kindRaw) {
      'image' => ChatMessageKind.image,
      'video' => ChatMessageKind.video,
      'voice' => ChatMessageKind.voice,
      'options' => ChatMessageKind.options,
      'typing' => ChatMessageKind.typing,
      _ => ChatMessageKind.text,
    };

    ChatAttachment? attachment;
    final attachmentMap = map['attachment'];
    if (attachmentMap is Map<String, dynamic>) {
      attachment = ChatAttachment.fromMap(attachmentMap);
    } else if ((map['url'] ?? '').toString().isNotEmpty) {
      attachment = ChatAttachment(
        url: (map['url'] ?? '').toString(),
        thumbUrl: map['videoThumbnail']?.toString(),
      );
    }

    return DoctorChatMessage(
      id: (map['id'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      kind: kind,
      receiverId: (map['receiverId'] ?? '').toString(),
      senderId: (map['senderId'] ?? '').toString(),
      createdAt: createdAt,
      attachment: attachment,
    );
  }
}
