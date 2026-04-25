import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:more_enjoy_karaoke_life/components/common/common_app_bar.dart';
import '../services/api_client.dart';
import '../services/room_api.dart';
import '../services/user_local_store.dart';
import '../models/room_state_models.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';

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
  bool isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  String _selectedColorHex = '#2196F3';

  // カラーバリエーションの定義
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'ブルー', 'hex': '#2196F3', 'color': Colors.blue},
    {'name': 'レッド', 'hex': '#F44336', 'color': Colors.red},
    {'name': 'グリーン', 'hex': '#4CAF50', 'color': Colors.green},
    {'name': 'イエロー', 'hex': '#FFEB3B', 'color': Colors.yellow},
    {'name': 'オレンジ', 'hex': '#FF9800', 'color': Colors.orange},
    {'name': 'パープル', 'hex': '#9C27B0', 'color': Colors.purple},
    {'name': 'ピンク', 'hex': '#E91E63', 'color': Colors.pink},
  ];

  @override
  void initState() {
    super.initState();
    _init();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    myUserId = await store.getUserId();
    if (myUserId == null && mounted) {
      context.go('/profile_edit');
      return;
    }

    try {
      state = await api.fetchState(code: widget.roomCode, sinceVersion: 0);
      final teamId = _getMyTeamId();
      if (teamId != null) {
        final team = state!.teams.firstWhere((t) => t.id == teamId);
        _nameController.text = team.name;
        _selectedColorHex = team.colorHex ?? '#2196F3';
      }
    } catch (e) {
      debugPrint('Error: $e');
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  int? _getMyTeamId() {
    if (state == null || myUserId == null) return null;

      // 1. まず、自分の roomUser を探す
      final myRoomUser = state!.roomUsers.firstWhereOrNull((ru) => ru.userId == myUserId);
      if (myRoomUser == null) return null;

      // 2. turns ではなく、全チームの中から自分がメンバーに含まれているチームを直接探す
      // (TeamDto に members が含まれている前提、もしくはこちらの判定の方が確実です)
      final myTeam = state!.teams.firstWhereOrNull((team) {
        // チームに紐づくメンバーの中に、自分の roomUserId があるかチェック
        // ※ state!.turns を使う場合は、現在のセット番号を考慮するようにします
        return state!.turns.any((t) => t.teamId == team.id && t.roomUserId == myRoomUser.id);
      });

      return myTeam?.id;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final teamId = _getMyTeamId();
    if (teamId == null) return const Scaffold(body: Center(child: Text('所属チームが見つかりません')));

    final int nameLength = _nameController.text.length;
    final bool isOver = nameLength > 10; // チーム名は10文字制限と仮定
    final bool isValid = nameLength >= 1 && !isOver && !isSaving;

    return Scaffold(
      appBar: const CommonAppBar(title: 'チーム設定'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('チームの個性を出そう！',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),

            const Text('チーム名', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '10文字以内で入力してください',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isOver ? Colors.red : Colors.lightBlue.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isOver ? Colors.red : Colors.lightBlue, width: 2),
                ),
              ),
            ),
            Text(
              isOver ? '${nameLength - 10}文字オーバーしています' : 'あと${10 - nameLength}文字入力できます',
              style: TextStyle(color: isOver ? Colors.red : Colors.black54, fontSize: 12),
            ),

            const SizedBox(height: 40),

            const Text('チームカラー', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // カラー選択（グリッド表示のラジオボタン風）
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorOptions.map((opt) {
                final bool isSelected = _selectedColorHex == opt['hex'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorHex = opt['hex']),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: opt['color'],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (isSelected) const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                      ],
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 60),

            Center(
              child: CommonButton(
                text: isSaving ? '保存中...' : '設定を保存する',
                onPressed: isValid ? () async {
                  setState(() => isSaving = true);
                  try {
                    await api.updateTeam(
                      code: widget.roomCode,
                      teamId: teamId,
                      requestedBy: myUserId!,
                      name: _nameController.text,
                      colorHex: _selectedColorHex,
                    );
                    if (!mounted) return;
                    showCustomSnackBar(
                      context,
                      message: 'チーム設定を保存しました',
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('保存に失敗しちゃった…')),
                    );
                  } finally {
                    if (mounted) setState(() => isSaving = false);
                  }
                } : () {}, // 無効時は何もしない（CommonButtonの仕様に合わせる）
              ),
            ),
          ],
        ),
      ),
    );
  }
}