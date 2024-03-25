import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/localbindings.dart';
import 'package:motivegold/utils/responsive_screen.dart';

class LanguageIntro extends StatefulWidget {
  @override
  State<LanguageIntro> createState() => _LanguageIntroState();
}

class _LanguageIntroState extends State<LanguageIntro> {
  Screen? size;

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Positioned(
        bottom: size!.getWidthPx(10),
        right: size!.getWidthPx(10),
        child: PopupMenuButton<String>(
          icon: Icon(Icons.language_outlined, color: Colors.blue[700]),
          onSelected: (String result) {
            switch (result) {
              case 'lo':
                context.setLocale(const Locale('lo', 'LA'));
                LocalStorage.sharedInstance.writeValue(key: 'lang', value: '1');
                Global.lang = 1;
                setState(() {});
                break;
              case 'en':
                context.setLocale(const Locale('en', 'US'));
                LocalStorage.sharedInstance.writeValue(key: 'lang', value: '0');
                Global.lang = 0;
                setState(() {});
                break;
              case 'zh':
                context.setLocale(const Locale('zh', 'CN'));
                LocalStorage.sharedInstance.writeValue(key: 'lang', value: '2');
                Global.lang = 2;
                setState(() {});
                break;
              default:
            }
            setState(() {

            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'lo',
              child: Text('ລາວ'),
            ),
            const PopupMenuItem<String>(
              value: 'en',
              child: Text('English'),
            ),
            const PopupMenuItem<String>(
              value: 'zh',
              child: Text('中国人'),
            ),
          ],
        ));
  }
}
