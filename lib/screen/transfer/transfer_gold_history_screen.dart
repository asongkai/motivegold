import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class TransferGoldHistoryScreen extends StatefulWidget {
  const TransferGoldHistoryScreen({super.key});

  @override
  State<TransferGoldHistoryScreen> createState() => _TransferGoldHistoryScreenState();
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
      var result = await ApiServices.post('/transfer/all', Global.requestObj(null));
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
      appBar: AppBar(
        title: const Text('รายการประวัติการโอนทอง'),
        actions: const [

        ],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : list!.isEmpty ? const Center(child: NoDataFoundWidget()) : SingleChildScrollView(
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
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: ListTile(
              // leading: SizedBox(
              //   width: 100,
              //   child: Image.asset(
              //     'assets/images/Gold-Chain-PNG.png',
              //     fit: BoxFit.fitHeight,
              //   ),
              // ),
              trailing: Text(
                Global.formatDate(list.transferDate.toString()),
                style: TextStyle(color: Colors.green, fontSize: size?.getWidthPx(6)),
              ),
              title: Text(
                '#${list.transferId.toString()}',
                style: TextStyle(fontSize: size?.getWidthPx(8)),
              ),
              subtitle: Table(
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                            'สินค้า',
                            textAlign: TextAlign.left,
                            style:
                            TextStyle(fontSize: size?.getWidthPx(8), color: Colors.orange)
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('น้ำหนัก',
                            textAlign: TextAlign.center,
                            style:
                            TextStyle(fontSize: size?.getWidthPx(8), color: Colors.orange)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('คลังสินค้า',
                            textAlign: TextAlign.center,
                            style:
                            TextStyle(fontSize: size?.getWidthPx(8), color: Colors.orange)),
                      ),
                    ],
                  ),
                  ...list.details!.map(
                        (e) => TableRow(
                      decoration: const BoxDecoration(),
                      children: [
                        paddedText(e.product!.name, style:
                        TextStyle(fontSize: size?.getWidthPx(7))),
                        paddedText(
                            formatter.format(e.weight!),
                            align: TextAlign.center,
                            style:
                            TextStyle(fontSize: size?.getWidthPx(7))),
                        paddedText('ต้นทาง: ${list.fromBinLocation!.name} \nปลายทาง: ${list.toBinLocation!.name}',
                            align: TextAlign.left,
                            style:
                            TextStyle(fontSize: size?.getWidthPx(7))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: Row(
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           // Navigator.push(
          //           //     context,
          //           //     MaterialPageRoute(
          //           //         builder: (context) => EditProductScreen(
          //           //             showBackButton: true,
          //           //             product: refillList[index],
          //           //             index: index
          //           //         ),
          //           //         fullscreenDialog: true))
          //           //     .whenComplete(() {
          //           //   loadData();
          //           // });
          //         },
          //         child: Container(
          //           height: 50,
          //           width: 60,
          //           decoration: BoxDecoration(
          //               color: Colors.teal,
          //               borderRadius: BorderRadius.circular(8)),
          //           child: const Icon(
          //             Icons.edit,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //       const Spacer(),
          //       GestureDetector(
          //         onTap: () {
          //           removeProduct(refillList[index].id!, index);
          //         },
          //         child: Container(
          //           height: 50,
          //           width: 60,
          //           decoration: BoxDecoration(
          //               color: Colors.red,
          //               borderRadius: BorderRadius.circular(8)),
          //           child: const Icon(
          //             Icons.delete,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
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
        setState(() {
        });
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
}
