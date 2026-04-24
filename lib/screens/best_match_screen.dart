import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/room_state_models.dart';
import '../services/api_client.dart';
import '../services/room_api.dart';
import '../services/user_local_store.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';
import 'package:collection/collection.dart';
import 'score_input_dialog.dart';
import 'set_result_dialog.dart';

class BestMatchScreen extends StatefulWidget {
  final String roomCode;
  const BestMatchScreen({super.key, required this.roomCode});

  @override
  State<BestMatchScreen> createState() => _BestMatchScreenState();
}

class _BestMatchScreenState extends State<BestMatchScreen> {
  final store = UserLocalStore();
  late final api = RoomApi(ApiClient.instance.dio);

  Timer? timer;
  int sinceVersion = 0;
  RoomStateResponse? state;
  int? myUserId;

  bool loading = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    myUserId = await store.getUserId();
    if (myUserId == null && mounted) {
      context.go('/user/edit');
      return;
    }
    await _pollOnce();
    timer = Timer.periodic(const Duration(seconds: 2), (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    try {
      final res = await api.fetchState(code: widget.roomCode, sinceVersion: sinceVersion);

      if (!mounted) return;

      if (res.changed) {
        sinceVersion = res.version;
        state = res;
      }

      loading = false;
      setState(() {});

      // statusで自動遷移
      final room = state?.room;
      if (room != null && room.status == 'finished') {
        context.go('/room/${widget.roomCode}/result');
      }
      if (room != null && room.status != 'playing') {
        // playing以外に戻ったらロビーへ
        context.go('/room/${widget.roomCode}/lobby');
      }
    } catch (e) {
      if (!mounted) return;
      context.go('/error', extra: e.toString());
    }
  }

  bool get isAdmin {
    final room = state?.room;
    return room != null && myUserId != null && room.adminUserId == myUserId;
  }

  RoomSetDto? get currentSet {
    if (state == null) return null;
    final setNo = state!.room?.currentSetNo ?? 1;
    return state!.sets.where((s) => s.setNo == setNo).cast<RoomSetDto?>().firstWhere((e) => true, orElse: () => null);
  }

  RoomUserDto? findRoomUserById(int roomUserId) {
    return state?.roomUsers.firstWhereOrNull((ru) => ru.id == roomUserId);
  }

  ScoreDto? findScore(int setId, int roomUserId) {
    final set = state?.sets.firstWhereOrNull((s) => s.id == setId);
    if (set == null) return null;
    return set.scores.firstWhereOrNull((sc) => sc.roomUserId == roomUserId);
  }

  List<TeamDto> topTeams(int n) {
    final teams = [...(state?.teams ?? [])];
    teams.sort((a, b) => b.totalPoint.compareTo(a.totalPoint));
    return teams.take(n).toList();
  }

  bool allScoresEnteredForCurrentSet() {
    final set = currentSet;
    if (set == null) return false;

    // ⚠️ ゲストがいると user_id 方式では入力できず confirm に失敗する可能性あり
    // MVP: ゲストがいたら false にして警告を出す
    final hasGuest = (state?.roomUsers.any((ru) => ru.userId == null) ?? false);
    if (hasGuest) return false;

    return set.scores.length >= (state?.roomUsers.length ?? 0);
  }

  /// フロント側で結果を“予測”してダイアログに出す（サーバ確定前）
  List<ComputedSetResult> computePreviewResultsForCurrentSet() {
    final set = currentSet!;
    final teams = state!.teams;

    // teamId -> digits list
    final Map<int, List<int>> digitsByTeam = {};
    for (final sc in set.scores) {
      digitsByTeam.putIfAbsent(sc.teamId, () => []);
      digitsByTeam[sc.teamId]!.add(sc.thirdDigit);
    }

    // diff計算（2人想定）
    final Map<int, int> diffMap = {};
    for (final t in teams) {
      final digits = digitsByTeam[t.id] ?? [];
      final a = digits.isNotEmpty ? digits[0] : 0;
      final b = digits.length > 1 ? digits[1] : 0;
      diffMap[t.id] = (a - b).abs();
    }

    final minDiff = diffMap.values.isEmpty ? 0 : diffMap.values.reduce((a, b) => a < b ? a : b);
    final hasBestMatch = diffMap.values.any((d) => d == 0);

    final results = <ComputedSetResult>[];
    for (final t in teams) {
      final diff = diffMap[t.id] ?? 0;
      final isBest = diff == 0;
      final point = hasBestMatch ? (isBest ? 5 : 0) : (diff == minDiff ? 1 : 0);
      results.add(ComputedSetResult(teamId: t.id, teamName: t.name, diff: diff, point: point, isBestMatch: isBest));
    }

    // 表示を“ポイント降順”
    results.sort((a, b) => b.point.compareTo(a.point));
    return results;
  }

  bool hasBestMatchPreview(List<ComputedSetResult> computed) => computed.any((e) => e.isBestMatch);

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (state == null) return const Scaffold(body: Center(child: Text('状態取得に失敗')));

    final room = state!.room!;
    final set = currentSet;
    final top3 = topTeams(3);

    return Scaffold(
      appBar: AppBar(
        title: Text('ベストマッチ（${widget.roomCode}）'),
        actions: [
          IconButton(
            onPressed: () => context.go('/room/${widget.roomCode}/team-settings'),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ✅ 上部：暫定上位3チーム
            _TopTeamsBar(top3: top3),

            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  Text('現在セット：${room.currentSetNo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  if (set == null)
                    const Text('セット情報がありません（サーバがsetを作っていない可能性）')
                  else
                    _CurrentSetList(
                      set: set,
                      turns: state!.turns,
                      findRoomUserById: findRoomUserById,
                      findScore: findScore,
                      onEdit: (turn, existingScore) async {
                        // ゲストは user_id が無いので入力不可（MVP）
                        final ru = findRoomUserById(turn.roomUserId);
                        if (ru == null) return;
                        if (ru.userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ゲストの点数入力はMVPでは未対応（偶数人数で遊んでね）')),
                          );
                          return;
                        }

                        final result = await showDialog<ScoreInputResult>(
                          context: context,
                          builder: (_) => ScoreInputDialog(
                            displayName: turn.displayName,
                            initialSong: existingScore?.songName,
                            initialScore: existingScore?.scoreRaw,
                          ),
                        );

                        if (result == null) return;

                        setState(() => submitting = true);
                        try {
                          await api.upsertScore(
                            code: widget.roomCode,
                            setNo: set.setNo,
                            userId: ru.userId!, // ✅ user_id方式
                            songName: result.songName,
                            scoreRaw: result.scoreRaw,
                          );
                          // 次ポーリングを待たずに即更新したいなら _pollOnce() を呼んでもOK
                          await _pollOnce();
                        } catch (e) {
                          if (!mounted) return;
                          context.go('/error', extra: e.toString());
                        } finally {
                          if (mounted) setState(() => submitting = false);
                        }
                      },
                      onRandom: (turn) async {
                        setState(() => submitting = true);
                        try {
                          await api.upsertGuestRandomThirdDigit(
                            code: widget.roomCode,
                            setNo: set.setNo,
                            roomUserId: turn.roomUserId,
                          );
                          await _pollOnce(); // 終わったら画面を更新！
                        } catch (e) {
                          if (!mounted) return;
                          context.go('/error', extra: e.toString());
                        } finally {
                          if (mounted) setState(() => submitting = false);
                        }
                      },
                    ),

                  const SizedBox(height: 12),
                  const Divider(),

                  // ✅ 過去セット一覧（結果があれば表示）
                  const Text('履歴', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._buildHistoryCards(state!.sets, state!.teams),
                ],
              ),
            ),

            // ✅ 下部：確定＆終了
            if (submitting) const LinearProgressIndicator(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (!isAdmin || set == null || !allScoresEnteredForCurrentSet() || submitting)
                        ? null
                        : () async {
                      final preview = computePreviewResultsForCurrentSet();
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => SetResultDialog(
                          setNo: set.setNo,
                          computed: preview,
                          hasBestMatch: hasBestMatchPreview(preview),
                        ),
                      );

                      if (ok != true) return;

                      setState(() => submitting = true);
                      try {
                        await api.confirmSet(code: widget.roomCode, setNo: set.setNo, requestedBy: myUserId!);
                        await _pollOnce();
                      } catch (e) {
                        if (!mounted) return;
                        context.go('/error', extra: e.toString());
                      } finally {
                        if (mounted) setState(() => submitting = false);
                      }
                    },
                    child: const Text('確定'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: (!isAdmin || submitting)
                        ? null
                        : () async {
                      setState(() => submitting = true);
                      try {
                        await api.finish(code: widget.roomCode, requestedBy: myUserId!);
                        await _pollOnce();
                        if (!mounted) return;
                        context.go('/room/${widget.roomCode}/result');
                      } catch (e) {
                        if (!mounted) return;
                        context.go('/error', extra: e.toString());
                      } finally {
                        if (mounted) setState(() => submitting = false);
                      }
                    },
                    child: const Text('終了する'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHistoryCards(List<RoomSetDto> sets, List<TeamDto> teams) {
    final history = [...sets]..sort((a, b) => a.setNo.compareTo(b.setNo));
    // 現在セットは一番下で表示しているので履歴は「確定済みのみ」
    final confirmed = history.where((s) => s.isConfirmed).toList();
    if (confirmed.isEmpty) return [const Text('まだ履歴がないよ')];

    String teamName(int teamId) => teams.firstWhere((t) => t.id == teamId, orElse: () => TeamDto(id: teamId, name: 'Team', totalPoint: 0, imagePath: null, colorHex: null)).name;

    return confirmed.map((s) {
      final results = s.results;
      return ExpansionTile(
        title: Text('セット ${s.setNo}（確定）'),
        children: [
          if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('結果がありません'),
            )
          else
            ...results.map((r) {
              return ListTile(
                title: Text(teamName(r.teamId)),
                subtitle: Text(r.isBestMatch ? 'ベストマッチ（差=0）' : '差=${r.diffValue}'),
                trailing: Text('+${r.point}'),
              );
            }),
        ],
      );
    }).toList();
  }
}

class _TopTeamsBar extends StatelessWidget {
  final List<TeamDto> top3;
  const _TopTeamsBar({required this.top3});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (i) {
            final t = (i < top3.length) ? top3[i] : null;
            return Column(
              children: [
                Text('暫定${i + 1}位', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(t?.name ?? '---', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${t?.totalPoint ?? 0} pt'),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CurrentSetList extends StatelessWidget {
  final RoomSetDto set;
  final List<TurnDto> turns;
  final RoomUserDto? Function(int roomUserId) findRoomUserById;
  final ScoreDto? Function(int setId, int roomUserId) findScore;
  final Future<void> Function(TurnDto turn, ScoreDto? existingScore) onEdit;
  final Future<void> Function(TurnDto turn) onRandom;

  const _CurrentSetList({
    required this.set,
    required this.turns,
    required this.findRoomUserById,
    required this.findScore,
    required this.onEdit,
    required this.onRandom,
  });

  @override
  Widget build(BuildContext context) {
    // turnsはサーバが current_set_no 用に返している想定
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('セット ${set.setNo}'),
            subtitle: Text(set.isConfirmed ? '確定済み' : '入力中'),
          ),
          const Divider(height: 1),
          ...turns.map((turn) {
            final ru = findRoomUserById(turn.roomUserId);
            final score = findScore(set.id, turn.roomUserId);

            return ListTile(
              leading: UserAvatar(iconPath: turn.iconPath, size: 40),
              title: Text('${turn.teamName} / ${turn.displayName}'),
              subtitle: Text(
                score == null
                    ? '未入力'
                    : '点数: ${score.scoreRaw}（3桁目: ${score.thirdDigit}）\n曲: ${score.songName ?? "-"}',
              ),
              trailing: ru?.userId == null
                  ? IconButton(
                icon: const Icon(Icons.casino, color: Colors.purple),
                onPressed: () => onRandom(turn),
              )
                  : IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onEdit(turn, score),
              ),
            );
          }),
        ],
      ),
    );
  }
}