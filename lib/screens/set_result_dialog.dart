import 'package:flutter/material.dart';
import '../models/room_state_models.dart';

class SetResultDialog extends StatelessWidget {
  final int setNo;
  final List<ComputedSetResult> computed;
  final bool hasBestMatch;

  const SetResultDialog({
    super.key,
    required this.setNo,
    required this.computed,
    required this.hasBestMatch,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('セット結果（$setNo）'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasBestMatch)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('🎯 ベストマッチ発生！ +5', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ...computed.map((r) {
            return ListTile(
              title: Text(r.teamName),
              subtitle: Text(r.isBestMatch ? 'ベストマッチ（差=0）' : '差 = ${r.diff}'),
              trailing: Text('+${r.point}', style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          }),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('戻る')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('確定して次へ')),
      ],
    );
  }
}

class ComputedSetResult {
  final int teamId;
  final String teamName;
  final int diff;
  final int point;
  final bool isBestMatch;

  ComputedSetResult({
    required this.teamId,
    required this.teamName,
    required this.diff,
    required this.point,
    required this.isBestMatch,
  });
}