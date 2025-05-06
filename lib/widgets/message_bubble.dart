import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageBubble extends StatelessWidget {
  final types.TextMessage message;
  final bool isUser;

  const MessageBubble({Key? key, required this.message, required this.isUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get message text and fix any encoding issues â¢
    String messageText = message.text;
    messageText = messageText.replaceAll('â¢', '•');

    if (isUser) {
      // User messages have light blue background (#E1F3FF)
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F3FF), // Light blue for user messages
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            messageText,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A1A),
              fontFamily: 'Inter',
            ),
            softWrap: true,
            textAlign: TextAlign.left,
          ),
        ),
      );
    } else {
      // Bot messages

      // if (messageText.contains("the information for") ||
      //     messageText.contains("Here are the work items")) {
      //   // Special work item format
      //   return Align(
      //     alignment: Alignment.centerLeft,
      //     child: Container(
      //       margin: const EdgeInsets.symmetric(vertical: 8),
      //       padding: const EdgeInsets.symmetric(horizontal: 12),
      //       child: _buildFormattedWorkItemText(context, messageText),
      //     ),
      //   );
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _buildFormattedWorkItemText(context, messageText),
        ),
      );
      // }

      // Normal bot message
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            messageText,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A1A),
              fontFamily: 'Inter',
            ),
            softWrap: true,
            textAlign: TextAlign.left,
          ),
        ),
      );
    }
  }

  Widget _buildFormattedWorkItemText(BuildContext context, String messageText) {
    // Convert the message text into markdown format
    String markdownText = messageText; // list bullet + bold field name

    return MarkdownBody(
      data: markdownText,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: const TextStyle(
          fontSize: 15,
          fontFamily: 'Inter',
          color: Color(0xFF1A1A1A),
        ),
        listBullet: const TextStyle(
          fontSize: 15,
          fontFamily: 'Inter',
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F8), // Same color as bot messages
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => _buildDot(context, index)),
        ),
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isDark ? Colors.white70 : Colors.black54,
        shape: BoxShape.circle,
      ),
      curve: Curves.easeInOut,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// class MessageBubble extends StatelessWidget {
//   final types.TextMessage message;
//   final bool isUser;

//   const MessageBubble({Key? key, required this.message, required this.isUser})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Get message text and fix any encoding issues â¢
//     String messageText = message.text;
//     messageText = messageText.replaceAll('â¢', '•');

//     if (isUser) {
//       // User messages have light blue background (#E1F3FF)
//       return Align(
//         alignment: Alignment.centerRight,
//         child: Container(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.75,
//           ),
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: const Color(0xFFE1F3FF), // Light blue for user messages
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             messageText,
//             style: const TextStyle(
//               fontSize: 15,
//               color: Color(0xFF1A1A1A),
//               fontFamily: 'Inter',
//             ),
//             softWrap: true,
//             textAlign: TextAlign.left,
//           ),
//         ),
//       );
//     } else {
//       // Bot messages - no background and no width constraint

//       // Check if this is a work item information message
//       if (messageText.contains("the information for") ||
//           messageText.contains("Here are the work items")) {
//         // Work item detail message - still needs special formatting
//         return Align(
//           alignment: Alignment.centerLeft,
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: _buildFormattedWorkItemText(messageText),
//           ),
//         );
//       }

//       // Regular bot message - no background, no width constraint
//       return Align(
//         alignment: Alignment.centerLeft,
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: Text(
//             messageText,
//             style: const TextStyle(
//               fontSize: 15,
//               color: Color(0xFF1A1A1A),
//               fontFamily: 'Inter',
//             ),
//             softWrap: true,
//             textAlign: TextAlign.left,
//           ),
//         ),
//       );
//     }
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
// }

// class TypingIndicator extends StatelessWidget {
//   const TypingIndicator({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
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
//           children: List.generate(3, (index) => _buildDot(context, index)),
//         ),
//       ),
//     );
//   }

//   Widget _buildDot(BuildContext context, int index) {
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
// }
