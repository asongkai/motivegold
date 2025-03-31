import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motivegold/screen/pos/modal/hold_list.dart';
import 'package:motivegold/screen/pos/storefront/paphun/ui/buy_screen.dart';
import 'package:motivegold/screen/pos/storefront/paphun/ui/sell_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';

import '../checkout_screen.dart';

class PosMenuScreen extends StatefulWidget {
  const PosMenuScreen({super.key, required this.title});

  final String title;

  @override
  PosMenuScreenState createState() => PosMenuScreenState();
}

class PosMenuScreenState extends State<PosMenuScreen> {
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
    Global.currentOrderType = 1;
    init();
  }

  void init() async {
    sideMenu.changePage(Global.posIndex);
    int count = (await Global.getHoldList()).length;
    int cart = await getCartCount();
    setState(() {
      holdCount = count;
      cartCount = cart;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Text(widget.title,
                      style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (holdCount > 0) {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const HoldListModal(),
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
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
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
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (cartCount > 0) {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const CheckOutScreen()))
                                      .whenComplete(() {
                                    init();
                                    sideMenu.changePage(Global.posIndex);
                                    pageController.jumpToPage(Global.posIndex);
                                    setState(() {});
                                  });
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                      "รถเข็นว่างเปล่า...",
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    backgroundColor: Colors.orange,
                                  ));
                                }
                              }),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
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
                title: 'ขายทองคำใหม่',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(FontAwesomeIcons.s),
                tooltipContent: "ขายทองคำใหม่",
              ),
              SideMenuItem(
                title: 'รับซื้อทองเก่า',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(FontAwesomeIcons.b),
                tooltipContent: 'รับซื้อทองเก่า',
              ),
            ],
          ),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [
                PaphunSellScreen(
                  refreshCart: refreshCart,
                  refreshHold: refreshHold,
                  cartCount: cartCount,
                ),
                PaphunBuyScreen(
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
