import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatSender { user, agent }

enum ChatMessageKind { text, image, video, voice, options, typing }

class ChatOption {
  final String title;
  final String subtitle;
  final String payload;

  const ChatOption({
    required this.title,
    required this.subtitle,
    required this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'payload': payload,
    };
  }

  factory ChatOption.fromMap(Map<String, dynamic> map) {
    return ChatOption(
      title: (map['title'] ?? '').toString(),
      subtitle: (map['subtitle'] ?? '').toString(),
      payload: (map['payload'] ?? '').toString(),
    );
  }
}

class ChatAttachment {
  final String url;
  final String? thumbUrl;
  final int? durationMs;
  final String? fileName;
  final int? sizeBytes;

  const ChatAttachment({
    required this.url,
    this.thumbUrl,
    this.durationMs,
    this.fileName,
    this.sizeBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'thumbUrl': thumbUrl,
      'durationMs': durationMs,
      'fileName': fileName,
      'sizeBytes': sizeBytes,
    };
  }

  factory ChatAttachment.fromMap(Map<String, dynamic> map) {
    return ChatAttachment(
      url: (map['url'] ?? '').toString(),
      thumbUrl: map['thumbUrl']?.toString(),
      durationMs: (map['durationMs'] as num?)?.toInt(),
      fileName: map['fileName']?.toString(),
      sizeBytes: (map['sizeBytes'] as num?)?.toInt(),
    );
  }
}

class ChatMessage {
  final String id;
  final ChatSender sender;
  final ChatMessageKind kind;
  final String text;
  final DateTime createdAt;
  final ChatAttachment? attachment;
  final List<ChatOption> options;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.kind,
    required this.text,
    required this.createdAt,
    this.attachment,
    this.options = const [],
  });

  bool get isUser => sender == ChatSender.user;
  bool get isAgent => sender == ChatSender.agent;
  bool get hasAttachment => attachment != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender.name,
      'kind': kind.name,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'attachment': attachment?.toMap(),
      'attachmentType': hasAttachment ? kind.name : null,
      'attachmentUrl': attachment?.url,
      'attachmentThumbUrl': attachment?.thumbUrl,
      'attachmentDurationMs': attachment?.durationMs,
      'attachmentFileName': attachment?.fileName,
      'attachmentSizeBytes': attachment?.sizeBytes,
      'options': options.map((e) => e.toMap()).toList(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];

    DateTime createdAt;
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    final kindRaw = (map['kind'] ?? map['attachmentType'] ?? 'text').toString();
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
    } else if ((map['attachmentUrl'] ?? '').toString().isNotEmpty) {
      attachment = ChatAttachment(
        url: (map['attachmentUrl'] ?? '').toString(),
        thumbUrl: map['attachmentThumbUrl']?.toString(),
        durationMs: (map['attachmentDurationMs'] as num?)?.toInt(),
        fileName: map['attachmentFileName']?.toString(),
        sizeBytes: (map['attachmentSizeBytes'] as num?)?.toInt(),
      );
    }

    return ChatMessage(
      id: (map['id'] ?? '').toString(),
      sender: (map['sender'] ?? 'agent').toString() == 'user'
          ? ChatSender.user
          : ChatSender.agent,
      kind: kind,
      text: (map['text'] ?? '').toString(),
      createdAt: createdAt,
      attachment: attachment,
      options: (map['options'] as List? ?? [])
          .map((e) => ChatOption.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class SupportConversationSummary {
  final String uid;
  final String title;
  final String avatarPath;
  final String lastMessage;
  final String lastMessageKind;
  final DateTime? lastMessageAt;

  const SupportConversationSummary({
    required this.uid,
    required this.title,
    required this.avatarPath,
    required this.lastMessage,
    required this.lastMessageKind,
    required this.lastMessageAt,
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

  factory SupportConversationSummary.fromDoc(
    String uid,
    Map<String, dynamic>? data,
  ) {
    final createdAtValue = data?['lastMessageAt'];

    DateTime? lastMessageAt;
    if (createdAtValue is Timestamp) {
      lastMessageAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      lastMessageAt = DateTime.tryParse(createdAtValue);
    }

    return SupportConversationSummary(
      uid: uid,
      title: (data?['title'] ?? 'O2 Clinic').toString(),
      avatarPath: (data?['avatarPath'] ?? 'assets/images/logos/logo.png')
          .toString(),
      lastMessage: (data?['lastMessage'] ?? '').toString(),
      lastMessageKind: (data?['lastMessageKind'] ?? 'text').toString(),
      lastMessageAt: lastMessageAt,
    );
  }
}