import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserLocalStore {
  static const _storage = FlutterSecureStorage();

  static const keyUserId = 'user_id';
  static const keyUserName = 'user_name';
  static const keyUserIconPath = 'user_icon_path';
  static const keyDeviceId = 'device_id';
  static const keyBirthday = 'birthday';

  Future<int?> getUserId() async {
    final v = await _storage.read(key: keyUserId);
    return v != null ? int.tryParse(v) : null;
  }

  Future<void> saveUserId(int id) async {
    await _storage.write(key: keyUserId, value: id.toString());
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: keyUserName);
  }

  Future<void> saveUserName(String name) async {
    await _storage.write(key: keyUserName, value: name);
  }

  Future<String?> getUserIconPath() async {
    return await _storage.read(key: keyUserIconPath);
  }

  Future<void> saveUserIconPath(String path) async {
    await _storage.write(key: keyUserIconPath, value: path);
  }

  Future<String?> getDeviceId() async {
    return await _storage.read(key: keyDeviceId);
  }

  Future<void> saveDeviceId(String id) async {
    await _storage.write(key: keyDeviceId, value: id);
  }

  Future<String?> getBirthday() async {
    return await _storage.read(key: keyBirthday);
  }

  Future<void> saveBirthday(String birthday) async {
    await _storage.write(key: keyBirthday, value: birthday);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}