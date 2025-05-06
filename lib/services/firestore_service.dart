import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new chat session
  Future<void> createSession(String sessionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db.collection('sessions').doc(sessionId).set({
      'userId': user.uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// List all sessions for the current user
  Stream<QuerySnapshot> getSessions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection('sessions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Add a message to a specific session
  Future<void> addMessage(types.TextMessage message, String sessionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .doc(message.id)
        .set({
          'id': message.id,
          'text': message.text,
          'author': message.author.id,
          'createdAt': message.createdAt,
          'userId': user.uid,
          'sessionId': sessionId,
        });
  }

  /// Stream messages for a given session
  Stream<QuerySnapshot> getChatMessages(String sessionId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<QuerySnapshot> getFirstUserMessage(String sessionId) {
    return FirebaseFirestore.instance
        .collection('sessions') // đổi từ chats -> sessions
        .doc(sessionId)
        .collection('messages')
        .where('author', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy('createdAt')
        .limit(1)
        .get();
  }

  Future<void> createSessionIfNotExists(String sessionId) async {
    final sessionDoc = FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId);
    final docSnapshot = await sessionDoc.get();
    if (!docSnapshot.exists) {
      await sessionDoc.set({
        'createdAt': FieldValue.serverTimestamp(),
        // add more initial fields if you want
      });
    }
  }
}
// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   /// Thêm tin nhắn vào Firestore, lưu kèm userId của người dùng hiện tại
//   Future<void> addMessage(types.TextMessage message) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     final messageRef = _db.collection('chats').doc();
//     await messageRef.set({
//       'id': message.id,
//       'text': message.text,
//       'author': message.author.id,
//       'createdAt': message.createdAt,
//       'userId': user.uid, // Lưu userId để lọc sau này
//     });
//   }

//   /// Lấy stream tin nhắn của user hiện tại, sắp xếp theo createdAt
//   Stream<QuerySnapshot> getChatMessages() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return const Stream.empty();
//     }

//     return _db
//         .collection('chats')
//         .where('userId', isEqualTo: user.uid) // Chỉ lấy tin nhắn của chính user
//         .orderBy('createdAt', descending: false)
//         .snapshots();
//   }
// }
