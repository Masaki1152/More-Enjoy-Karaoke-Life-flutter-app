import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/room_state_models.dart';
import '../services/api_client.dart';
import '../services/room_api.dart';

class GameResultScreen extends StatefulWidget {
  final String roomCode;
  const GameResultScreen({super.key, required this.roomCode});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  late final api = RoomApi(ApiClient.instance.dio);
  RoomStateResponse? state;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await api.fetchState(code: widget.roomCode, sinceVersion: 0);
    if (!mounted) return;
    setState(() {
      state = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final teams = [...state!.teams]
      ..sort((a, b) => b.totalPoint.compareTo(a.totalPoint));

    return Scaffold(
      appBar: AppBar(title: const Text('ゲーム結果')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: teams.length,
                itemBuilder: (_, i) {
                  final t = teams[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(t.name),
                      trailing: Text(
                        '${t.totalPoint} pt',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/room-entry'),
              child: const Text('ホームへ'),
            ),
          ],
        ),
      ),
    );
  }
}