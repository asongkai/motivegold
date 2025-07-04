import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:sizer/sizer.dart';
class TransferGoldPendingScreen extends StatefulWidget {
  const TransferGoldPendingScreen({super.key});

  @override
  State<TransferGoldPendingScreen> createState() =>
      _TransferGoldPendingScreenState();
}

class _TransferGoldPendingScreenState extends State<TransferGoldPendingScreen> {
  bool loading = false;
  List<TransferModel>? list = [];
  Screen? size;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post(
          '/transfer/other-branch/all', Global.requestObj(null));
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
      if (kDebugMode) {
        print(e.toString());
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายการประวัติการโอนทอง",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : list!.isEmpty
                ? const NoDataFoundWidget()
                : SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: list!.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              return dataCard(list![index], index);
                            }),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget dataCard(TransferModel list, int index) {
    return Stack(
      children: [
        Card(
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${list.transferId.toString()}',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      Text(
                        Global.formatDate(list.transferDate.toString()),
                        style: TextStyle(
                            color: Colors.green, fontSize: size!.getWidthPx(5)),
                      ),
                    ],
                  ),
                  subtitle: Table(
                    children: [
                      TableRow(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('สินค้า',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: size?.getWidthPx(8),
                                      color: Colors.orange)),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('น้ำหนัก',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: size?.getWidthPx(8),
                                      color: Colors.orange)),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('คลังสินค้า',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: size?.getWidthPx(8),
                                      color: Colors.orange)),
                            ),
                          ),
                        ],
                      ),
                      ...list.details!.map(
                        (e) => TableRow(
                          decoration: const BoxDecoration(),
                          children: [
                            paddedText(e.product!.name,
                                align: TextAlign.center,
                                style:
                                    TextStyle(fontSize: size?.getWidthPx(7))),
                            paddedText(formatter.format(e.weight!),
                                align: TextAlign.center,
                                style:
                                    TextStyle(fontSize: size?.getWidthPx(7))),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    paddedText('ต้นทาง:',
                                        align: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: size?.getWidthPx(7),
                                            fontWeight: FontWeight.w900)),
                                    paddedText(
                                        '${list.toBranchId != null && list.toBranchId != 0 ? 'สาขา ${list.toBranchName}' : ''} คลัง ${list.fromBinLocation!.name}',
                                        align: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: size?.getWidthPx(7))),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    paddedText('ปลายทาง:',
                                        align: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: size?.getWidthPx(7),
                                            fontWeight: FontWeight.w900)),
                                    paddedText(
                                        '${list.toBranchId != null && list.toBranchId != 0 ? 'สาขา ${list.toBranchName}' : ''} คลัง ${list.toBinLocation!.name}',
                                        align: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: size?.getWidthPx(7))),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (list.status == 'PENDING')
                      GestureDetector(
                        onTap: () {
                          confirm(list);
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                Text(
                                  'รับสินค้า',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(width: 10,),
                      // GestureDetector(
                      //   onTap: () {
                      //     reject(list);
                      //   },
                      //   child: Container(
                      //     height: 50,
                      //     width: 60,
                      //     decoration: BoxDecoration(
                      //         color: Colors.red,
                      //         borderRadius: BorderRadius.circular(8)),
                      //     child: const Icon(
                      //       Icons.refresh,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                )
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  color:
                      (list.status == 'SUCCESS') ? Colors.teal : Colors.orange,
                  borderRadius: BorderRadius.circular(10.0)),
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: RawMaterialButton(
                        elevation: 10.0,
                        child: Icon(
                          (list.status == 'SUCCESS')
                              ? Icons.check
                              : Icons.pending_actions,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Text(
                    list.status!,
                    style: const TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void removeProduct(int id, int i) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var result = await ApiServices.delete('/product', id);
      await pr.hide();
      if (result?.status == "success") {
        list!.removeAt(i);
        setState(() {});
      } else {
        if (mounted) {
          Alert.warning(context, 'Warning'.tr(), result!.message!, 'OK'.tr(),
              action: () {});
        }
      }
    } catch (e) {
      await pr.hide();
      if (mounted) {
        Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
            action: () {});
      }
    }
  }

  void confirm(TransferModel list) async {
    motivePrint(list.toJson());
    try {
      Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
          action: () async {
        final ProgressDialog pr = ProgressDialog(context,
            type: ProgressDialogType.normal,
            isDismissible: true,
            showLogs: true);
        await pr.show();
        pr.update(message: 'processing'.tr());
        var result = await ApiServices.post(
            '/transfer/between-branch-confirm', Global.requestObj(list));
        await pr.hide();
        if (result?.status == "success") {
          loadData();
        } else {
          if (mounted) {}
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
