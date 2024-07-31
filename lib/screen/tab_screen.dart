import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/screen/dashboard_screen.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/storefront/paphun/history_screen.dart';
import 'package:motivegold/screen/settings/setting_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';

List<TabItem> items = [
  TabItem(
    icon: Icons.home,
    title: 'หน้าแรก'.tr(),
  ),
  TabItem(
    icon: Icons.auto_graph,
    title: 'ประวัติ'.tr(),
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
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin {
  TabController? _tabController;

  @override
  void initState() {
    // implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future onBackPress(context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('คุณต้องการที่จะออก?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('ยกเลิก'),
                  onPressed: () => {Navigator.pop(context, false)},
                ),
                TextButton(
                    onPressed: () async {
                      var authObject = Global.requestObj(
                          {"deviceDetail": Global.deviceDetail.toString()});

                      try {
                        await ApiServices.post(
                            '/user/state/Close/${Global.user!.id}', authObject);
                      } catch (e) {
                        motivePrint(e.toString());
                      }
                      if (mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text('ออก'))
              ],
            ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        setUserState("Active");
        break;
      case AppLifecycleState.inactive:
        // setUserState("Inactive");
        break;
      case AppLifecycleState.paused:
        setUserState("Paused");
        break;
      case AppLifecycleState.detached:
        // setUserState("Detached");
        break;
      case AppLifecycleState.hidden:
        // setUserState("Hidden");
        break;
    }
  }

  void setUserState(String state) async {
    motivePrint(state);
    var authObject =
        Global.requestObj({"deviceDetail": Global.deviceDetail.toString()});

    try {
      await ApiServices.post(
          '/user/state/$state/${Global.user!.id}', authObject);
    } catch (e) {
      motivePrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      onPopInvoked: (bool value) => onBackPress(context),
      child: DefaultTabController(
        length: items.length,
        child: Scaffold(
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                DashboardScreen(),
                PosOrderHistoryScreen(),
                GoldPriceScreen(
                  showBackButton: false,
                ),
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
                onTap: (int i) => motivePrint('click index=$i'),
              ),
            )),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
