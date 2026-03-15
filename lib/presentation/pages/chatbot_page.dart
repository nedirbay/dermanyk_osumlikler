import 'package:flutter/material.dart';
import '../../data/models/chat_message.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/database_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final AiService _aiService = AiService();
  bool _isAiLoading = false;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await DatabaseService.instance.getChatMessages();
    setState(() {
      if (messages.isEmpty) {
        _messages = [
          ChatMessage(
            text: "Salam! Men Türkmenistanyň dermanlyk ösümlikleri boýunça size maslahat berip biljek emeli aň. Size nähili kömek edip bilerim?",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
      } else {
        _messages = messages;
      }
    });
  }

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isAiLoading) return;

    _controller.clear();
    final userMessage = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());
    
    setState(() {
      _messages.add(userMessage);
      _isAiLoading = true;
    });

    await DatabaseService.instance.saveChatMessage(userMessage);

    final response = await _aiService.sendMessage(text);
    final aiMessage = ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    if (mounted) {
      setState(() {
        _isAiLoading = false;
        _messages.add(aiMessage);
      });
    }

    await DatabaseService.instance.saveChatMessage(aiMessage);
  }

  void _sendSuggested(String text) async {
    if (_isAiLoading) return;

    final userMessage = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());

    setState(() {
      _messages.add(userMessage);
      _isAiLoading = true;
    });

    await DatabaseService.instance.saveChatMessage(userMessage);

    final response = await _aiService.sendMessage(text);
    final aiMessage = ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    if (mounted) {
      setState(() {
        _isAiLoading = false;
        _messages.add(aiMessage);
      });
    }

    await DatabaseService.instance.saveChatMessage(aiMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akylly maslahat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            Text(
              'Dermanlyk ösümlikler boýunça emeli aň maslahat berýär',
              style: TextStyle(fontSize: 12, color: Color(0xFF4E6E50)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isAiLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const _AiLoadingBubble();
                }
                final message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),
          _SuggestedQuestions(onTap: _sendSuggested),
          _InputArea(controller: _controller, onSend: _handleSend),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFFC8E6C9) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Color(0xFF1B5E20)),
        ),
      ),
    );
  }
}

class _SuggestedQuestions extends StatelessWidget {
  final Function(String) onTap;

  const _SuggestedQuestions({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      "Aşgazan üçin peýdaly ösümlikler",
      "Sowuklama garşy ösümlikler",
      "Gan basyşyny peseldýän ösümlikler",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: suggestions.map((text) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: const BorderSide(color: Color(0xFFA5D6A7)),
              onPressed: () => onTap(text),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputArea({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Soragyňyzy ýazyň... mysal: sowuklama üçin haýsy ösümlik peýdaly?",
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF7A8B7A)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F8E9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send, color: Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }
}
class _AiLoadingBubble extends StatelessWidget {
  const _AiLoadingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFE8F5E9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
        ),
      ),
    );
  }
}
