import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/dashboard/theng_menu.dart';
import 'package:motivegold/screen/pos/storefront/broker/menu_screen.dart';
import 'package:motivegold/screen/pos/storefront/paphun/menu_screen.dart';
import 'package:motivegold/screen/pos/wholesale/menu_paphun_screen.dart';
import 'package:motivegold/screen/pos/wholesale/menu_theng_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_menu_screen.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ApiServices api = ApiServices();
  Screen? size;
  List<OrderModel>? list = [];
  bool loading = false;

  @override
  void initState() {
    // implement initState
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      loading = true;
    });

    var result = await ApiServices.post(
        '/order/matching/PENDING/clear', Global.requestObj(null));
    // motivePrint(result?.data);
    if (result?.status == "success") {
      var data = jsonEncode(result?.data);
      List<OrderModel> products = orderListModelFromJson(data);
      setState(() {
        list = products;
      });
    } else {
      list = [];
    }

    Global.goldDataModel = await api.getGoldPrice(context);

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);

    return Scaffold(
      appBar: const CustomAppBar(
        height: 250,
        child: TitleContent(backButton: false,),
      ),
      body: Stack(
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
          // header,
          const SizedBox(
            height: 10,
          ),
          grid,
        ],
      );

  get header => ListTile(
        contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        title: Text(
          'แดชบอร์ด',
          style: TextStyle(color: Colors.teal, fontSize: size!.getWidthPx(14)),
        ),
        subtitle: Container(),
        // trailing: const SizedBox(
        //   child: CircleAvatar(
        //     radius: 50,
        //     backgroundColor: Colors.transparent,
        //     backgroundImage: AssetImage("assets/images/sample_profile.jpg"),
        //   ),
        // ),
      );

  itemDashboard(
          String title, IconData iconData, Color background, dynamic route) =>
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
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 1),
                    color: Theme.of(context).primaryColor.withValues(alpha: .1),
                    spreadRadius: 1,
                    blurRadius: 1)
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
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: size!.getWidthPx(10), color: Colors.teal),
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      );

  iconDashboard(String title, Widget iconData, Color background, dynamic route,
          {int index = 0}) =>
      GestureDetector(
        onTap: () {
          if (route != null) {
            Global.posIndex = index;
            setState(() {});
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => route));
          }
        },
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 1),
                  color: Theme.of(context).primaryColor.withValues(alpha: .1),
                  spreadRadius: 1,
                  blurRadius: 1)
            ],
          ),
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
                    fontSize: size!.getWidthPx(10), color: Colors.teal),
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
                crossAxisSpacing: 36,
                mainAxisSpacing: 36,
                crossAxisCount: 3,
                // childAspectRatio: orientation == Orientation.portrait ? .84 : .104,
                children: [
                  iconDashboard(
                      'ซื้อขายทองหน้าร้าน',
                      Image.asset(
                        'assets/icons/gold/gold-sub-dealer.png',
                        // width: 150,
                      ),
                      Colors.tealAccent,
                      const PosMenuScreen(title: 'POS'),
                      index: 0),
                  iconDashboard(
                      'ซื้อขายทองแท่ง ${orientation == Orientation.portrait ? '' : '\n'}',
                      Stack(
                        children: [
                          Image.asset(
                            'assets/icons/gold/buy-gold-tang.png',
                            // width: 150,
                          ),
                          if (list != null && list!.isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  padding: const EdgeInsets.only(
                                      left: 5.0, right: 5.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          (list == null)
                                              ? 0.toString()
                                              : list!.length.toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Colors.redAccent,
                      const ThengMenuScreen(),
                      index: 0),
                  itemDashboard(
                    'ออมทอง \n'.tr(),
                    CupertinoIcons.download_circle,
                    Colors.green,
                    null,
                  ),
                  itemDashboard(
                    'ขายฝากทอง (จำนำ)',
                    CupertinoIcons.f_cursive,
                    Colors.purple,
                    null,
                  ),
                  itemDashboard(
                    'ซื้อขายทองแท่งกับโบรกเกอร์',
                    Icons.shopping_cart_checkout_rounded,
                    Colors.brown,
                    const ThengBrokerMenuScreen(title: 'ทองคำแท่งกับโบรกเกอร์'),
                  ),
                  iconDashboard(
                    'ซื้อขายทองกับร้านขายส่ง(ทองรูปพรรณ)',
                    Image.asset('assets/icons/gold/gold-dealer.png'),
                    primer,
                    const WholeSalePaphunMenuScreen(title: 'POS'),
                  ),
                  iconDashboard(
                    'ซื้อขายทองกับร้านขายส่ง(ทองแท่ง)',
                    Image.asset('assets/icons/gold/gold-dealer.png'),
                    Colors.teal,
                    const WholeSaleThengMenuScreen(title: 'POS'),
                  ),
                  itemDashboard(
                    'โอนทอง \n',
                    Icons.compare_arrows_outlined,
                    primer,
                    const TransferGoldMenuScreen(),
                  ),
                ],
              );
            },
          ),
        ),
      );
}
