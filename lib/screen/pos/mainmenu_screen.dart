import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motivegold/screen/pos/modal/hold_list.dart';
import 'package:motivegold/screen/pos/pos_buy_screen.dart';
import 'package:motivegold/screen/pos/pos_sell_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:motivegold/screen/refill/refill_gold_stock_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_screen.dart';
import 'package:motivegold/utils/util.dart';

import '../../utils/global.dart';
import '../used/sell_used_gold_screen.dart';
import 'checkout_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MainMenuScreenState createState() => MainMenuScreenState();
}

class MainMenuScreenState extends State<MainMenuScreen> {
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
    int count = (await Global.getHoldList()).length;
    setState(() {
      holdCount = count;
      cartCount = Global.orders!.length;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        sumSellTotal();
                      }
                      if (Global.posIndex == 1) {
                        sumBuyTotal();
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
              iconSize: 100,
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
                title: 'ขายทองคำใหม่',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(FontAwesomeIcons.sellcast),
                tooltipContent: "ขายทองคำใหม่",
              ),
              SideMenuItem(
                title: 'รับซื้อทองเก่า',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(FontAwesomeIcons.buyNLarge),
                tooltipContent: 'รับซื้อทองเก่า',
              ),
            ],
          ),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [
                POSSellScreen(
                  refreshCart: refreshCart,
                  refreshHold: refreshHold,
                  cartCount: cartCount,
                ),
                POSBuyScreen(
                  refreshCart: refreshCart,
                  refreshHold: refreshHold,
                  cartCount: cartCount,
                )
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
