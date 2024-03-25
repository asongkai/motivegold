import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/screen/dashboard_screen.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/search/search_screen.dart';
import 'package:motivegold/screen/settings/setting_screen.dart';

List<TabItem> items = [
  TabItem(
    icon: Icons.home,
    title: 'หน้าแรก'.tr(),
  ),
  TabItem(
    icon: Icons.search_sharp,
    title: 'ค้นหา'.tr(),
  ),
  TabItem(
    icon: Icons.price_change_outlined,
    title: 'ราคาทอง'.tr(),
  ),
  TabItem(
    icon: Icons.people,
    title: 'ข้อมูลส่วนตัว'.tr(),
  ),
  const TabItem(
    icon: Icons.more_horiz_outlined,
  ),
];

class TabScreen extends StatefulWidget {
  const TabScreen({super.key, required this.title});

  final String title;

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: items.length,
      child: Scaffold(
          body: TabBarView(
            controller: _tabController,
            children: const [
              DashboardScreen(),
              SearchScreen(),
              GoldPriceScreen(showBackButton: false,),
              Icon(Icons.add),
              SettingScreen(),
            ],
          ),
          bottomNavigationBar: StyleProvider(
            style: Style(),
            child: ConvexAppBar(
              backgroundColor: Colors.teal,
              // color: textColor2,
              height: 62,
              controller: _tabController,
              items: items,
              style: TabStyle.reactCircle,
              onTap: (int i) => print('click index=$i'),
            ),
          )),
    );
  }
}

class Style extends StyleHook {
  @override
  double get activeIconSize => 40;

  @override
  double get activeIconMargin => 10;

  @override
  double get iconSize => 30;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return TextStyle(fontSize: 20, color: color);
  }
}
