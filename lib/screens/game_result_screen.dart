import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/room_state_models.dart';
import '../services/api_client.dart';
import '../services/room_api.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';

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

    // スコア順にソート
    final teams = [...state!.teams]
      ..sort((a, b) => b.totalPoint.compareTo(a.totalPoint));

    // 優勝チーム名を取得（ソート済みなので最初の要素）
    final winnerName = teams.isNotEmpty ? teams.first.name : '不明';

    return Scaffold(
      appBar: CommonAppBar(title: '最終結果'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ 優勝お祝いメッセージ
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    '🎉 お疲れさまでした！ 🎉',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('今回の優勝は...', style: TextStyle(fontSize: 16)),
                  Text(
                    winnerName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text('チームでした！！', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ✅ 各チームの結果（ランキング形式）
            Expanded(
              child: ListView.builder(
                itemCount: teams.length,
                itemBuilder: (_, i) {
                  final t = teams[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white, // 背景白
                      border: Border.all(color: Colors.lightBlue.shade200, width: 2), // 枠線ライトブルー
                      borderRadius: BorderRadius.circular(12), // 角丸12px
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: i == 0 ? Colors.orange : Colors.grey.shade200,
                        foregroundColor: i == 0 ? Colors.white : Colors.black,
                        child: Text('${i + 1}'),
                      ),
                      title: Text(
                        t.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${t.totalPoint} pt',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            // ✅ ホームへ戻るボタン
            CommonButton(
              text: 'ホームへ',
              onPressed: () => context.go('/'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}