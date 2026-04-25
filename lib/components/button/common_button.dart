import 'package:flutter/material.dart';
import 'package:more_enjoy_karaoke_life/utils/utils.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CommonButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: onPressed == null ? Colors.grey : AppColors.primaryColor, width: 2),
          foregroundColor: AppColors.primaryColor,
          disabledForegroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}