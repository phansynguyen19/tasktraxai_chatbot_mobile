import 'package:flutter/material.dart';
import 'package:test_2/screens/login_screen.dart';
import 'screens/chat_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADO Chatbot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter', // Using Sans-serif font
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF343541),
        // fontFamily: 'Inter', // Using Sans-serif font
      ),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
