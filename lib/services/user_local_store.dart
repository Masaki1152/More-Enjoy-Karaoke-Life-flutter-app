import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserLocalStore {
  static const _storage = FlutterSecureStorage();
  static const String keyUserId = 'user_id';

  Future<int?> getUserId() async {
    final v = await _storage.read(key: keyUserId);
    if (v == null) return null;
    return int.tryParse(v);
  }

  Future<void> saveUserId(int userId) async {
    await _storage.write(key: keyUserId, value: userId.toString());
  }

  Future<void> clear() async {
    await _storage.delete(key: keyUserId);
  }
}