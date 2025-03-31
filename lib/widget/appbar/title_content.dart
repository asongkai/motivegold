import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/image/cached_image.dart';

class TitleContent extends StatefulWidget {
  final Widget? title;
  final bool backButton;

  const TitleContent({super.key, this.title, this.backButton = true});

  @override
  State<TitleContent> createState() => _TitleContentState();
}

class _TitleContentState extends State<TitleContent> {
  ValueNotifier<dynamic>? branchNotifier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    branchNotifier = ValueNotifier<BranchModel>(
        Global.branch ?? BranchModel(id: 0, name: 'เลือกสาขา'));
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
                    onPressed: () => Navigator.of(context).pop(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    constraints: const BoxConstraints(minWidth: 0.0),
                    padding: const EdgeInsets.all(15.0),
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 35.0,
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
                              // child: Image.network(
                              //   '${Constants.DOMAIN_URL}/images/${Global.company?.logo}',
                              //   fit: BoxFit.fitHeight,
                              // ),
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
                                    '${Global.company?.name} (${Global.branch?.name})',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                      '${Global.branch?.address}, ${Global.branch?.village}, ${Global.branch?.district}, ${Global.branch?.province}',
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white)),
                                  Text(
                                      'โทรศัพท์/Phone : ${Global.branch?.phone}',
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white)),
                                  Text(
                                      'เลขประจําตัวผู้เสียภาษี/Tax ID : ${Global.company?.taxNumber} (สาขาที่ ${Global.branch?.branchId})',
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white)),
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
                            Global.user != null
                                ? 'ผู้ใช้: '
                                : '',
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w900),
                          ),
                          Text(
                            Global.user != null
                                ? '${Global.user!.firstName!} ${Global.user!.lastName!}'
                                : '',
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      if (Global.user?.userRole == 'Administrator')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'สาขา: ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900),
                            ),
                            SizedBox(
                              height: 60,
                              child: MiraiDropDownMenu<BranchModel>(
                                key: UniqueKey(),
                                children: Global.branchList,
                                space: 4,
                                maxHeight: 360,
                                showSearchTextField: false,
                                selectedItemBackgroundColor: Colors.transparent,
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
                                    fontSize: 20,
                                  );
                                },
                                onChanged: (BranchModel value) {
                                  Global.branch = value;
                                  branchNotifier!.value = value;
                                  setState(() {});
                                },
                                child: DropDownObjectChildWidget(
                                  key: GlobalKey(),
                                  fontSize: 20,
                                  projectValueNotifier: branchNotifier!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (Global.user?.userRole != 'Administrator')
                        Text(
                          Global.branch != null
                              ? 'สาขา: ${Global.branch!.name}'
                              : '',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ))
          ],
        ),
        Row(
          children: [
            const Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.only(left: 18.0),
                  child: Text(
                    'ติดต่อฝ่ายช่วยเหลือโปรแกรม 90039450835',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20),
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
}
