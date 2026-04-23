import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/room_state_models.dart';
import '../services/api_client.dart';
import '../services/room_api.dart';
import '../services/user_local_store.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';

class RoomLobbyScreen extends StatefulWidget {
  final String roomCode;
  const RoomLobbyScreen({super.key, required this.roomCode});

  @override
  State<RoomLobbyScreen> createState() => _RoomLobbyScreenState();
}

class _RoomLobbyScreenState extends State<RoomLobbyScreen> {
  final store = UserLocalStore();
  late final api = RoomApi(ApiClient.instance.dio);

  Timer? timer;
  int sinceVersion = 0;
  RoomStateResponse? state;
  int? myUserId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    myUserId = await store.getUserId();
    if (myUserId == null && mounted) {
      context.go('/profile_edit');
      return;
    }
    await _pollOnce();
    timer = Timer.periodic(const Duration(seconds: 2), (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    try {
      final res = await api.fetchState(code: widget.roomCode, sinceVersion: sinceVersion);

      if (!mounted) return;

      if (res.changed) {
        sinceVersion = res.version;
        state = res;
      }

      loading = false;
      setState(() {});

      // ✅ statusで遷移（全員同期）
      final room = state?.room;
      if (room != null && room.status == 'playing') {
        context.go('/room/${widget.roomCode}/best-match');
      }
      if (room != null && room.status == 'finished') {
        // いずれ結果画面へ。今は仮でEntryへ戻す
        context.go('/room-entry');
      }
    } catch (e) {
      if (!mounted) return;
      context.go('/error', extra: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = state?.room;
    final isAdmin = (room != null && myUserId != null && room.adminUserId == myUserId);

    return Scaffold(
      appBar: AppBar(
        title: Text('ルーム ${widget.roomCode}'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (state == null
          ? const Center(child: Text('状態取得に失敗しました'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ステータス：${room?.status}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('参加者一覧', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: state!.roomUsers.length,
                itemBuilder: (_, i) {
                  final ru = state!.roomUsers[i];
                  return ListTile(
                    leading: UserAvatar(iconPath: ru.isGuest ? ru.guestIconPath : ru.user?.iconPath),
                    title: Text(ru.displayName()),
                    subtitle: Text(ru.isGuest ? 'ゲスト' : 'ユーザーID: ${ru.userId ?? '-'}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            if (isAdmin) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text('あなたは管理者です ✅', style: TextStyle(color: Colors.blue.shade700)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  context.go('/room/${widget.roomCode}/shuffle');
                },
                child: const Text('チーム分け画面へ'),
              ),
            ] else ...[
              Text('管理者がチーム分けを開始するまで待ってね！', style: TextStyle(color: Colors.grey.shade700)),
            ]
          ],
        ),
      )),
    );
  }
}