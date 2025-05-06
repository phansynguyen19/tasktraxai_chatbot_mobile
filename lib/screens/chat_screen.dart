import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:test_2/screens/drawer.dart';
import 'package:test_2/screens/login_screen.dart';
import 'package:uuid/uuid.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_field.dart';
import '../services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();

  Timer? _typingTimer;
  int _dotCount = 1;
  String _sessionId = Uuid().v4();

  final ValueNotifier<List<types.TextMessage>> _tempMessagesNotifier =
      ValueNotifier([]);

  late types.User _user;
  final types.User _bot = const types.User(id: 'bot', firstName: 'ADO Chatbot');

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user = types.User(id: currentUser.uid);
    }
    // create initial session
    _firestoreService.createSession(_sessionId);
  }

  void _startNewChat() {
    setState(() {
      _sessionId = Uuid().v4();
      _tempMessagesNotifier.value = [];
    });
    _firestoreService.createSession(_sessionId);
  }

  void _addThinkingMessage() {
    _dotCount = 1;
    _updateThinkingMessage();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _dotCount = (_dotCount % 3) + 1;
      _updateThinkingMessage();
    });
    _scrollToBottom();
  }

  void _updateThinkingMessage() {
    final dots = '.' * _dotCount;
    final updated = List<types.TextMessage>.from(_tempMessagesNotifier.value);
    final index = updated.indexWhere((msg) => msg.id == 'typing-indicator');
    if (index != -1) {
      updated[index] = types.TextMessage(
        id: 'typing-indicator',
        text: 'Responding$dots',
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      updated.add(
        types.TextMessage(
          id: 'typing-indicator',
          text: 'Responding$dots',
          author: _bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
    _tempMessagesNotifier.value = updated;
  }

  void _removeThinkingMessage() {
    _typingTimer?.cancel();
    _typingTimer = null;
    final updated = List<types.TextMessage>.from(_tempMessagesNotifier.value)
      ..removeWhere((msg) => msg.id == 'typing-indicator');
    _tempMessagesNotifier.value = updated;
    _scrollToBottom();
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: text,
    );
    await _firestoreService.addMessage(userMessage, _sessionId);
    _controller.clear();
    _addThinkingMessage();
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      final uri = Uri.parse(
        'http://10.0.2.2:8000/api/v1/azure-devops/chatbot',
      ).replace(
        queryParameters: {
          'text': text,
          'email': FirebaseAuth.instance.currentUser?.email ?? '',
        },
      );
      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedBody);
        if (responseData['status']['code'] == 200) {
          final botReply = responseData['data']['content'];
          _removeThinkingMessage();
          await _simulateTyping(botReply);
        }
      } else {
        // Nếu API trả về nhưng bị lỗi logic
        await _simulateTyping(
          "Hmm 🤔 Something went wrong with the response. Please try again!",
        );
      }
    } catch (e) {
      print('API error: $e');
      await _simulateTyping("Hmm 🤔 Something went wrong with the response.");
    } finally {
      _removeThinkingMessage();
    }
  }

  Future<void> _simulateTyping(String fullReply) async {
    final StringBuffer buffer = StringBuffer();
    final tempId = Uuid().v4();
    for (int i = 0; i < fullReply.length; i++) {
      buffer.write(fullReply[i]);
      _updateBotTempMessage(tempId, buffer.toString());
      await Future.delayed(const Duration(milliseconds: 20));
    }
    final botMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: tempId,
      text: buffer.toString(),
    );
    await _firestoreService.addMessage(botMessage, _sessionId);
    final updated = List<types.TextMessage>.from(_tempMessagesNotifier.value)
      ..removeWhere((msg) => msg.id == tempId);
    _tempMessagesNotifier.value = updated;
  }

  void _updateBotTempMessage(String id, String text) {
    final updated = List<types.TextMessage>.from(_tempMessagesNotifier.value);
    final index = updated.indexWhere((msg) => msg.id == id);
    if (index != -1) {
      updated[index] = types.TextMessage(
        id: id,
        text: text,
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      updated.add(
        types.TextMessage(
          id: id,
          text: text,
          author: _bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
    _tempMessagesNotifier.value = updated;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
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
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _tempMessagesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0078D4), // Azure DevOps blue color
        elevation: 4, // Subtle shadow to give it a floating effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(
              20,
            ), // Rounded bottom corners for a sleek design
          ),
        ),
        title: const Text(
          "TASKTRAX AI CHATBOT",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17, // Slightly bigger font for better readability
            letterSpacing: 1.5, // Spacing to make the title look modern
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true, // Centers the title
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_comment,
              color:
                  Colors.white, // Make the icon color white to match the theme
            ),
            tooltip: 'New Chat',
            onPressed: _startNewChat,
          ),
        ],
      ),
      drawer: YourDrawerWidget(
        firestoreService: _firestoreService,
        sessionId: _sessionId,
        onSessionSelected: (newSessionId) {
          setState(() {
            _sessionId = newSessionId;
            _tempMessagesNotifier.value = [];
          });
        },
        parentContext: context,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getChatMessages(_sessionId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: \${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                final messages =
                    docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return types.TextMessage(
                        id: data['id'] ?? doc.id,
                        text: data['text'] ?? '',
                        author: types.User(id: data['author'] ?? 'unknown'),
                        createdAt: data['createdAt'] ?? 0,
                      );
                    }).toList();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                return ValueListenableBuilder<List<types.TextMessage>>(
                  valueListenable: _tempMessagesNotifier,
                  builder: (context, tempMessages, _) {
                    final allMessages = [...messages, ...tempMessages];
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: allMessages.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final message = allMessages[index];
                        final isUser = message.author.id == _user.id;
                        return MessageBubble(message: message, isUser: isUser);
                      },
                    );
                  },
                );
              },
            ),
          ),
          InputField(controller: _controller, onSend: sendMessage),
        ],
      ),
    );
  }
}
