import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_2/screens/login_screen.dart';
import 'package:test_2/services/firestore_service.dart';

class YourDrawerWidget extends StatefulWidget {
  final FirestoreService firestoreService;
  final String? sessionId;
  final ValueChanged<String> onSessionSelected;
  final BuildContext parentContext;

  const YourDrawerWidget({
    Key? key,
    required this.firestoreService,
    required this.sessionId,
    required this.onSessionSelected,
    required this.parentContext,
  }) : super(key: key);

  @override
  _YourDrawerWidgetState createState() => _YourDrawerWidgetState();
}

class _YourDrawerWidgetState extends State<YourDrawerWidget> {
  final Map<String, String> _sessionFirstMessages =
      {}; // Cache for session titles

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // User Info Section
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: const Color(0xFF0078D4), // Azure DevOps blue color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            accountName: Text(
              FirebaseAuth.instance.currentUser?.displayName ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                FirebaseAuth.instance.currentUser?.email
                        ?.substring(0, 1)
                        .toUpperCase() ??
                    '',
                style: const TextStyle(fontSize: 24, color: Color(0xFF0078D4)),
              ),
            ),
          ),
          const Divider(),

          // History Section Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'Chat History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),

          // Session List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.firestoreService.getSessions(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox();
                final sessions = snap.data!.docs;

                return ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, i) {
                    final doc = sessions[i];
                    final sessionId = doc.id;

                    final cachedTitle = _sessionFirstMessages[sessionId];
                    if (cachedTitle != null) {
                      return _buildSessionTile(sessionId, cachedTitle);
                    }

                    return FutureBuilder<QuerySnapshot>(
                      future: widget.firestoreService.getFirstUserMessage(
                        sessionId,
                      ),
                      builder: (context, firstMsgSnap) {
                        String titleText = 'Empty chat';
                        if (firstMsgSnap.hasData &&
                            firstMsgSnap.data!.docs.isNotEmpty) {
                          final firstMsg = firstMsgSnap.data!.docs.first;
                          titleText = firstMsg['text'] ?? 'No text';
                        }

                        _sessionFirstMessages[sessionId] = titleText;

                        if (titleText == 'Empty chat') {
                          return const SizedBox.shrink(); // Không render gì nếu rỗng
                        }

                        return _buildSessionTile(sessionId, titleText);
                      },
                    );
                  },
                );
              },
            ),
          ),

          const Divider(),

          // Logout Section with Elevated Button
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(widget.parentContext).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D4), // Azure blue color
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 24.0,
                ), // Add some vertical padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4, // Slight elevation for the button
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a session tile with customized style
  Widget _buildSessionTile(String sessionId, String titleText) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
      elevation: 6, // A bit higher elevation for more depth
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 2.0,
        ),
        title: Text(
          titleText.length > 30
              ? '${titleText.substring(0, 38)}...'
              : titleText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        selected: sessionId == widget.sessionId,
        onTap: () {
          widget.onSessionSelected(sessionId);
          Navigator.pop(context);
        },
      ),
    );
  }
}
