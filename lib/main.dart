import 'package:flutter/material.dart';
import 'screens/qr_scanner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR 코드 스캐너',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QRScannerScreen(),
    );
  }
}
