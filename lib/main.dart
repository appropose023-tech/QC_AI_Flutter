import 'package:flutter/material.dart';
import 'capture_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PCBInspectorApp());
}

class PCBInspectorApp extends StatelessWidget {
  const PCBInspectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCB Inspector',
      theme: ThemeData.dark(),
      home: const CaptureScreen(),
    );
  }
}
