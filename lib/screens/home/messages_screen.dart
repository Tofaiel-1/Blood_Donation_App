import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../models/message.dart';
import '../../services/chat_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _auth = fb_auth.FirebaseAuth.instance;
  final _chat = ChatService();
  List<ChatRoom> chatRooms = [];
  List<Message> emergencyNotifications = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock chat rooms
    chatRooms = [
      ChatRoom(
        id: '1',
        participants: ['user1', 'user2'],
        lastMessage: 'Thank you for being willing to donate!',
        lastMessageTime: DateTime.now().subtract(Duration(hours: 2)),
        unreadCount: 2,
        otherParticipantName: 'Dr. Sarah Ahmed',
      ),
      ChatRoom(
        id: '2',
        participants: ['user1', 'user3'],
        lastMessage: 'When can you come for donation?',
        lastMessageTime: DateTime.now().subtract(Duration(hours: 5)),
        unreadCount: 0,
        otherParticipantName: 'John Doe',
      ),
      ChatRoom(
        id: '3',
        participants: ['user1', 'user4'],
        lastMessage: 'The blood drive event is tomorrow',
        lastMessageTime: DateTime.now().subtract(Duration(days: 1)),
        unreadCount: 1,
        otherParticipantName: 'Blood Bank Center',
      ),
    ];

    // Mock emergency notifications
    emergencyNotifications = [
      Message(
        id: '1',
        senderId: 'system',
        senderName: 'Emergency Alert',
        receiverId: 'user1',
        content:
            'URGENT: O- blood needed at City Hospital. Patient in critical condition.',
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        isRead: false,
        type: MessageType.emergency,
      ),
      Message(
        id: '2',
        senderId: 'system',
        senderName: 'Emergency Alert',
        receiverId: 'user1',
        content:
            'Critical: AB+ blood required at PSTU Health Center for surgery.',
        timestamp: DateTime.now().subtract(Duration(hours: 3)),
        isRead: true,
        type: MessageType.emergency,
      ),
      Message(
        id: '3',
        senderId: 'system',
        senderName: 'Blood Bank System',
        receiverId: 'user1',
        content: 'Reminder: Your next donation eligibility date is in 10 days.',
        timestamp: DateTime.now().subtract(Duration(days: 2)),
        isRead: true,
        type: MessageType.system,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Messages', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            onTap: (index) => setState(() => _selectedTabIndex = index),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Chats', style: TextStyle(color: Colors.white)),
                    if (_getTotalUnreadChats() > 0) ...[
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${_getTotalUnreadChats()}',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notification_important, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Alerts', style: TextStyle(color: Colors.white)),
                    if (_getUnreadNotifications() > 0) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_getUnreadNotifications()}',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: _selectedTabIndex,
          children: [
            uid == null ? _buildLoginPrompt() : _buildChatsTab(uid),
            _buildAlertsTab(),
          ],
        ),
        floatingActionButton: _selectedTabIndex == 0
            ? FloatingActionButton(
                heroTag: 'messages_new_chat_fab',
                onPressed: () => _startNewChat(uid),
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                child: Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildChatsTab(String uid) {
    return StreamBuilder<List<ChatRoom>>(
      stream: _chat.watchChatRooms(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final rooms = snapshot.data ?? [];
        if (rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Start a conversation with admin/support',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return _buildChatRoomTile(room);
          },
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Please login to view messages',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return emergencyNotifications.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No alerts',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Emergency alerts and notifications will appear here',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: emergencyNotifications.length,
            itemBuilder: (context, index) {
              final notification = emergencyNotifications[index];
              return _buildNotificationCard(notification);
            },
          );
  }

  Widget _buildChatRoomTile(ChatRoom chatRoom) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red[100],
        child: Text(
          chatRoom.otherParticipantName[0].toUpperCase(),
          style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        chatRoom.otherParticipantName,
        style: TextStyle(
          fontWeight: chatRoom.unreadCount > 0
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        chatRoom.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: chatRoom.unreadCount > 0 ? Colors.black87 : Colors.grey[600],
          fontWeight: chatRoom.unreadCount > 0
              ? FontWeight.w500
              : FontWeight.normal,
        ),
      ),
      trailing: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatMessageTime(chatRoom.lastMessageTime),
              style: TextStyle(
                color: chatRoom.unreadCount > 0
                    ? Colors.red[700]
                    : Colors.grey[500],
                fontSize: 12,
                fontWeight: chatRoom.unreadCount > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (chatRoom.unreadCount > 0) ...[
              SizedBox(height: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${chatRoom.unreadCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      onTap: () => _openChat(chatRoom),
    );
  }

  Widget _buildNotificationCard(Message notification) {
    Color cardColor;
    Color textColor;
    IconData icon;

    switch (notification.type) {
      case MessageType.emergency:
        cardColor = Colors.red[50]!;
        textColor = Colors.red[900]!;
        icon = Icons.emergency;
        break;
      case MessageType.system:
        cardColor = Colors.blue[50]!;
        textColor = Colors.blue[900]!;
        icon = Icons.info;
        break;
      default:
        cardColor = Colors.grey[50]!;
        textColor = Colors.grey[900]!;
        icon = Icons.message;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.isRead ? Colors.white : cardColor,
      elevation: notification.isRead ? 1 : 3,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: textColor, size: 24),
        ),
        title: Text(
          notification.senderName,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Column(
          children: [
            SizedBox(height: 4),
            Text(
              notification.content,
              style: TextStyle(
                color: notification.isRead ? Colors.grey[700] : Colors.black87,
                fontWeight: notification.isRead
                    ? FontWeight.normal
                    : FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatMessageTime(notification.timestamp),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: notification.type == MessageType.emergency
            ? ElevatedButton(
                onPressed: () => _respondToEmergency(notification),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  minimumSize: Size(80, 36),
                ),
                child: Text('Respond'),
              )
            : null,
        onTap: () => _markAsRead(notification),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  int _getTotalUnreadChats() {
    return chatRooms.fold(0, (sum, room) => sum + room.unreadCount);
  }

  int _getUnreadNotifications() {
    return emergencyNotifications.where((n) => !n.isRead).length;
  }

  void _openChat(ChatRoom chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(chatRoom: chatRoom),
      ),
    ).then((_) {
      // Mark messages as read when returning from chat
      setState(() {
        final roomIndex = chatRooms.indexWhere(
          (room) => room.id == chatRoom.id,
        );
        if (roomIndex != -1) {
          chatRooms[roomIndex] = ChatRoom(
            id: chatRoom.id,
            participants: chatRoom.participants,
            lastMessage: chatRoom.lastMessage,
            lastMessageTime: chatRoom.lastMessageTime,
            unreadCount: 0,
            otherParticipantName: chatRoom.otherParticipantName,
          );
        }
      });
    });
  }

  void _startNewChat(String? uid) async {
    if (uid == null) return;
    final adminUid = await _chat.pickAnyAdminUid();
    if (adminUid == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No admin available')));
      }
      return;
    }
    final roomId = await _chat.startOrGetChatRoom(uid, adminUid);
    final room = ChatRoom(
      id: roomId,
      participants: [uid, adminUid],
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      otherParticipantName: 'Admin',
    );
    _openChat(room);
  }

  // Removed legacy emergency request dialog (unused after chat integration)

  void _respondToEmergency(Message notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Respond to Emergency'),
        content: Text(
          'Are you available to donate blood for this emergency request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Available'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thank you! Emergency response sent.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('I Can Help'),
          ),
        ],
      ),
    );
  }

  void _markAsRead(Message notification) {
    setState(() {
      final index = emergencyNotifications.indexWhere(
        (n) => n.id == notification.id,
      );
      if (index != -1) {
        emergencyNotifications[index] = Message(
          id: notification.id,
          senderId: notification.senderId,
          senderName: notification.senderName,
          receiverId: notification.receiverId,
          content: notification.content,
          timestamp: notification.timestamp,
          isRead: true,
          type: notification.type,
        );
      }
    });
  }
}

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatDetailScreen({super.key, required this.chatRoom});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final _chat = ChatService();
  final _auth = fb_auth.FirebaseAuth.instance;
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
  }

  void _loadChatMessages() {
    // Mark existing unread as read for current user
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _chat.markMessagesRead(widget.chatRoom.id, uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatRoom.otherParticipantName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Calling ${widget.chatRoom.otherParticipantName}...',
                  ),
                ),
              );
            },
            icon: Icon(Icons.call),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: _chat.watchMessages(widget.chatRoom.id),
                builder: (context, snapshot) {
                  final msgs = snapshot.data ?? [];
                  final myUid = _auth.currentUser?.uid;
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      final message = msgs[index];
                      final isMe = message.senderId == myUid;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.red[700] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.red[700],
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return;
    final otherUid = widget.chatRoom.participants.firstWhere(
      (p) => p != myUid,
      orElse: () => myUid,
    );
    _chat
        .sendMessage(
          chatRoomId: widget.chatRoom.id,
          content: text,
          receiverId: otherUid,
          type: MessageType.personal,
        )
        .then((_) => _messageController.clear());
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
