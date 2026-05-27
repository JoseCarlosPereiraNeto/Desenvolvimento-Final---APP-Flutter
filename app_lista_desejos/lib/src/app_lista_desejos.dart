import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class AppListaDesejos extends StatelessWidget {
  const AppListaDesejos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Lista de Desejos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
