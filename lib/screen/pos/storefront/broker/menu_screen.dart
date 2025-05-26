import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motivegold/screen/pos/modal/hold_list.dart';
import 'package:badges/badges.dart' as badges;
import 'package:motivegold/screen/pos/storefront/broker/ui/buy_theng_screen.dart';
import 'package:motivegold/screen/pos/storefront/broker/ui/sell_theng_screen.dart';
import 'package:motivegold/screen/pos/storefront/checkout_screen.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';

class ThengBrokerMenuScreen extends StatefulWidget {
  const ThengBrokerMenuScreen({super.key, required this.title});

  final String title;

  @override
  ThengBrokerMenuScreenState createState() => ThengBrokerMenuScreenState();
}

class ThengBrokerMenuScreenState extends State<ThengBrokerMenuScreen> {
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
    Global.currentOrderType = 4;
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
                    child: Text(widget.title,
                        style: TextStyle(
                            fontSize: size.getWidthPx(10),
                            color: Colors.white,
                            fontWeight: FontWeight.w900))),
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
                                size: (MediaQuery.of(context).orientation == Orientation.landscape)
                                    ? size.getWidthPx(8)
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
                                      sumSellThengTotalBroker();
                                    }
                                    if (Global.posIndex == 1) {
                                      sumBuyThengTotalBroker();
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
                                size: (MediaQuery.of(context).orientation == Orientation.landscape)
                                    ? size.getWidthPx(8)
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
                selectedColor: Colors.teal,
                selectedTitleTextStyle: const TextStyle(color: Colors.white),
                selectedIconColor: Colors.white,
                openSideMenuWidth: 190,
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
                title: 'ร้านทองขาย',
                subTitle: 'โบรกเกอร์รับซื้อ',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: null,
                //const Icon(FontAwesomeIcons.s),
                tooltipContent: 'ร้านทองขาย โบรกเกอร์รับซื้อ',
              ),
              SideMenuItem(
                title: 'ร้านทองซื้อ',
                subTitle: 'โบรกเกอร์ขาย',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: null,
                //const Icon(FontAwesomeIcons.b),
                tooltipContent: 'ร้านทองซื้อ โบรกเกอร์ขาย',
              ),
            ],
          ),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [
                SellThengBrokerScreen(
                  refreshCart: refreshCart,
                  refreshHold: refreshHold,
                  cartCount: cartCount,
                ),
                BuyThengBrokerScreen(
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
