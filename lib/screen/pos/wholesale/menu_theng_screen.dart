import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/screen/pos/wholesale/theng/refill/refill_theng_gold_stock_screen.dart';
import 'package:motivegold/screen/pos/wholesale/theng/used/sell_used_theng_gold_screen.dart';
import 'package:motivegold/screen/pos/wholesale/wholesale_checkout_screen.dart';
import 'package:motivegold/utils/cart/cart.dart';

import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:sizer/sizer.dart';
import 'paphun/refill/refill_gold_stock_screen.dart';
import 'paphun/used/sell_used_gold_screen.dart';

class WholeSaleThengMenuScreen extends StatefulWidget {
  const WholeSaleThengMenuScreen({super.key, required this.title});

  final String title;

  @override
  WholeSaleThengMenuScreenState createState() =>
      WholeSaleThengMenuScreenState();
}

class WholeSaleThengMenuScreenState extends State<WholeSaleThengMenuScreen> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();
  int cartCount = 0;
  int holdCount = 0;
  int posIndex = 0;

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    super.initState();
    Global.currentOrderType = 6;
    init();
  }

  void init() async {
    sideMenu.changePage(Global.posIndex);
    posIndex = Global.posIndex;
    int count = (await Global.getHoldList()).length;
    int cart = await getCartCount();
    setState(() {
      holdCount = count;
      cartCount = cart;
    });
  }

  @override
  Widget build(BuildContext context) {
    // sideMenu.changePage(Global.posIndex);
    // pageController.jumpToPage(Global.posIndex);
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Text(widget.title,
                      style: TextStyle(
                          fontSize: 14.sp, //16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 4,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
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
                            cartCount.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          child: IconButton(
                              icon: Icon(
                                Icons.shopping_cart,
                                size: (MediaQuery.of(context).orientation ==
                                        Orientation.landscape)
                                    ? Device.deviceType == DeviceType.web ? 16.sp : 16.sp
                                    : 16.sp,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (cartCount > 0) {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const WholeSaleCheckOutScreen()))
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
                showHamburger: true,
                displayMode: SideMenuDisplayMode.auto,
                hoverColor: Colors.teal[100],
                selectedHoverColor: Colors.teal[100],
                selectedColor: posIndex == 0 ? rfBgColor : suBgColor,
                selectedTitleTextStyle:
                    TextStyle(color: posIndex == 0 ? textColor : Colors.white),
                selectedIconColor: Colors.white,
                openSideMenuWidth: 150,
                itemHeight: 100,
                itemOuterPadding: const EdgeInsets.all(4.0)),
            title: const Column(
              children: [
                // ConstrainedBox(
                //   constraints: const BoxConstraints(
                //     maxHeight: 150,
                //     maxWidth: 150,
                //   ),
                //   child: Image.asset(
                //     'assets/icons/start.gif',
                //   ),
                // ),
                Divider(
                  indent: 8.0,
                  endIndent: 8.0,
                ),
              ],
            ),
            items: [
              SideMenuItem(
                title: 'เติม',
                subTitle: 'ทองคำแท่ง',
                onTap: (index, _) {
                  posIndex = index;
                  setState(() {});
                  sideMenu.changePage(index);
                },
                icon: null,
                //const Icon(FontAwesomeIcons.b),
                tooltipContent: "เติมทองคำแท่ง",
              ),
              SideMenuItem(
                title: 'ขาย',
                subTitle: 'ทองคำแท่ง',
                onTap: (index, _) {
                  posIndex = index;
                  setState(() {});
                  sideMenu.changePage(index);
                },
                icon: null,
                //const Icon(FontAwesomeIcons.s),
                tooltipContent: 'ขายทองคำแท่ง',
              ),
            ],
          ),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [
                RefillThengGoldStockScreen(
                  refreshCart: refreshCart,
                  cartCount: cartCount,
                ),
                SellUsedThengGoldScreen(
                  refreshCart: refreshCart,
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
