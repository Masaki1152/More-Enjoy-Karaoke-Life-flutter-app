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
      final Map<String, dynamic> map = {
        'device_id': deviceId,
        'name': name,
        'birthday': birthday,
      };

      if (iconPath != null && iconPath.isNotEmpty && !iconPath.startsWith('assets/')) {
        map['icon_path'] = await MultipartFile.fromFile(
          iconPath,
          filename: 'user_icon.jpg',
        );
      }

      final formData = FormData.fromMap(map);

      final response = await _dio.post(
        '/api/users/register',
        data: formData,
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<Map<String, dynamic>> getUser(int id) async {
    final response = await _dio.get('/api/users/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/users/$id', data: data);
    return response.data;
  }
}