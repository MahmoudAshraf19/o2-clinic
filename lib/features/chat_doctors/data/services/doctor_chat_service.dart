import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../../core/services/notification_service.dart';
import '../../../chat_support/data/models/chat_support_model.dart';
import '../../data/models/doctor_chat_model.dart';

class DoctorChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  String _getChatRoomId(String patientId, String doctorId) {
    // Unique deterministic room ID between a patient and a doctor
    final List<String> ids = [patientId, doctorId];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<List<DoctorChatRoom>> watchDoctorChatRooms(String doctorId) {
    return _db
        .collection('chat_doctors')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DoctorChatRoom.fromDoc(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<DoctorChatRoom>> watchPatientChatRooms(String patientId) {
    return _db
        .collection('chat_doctors')
        .where('customerId', isEqualTo: patientId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DoctorChatRoom.fromDoc(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<DoctorChatMessage>> watchMessages(String roomId) {
    return _db
        .collection('chat_doctors')
        .doc(roomId)
        .collection('thread')
        .orderBy('createdAt', descending: false)
        .snapshots(includeMetadataChanges: true)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DoctorChatMessage.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> _ensureRoomExists({
    required String roomId,
    required String patientId,
    required String patientName,
    required String patientProfileImage,
    required String doctorId,
    required String doctorName,
    required String doctorProfileImage,
    required String lastMessage,
    required String lastMessageKind,
    required String lastSenderId,
  }) async {
    final docRef = _db.collection('chat_doctors').doc(roomId);

    // We use set with merge: true to avoid overwriting creation dates if it exists
    await docRef.set({
      'customerId': patientId,
      'customerName': patientName,
      'customerProfileImage': patientProfileImage,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorProfileImage': doctorProfileImage,
      'lastMessage': lastMessage,
      'lastMessageKind': lastMessageKind,
      'lastSenderId': lastSenderId,
      'updatedAt': FieldValue.serverTimestamp(),
      // Add createdAt only if it doesn't exist
    }, SetOptions(merge: true));

    // To ensure createdAt exists safely without overwriting
    final docSnap = await docRef.get();
    if (!docSnap.data()!.containsKey('createdAt')) {
      await docRef.update({'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> sendTextMessage({
    required String patientId,
    required String patientName,
    required String patientProfileImage,
    required String doctorId,
    required String doctorName,
    required String doctorProfileImage,
    required String senderId,
    required String receiverId,
    required String text,
    required String senderNameForNotification,
    required String screenForNotification,
  }) async {
    final roomId = _getChatRoomId(patientId, doctorId);
    final msgId = _uuid.v4();

    await _ensureRoomExists(
      roomId: roomId,
      patientId: patientId,
      patientName: patientName,
      patientProfileImage: patientProfileImage,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorProfileImage: doctorProfileImage,
      lastMessage: text,
      lastMessageKind: 'text',
      lastSenderId: senderId,
    );

    final msg = DoctorChatMessage(
      id: msgId,
      message: text,
      kind: ChatMessageKind.text,
      receiverId: receiverId,
      senderId: senderId,
      createdAt: DateTime.now(),
    );

    await _db
        .collection('chat_doctors')
        .doc(roomId)
        .collection('thread')
        .doc(msgId)
        .set(msg.toMap());

    // Send push notification
    await NotificationService.instance.sendChatMessageNotification(
      userId: receiverId,
      chatRoomId: roomId,
      messageId: msgId,
      senderName: senderNameForNotification,
      doctorId: doctorId,
      screen: screenForNotification,
    );
  }

  Future<void> sendAttachmentMessage({
    required String patientId,
    required String patientName,
    required String patientProfileImage,
    required String doctorId,
    required String doctorName,
    required String doctorProfileImage,
    required String senderId,
    required String receiverId,
    required String localPath,
    required ChatMessageKind kind,
    String? fileName,
    String? caption,
    int? durationMs,
    Uint8List? bytes,
    required String senderNameForNotification,
    required String screenForNotification,
  }) async {
    final roomId = _getChatRoomId(patientId, doctorId);
    final msgId = _uuid.v4();
    final ext = p.extension(localPath).isNotEmpty
        ? p.extension(localPath)
        : '.bin';
    final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}$ext';
    final storageRef = _storage
        .ref()
        .child('chat_doctors')
        .child(roomId)
        .child(name);

    UploadTask uploadTask;
    if (kIsWeb && bytes != null) {
      uploadTask = storageRef.putData(bytes);
    } else {
      uploadTask = storageRef.putFile(File(localPath));
    }

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final attachment = ChatAttachment(
      url: downloadUrl,
      fileName: fileName,
      durationMs: durationMs,
    );

    final msg = DoctorChatMessage(
      id: msgId,
      message: caption ?? '',
      kind: kind,
      receiverId: receiverId,
      senderId: senderId,
      createdAt: DateTime.now(),
      attachment: attachment,
    );

    await _ensureRoomExists(
      roomId: roomId,
      patientId: patientId,
      patientName: patientName,
      patientProfileImage: patientProfileImage,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorProfileImage: doctorProfileImage,
      lastMessage: caption ?? '__ATTACHMENT_MESSAGE__',
      lastMessageKind: kind.name,
      lastSenderId: senderId,
    );

    await _db
        .collection('chat_doctors')
        .doc(roomId)
        .collection('thread')
        .doc(msgId)
        .set(msg.toMap());

    // Send push notification
    await NotificationService.instance.sendChatMessageNotification(
      userId: receiverId,
      chatRoomId: roomId,
      messageId: msgId,
      senderName: senderNameForNotification,
      doctorId: doctorId,
      screen: screenForNotification,
    );
  }
}
