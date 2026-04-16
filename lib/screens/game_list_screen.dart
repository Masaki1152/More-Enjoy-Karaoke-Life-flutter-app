import 'package:flutter/material.dart';
import 'package:more_enjoy_karaoke_life/conf/constantDev.dart';
import 'package:more_enjoy_karaoke_life/utils/utils.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';
import 'package:more_enjoy_karaoke_life/i18n/strings.g.dart';

class GameListScreen extends StatelessWidget {
  const GameListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: t.game.gameList,
      ),
      body: ListView(
        padding: const EdgeInsets.all(40),
        children: [
          // カラオケベストマッチ
          GameCard(
            imagePath: ConstantDev.gameBestMatchIconPath,
            onTap: () => GameUtils.userCheckHandler(context, '/match_room'),
          ),

          // 近日公開セル
          GameCard(
            imagePath: ConstantDev.comingSoonBgPath,
            onTap: () {},
            isComingSoon: true,
          ),
        ],
      ),
    );
  }
}