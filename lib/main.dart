import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MindVaultApp());
}

class MindVaultApp extends StatelessWidget {
  const MindVaultApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
