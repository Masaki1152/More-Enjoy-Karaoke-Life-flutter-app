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
      context.go('/user/edit');
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
      previewMembers.shuffle(rand);
      tick++;
      if (tick >= 18) {
        t.cancel();
        // 2人ずつのチームに分割してプレビュー表示
        previewTeams = [];
        for (int i = 0; i < previewMembers.length; i += 2) {
          previewTeams.add([previewMembers[i], previewMembers[i + 1]]);
        }
        setState(() {
          shuffling = false;
          previewReady = true;
        });
        completer.complete();
      } else {
        setState(() {});
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
      appBar: AppBar(title: const Text('チーム分け（管理者）')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('「チーム分けをする」で混ぜる演出 → プレビュー表示 → 「ゲーム開始」でサーバに確定！'),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: (shuffling || previewReady)
                  ? null
                  : () async {
                await playShuffleAnimation();
              },
              child: const Text('チーム分けをする'),
            ),

            const SizedBox(height: 12),
            if (shuffling) ...[
              const Text('混ぜてるよ〜！'),
              const SizedBox(height: 8),
              _MembersGrid(members: previewMembers),
            ],

            if (previewReady) ...[
              const SizedBox(height: 8),
              const Text('プレビュー（仮）', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: previewTeams.length,
                  itemBuilder: (_, idx) {
                    final t = previewTeams[idx];
                    return Card(
                      child: ListTile(
                        title: Text('チーム${idx + 1}'),
                        subtitle: Row(
                          children: [
                            _MemberChip(member: t[0]),
                            const SizedBox(width: 8),
                            _MemberChip(member: t[1]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // ✅ 本番確定：サーバがゲスト追加＆チーム生成＆status=playing
                    await api.shuffleTeams(code: widget.roomCode, requestedBy: myUserId!);
                    if (!mounted) return;

                    // ✅ ここではbest-matchへ遷移しない（全員同期をLobbyポーリングに任せる）
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('チーム分けをサーバに確定したよ！みんなの画面が自動で進むよ✨')),
                    );

                    // Lobbyに戻す（管理者本人も待機へ）
                    context.go('/room/${widget.roomCode}/lobby');
                  } catch (e) {
                    if (!mounted) return;
                    context.go('/error', extra: e.toString());
                  }
                },
                child: const Text('ゲーム開始（サーバに確定）'),
              ),
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