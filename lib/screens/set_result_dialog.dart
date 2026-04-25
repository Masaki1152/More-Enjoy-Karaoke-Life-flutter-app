import 'package:flutter/material.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';

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
      title: Text('セット $setNo 結果確認', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            ...results.map((r) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    // ベストマッチならアイコン、そうでなければ空白
                    SizedBox(
                      width: 30,
                      child: r.isBestMatch
                          ? const Text('✨', style: TextStyle(fontSize: 18))
                          : const Text(' '),
                    ),
                    // チーム名
                    Expanded(
                      child: Text(
                        r.teamName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // 差
                    Text('差：${r.diff}', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 16),
                    // ポイント
                    Text(
                      '+${r.point}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            const SizedBox(height: 16),
            // ✅ CommonButton を使用
            Center(
              child: CommonButton(
                text: 'OK',
                onPressed: () => Navigator.pop(context, true), // 確定のために true を返す
              ),
            ),
          ],
        ),
      ),
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