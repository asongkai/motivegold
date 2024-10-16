import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/pos/storefront/theng/matching_menu_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/matching_pending_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/menu_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_pending_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/utils/global.dart';

class ThengMenuScreen extends StatefulWidget {
  const ThengMenuScreen({super.key});

  @override
  State<ThengMenuScreen> createState() => _ThengMenuScreenState();
}

class _ThengMenuScreenState extends State<ThengMenuScreen> {
  ApiServices api = ApiServices();
  Screen? size;
  bool loading = false;
  List<OrderModel>? list = [];

  @override
  void initState() {
    // implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      // loading = true;
    });
    try {
      var result = await ApiServices.post(
          '/order/matching/PENDING', Global.requestObj(null));
      // motivePrint(result!.data);
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> products = orderListModelFromJson(data);
        setState(() {
          list = products;
        });
      } else {
        list = [];
      }
    } catch (e) {
      motivePrint(e.toString());
    }
    setState(() {
      // loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เมนูซื้อขายทองแท่ง',
          style: TextStyle(fontSize: size?.getWidthPx(8)),
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
              loadData();
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
                    color: Theme.of(context).primaryColor.withOpacity(.2),
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
                    color: Theme.of(context).primaryColor.withOpacity(.2),
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

  modalDashboard(
      String title, IconData iconData, Color background, dynamic route) =>
      GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => route));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          width: size!.hp(isTablet ? 30 : 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 5),
                    color: Theme.of(context).primaryColor.withOpacity(.2),
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
                    size: size!.getWidthPx(50),
                  )),
              const SizedBox(height: 8),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontSize: size!.getWidthPx(12)),
                overflow: TextOverflow.ellipsis,
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
                'ซื้อขายทองแท่ง \n(จับคู่) ',
                Image.asset('assets/icons/gold/sell-gold-tang.png'),
                kPrimaryTosca,
                const ThengSaleMatchingMenuScreen(title: 'Matching'),
              ),
              Stack(
                children: [
                  itemDashboard(
                    'รายการที่รอดำเนินการ',
                    Icons.pending_actions,
                    Colors.red,
                    const MatchingPendingScreen(),
                  ),
                  if (list != null && list!.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20.0)),
                          padding:
                          const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  (list == null)
                                      ? 0.toString()
                                      : list!.length.toString(),
                                  style:
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              iconDashboard(
                'ซื้อขายทองแท่ง \n(ซื้อ-ขายจริง) ',
                Image.asset('assets/icons/gold/buy-gold-tang.png'),
                primer,
                const ThengSaleMenuScreen(title: 'Real'),
              ),
            ],
          );
        },
      ),
    ),
  );
}
