import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/screen/tab_screen.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sizer/sizer.dart';

class TitleContent extends StatefulWidget {
  final Widget? title;
  final bool backButton;
  final bool goHome;

  const TitleContent({
    super.key,
    this.title,
    this.backButton = true,
    this.goHome = false,
  });

  @override
  State<TitleContent> createState() => _TitleContentState();
}

class _TitleContentState extends State<TitleContent> {
  @override
  void initState() {
    super.initState();
    // Initialize if null, otherwise update the existing notifier
    if (Global.branchNotifier == null) {
      Global.branchNotifier = ValueNotifier<BranchModel>(
        Global.branch ?? BranchModel(id: 0, name: 'เลือกสาขา'),
      );
    } else {
      Global.branchNotifier!.value =
          Global.branch ?? BranchModel(id: 0, name: 'เลือกสาขา');
    }

    if (Global.companyNotifier == null) {
      Global.companyNotifier = ValueNotifier<CompanyModel>(
        Global.company ?? CompanyModel(id: 0, name: 'เลือกบริษัท'),
      );
    } else {
      Global.companyNotifier!.value =
          Global.company ?? CompanyModel(id: 0, name: 'เลือกบริษัท');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {
                      if (widget.goHome) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TabScreen(
                                      title: "MENU",
                                    )));
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    elevation: 2.0,
                    fillColor: Colors.white,
                    constraints: const BoxConstraints(minWidth: 0.0),
                    padding: const EdgeInsets.all(8.0),
                    shape: const CircleBorder(),
                    child: Icon(
                      Icons.arrow_back,
                      size: 16.sp, // Adjust based on screen size
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ValueListenableBuilder<dynamic>(
                    valueListenable: Global.companyNotifier!,
                    builder: (context, company, child) {
                      return ValueListenableBuilder<dynamic>(
                        valueListenable: Global.branchNotifier!,
                        builder: (context, branch, child) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: company.logo == null
                                        ? Container()
                                        : Container(
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                '${Constants.DOMAIN_URL}/images/${company.logo}',
                                                fit: BoxFit.fitHeight,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.business,
                                          size: 16,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${company.name} (สาขา ${branch.name})',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? 14.sp
                                                  : 12.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${branch.address}, ${branch.village}, ${branch.district}, ${branch.province}',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? 12.sp
                                                  : 11.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          size: 14,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'โทรศัพท์/Phone : ${branch.phone}',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? 12.sp
                                                  : 11.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.receipt_long,
                                          size: 14,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'เลขประจําตัวผู้เสียภาษี/Tax ID : ${company.taxNumber} (สาขาที่ ${branch.branchId})',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? 12.sp
                                                  : 11.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ติดต่อฝ่ายช่วยเหลือโปรแกรม',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? 13.sp
                          : 12.sp,
                    ),
                  ),
                  Text(
                    '90039450835',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? 12.sp
                          : 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          Global.user != null ? 'ผู้ใช้: ' : '',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? 13.sp
                                : 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          Global.user != null
                              ? '${Global.user!.firstName!} ${Global.user!.lastName!}'
                              : '',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? 13.sp
                                : 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (Global.user?.userType == 'ADMIN')
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.domain,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'บริษัท: ',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).orientation ==
                                                Orientation.portrait
                                            ? 13.sp
                                            : 12.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 6,
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
                                  fontSize:
                                      MediaQuery.of(context).orientation ==
                                              Orientation.portrait
                                          ? 13.sp
                                          : 12.sp,
                                );
                              },
                              onChanged: (CompanyModel value) async {
                                Global.company = value;
                                Global.companyNotifier!.value = value;
                                await loadBranchList();
                                setState(() {});
                              },
                              child: DropDownObjectChildWidget(
                                key: GlobalKey(),
                                fontSize: MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? 13.sp
                                    : 12.sp,
                                projectValueNotifier: Global.companyNotifier!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (Global.user?.userRole == 'Administrator')
                      const SizedBox(height: 10),
                    if (Global.user?.userRole == 'Administrator')
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.store,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'สาขา: ',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).orientation ==
                                                Orientation.portrait
                                            ? 13.sp
                                            : 12.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 6,
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
                                      fontSize:
                                          MediaQuery.of(context).orientation ==
                                                  Orientation.portrait
                                              ? 13.sp
                                              : 12.sp,
                                    );
                                  },
                                  onChanged: (BranchModel value) {
                                    Global.branch = value;
                                    Global.branchNotifier!.value = value;
                                    setState(() {});
                                  },
                                  child: DropDownObjectChildWidget(
                                    key: GlobalKey(),
                                    fontSize:
                                        MediaQuery.of(context).orientation ==
                                                Orientation.portrait
                                            ? 13.sp
                                            : 12.sp,
                                    projectValueNotifier:
                                        Global.branchNotifier!,
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
                                              BorderRadius.circular(100.0),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipOval(
                                              child: SizedBox(
                                                width: 30.0,
                                                height: 30.0,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        Global.branch = null;
                                                        Global.branchNotifier!
                                                                .value =
                                                            BranchModel(
                                                          id: 0,
                                                          name: 'เลือกสาขา',
                                                        );
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: const Icon(
                                                        Icons.clear,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),
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
                      Row(
                        children: [
                          Icon(
                            Icons.store,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            Global.branch != null
                                ? 'สาขา: ${Global.branch!.name}'
                                : '',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? 13.sp
                                  : 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (widget.title != null)
          const Divider(
            thickness: 0.5,
            height: 2,
          ),
        const SizedBox(height: 5),
        if (widget.title != null) Center(child: widget.title ?? Container()),
        const SizedBox(height: 5),
      ],
    );
  }

  Future<void> loadBranchList() async {
    Global.branch = null;
    Global.branchNotifier!.value = BranchModel(id: 0, name: 'เลือกสาขา');

    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var b = await ApiServices.get('/branch/by-company/${Global.company?.id}');
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
