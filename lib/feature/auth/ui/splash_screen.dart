import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ... باقي الاستوردات بتاعتك

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // اعمل استدعاء للـ Router بتاعك هنا as usual
      // مثال:
    );
  }
}