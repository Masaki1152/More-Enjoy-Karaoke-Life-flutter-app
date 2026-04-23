import 'package:flutter/material.dart';

class BestMatchScreen extends StatelessWidget {
  final String roomCode;
  const BestMatchScreen({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ベストマッチ（$roomCode）')),
      body: const Center(
        child: Text('ここにベストマッチ本体を実装していくよ！'),
      ),
    );
  }
}