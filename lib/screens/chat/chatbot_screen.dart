import 'package:flutter/material.dart';
import '../../services/gemini_chat_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Msg> _messages = [];
  final List<String> _suggestions = const [
    'How do I prepare for donating blood?',
    'What are the eligibility criteria?',
    'How often can I donate blood?',
    'What happens to donated blood?',
  ];
  GeminiChatService? _chat;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    try {
      _chat = GeminiChatService();
    } catch (e) {
      _error = e.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Chat disabled: $e')));
      });
      setState(() {});
    }
  }

  Future<void> _send({String? override}) async {
    final text = (override ?? _controller.text).trim();
    if (text.isEmpty || _chat == null) return;
    setState(() {
      _messages.add(_Msg.user(text));
      _loading = true;
      _controller.clear();
    });
    try {
      final reply = await _chat!.ask(text);
      setState(() {
        _messages.add(_Msg.bot(reply.isEmpty ? 'No response' : reply));
      });
    } catch (e) {
      setState(() {
        _messages.add(_Msg.bot('Error: $e'));
      });
    } finally {
      setState(() => _loading = false);
      await Future.delayed(const Duration(milliseconds: 30));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF8E0E00), Color(0xFFB71C1C), Color(0xFFD32F2F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Blood Donation Assistant',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 4,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_chat != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Chip(
                label: Text(
                  _chat!.modelName,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.15),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Column(
          children: [
            if (_error != null)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade700.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                itemCount: _messages.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _messages.isEmpty
                        ? _buildIntroCard()
                        : const SizedBox();
                  }
                  final m = _messages[i - 1];
                  return _MessageBubble(message: m);
                },
              ),
            ),
            _buildSuggestionRow(),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Card(
      elevation: 3,
      color: Colors.white.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome! 👋',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'I am your AI-assisted blood donation guide. Ask me anything about eligibility, safety, preparation, recovery and more.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions
                  .map(
                    (s) => ActionChip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      onPressed: _loading ? null : () => _send(override: s),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionRow() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _suggestions
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(s, style: const TextStyle(fontSize: 11)),
                  selected: false,
                  onSelected: _loading ? null : (_) => _send(override: s),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _send(),
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Ask about blood donation... ',
                  border: InputBorder.none,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _loading
                  ? const SizedBox(
                      key: ValueKey('loader'),
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : IconButton(
                      key: const ValueKey('send'),
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: _send,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  _Msg(this.text, this.isUser);
  _Msg.user(String t) : this(t, true);
  _Msg.bot(String t) : this(t, false);
}

class _MessageBubble extends StatelessWidget {
  final _Msg message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bubbleColor = isUser
        ? Theme.of(context).colorScheme.primary
        : Colors.white.withValues(alpha: 0.9);
    final textColor = isUser ? Colors.white : Colors.black87;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 18),
    );
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isUser ? 60 : 12,
        right: isUser ? 12 : 60,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isUser)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.red.shade800,
                  child: const Icon(
                    Icons.health_and_safety,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              if (!isUser) const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SelectableText(
                    message.text,
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 6),
              if (isUser)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
