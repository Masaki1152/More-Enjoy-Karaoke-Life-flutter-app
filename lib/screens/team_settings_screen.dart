import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:more_enjoy_karaoke_life/components/common/common_app_bar.dart';
import '../services/api_client.dart';
import '../services/room_api.dart';
import '../services/user_local_store.dart';
import '../models/room_state_models.dart';

class TeamSettingsScreen extends StatefulWidget {
  final String roomCode;
  const TeamSettingsScreen({super.key, required this.roomCode});

  @override
  State<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends State<TeamSettingsScreen> {
  final store = UserLocalStore();
  late final api = RoomApi(ApiClient.instance.dio);

  int? myUserId;
  RoomStateResponse? state;
  bool loading = true;

  final Map<int, TextEditingController> nameControllers = {};
  final Map<int, TextEditingController> colorControllers = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    myUserId = await store.getUserId();
    if (myUserId == null && mounted) {
      context.go('/profile_edit');
      return;
    }

    state = await api.fetchState(code: widget.roomCode, sinceVersion: 0);

    for (final t in state!.teams) {
      nameControllers[t.id] = TextEditingController(text: t.name);
      colorControllers[t.id] = TextEditingController(text: t.colorHex ?? '');
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  int? myTeamId() {
    if (state == null || myUserId == null) return null;
    try {
      final myRoomUser = state!.roomUsers
          .where((ru) => ru.userId == myUserId)
          .firstOrNull;

      if (myRoomUser == null) return null;

      final myTurn = state!.turns
          .where((t) => t.roomUserId == myRoomUser.id)
          .firstOrNull;

      return myTurn?.teamId;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final teamId = myTeamId();
    if (teamId == null) {
      return const Scaffold(body: Center(child: Text('所属チームが見つかりません')));
    }

    final team = state!.teams.firstWhere((t) => t.id == teamId);

    return Scaffold(
      appBar: CommonAppBar(title: 'チーム設定'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('あなたのチーム：${team.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: nameControllers[team.id],
              decoration: const InputDecoration(labelText: 'チーム名'),
            ),
            TextField(
              controller: colorControllers[team.id],
              decoration: const InputDecoration(labelText: 'カラー（例: #FFAA00）'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await api.updateTeam(
                  code: widget.roomCode,
                  teamId: team.id,
                  requestedBy: myUserId!,
                  name: nameControllers[team.id]!.text,
                  colorHex: colorControllers[team.id]!.text,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('チーム設定を更新したよ！')),
                );
              },
              child: const Text('保存'),
            )
          ],
        ),
      ),
    );
  }
}