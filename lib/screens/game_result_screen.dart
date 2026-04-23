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
  bool loading = true;
  RoomStateResponse? state;

  Timer? timer;
  int sinceVersion = 0;

  @override
  void initState() {
    super.initState();
    _poll();
    timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    final res = await api.fetchState(code: widget.roomCode, sinceVersion: sinceVersion);
    if (!mounted) return;

    if (res.changed) {
      sinceVersion = res.version;
      state = res;
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (state == null) return const Scaffold(body: Center(child: Text('結果取得に失敗')));

    final teams = [...state!.teams]..sort((a, b) => b.totalPoint.compareTo(a.totalPoint));

    return Scaffold(
      appBar: AppBar(title: Text('結果（${widget.roomCode}）')),
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
                      trailing: Text('${t.totalPoint} pt', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/room-entry'),
              child: const Text('ホームへ'),
            )
          ],
        ),
      ),
    );
  }
}