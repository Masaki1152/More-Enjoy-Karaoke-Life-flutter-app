import 'package:flutter/material.dart';
import 'package:more_enjoy_karaoke_life/utils/utils.dart';

void showCustomSnackBar(
  BuildContext context, {
    required String message,
    Color backgroundColor = AppColors.primaryColor,
    Color textColor = AppColors.white,
    Color iconColor = AppColors.white,
    Duration duration = const Duration(seconds: 4),
}) {
  final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(message, style: TextStyle(color: textColor),)
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            child: Icon(Icons.close, color: iconColor),
          )
        ],
      )
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}