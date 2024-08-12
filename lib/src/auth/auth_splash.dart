import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:tap_books/src/auth/auth_gate.dart';

class AuthSplash extends StatefulWidget {
  const AuthSplash({Key? key}) : super(key: key);

  static const routeName = '/auth_splash';

  @override
  _AuthSplashState createState() => _AuthSplashState();
}

class _AuthSplashState extends State<AuthSplash> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              child: Column(
                children: AnimateList(children: [
                  Lottie.asset('assets/animations/app_brand_light.json',
                      controller: _controller, onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..forward();
                  }, height: 200, width: 200),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.pushReplacementNamed(context,  AuthGate.routeName);
                        
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.transparent),
                          textStyle: WidgetStatePropertyAll(
                              TextStyle(color: Colors.white))),
                      child: const Text("Get Started"))
                ],
                interval: 2500.ms,
                effects: [FadeEffect(duration: 300.ms)],
                )
              )),
        ],
      ),
    );
  }
}
