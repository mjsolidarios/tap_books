import 'package:flutter/material.dart';
import 'package:jumping_dot/jumping_dot.dart';

class DotsProgress extends StatelessWidget {
  const DotsProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: JumpingDots(
        radius: 10,
        numberOfDots: 3,
        verticalOffset: -8,
        color: ThemeMode.system != ThemeMode.dark? Colors.white: Colors.black45,
        animationDuration: const Duration(milliseconds: 180)),
    );
  }
}
