import 'package:flutter/material.dart';
import '../features/home/presentation/pages/home_page.dart';

class ZaiwanApp extends StatelessWidget {
  const ZaiwanApp({super.key});


  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaiwan',
      debugShowCheckedModeBanner: false,
      home: const HomePage()
    );
  }
}