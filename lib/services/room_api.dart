import 'package:dio/dio.dart';
import '../models/room_state_models.dart';

class RoomApi {
  RoomApi(this.dio);

  final Dio dio;

  Future<String> createRoom({required int userId}) async {
    final res = await dio.post('/rooms', data: {'user_id': userId});
    return res.data['code'] as String;
  }

  Future<void> joinRoom({required String code, required int userId}) async {
    await dio.post('/rooms/$code/join', data: {'user_id': userId});
  }

  Future<void> shuffleTeams({required String code, required int requestedBy}) async {
    await dio.post('/rooms/$code/shuffle-teams', data: {'requested_by': requestedBy});
  }

  Future<RoomStateResponse> fetchState({required String code, required int sinceVersion}) async {
    final res = await dio.get('/rooms/$code/state', queryParameters: {'sinceVersion': sinceVersion});
    return RoomStateResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // ✅ 点数登録（user_id方式）
  Future<void> upsertScore({
    required String code,
    required int setNo,
    required int userId,
    required String songName,
    required String scoreRaw,
  }) async {
    await dio.post(
      '/rooms/$code/sets/$setNo/scores',
      data: {
        'user_id': userId,
        'song_name': songName,
        'score_raw': scoreRaw,
      },
    );
  }

  // ✅ セット確定（管理者）
  Future<void> confirmSet({
    required String code,
    required int setNo,
    required int requestedBy,
  }) async {
    await dio.post(
      '/rooms/$code/sets/$setNo/confirm',
      data: {'requested_by': requestedBy},
    );
  }

  // ✅ 終了（管理者）
  Future<void> finish({
    required String code,
    required int requestedBy,
  }) async {
    await dio.post('/rooms/$code/finish', data: {'requested_by': requestedBy});
  }

  // ✅ チーム編集（管理者）
  Future<void> updateTeam({
    required String code,
    required int teamId,
    required int requestedBy,
    required String name,
    String? colorHex,
    String? imagePath,
  }) async {
    await dio.put(
      '/rooms/$code/teams/$teamId',
      data: {
        'requested_by': requestedBy,
        'name': name,
        'color_hex': colorHex,
        'image_path': imagePath,
      },
    );
  }
}