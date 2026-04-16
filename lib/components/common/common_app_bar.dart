import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showTitle;
  final bool showUserIcon;

  const CommonAppBar({
    super.key,
    this.title = '',
    this.showTitle = true,
    this.showUserIcon = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  // Storageから画像パスを取得
  Future<String?> _getUserIconPath() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'user_icon_path');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100,
      title: showTitle
          ? Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      )
          : null,
      centerTitle: true,
      actions: [
        if (showUserIcon)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FutureBuilder<String?>(
              future: _getUserIconPath(),
              builder: (context, snapshot) {
                // 保存されたパスがあるかチェック
                final String? imagePath = snapshot.data;

                Widget iconWidget;
                if (imagePath != null && imagePath.isNotEmpty) {
                  // 画像パスがある場合
                  iconWidget = CircleAvatar(
                    radius: 30,
                    backgroundImage: FileImage(File(imagePath)),
                    backgroundColor: Colors.transparent,
                  );
                } else {
                  // パスがない、または取得中ならデフォルトアイコン
                  iconWidget = const Icon(Icons.account_circle, size: 60);
                }

                return IconButton(
                  onPressed: () => context.push('/profile'),
                  icon: iconWidget,
                  iconSize: 60,
                  padding: EdgeInsets.zero,
                );
              },
            ),
          ),
      ],
    );
  }
}