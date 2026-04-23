import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void dispose() {
    for (final c in nameControllers.values) { c.dispose(); }
    for (final c in colorControllers.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> _init() async {
    myUserId = await store.getUserId();
    if (myUserId == null && mounted) {
      context.go('/user/edit');
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

  bool get isAdmin {
    final room = state?.room;
    return room != null && myUserId != null && room.adminUserId == myUserId;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('チーム設定')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(isAdmin ? '管理者として編集できます' : '閲覧のみ（管理者のみ編集可能）'),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: state!.teams.length,
                itemBuilder: (_, i) {
                  final team = state!.teams[i];
                  final nameC = nameControllers[team.id]!;
                  final colorC = colorControllers[team.id]!;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('チームID: ${team.id} / 現在ポイント: ${team.totalPoint}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameC,
                            enabled: isAdmin,
                            decoration: const InputDecoration(labelText: 'チーム名'),
                          ),
                          TextField(
                            controller: colorC,
                            enabled: isAdmin,
                            decoration: const InputDecoration(labelText: 'カラー（例：#FFAA00）'),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: isAdmin
                                  ? () async {
                                try {
                                  await api.updateTeam(
                                    code: widget.roomCode,
                                    teamId: team.id,
                                    requestedBy: myUserId!,
                                    name: nameC.text.trim().isEmpty ? team.name : nameC.text.trim(),
                                    colorHex: colorC.text.trim().isEmpty ? null : colorC.text.trim(),
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('更新したよ！')),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  context.go('/error', extra: e.toString());
                                }
                              }
                                  : null,
                              child: const Text('保存'),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}