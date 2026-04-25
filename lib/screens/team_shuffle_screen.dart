import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/room_state_models.dart';
import '../services/api_client.dart';
import '../services/room_api.dart';
import '../services/user_local_store.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';

class TeamShuffleScreen extends StatefulWidget {
  final String roomCode;
  const TeamShuffleScreen({super.key, required this.roomCode});

  @override
  State<TeamShuffleScreen> createState() => _TeamShuffleScreenState();
}

class _TeamShuffleScreenState extends State<TeamShuffleScreen> with SingleTickerProviderStateMixin {
  final store = UserLocalStore();
  late final api = RoomApi(ApiClient.instance.dio);

  int? myUserId;
  RoomStateResponse? state;

  bool loading = true;
  bool shuffling = false;
  bool previewReady = false;

  List<RoomUserDto> previewMembers = [];
  List<List<RoomUserDto>> previewTeams = [];

  Timer? animTimer;
  int tick = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    animTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    myUserId = await store.getUserId();
    if (myUserId == null && mounted) {
      context.go('/profile_edit');
      return;
    }

    await _loadState();
    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> _loadState() async {
    final res = await api.fetchState(code: widget.roomCode, sinceVersion: 0);
    state = res;
  }

  bool get isAdmin {
    final room = state?.room;
    if (room == null || myUserId == null) return false;
    return room.adminUserId == myUserId;
  }

  List<RoomUserDto> _applySpecialSort(List<RoomUserDto> members) {
    // 1. 対象の2人を抽出
    final specialPair = members.where((m) {
      final bday = m.user?.birthday;
      if (bday == null) return false;
      // Laravel側と同じ日付をチェック (フォーマットに合わせて調整してください)
      return bday.contains('05-02') || bday.contains('01-11');
    }).toList();

    // 2. もし2人とも揃っていたら「八百長」発動
    if (specialPair.length == 2) {
      // 残りのメンバーを取得してシャッフル
      final others = members.where((m) => !specialPair.contains(m)).toList()..shuffle();
      // 先頭に特定の2人を置いて、残りを結合（これでこの2人がチーム1になる）
      return [...specialPair, ...others];
    }

    // 3. 揃っていなければ普通のランダム
    return members..shuffle();
  }

  Future<void> playShuffleAnimation() async {
    if (state == null) return;

    // 参加者（room_users）から仮プレビュー用に作る
    final members = List<RoomUserDto>.from(state!.roomUsers);

    // 奇数ならゲスト仮追加（サーバでも実際追加される）
    if (members.length.isOdd) {
      members.add(RoomUserDto(
        id: -1,
        userId: null,
        isGuest: true,
        guestName: 'ゲスト(仮)',
        guestIconPath: null,
        user: null,
      ));
    }

    previewMembers = members;

    setState(() {
      shuffling = true;
      previewReady = false;
      tick = 0;
    });

    final rand = Random();

    // 簡易アニメ：一定回数シャッフルして見せる
    animTimer?.cancel();
    final completer = Completer<void>();
    animTimer = Timer.periodic(const Duration(milliseconds: 120), (t) {
      tick++;

      if (tick >= 18) {
        t.cancel();

        // ✅ ここで「ランダム」ではなく「八百長ロジック」を適用したリストを作る
        final sortedMembers = _applySpecialSort(List<RoomUserDto>.from(previewMembers));

        // 2人ずつのチームに分割してプレビュー表示
        previewTeams = [];
        for (int i = 0; i < sortedMembers.length; i += 2) {
          previewTeams.add([sortedMembers[i], sortedMembers[i + 1]]);
        }

        setState(() {
          previewMembers = sortedMembers; // 画面表示用リストも更新
          shuffling = false;
          previewReady = true;
        });
        completer.complete();
      } else {
        // 途中経過（17回目まで）は完全にランダムに見せる
        setState(() {
          previewMembers.shuffle();
        });
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('チーム分け')),
        body: const Center(child: Text('この画面は管理者のみ表示できます。')),
      );
    }

    return Scaffold(
      appBar: const CommonAppBar(title: 'チーム分け（管理者）'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: double.infinity),
            const Text(
              '「チーム分けをする」で混ぜる演出 → プレビュー表示\n→ 「ゲーム開始」でサーバに確定！',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 1. チーム分けボタン (CommonButton)
            if (!previewReady)
              CommonButton(
                text: shuffling ? 'シャッフル中...' : 'チーム分けをする',
                onPressed: (shuffling) ? () {} : () async => await playShuffleAnimation(),
              ),

            const SizedBox(height: 20),

            // シャッフル中の演出
            if (shuffling) ...[
              const Text('混ぜてるよ〜！', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _MembersGrid(members: previewMembers),
            ],

            // 2. プレビュー表示 (UserListCellを横並び)
            if (previewReady) ...[
              const Text('このチームで確定したよ！', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: previewTeams.length,
                  itemBuilder: (_, idx) {
                    final t = previewTeams[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // チームごとに淡い青色の背景
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withAlpha(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(' チーム ${idx + 1}',
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // ペアを横並びに配置
                              Expanded(
                                child: UserListCell(
                                  iconPath: t[0].isGuest ? t[0].guestIconPath : t[0].user?.iconPath,
                                  userName: t[0].displayName(),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text('×', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: UserListCell(
                                  iconPath: t[1].isGuest ? t[1].guestIconPath : t[1].user?.iconPath,
                                  userName: t[1].displayName(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 3. ゲーム開始ボタン (CommonButton)
              CommonButton(
                text: 'ゲーム開始',
                onPressed: () async {
                  try {
                    await api.shuffleTeams(code: widget.roomCode, requestedBy: myUserId!);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('チーム分けを確定したよ！')),
                    );
                    context.push('/room/${widget.roomCode}/lobby');
                  } catch (e) {
                    if (!mounted) return;
                    context.push('/error', extra: e.toString());
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _MembersGrid extends StatelessWidget {
  final List<RoomUserDto> members;
  const _MembersGrid({required this.members});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: members
          .map((m) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(iconPath: m.isGuest ? m.guestIconPath : m.user?.iconPath, size: 48),
          const SizedBox(height: 4),
          Text(m.displayName(), style: const TextStyle(fontSize: 12)),
        ],
      ))
          .toList(),
    );
  }
}

class _MemberChip extends StatelessWidget {
  final RoomUserDto member;
  const _MemberChip({required this.member});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: UserAvatar(iconPath: member.isGuest ? member.guestIconPath : member.user?.iconPath, size: 28),
      label: Text(member.displayName()),
    );
  }
}