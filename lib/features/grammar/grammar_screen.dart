import 'package:flutter/material.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('语法课程'),
      ),
      body: const Center(
        child: Text('语法课程模块'),
      ),
    );
  }
}
