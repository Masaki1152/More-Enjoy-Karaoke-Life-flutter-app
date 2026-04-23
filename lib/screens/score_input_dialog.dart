import 'package:flutter/material.dart';

class ScoreInputResult {
  final String songName;
  final String scoreRaw;
  ScoreInputResult(this.songName, this.scoreRaw);
}

class ScoreInputDialog extends StatefulWidget {
  final String displayName;
  final String? initialSong;
  final String? initialScore;

  const ScoreInputDialog({
    super.key,
    required this.displayName,
    this.initialSong,
    this.initialScore,
  });

  @override
  State<ScoreInputDialog> createState() => _ScoreInputDialogState();
}

class _ScoreInputDialogState extends State<ScoreInputDialog> {
  late final songController = TextEditingController(text: widget.initialSong ?? '');
  late final scoreController = TextEditingController(text: widget.initialScore ?? '');
  String? error;

  bool _isValidScore(String s) {
    // "91.002" / "90" / "88.3" など許容（サーバは文字列で3桁目抽出）
    final reg = RegExp(r'^\d{1,3}(\.\d{1,3})?$');
    return reg.hasMatch(s.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('点数入力：${widget.displayName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: songController,
            decoration: const InputDecoration(labelText: '曲名'),
          ),
          TextField(
            controller: scoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: '点数', errorText: error),
          ),
          const SizedBox(height: 8),
          const Text('例：91.002（小数第3位を使うよ）', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
        ElevatedButton(
          onPressed: () {
            final song = songController.text.trim();
            final score = scoreController.text.trim();
            if (score.isEmpty || !_isValidScore(score)) {
              setState(() => error = '点数の形式が違うかも（例：91.002）');
              return;
            }
            Navigator.pop(context, ScoreInputResult(song, score));
          },
          child: const Text('登録'),
        )
      ],
    );
  }
}