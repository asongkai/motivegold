import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/screen/pos/modal/hold_list.dart';
import 'package:badges/badges.dart' as badges;
import 'package:motivegold/screen/pos/storefront/checkout_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/ui-matching/buy_theng_matching_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/ui-matching/sell_theng_matching_screen.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:sizer/sizer.dart';

class ThengSaleMatchingMenuScreen extends StatefulWidget {
  const ThengSaleMatchingMenuScreen({Key? key, required this.title})
      : super(key: key);

  final String title;

  @override
  ThengSaleMatchingMenuScreenState createState() =>
      ThengSaleMatchingMenuScreenState();
}

class ThengSaleMatchingMenuScreenState
    extends State<ThengSaleMatchingMenuScreen> {
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
    Global.currentOrderType = 2;
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
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Text("ซื้อขายทองคำแท่ง (จับคู่)",
                      style: TextStyle(
                          fontSize: 14.sp, //size.getWidthPx(10),
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
                              icon: Icon(
                                Icons.save,
                                size: (MediaQuery.of(context).orientation ==
                                        Orientation.landscape)
                                    ? Device.deviceType == DeviceType.web
                                        ? 16.sp
                                        : size.getWidthPx(8)
                                    : size.getWidthPx(15),
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
                                      sumSellThengTotalMatching();
                                    }
                                    if (Global.posIndex == 1) {
                                      sumBuyThengTotalMatching();
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
                              icon: Icon(
                                Icons.shopping_cart,
                                size: (MediaQuery.of(context).orientation ==
                                        Orientation.landscape)
                                    ? Device.deviceType == DeviceType.web
                                        ? 16.sp
                                        : size.getWidthPx(8)
                                    : size.getWidthPx(15),
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
                showHamburger: true,
                displayMode: SideMenuDisplayMode.auto,
                hoverColor: Colors.teal[100],
                selectedHoverColor: Colors.teal[100],
                selectedColor: posIndex == 0 ? stmBgColor : Colors.teal,
                selectedTitleTextStyle: const TextStyle(color: Colors.white),
                selectedIconColor: Colors.white,
                openSideMenuWidth: 160,
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
                title: 'ลูกค้าซื้อ',
                subTitle: 'ร้านทองขาย',
                onTap: (index, _) {
                  posIndex = index;
                  setState(() {});
                  sideMenu.changePage(index);
                },
                icon: null,
                //const Icon(FontAwesomeIcons.s),
                tooltipContent: 'ลูกค้าซื้อ ร้านทองขาย',
              ),
              SideMenuItem(
                title: 'ลูกค้าขาย',
                subTitle: 'ร้านทองรับซื้อ',
                onTap: (index, _) {
                  posIndex = index;
                  setState(() {});
                  sideMenu.changePage(index);
                },
                icon: null,
                //const Icon(FontAwesomeIcons.b),
                tooltipContent: 'ลูกค้าขาย ร้านทองรับซื้อ',
              ),
            ],
          ),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [
                SellThengMatchingScreen(
                  refreshCart: refreshCart,
                  refreshHold: refreshHold,
                  cartCount: cartCount,
                ),
                BuyThengMatchingScreen(
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
