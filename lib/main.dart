import 'package:flutter/material.dart';
import 'package:persona/pallete.dart';

import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Persona',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Cera Pro').copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Pallete.whiteColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Pallete.whiteColor,
        ),
      ),
      home: HomePage(),
    );
  }
}
