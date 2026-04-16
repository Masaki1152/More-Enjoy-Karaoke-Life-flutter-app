import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorHandler {
  static void handleError(
      BuildContext context,
      Object e, {
        bool popLoading = true,
  }) {
    final navigator = Navigator.of(context);

    // ローディングダイアログを閉じる
    if(popLoading) {
      try {
        navigator.pop();
      } catch (_) {}
    }

    final String errorMessage = e.toString();
    debugPrint(e.toString());

    //エラー画面の表示
    if (context.mounted) {
      context.push('/error', extra: errorMessage);
    }
  }
}