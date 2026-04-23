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
}