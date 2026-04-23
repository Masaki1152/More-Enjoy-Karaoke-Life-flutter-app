import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? iconPath;
  final double size;

  const UserAvatar({super.key, required this.iconPath, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      child: iconPath == null ? const Icon(Icons.person) : const Icon(Icons.image),
    );
  }
}