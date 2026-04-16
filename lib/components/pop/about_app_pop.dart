import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:more_enjoy_karaoke_life/utils/utils.dart';
import 'package:more_enjoy_karaoke_life/i18n/strings.g.dart';

class AboutAppPop extends StatelessWidget {
  const AboutAppPop({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close, size: 28),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            const Icon(Icons.music_note, color: AppColors.primaryColor, size: 56),
            const SizedBox(height: 16),

            Text(
              t.about.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  t.about.description,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}