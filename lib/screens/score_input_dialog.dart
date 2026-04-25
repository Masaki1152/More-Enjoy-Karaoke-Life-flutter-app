import 'package:flutter/material.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';

class ScoreInputResult {
  final String? songName;
  final String scoreRaw;
  ScoreInputResult({this.songName, required this.scoreRaw});
}

class ScoreInputDialog extends StatefulWidget {
  final String setLabel;
  final String displayName;
  final String? iconPath;
  final bool isGuest;
  final String? initialSong;
  final String? initialScore;

  const ScoreInputDialog({
    super.key,
    required this.setLabel,
    required this.displayName,
    required this.iconPath,
    required this.isGuest,
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
  bool loading = false; // ローディング状態を追加

  bool _isValidScore(String s) {
    final reg = RegExp(r'^\d{1,3}(\.\d{1,3})?$');
    return reg.hasMatch(s.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.setLabel} / 点数入力'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              UserAvatar(iconPath: widget.iconPath, size: 40),
              const SizedBox(width: 8),
              Text(
                widget.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 曲名（ゲストは入力不可）
          TextField(
            controller: songController,
            enabled: !widget.isGuest,
            decoration: InputDecoration(
              labelText: '曲名',
              hintText: widget.isGuest ? 'ゲストは入力不要' : null,
            ),
          ),
          TextField(
            controller: scoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '点数',
              errorText: error,
              hintText: '例：91.002',
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center, // 中央配置に設定
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
          onPressed: loading
              ? null
              : () async {
            final score = scoreController.text.trim();
            if (!_isValidScore(score)) {
              setState(() => error = '点数の形式が正しくありません（例：91.002）');
              return;
            }

            setState(() {
              loading = true;
              error = null;
            });

            // 擬似的な待機時間（必要に応じて削除してください）
            // await Future.delayed(const Duration(milliseconds: 500));

            if (!mounted) return;

            Navigator.pop(
              context,
              ScoreInputResult(
                songName: widget.isGuest ? null : songController.text.trim(),
                scoreRaw: score,
              ),
            );
            showCustomSnackBar(
              context,
              message: '点数を登録しました',
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.lightBlue),
          ),
          child: loading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text(
            '登録する',
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