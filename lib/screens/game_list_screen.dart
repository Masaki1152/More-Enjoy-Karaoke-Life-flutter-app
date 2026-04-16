import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:more_enjoy_karaoke_life/conf/constantDev.dart';
import 'package:more_enjoy_karaoke_life/utils/utils.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';
import 'package:more_enjoy_karaoke_life/i18n/strings.g.dart';

class GameListScreen extends StatelessWidget {
  const GameListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          t.game.gameList,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.account_circle, size: 60),
            ),
          ),
        ],
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