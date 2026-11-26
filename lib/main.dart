import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'features/dashboard/presentation/screen/main_navigation_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  setupLocator();

  runApp(const TehSoloApp());
}

class TehSoloApp extends StatelessWidget {
  const TehSoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Teh Solo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(), 
    );
  }
}