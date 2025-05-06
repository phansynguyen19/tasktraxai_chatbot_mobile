import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:uuid/uuid.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ADO Chatbot',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.white,
//         fontFamily: 'Inter', // Using Sans-serif font
//       ),
//       darkTheme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: const Color(0xFF343541),
//         // fontFamily: 'Inter', // Using Sans-serif font
//       ),
//       themeMode: ThemeMode.system,
//       home: const ChatScreen(),
//     );
//   }
// }

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ScrollController _scrollController = ScrollController();
//   bool _isTyping = false;

//   final types.User _user = const types.User(id: 'user');
//   final types.User _bot = const types.User(id: 'bot', firstName: 'ADO Chatbot');

//   String randomString() => const Uuid().v4();

//   Future<void> _addMessage(types.TextMessage message) async {
//     await _firestore.collection('chats').doc(message.id).set({
//       'id': message.id,
//       'text': message.text,
//       'author': message.author.id,
//       'createdAt': message.createdAt,
//     });
//   }

//   Future<void> sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;

//     final userMessage = types.TextMessage(
//       author: _user,
//       createdAt: DateTime.now().millisecondsSinceEpoch,
//       id: randomString(),
//       text: text,
//     );

//     await _addMessage(userMessage);
//     _controller.clear();

//     setState(() => _isTyping = true);
//     _scrollToBottom();

//     try {
//       final uri = Uri.parse(
//         'http://10.0.2.2:8000/api/v1/azure-devops/chatbot',
//       ).replace(queryParameters: {'text': text});
//       final response = await http.get(uri);

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['status']['code'] == 200) {
//           final botReply = responseData['data']['content'];
//           final botMessage = types.TextMessage(
//             author: _bot,
//             createdAt: DateTime.now().millisecondsSinceEpoch,
//             id: randomString(),
//             text: botReply,
//           );
//           await _addMessage(botMessage);
//         }
//       }
//     } catch (e) {
//       print('API error: $e');
//     } finally {
//       setState(() => _isTyping = false);
//       _scrollToBottom();
//     }
//   }

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("ADO Chatbot"), centerTitle: true),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream:
//                   _firestore
//                       .collection('chats')
//                       .orderBy('createdAt')
//                       .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text("Error: ${snapshot.error}"));
//                 }
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final docs = snapshot.data!.docs;
//                 final messages =
//                     docs.map((doc) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       return types.TextMessage(
//                         id: data['id'] ?? doc.id,
//                         text: data['text'] ?? '',
//                         author: types.User(id: data['author'] ?? 'unknown'),
//                         createdAt: data['createdAt'] ?? 0,
//                       );
//                     }).toList();

//                 return ListView.builder(
//                   controller: _scrollController,
//                   itemCount: messages.length + (_isTyping ? 1 : 0),
//                   padding: const EdgeInsets.all(16),
//                   itemBuilder: (context, index) {
//                     if (_isTyping && index == messages.length) {
//                       return _buildTypingIndicator();
//                     }
//                     final message = messages[index];
//                     final isUser = message.author.id == _user.id;
//                     return _buildMessageBubble(message, isUser);
//                   },
//                 );
//               },
//             ),
//           ),
//           _buildInputField(),
//         ],
//       ),
//     );
//   }

//   // Widget _buildMessageBubble(types.TextMessage message, bool isUser) {
//   //   // User messages have light blue background (#E1F3FF)
//   //   // Bot messages have very light gray background (#F7F7F8)
//   //   final Color backgroundColor =
//   //       isUser
//   //           ? const Color(0xFFE1F3FF) // Light blue for user messages
//   //           : const Color(0xFFF7F7F8); // Very light gray for bot messages

//   //   // Text color is dark for both message types
//   //   const Color textColor = Color(0xFF1A1A1A);

//   //   // Fix encoding issues in the message text
//   //   String processedText = message.text;
//   //   // Replace the problematic encoded characters with proper bullet points
//   //   processedText = processedText.replaceAll('â¢', '•');

//   //   return Align(
//   //     alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//   //     child: Container(
//   //       constraints: BoxConstraints(
//   //         maxWidth: MediaQuery.of(context).size.width * 0.75,
//   //       ),
//   //       margin: const EdgeInsets.symmetric(vertical: 8),
//   //       padding: const EdgeInsets.all(12),
//   //       decoration: BoxDecoration(
//   //         color: backgroundColor,
//   //         borderRadius: BorderRadius.circular(12), // 12px rounded corners
//   //       ),
//   //       child: Text(
//   //         processedText,
//   //         style: const TextStyle(
//   //           fontSize: 15, // 14px-16px as requested
//   //           color: textColor,
//   //           fontFamily: 'Inter', // Sans-serif font
//   //         ),
//   //         softWrap: true,
//   //         textAlign: TextAlign.left,
//   //       ),
//   //     ),
//   //   );
//   // }
//   Widget _buildMessageBubble(types.TextMessage message, bool isUser) {
//     // User messages have light blue background (#E1F3FF)
//     // Bot messages have very light gray background (#F7F7F8)
//     final Color backgroundColor =
//         isUser
//             ? const Color(0xFFE1F3FF) // Light blue for user messages
//             : const Color(0xFFF7F7F8); // Very light gray for bot messages

//     // Text color is dark for both message types
//     const Color textColor = Color(0xFF1A1A1A);

//     String messageText = message.text;
//     messageText = messageText.replaceAll('â¢', '•');

//     // Check if this is a work item information message
//     if (!isUser && messageText.contains("the information for")) {
//       // This is likely a work item detail message
//       return Align(
//         alignment: Alignment.centerLeft,
//         child: Container(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.75,
//           ),
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: backgroundColor,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: _buildFormattedWorkItemText(messageText),
//         ),
//       );
//     }

//     // Regular text message
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(
//           messageText,
//           style: const TextStyle(
//             fontSize: 15,
//             color: textColor,
//             fontFamily: 'Inter',
//           ),
//           softWrap: true,
//           textAlign: TextAlign.left,
//         ),
//       ),
//     );
//   }

//   Widget _buildFormattedWorkItemText(String messageText) {
//     // Split the message into lines
//     List<String> lines = messageText.split('\n');
//     List<Widget> textWidgets = [];

//     // Process header
//     if (lines.isNotEmpty) {
//       textWidgets.add(
//         Text(
//           lines[0],
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1A1A1A),
//             fontFamily: 'Inter',
//           ),
//         ),
//       );
//       textWidgets.add(const SizedBox(height: 8));
//     }

//     // Process detail lines
//     for (int i = 1; i < lines.length; i++) {
//       String line = lines[i];

//       // Skip empty lines
//       if (line.trim().isEmpty) continue;

//       // Check if this is a list item with a field name
//       if (line.startsWith('• ')) {
//         // Remove the "- " prefix
//         line = line.substring(2);

//         // Find the position of the colon
//         int colonIndex = line.indexOf(':');
//         if (colonIndex > 0) {
//           String fieldName = line.substring(0, colonIndex + 1);
//           String fieldValue = line.substring(colonIndex + 1);

//           textWidgets.add(
//             Padding(
//               padding: const EdgeInsets.only(bottom: 4),
//               child: RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: "• $fieldName",
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1A1A1A),
//                         fontFamily: 'Inter',
//                       ),
//                     ),
//                     TextSpan(
//                       text: fieldValue,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.normal,
//                         color: Color(0xFF1A1A1A),
//                         fontFamily: 'Inter',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//           continue;
//         }
//       }

//       // Default handling for other lines
//       textWidgets.add(
//         Text(
//           line,
//           style: const TextStyle(
//             fontSize: 15,
//             color: Color(0xFF1A1A1A),
//             fontFamily: 'Inter',
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: textWidgets,
//     );
//   }

//   Widget _buildDot(int index) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 500),
//       margin: const EdgeInsets.symmetric(horizontal: 2),
//       width: 8,
//       height: 8,
//       decoration: BoxDecoration(
//         color: isDark ? Colors.white70 : Colors.black54,
//         shape: BoxShape.circle,
//       ),
//       curve: Curves.easeInOut,
//     );
//   }

//   Widget _buildTypingIndicator() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF7F7F8), // Same color as bot messages
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: List.generate(3, (index) => _buildDot(index)),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputField() {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 3,
//             offset: const Offset(0, -1),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText: "Enter message...",
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor:
//                     Theme.of(context).brightness == Brightness.dark
//                         ? Colors.grey[800]
//                         : Colors.grey[200],
//               ),
//               onSubmitted: (_) => sendMessage(),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.send, color: Colors.white),
//               onPressed: sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
