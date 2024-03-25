import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:motivegold/screen/auth/signin_screen.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/localbindings.dart';
import 'package:motivegold/utils/screen_utils.dart';


class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 3), () {
      navigateFromSplash();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: LoadingAnimationWidget.threeRotatingDots(
            color: Colors.orange,
            size: 200,
          ),
        ),
      ),
    );
  }

  Future navigateFromSplash() async {
    var lang = await LocalStorage.sharedInstance.readValue('lang');
    // lang = null;
    if (lang != null) {
      Global.lang = int.parse(lang);
      if (Global.lang == 0) {
        context.setLocale(const Locale('en', 'US'));
      } else if (Global.lang == 1) {
        context.setLocale(const Locale('lo', 'LA'));
      } else if (Global.lang == 2) {
        context.setLocale(const Locale('zh', 'CN'));
      } else {
        context.setLocale(const Locale('vi', 'VN'));
      }
    } else {
      Global.lang = 0;
      LocalStorage.sharedInstance.writeValue(key: 'lang', value: 0.toString());
      context.setLocale(const Locale('en', 'US'));
    }
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignInTen()));
  }
}
