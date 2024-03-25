import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/screen/auth/login_screen.dart';
import 'package:motivegold/screen/pos/customer_entry_screen.dart';
import 'package:motivegold/screen/pos/mainmenu_screen.dart';
import 'package:motivegold/screen/pos/pos_sell_screen.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ApiServices api = ApiServices();
  Screen? size;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      loading = true;
    });
    Global.goldDataModel = await api.getGoldPrice(context);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แดชบอร์ด',
          style: TextStyle(fontSize: size?.getWidthPx(8)),
        ),
        automaticallyImplyLeading: false,
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
          child: GridView.count(
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            crossAxisCount: 4,
            // childAspectRatio: .90,
            children: [
              iconDashboard(
                'ซื้อขายทองสำหรับร้านขายส่ง',
                Image.asset('assets/icons/gold/gold-dealer.png'),
                primer,
                const MainMenuScreen(title: 'POS'),
              ),
              iconDashboard(
                'ซื้อขายทองสำหรับร้านขายปลีก',
                Image.asset('assets/icons/gold/gold-sub-dealer.png'),
                Colors.tealAccent,
                const MainMenuScreen(title: 'POS'),
              ),
              iconDashboard(
                'ซื้อทองแท่ง',
                Image.asset('assets/icons/gold/buy-gold-tang.png'),
                Colors.redAccent,
                const MainMenuScreen(title: 'POS'),
              ),
              iconDashboard(
                'ขายทองแท่ง',
                Image.asset('assets/icons/gold/sell-gold-tang.png'),
                Colors.teal,
                const MainMenuScreen(title: 'POS'),
              ),
              itemDashboard(
                'ออมทอง'.tr(),
                CupertinoIcons.download_circle,
                Colors.green,
                const MainMenuScreen(title: 'POS'),
              ),
              itemDashboard(
                'ขายฝากทอง(จำนำ)',
                CupertinoIcons.f_cursive,
                Colors.purple,
                const MainMenuScreen(title: 'POS'),
              ),
            ],
          ),
        ),
      );
}