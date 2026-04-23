import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_client.dart';
import '../services/room_api.dart';
import '../services/user_local_store.dart';
import 'room_search_dialog.dart';

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
      appBar: AppBar(title: const Text('ルーム作成 / 参加')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('もっとEnjoy!カラオケLIFE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: loading
                    ? null
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
                child: loading ? const CircularProgressIndicator() : const Text('ルームを作成する'),
              ),
              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: loading
                    ? null
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
                child: const Text('ルームに参加する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}