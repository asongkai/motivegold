import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class TransferGoldHistoryScreen extends StatefulWidget {
  const TransferGoldHistoryScreen({super.key});

  @override
  State<TransferGoldHistoryScreen> createState() =>
      _TransferGoldHistoryScreenState();
}

class _TransferGoldHistoryScreenState extends State<TransferGoldHistoryScreen> {
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
      var result =
          await ApiServices.post('/transfer/all', Global.requestObj(null));
      motivePrint(result?.toJson());
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
                ? const Center(child: NoDataFoundWidget())
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
          color:
              list.status == 'PENDING' ? Colors.orange.shade50 : Colors.white,
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
                        style: TextStyle(fontSize: size?.getWidthPx(8)),
                      ),
                      Text(
                        Global.formatDate(list.transferDate.toString()),
                        style: TextStyle(
                            color: Colors.green, fontSize: size?.getWidthPx(6)),
                      )
                    ],
                  ),
                  subtitle: Table(
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('สินค้า',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: size?.getWidthPx(8),
                                    color: Colors.orange)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('น้ำหนัก',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: size?.getWidthPx(8),
                                    color: Colors.orange)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('คลังสินค้า',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: size?.getWidthPx(8),
                                    color: Colors.orange)),
                          ),
                        ],
                      ),
                      ...list.details!.map(
                        (e) => TableRow(
                          decoration: const BoxDecoration(),
                          children: [
                            paddedText(e.product!.name,
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (list.toBranchId != null &&
                          list.toBranchId != 0 &&
                          list.status == 'PENDING' && list.toBranchId != Global.user!.branchId)
                        GestureDetector(
                          onTap: () {
                            cancel(list);
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'ยกเลิก',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Center(
            child: Row(
              children: [
                if (list.status == 'PENDING' || list.status == 'CANCEL' || list.status == 'REJECT')
                Container(
                  decoration: BoxDecoration(
                      color: list.status == 'PENDING'
                          ? Colors.deepOrange
                          : Colors.red,
                      borderRadius: BorderRadius.circular(10.0)),
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 30.0,
                            height: 30.0,
                            child: RawMaterialButton(
                              elevation: 10.0,
                              child: const Icon(
                                Icons.pending_actions,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Text('${list.status}',
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20,),
                Container(
                  decoration: BoxDecoration(
                      color: list.toBranchId != null && list.toBranchId != 0
                          ? Colors.teal.shade900
                          : Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(10.0)),
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 30.0,
                            height: 30.0,
                            child: RawMaterialButton(
                              elevation: 10.0,
                              child: const Icon(
                                Icons.transform_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Text(
                          list.toBranchId != null && list.toBranchId != 0
                              ? 'โอนระหว่างสาขา'
                              : 'โอนภายใน',
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ),
              ],
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

  void cancel(TransferModel list) async {
    try {
      // motivePrint(list.toJson());
      // return;
      Alert.info(
          context, 'คุณแน่ใจที่จะยกเลิกการทำธุรกรรมนี้หรือไม่?', '', 'ตกลง',
          action: () async {
            final ProgressDialog pr = ProgressDialog(context,
                type: ProgressDialogType.normal,
                isDismissible: true,
                showLogs: true);
            await pr.show();
            pr.update(message: 'processing'.tr());
            var result = await ApiServices.post(
                '/transfer/between-branch-cancel', Global.requestObj(list));
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
