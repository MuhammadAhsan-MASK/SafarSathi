import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/gemini_service.dart';
import '../../core/theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Keeps raw conversation for the API
  final List<Map<String, String>> _history = [];

  final List<String> _quickReplies = [
    '🏔️ Best places in Pakistan',
    '💰 Budget trip to Hunza',
    '🍜 Food in Lahore',
    '☀️ Best travel season',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(ChatMessage(
      text:
          '👋 Assalam o Alaikum! I\'m **SafarBot** 🇵🇰\n\nYour personal Pakistan travel assistant! Ask me about destinations, budgets, food, or let me plan your next adventure.',
      isUser: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMsg = ChatMessage(
      text: text.trim(),
      isUser: true,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
      _controller.clear();
    });

    _scrollToBottom();

    // Add to history for Gemini
    _history.add({'role': 'user', 'text': text.trim()});

    final response = await GeminiService.sendMessage(_history);

    final botMsg = ChatMessage(
      text: response,
      isUser: false,
      time: DateTime.now(),
    );

    _history.add({'role': 'model', 'text': response});

    if (mounted) {
      setState(() {
        _messages.add(botMsg);
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: _messages.length <= 1
                ? _buildWelcomeView()
                : _buildMessageList(),
          ),
          if (_isLoading) _buildTypingIndicator(),
          if (_messages.length <= 1) _buildQuickReplies(),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryPurple,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SafarBot',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: const BoxDecoration(
                        color: Color(0xFF69F0AE), shape: BoxShape.circle),
                  ),
                  Text('Online',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Clear chat',
          onPressed: () => setState(() {
            _messages.clear();
            _history.clear();
            _messages.add(ChatMessage(
              text:
                  '👋 Chat cleared! How can I help you plan your next Pakistan adventure? 🇵🇰',
              isUser: false,
              time: DateTime.now(),
            ));
          }),
        ),
      ],
    );
  }

  // ── Welcome view (no messages yet) ───────────────────────────────────────
  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'SafarBot',
              style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple),
            ),
            Text(
              'Your Pakistan Travel AI Assistant',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            _buildWelcomeMsgBubble(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Try asking:',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.grey[700])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMsgBubble() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: _buildMarkdownText(
        '👋 Assalam o Alaikum! I\'m **SafarBot** 🇵🇰\n\nYour personal Pakistan travel assistant! Ask me about destinations, budgets, food, or let me plan your next adventure.',
        isUser: false,
      ),
    );
  }

  // ── Message List ──────────────────────────────────────────────────────────
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _buildMessageBubble(msg);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser ? AppTheme.primaryPurple : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: msg.isUser
                        ? AppTheme.primaryPurple.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildMarkdownText(msg.text, isUser: msg.isUser),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // Simple bold/italic markdown rendering
  Widget _buildMarkdownText(String text, {required bool isUser}) {
    final baseStyle = GoogleFonts.poppins(
      fontSize: 14,
      color: isUser ? Colors.white : Colors.black87,
      height: 1.5,
    );

    // Split by lines and handle **bold** and bullet points
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines.map((line) {
        return Padding(
          padding: EdgeInsets.only(bottom: line.isEmpty ? 4 : 0),
          child: _renderLine(line, baseStyle, isUser),
        );
      }).toList(),
    );
  }

  Widget _renderLine(String line, TextStyle base, bool isUser) {
    if (line.isEmpty) return const SizedBox(height: 4);

    final parts = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int last = 0;

    for (final match in regex.allMatches(line)) {
      if (match.start > last) {
        parts.add(TextSpan(text: line.substring(last, match.start), style: base));
      }
      parts.add(TextSpan(
        text: match.group(1),
        style: base.copyWith(fontWeight: FontWeight.bold),
      ));
      last = match.end;
    }
    if (last < line.length) {
      parts.add(TextSpan(text: line.substring(last), style: base));
    }

    return RichText(text: TextSpan(children: parts));
  }

  // ── Typing Indicator ──────────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(300),
                _dot(500),
                _dot(700),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withValues(
                alpha: (0.3 + 0.7 * (value < 0.5 ? value * 2 : 2 - value * 2))
                    .clamp(0.0, 1.0)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  // ── Quick Replies ─────────────────────────────────────────────────────────
  Widget _buildQuickReplies() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickReplies.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _sendMessage(_quickReplies[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Text(
                _quickReplies[index],
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w500),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Input Bar ─────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FF),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.2)),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything about Pakistan travel...',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _sendMessage(_controller.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
