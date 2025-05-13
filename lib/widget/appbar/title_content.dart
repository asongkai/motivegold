import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/image/cached_image.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class TitleContent extends StatefulWidget {
  final Widget? title;
  final bool backButton;

  const TitleContent({super.key, this.title, this.backButton = true});

  @override
  State<TitleContent> createState() => _TitleContentState();
}

class _TitleContentState extends State<TitleContent> {
  ValueNotifier<dynamic>? branchNotifier;
  ValueNotifier<dynamic>? companyNotifier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    branchNotifier = ValueNotifier<BranchModel>(
        Global.branch ?? BranchModel(id: 0, name: 'เลือกสาขา'));
    companyNotifier = ValueNotifier<CompanyModel>(
        Global.company ?? CompanyModel(id: 0, name: 'เลือกบริษัท'));
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.backButton)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RawMaterialButton(
                    onPressed: () => Navigator.of(context).pop(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    constraints: const BoxConstraints(minWidth: 0.0),
                    padding: const EdgeInsets.all(8.0),
                    shape: const CircleBorder(),
                    child: Icon(
                      Icons.arrow_back,
                      size: size.getWidthPx(15),
                    ),
                  ),
                ),
              ),
            Expanded(
                flex: 7,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Global.company?.logo == null
                                  ? Container()
                                  : Image.network(
                                      '${Constants.DOMAIN_URL}/images/${Global.company?.logo}',
                                      fit: BoxFit.fitHeight,
                                    ),
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 9,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '${Global.company?.name} (สาขา ${Global.branch?.name})',
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6),
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                      '${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(7) : size.getWidthPx(5),
                                          color: Colors.white)),
                                  Text(
                                      'โทรศัพท์/Phone : ${Global.branch?.phone}',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(7) : size.getWidthPx(5),
                                          color: Colors.white)),
                                  Text(
                                      'เลขประจําตัวผู้เสียภาษี/Tax ID : ${Global.company?.taxNumber} (สาขาที่ ${Global.branch?.branchId})',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(7) : size.getWidthPx(5),
                                          color: Colors.white)),
                                ]))
                      ]),
                    ])),
            const SizedBox(
              width: 20,
            ),
            Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            Global.user != null ? 'ผู้ใช้: ' : '',
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6),
                                color: Colors.white,
                                fontWeight: FontWeight.w900),
                          ),
                          Text(
                            Global.user != null
                                ? '${Global.user!.firstName!} ${Global.user!.lastName!}'
                                : '',
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6),
                                color: Colors.white,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      if (Global.user?.userType == 'ADMIN')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'บริษัท: ',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900),
                            ),
                            SizedBox(
                              // height: 60,
                              child: MiraiDropDownMenu<CompanyModel>(
                                key: UniqueKey(),
                                children: Global.companyList,
                                space: 4,
                                maxHeight: 360,
                                showSearchTextField: false,
                                selectedItemBackgroundColor: Colors.transparent,
                                emptyListMessage: 'ไม่มีข้อมูล',
                                showSelectedItemBackgroundColor: true,
                                itemWidgetBuilder: (
                                  int index,
                                  CompanyModel? project, {
                                  bool isItemSelected = false,
                                }) {
                                  return DropDownItemWidget(
                                    project: project,
                                    isItemSelected: isItemSelected,
                                    firstSpace: 10,
                                    fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6),
                                  );
                                },
                                onChanged: (CompanyModel value) async {
                                  Global.company = value;
                                  companyNotifier!.value = value;

                                  await loadBranchList();
                                  setState(() {});
                                },
                                child: DropDownObjectChildWidget(
                                  key: GlobalKey(),
                                  fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6),
                                  projectValueNotifier: companyNotifier!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (Global.user?.userRole == 'Administrator')
                        const SizedBox(
                          width: 20,
                        ),
                      if (Global.user?.userRole == 'Administrator')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'สาขา: ',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900),
                            ),
                            SizedBox(
                              // height: 60,
                              child: Stack(
                                children: [
                                  MiraiDropDownMenu<BranchModel>(
                                    key: UniqueKey(),
                                    children: Global.branchList,
                                    space: 4,
                                    maxHeight: 360,
                                    showSearchTextField: false,
                                    selectedItemBackgroundColor:
                                        Colors.transparent,
                                    emptyListMessage: 'ไม่มีข้อมูล',
                                    showSelectedItemBackgroundColor: true,
                                    itemWidgetBuilder: (
                                      int index,
                                      BranchModel? project, {
                                      bool isItemSelected = false,
                                    }) {
                                      return DropDownItemWidget(
                                        project: project,
                                        isItemSelected: isItemSelected,
                                        firstSpace: 10,
                                        fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6),
                                      );
                                    },
                                    onChanged: (BranchModel value) {
                                      Global.branch = value;
                                      branchNotifier!.value = value;
                                      setState(() {});
                                    },
                                    child: DropDownObjectChildWidget(
                                      key: GlobalKey(),
                                      fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6),
                                      projectValueNotifier: branchNotifier!,
                                    ),
                                  ),
                                  if (Global.branch != null)
                                    Positioned(
                                      right: 5,
                                      top: 5,
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(100.0)),
                                          // padding: const EdgeInsets.only(
                                          //     left: 5.0, right: 5.0),
                                          child: Row(
                                            children: [
                                              ClipOval(
                                                child: SizedBox(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  child: RawMaterialButton(
                                                    elevation: 10.0,
                                                    child: const Icon(
                                                      Icons.clear,
                                                      color: Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        // Global.branchList = [];
                                                        Global.branch = null;
                                                        branchNotifier = ValueNotifier<
                                                            BranchModel>(Global
                                                                .branch ??
                                                            BranchModel(
                                                                id: 0,
                                                                name:
                                                                    'เลือกสาขา'));
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (Global.user?.userRole != 'Administrator')
                        Text(
                          Global.branch != null
                              ? 'สาขา: ${Global.branch!.name}'
                              : '',
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6),
                              color: Colors.white,
                              fontWeight: FontWeight.w900),
                        ),
                    ],
                  ),
                ))
          ],
        ),
        Row(
          children: [
            Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Text(
                    'ติดต่อฝ่ายช่วยเหลือโปรแกรม 90039450835',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? size.getWidthPx(8) : size.getWidthPx(6)),
                  ),
                )),
            Expanded(flex: 4, child: Container())
          ],
        ),
        if (widget.title != null)
          const Divider(
            thickness: 0.5,
            height: 2,
          ),
        if (widget.title != null) Center(child: widget.title ?? Container()),
        const SizedBox(
          height: 0,
        ),
      ],
    );
  }

  loadBranchList() async {
    Global.branch = null;
    branchNotifier = ValueNotifier<BranchModel>(
        Global.branch ?? BranchModel(id: 0, name: 'เลือกสาขา'));
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var b = await ApiServices.get('/branch/by-company/${Global.company?.id}');
      // motivePrint(b!.data);
      await pr.hide();
      if (b?.status == "success") {
        var data = jsonEncode(b?.data);
        List<BranchModel> products = branchListModelFromJson(data);
        setState(() {
          Global.branchList = products;
        });
      } else {
        Global.branchList = [];
      }
    } catch (e) {
      await pr.hide();
      Alert.warning(context, 'คำเตือน', '${e.toString()}', 'OK', action: () {});
    }
  }
}
