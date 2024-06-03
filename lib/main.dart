import 'package:flutter/material.dart';
import 'package:qr_scanner/screens/qr_generator.dart';
import 'package:qr_scanner/screens/qr_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: 'qr_generator',
      routes: {
        'qr_generator' : (context) => const QRGenerator(),
        'qr_scanner' : (context) => const QRScanner(),
      },
    );
  }
}