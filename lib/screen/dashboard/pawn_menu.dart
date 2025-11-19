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
import 'package:sizer/sizer.dart';

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
                    size: 18.sp,
                  )),
              const SizedBox(height: 8),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: 14.sp, color: Colors.teal),
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      );

  iconDashboard(
      String title, dynamic iconData, Color background, dynamic route) =>
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
              // Icon or Image
              iconData is Image
                  ? iconData
                  : Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
              const SizedBox(height: 8),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: 14.sp, color: Colors.teal),
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      );

  get grid => Expanded(
    child: Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildMenuItem(
                      'ไถ่ถอน',
                      'assets/icons/menu_icons/redeem.png',
                      stmBgColor,
                      const RedeemMenuScreen(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildMenuItem(
                      'ออกตั๋วขายฝาก\nไถ่ถอน',
                      'assets/icons/menu_icons/pawn_ticket.png',
                      stmBgColor,
                      null,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildMenuItem(
                      'ขายฝาก รับดอกเบี้ย\nเพิ่มต้น-ลดต้น ไถ่ถอน',
                      'assets/icons/menu_icons/pawn.png',
                      stmBgColor,
                      null,
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildMenuItem(String title, String imagePath, Color color, dynamic route) {
    return InkWell(
      onTap: () {
        if (route != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          ).whenComplete(() {
            setState(() {});
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
