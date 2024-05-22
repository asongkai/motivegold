import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/screen/pos/mainmenu_screen.dart';
import 'package:motivegold/screen/refill/refill_gold_history_screen.dart';
import 'package:motivegold/screen/refill/refill_gold_stock_screen.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';

class RefillGoldMenuScreen extends StatefulWidget {
  const RefillGoldMenuScreen({super.key});

  @override
  State<RefillGoldMenuScreen> createState() => _RefillGoldMenuScreenState();
}

class _RefillGoldMenuScreenState extends State<RefillGoldMenuScreen> {
  ApiServices api = ApiServices();
  Screen? size;
  bool loading = false;

  @override
  void initState() {
    // implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เมนูเติมทอง',
          style: TextStyle(fontSize: size?.getWidthPx(8)),
        ),
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
                context, MaterialPageRoute(builder: (context) => route));
          } else {
            showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0)),
              ),
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: isTablet ? 30 : 20,
                    // crossAxisSpacing: 16,
                    // mainAxisSpacing: 16,
                    // crossAxisCount: 2,
                    // childAspectRatio: .99,
                    children: [
                      modalDashboard(
                          'สำหรับร้านขายส่ง',
                          CupertinoIcons.sort_down_circle_fill,
                          Colors.deepPurple,
                          Container()),
                      modalDashboard(
                          'สำหรับร้านขายปลีก',
                          CupertinoIcons.doc_text_search,
                          Colors.teal,
                          Container()),
                    ],
                  ),
                );
              },
            );
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
          } else {
            showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0)),
              ),
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: isTablet ? 30 : 20,
                    // crossAxisSpacing: 16,
                    // mainAxisSpacing: 16,
                    // crossAxisCount: 2,
                    // childAspectRatio: .99,
                    children: [
                      modalDashboard(
                          'สำหรับร้านขายส่ง',
                          CupertinoIcons.sort_down_circle_fill,
                          Colors.deepPurple,
                          Container()),
                      modalDashboard(
                          'สำหรับร้านขายปลีก',
                          CupertinoIcons.doc_text_search,
                          Colors.teal,
                          Container()),
                    ],
                  ),
                );
              },
            );
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
            childAspectRatio: orientation == Orientation.portrait ? .80 : .90,
            children: [
              itemDashboard(
                'เติมทอง',
                Icons.add,
                primer,
                const RefillGoldStockScreen(),
              ),
              itemDashboard(
                'รายการเติมทอง',
                Icons.view_list,
                Colors.teal,
                const RefillGoldHistoryScreen(),
              ),
            ],
          );
        },
      ),
    ),
  );
}