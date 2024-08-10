import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class AuthView extends StatefulWidget {
  const AuthView({Key? key}) : super(key: key);

  static const routeName = "/";

  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

    @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        SvgPicture.asset('assets/images/app_brand.svg',
            semanticsLabel: 'TapBooks'),
        Lottie.asset('assets/animations/app_brand_light.json',
            controller: _controller,  
            onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..forward();
              })
      ],
    ));
  }
}
