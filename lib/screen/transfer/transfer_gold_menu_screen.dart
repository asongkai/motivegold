import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/screen/transfer/transfer_gold_history_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_pending_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import '../../model/transfer.dart';
import '../../utils/global.dart';

class TransferGoldMenuScreen extends StatefulWidget {
  const TransferGoldMenuScreen({super.key});

  @override
  State<TransferGoldMenuScreen> createState() => _TransferGoldMenuScreenState();
}

class _TransferGoldMenuScreenState extends State<TransferGoldMenuScreen> {
  ApiServices api = ApiServices();
  Screen? size;
  bool loading = false;
  List<TransferModel>? list = [];

  @override
  void initState() {
    // implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      // loading = true;
    });
    try {
      var result = await ApiServices.post(
          '/transfer/other-branch/pending', Global.requestObj(null));
      // motivePrint(result!.data);
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<TransferModel> products = transferListModelFromJson(data);
        setState(() {
          list = products;
        });
      } else {
        list = [];
      }
    } catch (e) {
      motivePrint(e.toString());
    }
    setState(() {
      // loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เมนูโอนทอง',
          style: TextStyle(fontSize: size?.getWidthPx(8)),
        ),
      ),
      body: loading
          ? const LoadingProgress()
          : Stack(
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
                    context, MaterialPageRoute(builder: (context) => route))
                .whenComplete(() {
              loadData();
              setState(() {});
            });
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
                childAspectRatio:
                    orientation == Orientation.portrait ? .80 : .90,
                children: [
                  itemDashboard(
                    'โอนทอง \n ',
                    Icons.compare_arrows_outlined,
                    primer,
                    const TransferGoldScreen(),
                  ),
                  Stack(
                    children: [
                      itemDashboard(
                        'รายการโอน (จากสาขาอื่น)',
                        Icons.pending_actions,
                        Colors.red,
                        const TransferGoldPendingScreen(),
                      ),
                      if (list != null && list!.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10.0)),
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      (list == null)
                                          ? 0.toString()
                                          : list!.length.toString(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // itemDashboard(
                  //   'รายการโอนทอง \n ',
                  //   Icons.view_list,
                  //   Colors.teal,
                  //   const TransferGoldHistoryScreen(),
                  // ),
                ],
              );
            },
          ),
        ),
      );
}
