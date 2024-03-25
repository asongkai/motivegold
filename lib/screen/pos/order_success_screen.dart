import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/screen/tab_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';

class OrderSuccessScreen extends StatelessWidget {
  static const routeName = '/orderSuccess';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Image.asset('assets/images/wallet_illu.png'),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    'สั่งซื้อสำเร็จ'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                      fontFamily: 'NotoSansLao',
                        ),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(8.0),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(16.0),
                    ),
                    child: Text(
                      'สำเร็จ'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: kTextColorAccent,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'NotoSansLao',
                          ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(16.0),
                vertical: getProportionateScreenHeight(16.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                      const TabScreen(title: 'GOLD')));
                },
                child: Text('ดำเนินการต่อ'.tr(), style: const TextStyle(fontSize: 18),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
