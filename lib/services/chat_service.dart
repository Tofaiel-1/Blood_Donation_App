import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  /// Get or create a chat room between two users
  Future<String> startOrGetChatRoom(String userA, String userB) async {
    final participantsSorted = [userA, userB]..sort();

    // Try find existing chat room containing userA and userB
    final existing = await _db
        .collection('chatRooms')
        .where('participants', arrayContains: userA)
        .get();

    for (final doc in existing.docs) {
      final parts = List<String>.from(doc.data()['participants'] ?? []);
      if (parts.toSet().containsAll(participantsSorted)) {
        return doc.id;
      }
    }

    // Create new chat room
    final now = FieldValue.serverTimestamp();
    final docRef = await _db.collection('chatRooms').add({
      'participants': participantsSorted,
      'lastMessage': '',
      'lastMessageTime': now,
    });
    return docRef.id;
  }

  /// Stream chat rooms for current user with computed metadata
  Stream<List<ChatRoom>> watchChatRooms(String uid) {
    return _db
        .collection('chatRooms')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final rooms = await Future.wait(
            snapshot.docs.map((doc) async {
              final data = doc.data();
              final participants = List<String>.from(
                data['participants'] ?? [],
              );
              final otherUid = participants.firstWhere(
                (p) => p != uid,
                orElse: () => uid,
              );

              // Fetch other participant name
              String otherName = 'User';
              try {
                final otherDoc = await _db
                    .collection('users')
                    .doc(otherUid)
                    .get();
                otherName = (otherDoc.data() ?? const {})['name'] ?? otherName;
              } catch (_) {}

              // Compute unread count for this chat for uid
              int unread = 0;
              try {
                final unreadSnap = await _db
                    .collection('chatRooms')
                    .doc(doc.id)
                    .collection('messages')
                    .where('receiverId', isEqualTo: uid)
                    .where('isRead', isEqualTo: false)
                    .get();
                unread = unreadSnap.docs.length;
              } catch (_) {}

              final lastMessageTime =
                  (data['lastMessageTime'] as Timestamp?)?.toDate() ??
                  DateTime.now();
              final roomMap = {
                'id': doc.id,
                'participants': participants,
                'lastMessage': data['lastMessage'] ?? '',
                'lastMessageTime': lastMessageTime,
                'unreadCount': unread,
                'otherParticipantName': otherName,
              };
              return ChatRoom.fromMap(roomMap);
            }).toList(),
          );
          return rooms;
        });
  }

  /// Stream messages in a chat room
  Stream<List<Message>> watchMessages(String chatRoomId) {
    return _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => Message.fromFirestore(d)).toList(),
        );
  }

  /// Send a message and update the chat room metadata
  Future<void> sendMessage({
    required String chatRoomId,
    required String content,
    required String receiverId,
    MessageType type = MessageType.personal,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not authenticated');

    // Fetch sender name from users profile
    String senderName = user.displayName ?? 'You';
    try {
      final userDoc = await _db.collection('users').doc(user.uid).get();
      senderName = (userDoc.data() ?? const {})['name'] ?? senderName;
    } catch (_) {}

    final msg = Message(
      id: '',
      senderId: user.uid,
      senderName: senderName,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
    );

    final batch = _db.batch();
    final roomRef = _db.collection('chatRooms').doc(chatRoomId);
    final msgRef = roomRef.collection('messages').doc();

    batch.set(msgRef, msg.toMap());
    batch.update(roomRef, {
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Mark all messages as read for current user in this room
  Future<void> markMessagesRead(String chatRoomId, String uid) async {
    final q = await _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final d in q.docs) {
      batch.update(d.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Find any admin (admin/orgAdmin/superAdmin)
  Future<String?> pickAnyAdminUid() async {
    final q = await _db
        .collection('users')
        .where('role', whereIn: ['admin', 'orgAdmin', 'superAdmin'])
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.id;
  }
}
