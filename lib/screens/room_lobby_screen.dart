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
  int? selectedAdminUserId;
  bool adminChanging = false;

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

      if (state == null || res.changed) {
        sinceVersion = res.version;
        state = res;

        final room = state?.room;
        if (room != null) {
          final candidates = state!.roomUsers.where((ru) => !ru.isGuest && ru.userId != null).toList();

          if (candidates.isNotEmpty) {
            selectedAdminUserId ??= room.adminUserId;
            final exists = candidates.any((ru) => ru.userId == selectedAdminUserId);
            if (!exists) selectedAdminUserId = candidates.first.userId;
          }
        }
      }

      final room = state?.room;
      if (room == null) return;

      if (room.status == 'playing') {
        timer?.cancel();
        context.go('/room/${widget.roomCode}/best-match');
        return;
      }

      if (room.status == 'finished') {
        timer?.cancel();
        context.go('/room-entry');
        return;
      }

      loading = false;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      context.push('/error', extra: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = state?.room;
    final isAdmin = (room != null && myUserId != null && room.adminUserId == myUserId);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'ルーム ${widget.roomCode}',
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
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: state!.roomUsers.length,
                itemBuilder: (_, i) {
                  final ru = state!.roomUsers[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: UserListCell(
                      iconPath: ru.isGuest ? ru.guestIconPath : ru.user?.iconPath,
                      userName: ru.displayName(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            if (isAdmin) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text('あなたは管理者です ✅', style: TextStyle(color: Colors.blue.shade700)),
              const SizedBox(height: 12),

              // ✅ 管理者選択UI（ゲスト除外）
              const Text('管理者を選択（参加者のみ）', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              DropdownButton<int>(
                isExpanded: true,
                value: selectedAdminUserId,
                items: state!.roomUsers
                    .where((ru) => !ru.isGuest && ru.userId != null)
                    .map((ru) => DropdownMenuItem<int>(
                  value: ru.userId!,
                  child: Text(ru.displayName()),
                ))
                    .toList(),
                onChanged: adminChanging ? null : (v) => setState(() => selectedAdminUserId = v),
              ),

              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: (selectedAdminUserId == null || adminChanging)
                    ? null
                    : () async {
                  setState(() => adminChanging = true);
                  try {
                    await api.setAdmin(
                      code: widget.roomCode,
                      requestedBy: myUserId!, // 現管理者が実行
                      newAdminUserId: selectedAdminUserId!,
                    );
                    // すぐ反映したいなら即ポーリング
                    await _pollOnce();
                  } catch (e) {
                    if (!mounted) return;
                    context.push('/error', extra: e.toString());
                  } finally {
                    if (mounted) setState(() => adminChanging = false);
                  }
                },
                child: adminChanging ? const Text('変更中...') : const Text('この人を管理者にする'),
              ),

              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  context.push('/room/${widget.roomCode}/shuffle');
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