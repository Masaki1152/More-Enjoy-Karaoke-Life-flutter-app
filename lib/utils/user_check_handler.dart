import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GameUtils {
  static const storage = FlutterSecureStorage();

  // ユーザー情報をチェックして遷移先を決める
  static Future<void> userCheckHandler(BuildContext context, String targetPath) async {
    final String? userName = await storage.read(key: 'user_name');

    if (userName == null || userName.isEmpty) {
      // 未登録の場合はプロフィール登録画面に遷移
      if (context.mounted) context.push('/profile_edit');
    } else {
      // 登録済みの場合
      if (context.mounted) context.push(targetPath);
    }
  }
}