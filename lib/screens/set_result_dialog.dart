import 'package:flutter/material.dart';
import '../models/room_state_models.dart';

class SetResultItem {
  final String teamName;
  final int diff;
  final int point;
  final bool isBestMatch;

  SetResultItem({
    required this.teamName,
    required this.diff,
    required this.point,
    required this.isBestMatch,
  });
}

class SetResultDialog extends StatelessWidget {
  final int setNo;
  final List<SetResultItem> results;

  const SetResultDialog({
    super.key,
    required this.setNo,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('セット $setNo 結果'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: results.map((r) {
          return ListTile(
            leading: r.isBestMatch
                ? const Text('◎', style: TextStyle(fontSize: 20))
                : null,
            title: Text(r.teamName),
            subtitle: Text('差：${r.diff}'),
            trailing: Text(
              '+${r.point}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
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