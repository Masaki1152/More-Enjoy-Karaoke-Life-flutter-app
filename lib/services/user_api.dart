import 'package:dio/dio.dart';
import 'package:more_enjoy_karaoke_life/conf/constantDev.dart';

class UserService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ConstantDev.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<Map<String, dynamic>> registerUser({
    required String deviceId,
    required String name,
    required String birthday,
    String? iconPath,
  }) async {
    try {
      final response = await _dio.post(
        '/users/register',
        data: {
          'device_id': deviceId,
          'name': name,
          'icon_path': iconPath,
          'birthday': birthday,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<Map<String, dynamic>> getUser(int id) async {
    final response = await _dio.get('/users/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/users/$id', data: data);
    return response.data;
  }
}