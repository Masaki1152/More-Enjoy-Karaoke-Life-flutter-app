import 'dart:io';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? iconPath;
  final double size;

  const UserAvatar({super.key, required this.iconPath, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: _getImageProvider(iconPath),
        child: iconPath == null ? const Icon(Icons.person) : null,
      ),
    );
  }

  ImageProvider? _getImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;

    if (path.startsWith('http')) {
      return NetworkImage(path);
    }

    if (path.startsWith('/storage')) {
      return NetworkImage('https://karaokelife.skr.jp$path');
    }

    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }

    if (path.startsWith('/') || path.contains('data/user')) {
      return FileImage(File(path));
    }

    return null;
  }
}