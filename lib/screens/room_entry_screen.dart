import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_client.dart';
import '../services/room_api.dart';
import '../services/user_local_store.dart';
import 'room_search_dialog.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';
import 'package:more_enjoy_karaoke_life/conf/constantDev.dart';

class RoomEntryScreen extends StatefulWidget {
  const RoomEntryScreen({super.key});

  @override
  State<RoomEntryScreen> createState() => _RoomEntryScreenState();
}

class _RoomEntryScreenState extends State<RoomEntryScreen> {
  final store = UserLocalStore();
  late final api = RoomApi(ApiClient.instance.dio);
  bool loading = false;

  Future<int?> _requireUserId() async {
    final userId = await store.getUserId();
    if (userId == null && mounted) {
      context.go('/user/edit');
      return null;
    }
    return userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'ルーム作成 / 参加'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GameCard(imagePath: ConstantDev.gameBestMatchIconPath, onTap: () {}),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: SquareMenuButton(
                    text: 'ルームを作成',
                    onPressed: loading
                        ? () {}
                        : () async {
                            setState(() => loading = true);
                            try {
                              final userId = await _requireUserId();
                              if (userId == null) return;
                              final code = await api.createRoom(userId: userId);
                              if (!mounted) return;
                              context.go('/room/$code/lobby');
                            } catch (e) {
                              if (!mounted) return;
                              context.go('/error', extra: e.toString());
                            } finally {
                              if (mounted) setState(() => loading = false);
                            }
                          },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SquareMenuButton(
                    text: 'ルームに参加',
                    onPressed: loading
                        ? () {}
                        : () async {
                            final userId = await _requireUserId();
                            if (userId == null) return;
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (_) => RoomSearchDialog(
                                onJoined: (code) {
                                  context.go('/room/$code/lobby');
                                },
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
