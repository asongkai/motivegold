import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motivegold/screen/pos/modal/hold_list.dart';
import 'package:badges/badges.dart' as badges;
import 'package:motivegold/screen/pos/storefront/theng/sell_theng_screen.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/util.dart';

import '../checkout_screen.dart';
import 'buy_theng_screen.dart';

class ThengSaleMenuScreen extends StatefulWidget {
  const ThengSaleMenuScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  ThengSaleMenuScreenState createState() => ThengSaleMenuScreenState();
}

class ThengSaleMenuScreenState extends State<ThengSaleMenuScreen> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();
  int cartCount = 0;
  int holdCount = 0;

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    super.initState();
    init();
  }

  void init() async {
    sideMenu.changePage(Global.posIndex);
    int count = (await Global.getHoldList()).length;
    setState(() {
      holdCount = count;
      cartCount = Global.orders!.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // sideMenu.changePage(Global.posIndex);
    // pageController.jumpToPage(Global.posIndex);
    setState(() {});
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 0),
            badgeAnimation: const badges.BadgeAnimation.slide(
              // disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
              // curve: Curves.easeInCubic,
            ),
            showBadge: true,
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
            ),
            badgeContent: Text(
              '$holdCount',
              style: const TextStyle(color: Colors.white),
            ),
            child: IconButton(
                icon: const Icon(
                  Icons.save,
                  size: 42,
                ),
                onPressed: () {
                  if (holdCount > 0) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HoldListModal(),
                            fullscreenDialog: true))
                        .whenComplete(() {
                      init();
                      if (Global.posIndex == 0) {
                        sumSellThengTotal();
                      }
                      if (Global.posIndex == 1) {
                        sumBuyThengTotal();
                      }
                      sideMenu.changePage(Global.posIndex);
                      pageController.jumpToPage(Global.posIndex);
                      setState(() {});
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        "ว่างเปล่า...",
                        style: TextStyle(fontSize: 22),
                      ),
                      backgroundColor: Colors.orange,
                    ));
                  }
                }),
          ),
          const SizedBox(
            width: 10,
          ),
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 0),
            badgeAnimation: const badges.BadgeAnimation.slide(
              // disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
              // curve: Curves.easeInCubic,
            ),
            showBadge: true,
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
            ),
            badgeContent: Text(
              cartCount.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            child: IconButton(
                icon: const Icon(
                  Icons.shopping_cart,
                  size: 42,
                ),
                onPressed: () {
                  if (cartCount > 0) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CheckOutScreen()))
                        .whenComplete(() {
                      init();
                      sideMenu.changePage(Global.posIndex);
                      pageController.jumpToPage(Global.posIndex);
                      setState(() {});
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        "รถเข็นว่างเปล่า...",
                        style: TextStyle(fontSize: 22),
                      ),
                      backgroundColor: Colors.orange,
                    ));
                  }
                }),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: sideMenu,
            style: SideMenuStyle(
              showTooltip: true,
              iconSize: 90,
              compactSideMenuWidth: 130,
              itemHeight: 130,
              displayMode: SideMenuDisplayMode.compact,
              hoverColor: Colors.teal[100],
              selectedHoverColor: Colors.teal[100],
              selectedColor: Colors.teal,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              selectedIconColor: Colors.white,
            ),
            title: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 150,
                    maxWidth: 150,
                  ),
                  child: Image.asset(
                    'assets/icons/start.gif',
                  ),
                ),
                const Divider(
                  indent: 8.0,
                  endIndent: 8.0,
                ),
              ],
            ),
            items: [
              SideMenuItem(
                title: 'ขายทองแท่ง',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(FontAwesomeIcons.s),
                tooltipContent: 'ขายทองแท่ง',
              ),
              SideMenuItem(
                title: 'ซื้อทองแท่ง',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(FontAwesomeIcons.b),
                tooltipContent: 'ซื้อทองแท่ง',
              ),
            ],
          ),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [
                SellThengScreen(
                  refreshCart: refreshCart,
                  refreshHold: refreshHold,
                  cartCount: cartCount,
                ),
                BuyThengScreen(
                  refreshCart: refreshCart,
                  refreshHold: refreshHold,
                  cartCount: cartCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void refreshCart(dynamic childValue) {
    setState(() {
      cartCount = int.parse(childValue);
    });
  }

  void refreshHold(dynamic childValue) {
    setState(() {
      holdCount = int.parse(childValue);
    });
  }
}
