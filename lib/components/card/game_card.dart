import 'package:flutter/material.dart';
import 'package:more_enjoy_karaoke_life/utils/utils.dart';
import 'package:more_enjoy_karaoke_life/i18n/strings.g.dart';

class GameCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final bool isComingSoon;

  const GameCard({
    super.key,
    required this.imagePath,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isComingSoon ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isComingSoon ? Colors.grey[300] : Colors.transparent,
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: isComingSoon
                ? ColorFilter.mode(
                    AppColors.black.withValues(alpha: 0.6),
                    BlendMode.darken,
                  )
                : null,
          ),
        ),
        child: isComingSoon
            ? Center(
                child: Text(
                  t.game.comingSoonGame,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: AppColors.black)],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
