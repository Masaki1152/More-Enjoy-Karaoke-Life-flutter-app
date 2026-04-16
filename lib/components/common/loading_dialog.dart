import 'package:flutter/material.dart';
import 'package:more_enjoy_karaoke_life/utils/utils.dart';

Future<void> showLoadingDialog({required BuildContext context}) async {
  showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 250),
      barrierColor: Colors.black.withValues(alpha: 0.5),
      pageBuilder: (
          BuildContext context,
          Animation animation,
          Animation secondaryAnimation,
      ) {
        return PopScope(
            canPop: false,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
        );
      },
  );
}