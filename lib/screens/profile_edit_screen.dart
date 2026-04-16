import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';
import 'package:more_enjoy_karaoke_life/i18n/strings.g.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final storage = const FlutterSecureStorage();
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
    _controller.addListener(() => setState(() {}));
  }

  // 既存データを取得
  Future<void> _loadCurrentProfile() async {
    final name = await storage.read(key: 'user_name');
    final image = await storage.read(key: 'user_icon_path');
    if (name != null) {
      setState(() {
        _controller.text = name;
        _imagePath = image;
      });
    }
  }

  Future<void> _pickAndCropImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: '切り抜き',
              toolbarColor: Colors.lightBlue,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true,
              cropStyle: CropStyle.circle,
            ),
            IOSUiSettings(
              title: '切り抜き',
              aspectRatioLockEnabled: true,
              cropStyle: CropStyle.circle,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() => _imagePath = croppedFile.path);
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.push('/error', extra: e);
      }
    }
  }

  Future<void> _saveProfile() async {
    try {
      await storage.write(key: 'user_name', value: _controller.text);
      if (_imagePath != null) {
        await storage.write(key: 'user_icon_path', value: _imagePath!);
      }

      // 保存後に前の画面に戻る
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        context.push('/error', extra: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int nameLength = _controller.text.length;
    final bool isOver = nameLength > 15;
    final bool isValid = nameLength >= 1 && !isOver;

    return Scaffold(
      appBar: CommonAppBar(
        title: t.profile.title,
        showUserIcon: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('キミのことを教えて！',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),

            const Text('名前（ニックネーム）', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '15文字以内で入力してください',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isOver ? Colors.red : Colors.lightBlue.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isOver ? Colors.red : Colors.lightBlue, width: 2),
                ),
              ),
            ),
            Text(
              isOver ? '${nameLength - 15}文字オーバーしています' : 'あと${15 - nameLength}文字入力できます',
              style: TextStyle(color: isOver ? Colors.red : Colors.black54, fontSize: 12),
            ),

            const SizedBox(height: 40),

            const Text('ユーザー画像（任意）', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAndCropImage,
                    child: _buildAvatar(size: 150),
                  ),
                  TextButton.icon(
                    onPressed: _pickAndCropImage,
                    icon: const Icon(Icons.image),
                    label: const Text('画像を選択・変更'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            Center(
              child: SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  onPressed: isValid ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('保存してはじめる',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 40),
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