import 'package:flutter/material.dart';
import 'package:more_enjoy_karaoke_life/utils/utils.dart';
import 'package:more_enjoy_karaoke_life/components/components.dart';
import 'package:more_enjoy_karaoke_life/i18n/strings.g.dart';
import 'package:more_enjoy_karaoke_life/conf/constantDev.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  ConstantDev.appHomeIconPath,
                  width: screenWidth * 0.8,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 80,
                        child: CommonButton(
                          text: t.common.start,
                          onPressed: () {
                            print('');
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 80,
                        child: CommonButton(
                          text: t.common.aboutApp,
                          onPressed: () {
                            print('');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}