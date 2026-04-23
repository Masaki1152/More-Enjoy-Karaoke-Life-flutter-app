import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/room_api.dart';
import '../services/user_local_store.dart';

class RoomSearchDialog extends StatefulWidget {
  final void Function(String code) onJoined;

  const RoomSearchDialog({super.key, required this.onJoined});

  @override
  State<RoomSearchDialog> createState() => _RoomSearchDialogState();
}

class _RoomSearchDialogState extends State<RoomSearchDialog> {
  final controller = TextEditingController();
  final store = UserLocalStore();
  late final api = RoomApi(ApiClient.instance.dio);

  bool loading = false;
  String? errorText;

  bool _isValidCode(String code) {
    final reg = RegExp(r'^\d{4}$');
    return reg.hasMatch(code);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ルームIDを入力'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 4,
        decoration: InputDecoration(
          hintText: '例：1234',
          errorText: errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
            final code = controller.text.trim();
            if (!_isValidCode(code)) {
              setState(() => errorText = '4桁の数字で入力してね！');
              return;
            }

            final userId = await store.getUserId();
            if (userId == null) {
              setState(() => errorText = 'ユーザー登録が必要だよ！');
              return;
            }

            setState(() {
              loading = true;
              errorText = null;
            });

            try {
              await api.joinRoom(code: code, userId: userId);
              if (!mounted) return;
              Navigator.pop(context);
              widget.onJoined(code);
            } catch (_) {
              if (!mounted) return;
              setState(() => errorText = 'ルームが見つからない/参加できないよ…');
            } finally {
              if (mounted) setState(() => loading = false);
            }
          },
          child: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : const Text('参加する'),
        ),
      ],
    );
  }
}