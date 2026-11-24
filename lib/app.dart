import 'package:flutter/material.dart';
// import 'core/router/app_router.dart'; // Tempat go_router ditaruh

class TehSoloApp extends StatelessWidget {
  const TehSoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router( // Atau MaterialApp biasa kalau pakai go_router
      title: 'POS Teh Solo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      // routerConfig: appRouter, // Nanti di-setup pake GoRouter
    );
  }
}