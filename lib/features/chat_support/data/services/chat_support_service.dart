import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../data/models/chat_support_model.dart';

class SupportChatService {
  SupportChatService._();
  static final instance = SupportChatService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _messagesRef(String uid) {
    return _firestore
        .collection('support_chats')
        .doc(uid)
        .collection('messages');
  }

  DocumentReference<Map<String, dynamic>> _chatRef(String uid) {
    return _firestore.collection('support_chats').doc(uid);
  }

  Future<void> ensureConversation(String uid) async {
    final chatDoc = await _chatRef(uid).get();
    final messages = await _messagesRef(uid).limit(1).get();

    if (chatDoc.exists && messages.docs.isNotEmpty) return;

    final now = DateTime.now();

    if (!chatDoc.exists) {
      await _chatRef(uid).set({
        'uid': uid,
        'title': 'O2 Clinic',
        'avatarPath': 'assets/images/logos/logo.png',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'lastMessage': '__WELCOME_MESSAGE_SHORT__',
        'lastMessageKind': 'text',
        'lastMessageAt': Timestamp.fromDate(now),
        'lastSender': 'agent',
      }, SetOptions(merge: true));
    }

    if (messages.docs.isEmpty) {
      final welcome = ChatMessage(
        id: _id(),
        sender: ChatSender.agent,
        kind: ChatMessageKind.text,
        text: '__WELCOME_MESSAGE_FULL__',
        createdAt: now,
      );

      await _messagesRef(uid).doc(welcome.id).set(welcome.toMap());

      await _chatRef(uid).set({
        'uid': uid,
        'title': 'O2 Clinic',
        'avatarPath': 'assets/images/logos/logo.png',
        'updatedAt': Timestamp.fromDate(now),
        'lastMessage': welcome.text,
        'lastMessageKind': 'text',
        'lastMessageAt': Timestamp.fromDate(now),
        'lastSender': 'agent',
      }, SetOptions(merge: true));
    }
  }

  Stream<List<ChatMessage>> watchMessages(String uid) {
    return _messagesRef(uid)
        .orderBy('createdAt')
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) =>
              snap.docs.map((e) => ChatMessage.fromMap(e.data())).toList(),
        );
  }

  Stream<SupportConversationSummary> watchSummary(String uid) {
    return _chatRef(uid).snapshots().map((doc) {
      return SupportConversationSummary.fromDoc(uid, doc.data());
    });
  }

  Future<void> sendUserTextMessage({
    required String uid,
    required String text,
    ChatReplyInfo? replyTo,
  }) async {
    final now = DateTime.now();

    final message = ChatMessage(
      id: _id(),
      sender: ChatSender.user,
      kind: ChatMessageKind.text,
      text: text,
      createdAt: now,
      replyTo: replyTo,
    );

    final batch = _firestore.batch();

    batch.set(_messagesRef(uid).doc(message.id), message.toMap());

    batch.set(_chatRef(uid), {
      'uid': uid,
      'title': 'O2 Clinic',
      'avatarPath': 'assets/images/logos/logo.png',
      'updatedAt': Timestamp.fromDate(now),
      'lastMessage': text,
      'lastMessageKind': 'text',
      'lastMessageAt': Timestamp.fromDate(now),
      'lastSender': 'user',
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> sendUserAttachmentMessage({
    required String uid,
    required String localPath,
    required ChatMessageKind kind,
    String? fileName,
    String? caption,
    int? durationMs,
    Uint8List? bytes,
  }) async {
    final now = DateTime.now();
    final downloadUrl = await _uploadMedia(
      uid: uid,
      localPath: localPath,
      kind: kind,
      bytes: bytes,
    );

    final safeFileName =
        fileName ??
        (kIsWeb
            ? localPath.split('/').last
            : localPath.split(Platform.pathSeparator).last);

    final message = ChatMessage(
      id: _id(),
      sender: ChatSender.user,
      kind: kind,
      text: (caption ?? '').trim(),
      createdAt: now,
      attachment: ChatAttachment(
        url: downloadUrl,
        fileName: safeFileName,
        durationMs: durationMs,
      ),
    );

    final batch = _firestore.batch();

    batch.set(_messagesRef(uid).doc(message.id), message.toMap());

    batch.set(_chatRef(uid), {
      'uid': uid,
      'title': 'O2 Clinic',
      'avatarPath': 'assets/images/logos/logo.png',
      'updatedAt': Timestamp.fromDate(now),
      'lastMessage': _buildLastMessageLabel(kind: kind, caption: caption),
      'lastMessageKind': kind.name,
      'lastMessageAt': Timestamp.fromDate(now),
      'lastSender': 'user',
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<String> _uploadMedia({
    required String uid,
    required String localPath,
    required ChatMessageKind kind,
    Uint8List? bytes,
  }) async {
    final ext = _extensionOf(localPath);
    final fileName = '${DateTime.now().microsecondsSinceEpoch}$ext';
    final folder = switch (kind) {
      ChatMessageKind.image => 'images',
      ChatMessageKind.video => 'videos',
      ChatMessageKind.voice => 'voices',
      _ => 'files',
    };

    final ref = _storage.ref('support_chats/$uid/$folder/$fileName');

    if (kIsWeb && bytes != null) {
      final task = await ref.putData(bytes);
      return task.ref.getDownloadURL();
    } else {
      final file = File(localPath);
      final task = await ref.putFile(file);
      return task.ref.getDownloadURL();
    }
  }

  String _buildLastMessageLabel({
    required ChatMessageKind kind,
    String? caption,
  }) {
    final cleanCaption = (caption ?? '').trim();
    if (cleanCaption.isNotEmpty) return cleanCaption;

    return switch (kind) {
      ChatMessageKind.image => '__ATTACHMENT_PHOTO__',
      ChatMessageKind.video => '__ATTACHMENT_VIDEO__',
      ChatMessageKind.voice => '__ATTACHMENT_VOICE__',
      _ => '__ATTACHMENT_MESSAGE__',
    };
  }

  String _extensionOf(String path) {
    final index = path.lastIndexOf('.');
    if (index == -1) return '';
    return path.substring(index);
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
}
