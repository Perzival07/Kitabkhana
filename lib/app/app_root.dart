import 'package:flutter/material.dart';

import 'app_config.dart';

/// Minimal placeholder app; replaced by the themed, routed app in P01.
class AppRoot extends StatelessWidget {
  const AppRoot({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(body: Center(child: Text('Kitabkhana'))),
    );
  }
}
