import 'package:flutter/material.dart';
import 'user_avatar.dart';

class UserListCell extends StatelessWidget {
  final String? iconPath;
  final String userName;

  const UserListCell({
    super.key,
    required this.iconPath,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightBlue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.lightBlue),
            ),
            child: UserAvatar(iconPath: iconPath, size: 44),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              userName,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
