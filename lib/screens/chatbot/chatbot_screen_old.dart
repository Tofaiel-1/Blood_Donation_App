import 'package:flutter/material.dart';
import '../../services/gemini_chat_service.dart';
import '../home/donate_screen.dart';
import '../home/search_screen.dart';
import '../home/profile_screen.dart';
import '../home/request_posting_screen.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  void _handleChatAction(
    BuildContext context,
    ChatAction action, {
    Map<String, dynamic>? payload,
  }) {
    switch (action) {
      case ChatAction.findCenters:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DonateScreen(initialTabIndex: 2)),
        );
        break;
      case ChatAction.findDonors:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SearchScreen()),
        );
        break;
      case ChatAction.scheduleDonation:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DonateScreen(initialTabIndex: 0)),
        );
        break;
      case ChatAction.openHealthDashboard:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
        break;
      case ChatAction.openEmergencyMode:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestPostingScreen(
              initialBloodType: payload != null
                  ? payload['bloodType'] as String?
                  : null,
              initialHospital: payload != null
                  ? payload['hospital'] as String?
                  : null,
              initialUrgency: payload != null
                  ? payload['urgency'] as String?
                  : null,
              initialNote: payload != null ? payload['note'] as String? : null,
            ),
          ),
        );
        break;
      case ChatAction.openStories:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Stories & Awareness'),
            content: Text(
              'Coming soon: donor stories, awareness content and videos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
        break;
      case ChatAction.showPrivacy:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Privacy First'),
            content: Text(
              'Your data is protected. We only use it to facilitate safe donations.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Got it'),
              ),
            ],
          ),
        );
        break;
      case ChatAction.openWidgetsManager:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open Widgets Manager from Home screen.')),
        );
        break;
      case ChatAction.toggleAlerts:
        final enabled = payload?['enabled'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Emergency alerts ${enabled ? 'enabled' : 'disabled'}',
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.bloodtype, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Blood Bank AI Assistant',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Premium',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade700, Colors.pink.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: AIChatMessages()),
            AIChatInput(
              onAction: (action, {payload}) =>
                  _handleChatAction(context, action, payload: payload),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Chatbot implementation (extracted) ---

class AIChatMessages extends StatefulWidget {
  const AIChatMessages({super.key});
  @override
  State<AIChatMessages> createState() => _AIChatMessagesState();
}

class _AIChatMessagesState extends State<AIChatMessages> {
  List<ChatMessage> messages = [
    ChatMessage(
      text:
          'I\'m your Blood Bank AI Assistant.\n\n🩸 Encourage & Support — I\'ll remind you when you\'re eligible, help you prepare, and cheer you on.\n🏥 Find Help Fast — Nearby banks, camps, and emergency donors in seconds.\n💡 Stay Informed — Safety, recovery, and health tips you can trust.\n❤️ Build Community — Join drives, groups, and inspire others.\n🎖️ Celebrate Impact — Badges, milestones, and lifetime liters donated.\n⚡ Smart Matching — Based on blood type, location, and urgency.\n🚨 Emergency Mode — Notify nearby donors & hospitals when needed.\n📅 AI Scheduling — Book and sync your next donation.\n📊 Health Dashboard — Track hemoglobin, BP, and history.\n🌍 Global Connect — Help beyond your city in shortages or disasters.\n🔐 Privacy First — Your data. Your control.\n\nTry commands: /search [topic], /news, /trends, /feedback [topic], /update-cache, /offline-mode\n\nHow can I help right now?',
      isUser: false,
      timestamp: DateTime.now().subtract(Duration(seconds: 2)),
    ),
  ];

  bool _isTyping = false;

  void setTyping(bool value) {
    if (!mounted) return;
    setState(() => _isTyping = value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (_isTyping && index == messages.length) {
            return _buildTypingBubble();
          }
          return _buildMessageBubble(messages[index]);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isUser) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.red[700],
                child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.red[700] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.person, color: Colors.black54, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delayMs: 0),
            SizedBox(width: 4),
            _TypingDot(delayMs: 200),
            SizedBox(width: 4),
            _TypingDot(delayMs: 400),
          ],
        ),
      ),
    );
  }

  void addMessage(String text, bool isUser) {
    setState(() {
      messages.add(
        ChatMessage(text: text, isUser: isUser, timestamp: DateTime.now()),
      );
    });
  }
}

class AIChatInput extends StatefulWidget {
  final void Function(ChatAction action, {Map<String, dynamic>? payload})
  onAction;

  const AIChatInput({super.key, required this.onAction});

  @override
  State<AIChatInput> createState() => _AIChatInputState();
}

class _AIChatInputState extends State<AIChatInput> {
  final TextEditingController _messageController = TextEditingController();
  List<String> _suggestions = const [
    'Find nearby centers',
    'Am I eligible now?',
    'Emergency help',
    'Schedule donation',
  ];
  bool _onlineMode = true;
  final Map<String, CachedEntry> _cache = {};
  ConversationIntent _intent = ConversationIntent.none;
  final Map<String, String> _draftEmergency = {};
  GeminiChatService? _gemini;
  @override
  void initState() {
    super.initState();
    try {
      _gemini = GeminiChatService();
    } catch (e) {
      _gemini = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_suggestions.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  final s = _suggestions[i];
                  return GestureDetector(
                    onTap: () => _onSuggestionTap(s),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 14,
                            color: Colors.red[700],
                          ),
                          SizedBox(width: 6),
                          Text(s, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => SizedBox(width: 8),
                itemCount: _suggestions.length,
              ),
            ),
          if (_suggestions.isNotEmpty) SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _startVoiceInput,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.mic, color: Colors.red[700], size: 20),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text.trim();

      final chatMessagesState = context
          .findAncestorStateOfType<_AIChatMessagesState>();
      chatMessagesState?.addMessage(message, true);

      _messageController.clear();

      chatMessagesState?.setTyping(true);
      // If Gemini is available and online mode is enabled, use the API.
      if (_gemini != null && _onlineMode) {
        () async {
          try {
            final replyText = await _gemini!.ask(message);
            chatMessagesState?.addMessage(
              replyText.isEmpty ? 'No response from API.' : replyText,
              false,
            );
            // No structured actions from API by default.
            setState(() => _suggestions = const []);
          } catch (e) {
            chatMessagesState?.addMessage('Chat error: $e', false);
          } finally {
            chatMessagesState?.setTyping(false);
          }
        }();
      } else {
        Future.delayed(const Duration(milliseconds: 900), () {
          final reply = _generateAIResponse(message);
          chatMessagesState?.addMessage(reply.text, false);
          if (reply.action != null) {
            widget.onAction(reply.action!, payload: reply.payload);
          }
          setState(() => _suggestions = reply.suggestions);
          chatMessagesState?.setTyping(false);
        });
      }
    }
  }

  void _startVoiceInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice input coming soon. For now, type your message.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onSuggestionTap(String s) {
    _messageController.text = s;
    _sendMessage();
  }

  AIReply _generateAIResponse(String userMessage) {
    if (userMessage.startsWith('/')) {
      return _handleSlashCommand(userMessage);
    }

    final message = userMessage.toLowerCase();

    if (_intent == ConversationIntent.emergency) {
      return _handleEmergencyFlow(message);
    }
    if (_intent == ConversationIntent.schedule) {
      return _handleScheduleFlow(message);
    }

    if (message.contains('emergency') || message.contains('urgent')) {
      _intent = ConversationIntent.emergency;
      _draftEmergency.clear();
      return AIReply(
        text:
            'I\'m here. Let\'s draft your emergency request safely. What\'s the needed blood type? (e.g., O-, AB+)',
        suggestions: const ['O-', 'O+', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'],
      );
    }

    if (message.contains('eligible') ||
        message.contains('eligibility') ||
        message.contains('when can i donate')) {
      return AIReply(
        text:
            'You can usually donate every 56 days if you\'re healthy, 18–65, and 50kg+. I can also track your last donation and remind you. Want to schedule your next slot?',
        suggestions: const [
          'Schedule donation',
          'Donation checklist',
          'Nearby centers',
        ],
      );
    }

    if (message.contains('center') ||
        message.contains('bank') ||
        message.contains('where') ||
        message.contains('nearby')) {
      return AIReply(
        text:
            'Here are centers near you: PSTU Health Center, City Hospital Blood Bank, and Red Cross Unit. I can open the Centers tab or search donors nearby.',
        action: ChatAction.findCenters,
        suggestions: const [
          'Open Centers',
          'Find nearby donors',
          'Schedule donation',
        ],
      );
    }

    if (message.contains('donor') ||
        message.contains('recipient') ||
        message.contains('match')) {
      return AIReply(
        text:
            'Smart matching considers blood type, proximity, and urgency. I can search donors now or post a request.',
        action: ChatAction.findDonors,
        suggestions: const [
          'Find donors',
          'Post a request',
          'Blood type guide',
        ],
      );
    }

    if (message.contains('schedule') ||
        message.contains('book') ||
        message.contains('appointment')) {
      _intent = ConversationIntent.schedule;
      return AIReply(
        text:
            'Nice! When would you like to donate? You can say something like "next Friday morning". We\'ll confirm on the booking screen.',
        suggestions: const [
          'This weekend',
          'Next Friday',
          'Next available slot',
        ],
      );
    }

    if (message.contains('health') ||
        message.contains('hemoglobin') ||
        message.contains('bp') ||
        message.contains('history')) {
      return AIReply(
        text:
            'Your health dashboard shows hemoglobin, BP, and donation history. Opening your profile now.',
        action: ChatAction.openHealthDashboard,
        suggestions: const [
          'View profile',
          'Preparation tips',
          'Recovery tips',
        ],
      );
    }

    if (message.contains('story') ||
        message.contains('stories') ||
        message.contains('awareness')) {
      return AIReply(
        text:
            'I can share donor stories and awareness content to inspire and inform.',
        action: ChatAction.openStories,
        suggestions: const ['Show stories', 'Nearby drives', 'Share my story'],
      );
    }
    if (message.contains('privacy') ||
        message.contains('secure') ||
        message.contains('data')) {
      return AIReply(
        text: 'Your privacy matters. We never share your data without consent.',
        action: ChatAction.showPrivacy,
        suggestions: const [
          'Privacy policy',
          'Manage consent',
          'Delete my data',
        ],
      );
    }

    if (message.contains('donate') || message.contains('donation')) {
      return AIReply(
        text:
            'To donate: be 18–65, 50kg+, healthy, and wait 56 days between donations. Want me to find a center or schedule you?',
        suggestions: const [
          'Nearby centers',
          'Schedule donation',
          'Am I eligible now?',
        ],
      );
    }

    if (message.contains('help') ||
        message.contains('hi') ||
        message.contains('hello')) {
      return AIReply(
        text:
            'I can help with eligibility, finding centers/donors, scheduling, and emergencies. What do you need?',
        suggestions: const [
          'Find nearby centers',
          'Emergency help',
          'Schedule donation',
        ],
      );
    }

    return AIReply(
      text:
          'I can help with eligibility checks, nearby centers, scheduling, emergency requests, and health tips. What should we do?',
      suggestions: const [
        'Am I eligible now?',
        'Find nearby centers',
        'Emergency help',
      ],
    );
  }

  AIReply _handleEmergencyFlow(String message) {
    final valid = ['a+', 'a-', 'b+', 'b-', 'ab+', 'ab-', 'o+', 'o-'];
    if (!_draftEmergency.containsKey('bloodType')) {
      final m = message.replaceAll(' ', '');
      if (valid.contains(m)) {
        _draftEmergency['bloodType'] = m.toUpperCase();
        return AIReply(
          text:
              'Got it: ${_draftEmergency['bloodType']}. Where is the patient (hospital or location)?',
          suggestions: const [
            'City Hospital',
            'PSTU Health Center',
            'Red Cross Unit',
          ],
        );
      }
      return AIReply(
        text: 'Please provide a valid blood type (A+/A-/B+/B-/AB+/AB-/O+/O-).',
        suggestions: const ['O-', 'A+', 'B+', 'AB+'],
      );
    }

    if (!_draftEmergency.containsKey('hospital')) {
      _draftEmergency['hospital'] = message;
      return AIReply(
        text:
            'Noted: ${_draftEmergency['hospital']}. How urgent is it? (Urgent or Critical)',
        suggestions: const ['Urgent', 'Critical'],
      );
    }

    if (!_draftEmergency.containsKey('urgency')) {
      final u = message.toLowerCase().contains('critical')
          ? 'Critical'
          : 'Urgent';
      _draftEmergency['urgency'] = u;
      final summary =
          'Blood: ${_draftEmergency['bloodType']}, Place: ${_draftEmergency['hospital']}, Urgency: ${_draftEmergency['urgency']}';
      _intent = ConversationIntent.none;
      return AIReply(
        text:
            'Summary: $summary. Open the emergency helper to post and alert nearby donors?',
        action: ChatAction.openEmergencyMode,
        payload: {
          'bloodType': _draftEmergency['bloodType'],
          'hospital': _draftEmergency['hospital'],
          'urgency': _draftEmergency['urgency'],
        },
        suggestions: const [
          'Open Emergency Helper',
          'Find nearby donors',
          'View hospitals',
        ],
      );
    }

    _intent = ConversationIntent.none;
    return AIReply(
      text: 'Opening emergency helper.',
      action: ChatAction.openEmergencyMode,
      payload: {
        'bloodType': _draftEmergency['bloodType'],
        'hospital': _draftEmergency['hospital'],
        'urgency': _draftEmergency['urgency'],
      },
    );
  }

  AIReply _handleScheduleFlow(String message) {
    _intent = ConversationIntent.none;
    return AIReply(
      text: 'Great, taking you to the booking screen to pick an exact slot.',
      action: ChatAction.scheduleDonation,
      suggestions: const ['Preparation tips', 'Nearby centers'],
    );
  }

  AIReply _handleSlashCommand(String input) {
    final parts = input.trim().split(RegExp(r"\s+"));
    final cmd = parts.first.toLowerCase();
    final arg = parts.length > 1 ? parts.skip(1).join(' ') : '';

    switch (cmd) {
      case '/offline-mode':
        _onlineMode = false;
        return AIReply(
          text:
              'Offline mode enabled. I\'ll use cached data and saved tips. I\'ll sync when you\'re back online.',
          suggestions: const ['/trends', '/news', 'Find nearby centers'],
        );
      case '/cache-update':
        return _handleSlashCommand('/update-cache');
      case '/update-cache':
        final now = DateTime.now();
        _cache['trends'] = CachedEntry(
          key: 'trends',
          title: 'Trending Now',
          lines: [
            'World Blood Donor Day campaigns',
            'Post-donation recovery nutrition',
            'University mega-drives this month',
          ],
          sources: [
            'https://www.who.int/campaigns/world-blood-donor-day',
            'https://www.redcrossblood.org/',
          ],
          updatedAt: now,
        );
        _cache['news'] = CachedEntry(
          key: 'news',
          title: 'Latest Verified News',
          lines: [
            'New guidance on donation intervals published by regional health boards.',
            'Blood banks report seasonal shortages; community drives planned.',
          ],
          sources: [
            'https://www.who.int/health-topics/blood-safety',
            'https://www.ifrc.org/',
          ],
          updatedAt: now,
        );
        return AIReply(
          text:
              'Cache updated. I\'ve saved trending topics and the latest news for offline use. Use /trends or /news to view.',
          suggestions: const ['/trends', '/news', '/offline-mode'],
        );
      case '/trends':
        final data = _ensureData(
          'trends',
          _onlineMode,
          fallback: CachedEntry(
            key: 'trends',
            title: 'Trending Now',
            lines: [
              'Local blood drive awareness on campuses',
              'Hydration & iron tips before donation',
              'Verified donor badges increase participation',
            ],
            sources: [
              'https://www.who.int/campaigns/world-blood-donor-day',
              'https://www.redcrossblood.org/',
            ],
            updatedAt: DateTime.now(),
          ),
        );
        return AIReply(
          text: _formatList(data, note: _onlineMode ? null : 'Offline copy'),
          suggestions: const [
            '/news',
            '/search donation tips',
            'Find nearby centers',
          ],
        );
      case '/news':
        final data = _ensureData(
          'news',
          _onlineMode,
          fallback: CachedEntry(
            key: 'news',
            title: 'Latest Verified News',
            lines: [
              'Hospital-led drives planned across districts next week.',
              'New donor eligibility FAQs released by public health authority.',
            ],
            sources: [
              'https://www.who.int/health-topics/blood-safety',
              'https://www.ifrc.org/',
            ],
            updatedAt: DateTime.now(),
          ),
        );
        return AIReply(
          text: _formatList(data, note: _onlineMode ? null : 'Offline copy'),
          suggestions: const [
            '/trends',
            '/feedback awareness',
            'Schedule donation',
          ],
        );
      case '/search':
        if (arg.isEmpty) {
          return AIReply(
            text: 'Usage: /search [topic] — e.g., /search hydration tips',
            suggestions: const [
              '/search donation eligibility',
              '/search recovery tips',
            ],
          );
        }
        final key = 'search:$arg';
        final data = _ensureData(
          key,
          _onlineMode,
          fallback: CachedEntry(
            key: key,
            title: 'Search: $arg',
            lines: [
              'Summary on "$arg" from trusted health sources.',
              'Local guidance often recommends hydration and rest.',
            ],
            sources: [
              'https://www.who.int/health-topics/blood-safety',
              'https://www.redcrossblood.org/donate-blood/how-to-donate-blood.html',
            ],
            updatedAt: DateTime.now(),
          ),
        );
        return AIReply(
          text: _formatList(data, note: _onlineMode ? null : 'Offline copy'),
          suggestions: const ['/news', '/trends', 'Nearby centers'],
        );
      case '/donor-match':
        return AIReply(
          text:
              'I can find suitable donors near you based on type, distance, and urgency.',
          action: ChatAction.findDonors,
          suggestions: const [
            'Find donors',
            'Post a request',
            'Nearby centers',
          ],
        );
      case '/drives':
        return AIReply(
          text:
              'Upcoming drives: Community Blood Drive (Patuakhali), Hospital Donation Camp (Chattogram).',
          suggestions: const [
            'Schedule donation',
            'Nearby centers',
            'Show stories',
          ],
        );
      case '/alerts':
        if (arg.toLowerCase() == 'on') {
          return AIReply(
            text: 'Emergency alerts enabled.',
            action: ChatAction.toggleAlerts,
            payload: {'enabled': true},
          );
        } else if (arg.toLowerCase() == 'off') {
          return AIReply(
            text: 'Emergency alerts disabled.',
            action: ChatAction.toggleAlerts,
            payload: {'enabled': false},
          );
        } else {
          return AIReply(
            text: 'Usage: /alerts on or /alerts off',
            suggestions: const ['/alerts on', '/alerts off'],
          );
        }
      case '/widgets':
        return AIReply(
          text: 'Open the Widgets Manager to customize your home dashboard.',
          action: ChatAction.openWidgetsManager,
          suggestions: const ['Show Health Stats', 'Show Nearby Map'],
        );
      case '/profile':
        return AIReply(
          text: 'Opening your profile securely.',
          action: ChatAction.openHealthDashboard,
          suggestions: const ['Donation history', 'Badges', 'Health tips'],
        );
      case '/feedback':
        if (arg.isEmpty) {
          return AIReply(
            text: 'Usage: /feedback [topic] — e.g., /feedback campus drives',
            suggestions: const [
              '/feedback awareness',
              '/feedback donor badges',
            ],
          );
        }
        final key = 'feedback:$arg';
        final data = _ensureData(
          key,
          _onlineMode,
          fallback: CachedEntry(
            key: key,
            title: 'Community feedback on: $arg',
            lines: [
              'Positive sentiment towards $arg; participation rises with verified badges.',
              'Common concern: privacy and safe handling of donor data.',
            ],
            sources: [
              'https://www.ifrc.org/',
              'https://www.redcrossblood.org/',
            ],
            updatedAt: DateTime.now(),
          ),
        );
        return AIReply(
          text: _formatList(data, note: _onlineMode ? null : 'Offline copy'),
          suggestions: const ['/trends', '/news', 'Share my story'],
        );
      default:
        return AIReply(
          text:
              'Unknown command. Try /search [topic], /news, /trends, /feedback [topic], /update-cache, or /offline-mode',
          suggestions: const ['/news', '/trends', '/search donation tips'],
        );
    }
  }

  CachedEntry _ensureData(
    String key,
    bool online, {
    required CachedEntry fallback,
  }) {
    if (online) {
      _cache[key] = fallback.copyWith(updatedAt: DateTime.now());
    } else {
      _cache[key] = _cache[key] ?? fallback;
    }
    return _cache[key]!;
  }

  String _formatList(CachedEntry data, {String? note}) {
    final b = StringBuffer();
    b.writeln(data.title);
    b.writeln('');
    for (final line in data.lines) {
      b.writeln('• $line');
    }
    if (data.sources.isNotEmpty) {
      b.writeln('');
      b.writeln('Sources:');
      for (final s in data.sources) {
        b.writeln('- $s');
      }
    }
    b.writeln('');
    b.writeln(
      'Updated: ${_fmtTime(data.updatedAt)}${note != null ? ' · $note' : ''}',
    );
    b.writeln('');
    b.writeln('Note: Educational only — not medical advice.');
    return b.toString();
  }

  String _fmtTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} $hh:$mm';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

enum ChatAction {
  findCenters,
  findDonors,
  scheduleDonation,
  openHealthDashboard,
  openEmergencyMode,
  openStories,
  showPrivacy,
  openWidgetsManager,
  toggleAlerts,
}

class AIReply {
  final String text;
  final List<String> suggestions;
  final ChatAction? action;
  final Map<String, dynamic>? payload;

  AIReply({
    required this.text,
    this.suggestions = const [],
    this.action,
    this.payload,
  });
}

class CachedEntry {
  final String key;
  final String title;
  final List<String> lines;
  final List<String> sources;
  final DateTime updatedAt;

  CachedEntry({
    required this.key,
    required this.title,
    required this.lines,
    this.sources = const [],
    required this.updatedAt,
  });

  CachedEntry copyWith({
    String? key,
    String? title,
    List<String>? lines,
    List<String>? sources,
    DateTime? updatedAt,
  }) => CachedEntry(
    key: key ?? this.key,
    title: title ?? this.title,
    lines: lines ?? this.lines,
    sources: sources ?? this.sources,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

enum ConversationIntent { none, emergency, schedule }

class _TypingDot extends StatefulWidget {
  final int delayMs;
  const _TypingDot({required this.delayMs});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _a = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.grey[500],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
