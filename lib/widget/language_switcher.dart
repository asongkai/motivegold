import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/localbindings.dart';
import 'package:motivegold/utils/responsive_screen.dart';


class LanguageSwitcher extends StatelessWidget {
   Screen? size;
  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
      return PopupMenuButton<String>(
        icon: Icon(Icons.language, color: Colors.blue[700]),
        onSelected: (String result) {
          switch (result) {
            case 'lo':
              context.setLocale(const Locale('lo', 'LA'));
              LocalStorage.sharedInstance.writeValue(key: 'lang', value: '1');
              Global.lang = 1;
              break;
            case 'en':
              context.setLocale(const Locale('en', 'US'));
              LocalStorage.sharedInstance.writeValue(key: 'lang', value: '0');
              Global.lang = 0;
              break;
            case 'zh':
              context.setLocale(const Locale('zh', 'CN'));
              LocalStorage.sharedInstance.writeValue(key: 'lang', value: '2');
              Global.lang = 2;
              break;
            default:
          }
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
      );
  }
}
