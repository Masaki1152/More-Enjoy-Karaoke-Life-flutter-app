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
        decoration: InputDecoration(hintText: '例：1234', errorText: errorText),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: loading ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.lightBlue),
          ),
          child: const Text(
            'キャンセル',
            style: TextStyle(
              color: Colors.lightBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: loading ? null : () async {},
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.lightBlue),
          ),
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(),
                )
              : const Text(
                  '参加する',
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
