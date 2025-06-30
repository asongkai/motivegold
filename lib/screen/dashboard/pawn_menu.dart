import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/pos/redeem/redeem_sell_menu.dart';
import 'package:motivegold/screen/pos/storefront/theng/matching_menu_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/ui-matching/matching_pending_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/menu_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/utils/global.dart';

class PawnMenuScreen extends StatefulWidget {
  const PawnMenuScreen({super.key});

  @override
  State<PawnMenuScreen> createState() => _PawnMenuScreenState();
}

class _PawnMenuScreenState extends State<PawnMenuScreen> {
  ApiServices api = ApiServices();
  Screen? size;
  bool loading = false;
  List<OrderModel>? list = [];

  @override
  void initState() {
    // implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);

    return Scaffold(
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("เมนูขายฝากทอง(จำนำ)",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: loading
          ? const LoadingProgress()
          : Stack(
        children: <Widget>[dashBg, content],
      ),
    );
  }

  get dashBg => Column(
    children: <Widget>[
      Expanded(
        flex: 2,
        child: Container(color: bgColor2),
      ),
      Expanded(
        flex: 5,
        child: Container(color: bgColor2),
      ),
    ],
  );

  get content => Column(
    children: <Widget>[
      const SizedBox(
        height: 10,
      ),
      grid,
    ],
  );

  itemDashboard(
      String title, IconData iconData, Color background, dynamic route) =>
      GestureDetector(
        onTap: () {
          if (route != null) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => route))
                .whenComplete(() {
              setState(() {});
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 5),
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 5)
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: Colors.white,
                    size: size!.getWidthPx(30),
                  )),
              const SizedBox(height: 8),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: size!.getWidthPx(8), color: Colors.teal),
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      );

  iconDashboard(
      String title, Image iconData, Color background, dynamic route) =>
      GestureDetector(
        onTap: () {
          if (route != null) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => route));
          }
        },
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 5),
                    color: Theme.of(context).primaryColor.withValues(alpha: .2),
                    spreadRadius: 2,
                    blurRadius: 5)
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                  ),
                  child: iconData
                // Icon(
                //   iconData,
                //   color: Colors.white,
                //   size: size!.getWidthPx(30),
                // )
              ),
              const SizedBox(height: 8),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: size!.getWidthPx(8), color: Colors.teal),
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      );

  get grid => Expanded(
    child: Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: OrientationBuilder(
        builder: (context, orientation) {
          return GridView.count(
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            crossAxisCount: 4,
            childAspectRatio:
            orientation == Orientation.portrait ? .80 : .90,
            children: [
              iconDashboard(
                'ขายฝากจำนำ\nไถ่ถอน',
                Image.asset('assets/icons/gold/gold.png', height: 110,),
                stmBgColor,
                const RedeemMenuScreen(),
              ),
              iconDashboard(
                'ขายฝากจำนำ\nออกตั๋วและไถ่ถอน',
                Image.asset('assets/icons/gold/sell-gold-tang.png'),
                stmBgColor,
                null,
              ),
              iconDashboard(
                'ขายฝากจำนำ\nออกตั๋ว รับดอกเบี้ย\nและไถ่ถอน',
                Image.asset('assets/icons/gold/gold-sub-dealer.png'),
                stmBgColor,
                null,
              ),
            ],
          );
        },
      ),
    ),
  );
}
