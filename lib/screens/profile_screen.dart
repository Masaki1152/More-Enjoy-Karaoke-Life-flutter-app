import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = const FlutterSecureStorage();
  String? _name;
  String? _imagePath;
  String? _birthday;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // データを読み込むよ！
  Future<void> _loadProfile() async {
    final name = await storage.read(key: 'user_name');
    final image = await storage.read(key: 'user_icon_path');
    final birthday = await storage.read(key: 'birthday');
    setState(() {
      _name = name;
      _imagePath = image;
      _birthday = birthday;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 読み込み中はぐるぐるを表示して、不自然な切り替わりを防ぐよ！
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.lightBlue)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "プロフィール",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            iconSize: 40,
            onPressed: () async {
              // 編集画面へ遷移！戻ってきたらデータを再読み込みするよ
              await context.push('/profile_edit');
              _loadProfile();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('名前（ニックネーム）', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_name ?? '', style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 40),

            const Text('誕生日', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              _birthday != null
                  ? '${DateTime.parse(_birthday!).year}年${DateTime.parse(_birthday!).month}月${DateTime.parse(_birthday!).day}日'
                  : '',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 40),

            const Text('ユーザー画像', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Center(
              child: _buildAvatar(size: 150),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar({required double size}) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey[200],
      backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
      child: _imagePath == null
          ? Icon(Icons.account_circle, size: size, color: Colors.grey)
          : null,
    );
  }
}