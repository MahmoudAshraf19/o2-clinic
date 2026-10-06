import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_support_model.dart';

class RadiologyChatService {
  RadiologyChatService._();
  static final instance = RadiologyChatService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String collectionPath = 'radiology_price_inquiries';

  CollectionReference<Map<String, dynamic>> _messagesRef(String bookingId) {
    return _firestore
        .collection(collectionPath)
        .doc(bookingId)
        .collection('messages');
  }

  DocumentReference<Map<String, dynamic>> _chatRef(String bookingId) {
    return _firestore.collection(collectionPath).doc(bookingId);
  }

  Future<void> ensureConversation(
    String uid,
    String bookingId,
    String serviceName, {
    String? defaultWelcomeMessage,
  }) async {
    final chatDoc = await _chatRef(bookingId).get();
    final messages = await _messagesRef(bookingId).limit(1).get();

    if (chatDoc.exists && messages.docs.isNotEmpty) return;

    final now = DateTime.now();
    final welcomeMessage =
        defaultWelcomeMessage ??
        'اهلا بيك  قم بارفاق صورة روشتة الاشعة\nاو تفاصيل اشعة لتحديد السعر';

    if (!chatDoc.exists) {
      await _chatRef(bookingId).set({
        'uid': uid,
        'bookingId': bookingId,
        'serviceName': serviceName,
        'title': serviceName.isNotEmpty ? serviceName : 'Radiology Pricing',
        'avatarPath': 'assets/images/logos/logo.png',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'lastMessage': welcomeMessage,
        'lastMessageKind': 'text',
        'lastMessageAt': Timestamp.fromDate(now),
        'lastSender': 'agent',
        'determinedPrice': -1,
      }, SetOptions(merge: true));
    }

    if (messages.docs.isEmpty) {
      final welcome = ChatMessage(
        id: _id(),
        sender: ChatSender.agent,
        kind: ChatMessageKind.text,
        text: welcomeMessage,
        createdAt: now,
      );

      await _messagesRef(bookingId).doc(welcome.id).set(welcome.toMap());

      await _chatRef(bookingId).set({
        'updatedAt': Timestamp.fromDate(now),
        'lastMessage': welcome.text,
        'lastMessageKind': 'text',
        'lastMessageAt': Timestamp.fromDate(now),
        'lastSender': 'agent',
      }, SetOptions(merge: true));
    }
  }

  Stream<List<ChatMessage>> watchMessages(String bookingId) {
    return _messagesRef(bookingId)
        .orderBy('createdAt')
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) =>
              snap.docs.map((e) => ChatMessage.fromMap(e.data())).toList(),
        );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchChatInfo(
    String bookingId,
  ) {
    return _chatRef(bookingId).snapshots();
  }

  Future<void> sendUserTextMessage({
    required String uid,
    required String bookingId,
    required String text,
  }) async {
    final now = DateTime.now();

    final message = ChatMessage(
      id: _id(),
      sender: ChatSender.user,
      kind: ChatMessageKind.text,
      text: text,
      createdAt: now,
    );

    final batch = _firestore.batch();
    batch.set(_messagesRef(bookingId).doc(message.id), message.toMap());
    batch.set(_chatRef(bookingId), {
      'updatedAt': Timestamp.fromDate(now),
      'lastMessage': text,
      'lastMessageKind': 'text',
      'lastMessageAt': Timestamp.fromDate(now),
      'lastSender': 'user',
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> resetDeterminedPrice(String bookingId) async {
    await _chatRef(bookingId).set({
      'determinedPrice': -1,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> sendUserAttachmentMessage({
    required String uid,
    required String bookingId,
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
      bookingId: bookingId,
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
    batch.set(_messagesRef(bookingId).doc(message.id), message.toMap());
    batch.set(_chatRef(bookingId), {
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
    required String bookingId,
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

    final ref = _storage.ref('$collectionPath/$bookingId/$folder/$fileName');

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
      ChatMessageKind.image => '📷 Image',
      ChatMessageKind.video => '🎥 Video',
      ChatMessageKind.voice => '🎤 Voice',
      _ => '📎 File',
    };
  }

  String _extensionOf(String path) {
    final index = path.lastIndexOf('.');
    if (index == -1) return '';
    return path.substring(index);
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
}
