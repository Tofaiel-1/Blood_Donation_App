import 'package:flutter/material.dart';
import '../../models/message.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: TabController(length: 2, vsync: Scaffold.of(context)),
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
        children: [_buildChatsTab(), _buildAlertsTab()],
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton(
              heroTag: 'messages_new_chat_fab',
              onPressed: _startNewChat,
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildChatsTab() {
    return chatRooms.isEmpty
        ? Center(
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
                  'Start a conversation with donors or blood banks',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              return _buildChatRoomTile(chatRoom);
            },
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

  void _startNewChat() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start New Chat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.search, color: Colors.red[700]),
              title: Text('Search Donors'),
              subtitle: Text('Find and message blood donors'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening donor search...')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.red[700]),
              title: Text('Contact Blood Bank'),
              subtitle: Text('Message blood bank centers'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening blood bank contacts...')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.emergency, color: Colors.red[700]),
              title: Text('Emergency Request'),
              subtitle: Text('Send urgent blood request'),
              onTap: () {
                Navigator.pop(context);
                _showEmergencyRequestDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyRequestDialog() {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    String? selectedBloodType;
    final locationController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Blood Request'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Blood Type Needed',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedBloodType,
                  items: bloodTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedBloodType = value);
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Hospital/Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: 'Additional Details',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedBloodType != null &&
                  locationController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Emergency request sent for $selectedBloodType blood',
                    ),
                    backgroundColor: Colors.red[700],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: Text('Send Request'),
          ),
        ],
      ),
    );
  }

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
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
  }

  void _loadChatMessages() {
    // Mock chat messages
    messages = [
      Message(
        id: '1',
        senderId: widget.chatRoom.participants[1],
        senderName: widget.chatRoom.otherParticipantName,
        receiverId: widget.chatRoom.participants[0],
        content: 'Hello! I saw your blood donation post.',
        timestamp: DateTime.now().subtract(Duration(hours: 3)),
        isRead: true,
        type: MessageType.personal,
      ),
      Message(
        id: '2',
        senderId: widget.chatRoom.participants[0],
        senderName: 'You',
        receiverId: widget.chatRoom.participants[1],
        content: 'Hi! Yes, I\'m available to donate. When do you need it?',
        timestamp: DateTime.now().subtract(Duration(hours: 2, minutes: 30)),
        isRead: true,
        type: MessageType.personal,
      ),
      Message(
        id: '3',
        senderId: widget.chatRoom.participants[1],
        senderName: widget.chatRoom.otherParticipantName,
        receiverId: widget.chatRoom.participants[0],
        content: widget.chatRoom.lastMessage,
        timestamp: widget.chatRoom.lastMessageTime,
        isRead: false,
        type: MessageType.personal,
      ),
    ];
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe =
                    message.senderId == widget.chatRoom.participants[0];
                return _buildMessageBubble(message, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
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
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add(
          Message(
            id: '${messages.length + 1}',
            senderId: widget.chatRoom.participants[0],
            senderName: 'You',
            receiverId: widget.chatRoom.participants[1],
            content: _messageController.text.trim(),
            timestamp: DateTime.now(),
            isRead: true,
            type: MessageType.personal,
          ),
        );
      });
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
