import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/sell_detail.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/model/sell.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../api/api_services.dart';
import '../../utils/alert.dart';
import '../../utils/global.dart';
import '../../utils/responsive_screen.dart';
import '../../utils/util.dart';
import '../../widget/loading/loading_progress.dart';
import '../pos/print_bill_screen.dart';

class SellUsedGoldHistoryScreen extends StatefulWidget {
  const SellUsedGoldHistoryScreen({super.key});

  @override
  State<SellUsedGoldHistoryScreen> createState() =>
      _SellUsedGoldHistoryScreenState();
}

class _SellUsedGoldHistoryScreenState extends State<SellUsedGoldHistoryScreen> {
  bool loading = false;
  List<SellModel>? sellList = [];
  Screen? size;
  TextEditingController productEntryWeightCtrl = TextEditingController();
  TextEditingController productEntryWeightBahtCtrl = TextEditingController();
  TextEditingController sellIdCtrl = TextEditingController();
  TextEditingController dateCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  SellModel? selectedSell;
  SellDetailModel? selectedDetail;

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
      var result = await ApiServices.post('/sell/all', Global.requestObj(null));
      // print(result!.data);
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<SellModel> products = sellListModelFromJson(data);
        setState(() {
          sellList = products;
        });
      } else {
        sellList = [];
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
        title: const Text('รายการประวัติการขายทองเก่า'),
        actions: const [],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : sellList!.isEmpty
                ? const EmptyContent()
                : SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: sellList!.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              return dataCard(sellList![index], index);
                            }),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget dataCard(SellModel list, int index) {
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
                        '#${list.sellId.toString()}',
                        style: TextStyle(fontSize: size?.getWidthPx(8)),
                      ),
                      Text(
                        Global.formatDate(list.sellDate.toString()),
                        style: TextStyle(
                            color: Colors.green, fontSize: size?.getWidthPx(6)),
                      )
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
                          if (list.status == 'PENDING')
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Container(),
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
                            paddedText(
                                '${e.fromBinLocation!.name} - ${e.toBinLocation!.name}',
                                align: TextAlign.center,
                                style:
                                    TextStyle(fontSize: size?.getWidthPx(7))),
                            if (list.status == 'PENDING')
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSell = list;
                                        sellIdCtrl.text = list.sellId!;
                                        dateCtrl.text = Global.formatDate(
                                            list.sellDate!.toString());
                                        productWeightCtrl.text =
                                            formatter.format(e.weight);
                                        productWeightBahtCtrl.text =
                                            formatter.format(e.weightBath);
                                        productEntryWeightCtrl.text = "";
                                        productEntryWeightBahtCtrl.text = "";
                                        selectedDetail = e;
                                      });
                                      adjustWeight(e);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 60,
                                        // width: 100,
                                        decoration: BoxDecoration(
                                            color: Colors.teal,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              ),
                                              Text('ยืนยัน',
                                                  style: TextStyle(
                                                      fontSize:
                                                          size!.getWidthPx(6),
                                                      color: Colors.white))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (list.status == 'PENDING')
          Positioned(
            right: 0,
            top: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.orange,
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
                          child: const Icon(
                            Icons.pending_actions,
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

  void adjustWeight(SellDetailModel e) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: buildTextFieldBig(
                                    labelText: "เลขที่",
                                    inputType: TextInputType.text,
                                    textColor: Colors.orange,
                                    enabled: false,
                                    controller: sellIdCtrl,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: buildTextFieldBig(
                                    labelText: "วันที่",
                                    inputType: TextInputType.text,
                                    textColor: Colors.orange,
                                    enabled: false,
                                    controller: dateCtrl,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: buildTextFieldBig(
                                    labelText: "น้ำหนัก (gram)",
                                    inputType: TextInputType.number,
                                    textColor: Colors.orange,
                                    enabled: false,
                                    controller: productWeightCtrl,
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: buildTextFieldBig(
                                    labelText: "น้ำหนัก (บาททอง)",
                                    inputType: TextInputType.phone,
                                    textColor: Colors.orange,
                                    enabled: false,
                                    controller: productWeightBahtCtrl,
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: buildTextFieldBig(
                                      labelText: "ป้อนน้ำหนักจริง (gram)",
                                      inputType: TextInputType.number,
                                      textColor: Colors.orange,
                                      controller: productEntryWeightCtrl,
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      onChanged: (String value) {
                                        if (productEntryWeightCtrl
                                            .text.isNotEmpty) {
                                          productEntryWeightBahtCtrl.text =
                                              formatter.format((Global.toNumber(
                                                          productEntryWeightCtrl
                                                              .text) /
                                                      15.16)
                                                  .toPrecision(2));
                                        } else {
                                          productEntryWeightBahtCtrl.text = "";
                                        }
                                      }),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: buildTextFieldBig(
                                      labelText: "ป้อนน้ำหนักจริง (บาททอง)",
                                      inputType: TextInputType.phone,
                                      textColor: Colors.orange,
                                      controller: productEntryWeightBahtCtrl,
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      onChanged: (String value) {
                                        if (productEntryWeightBahtCtrl
                                            .text.isNotEmpty) {
                                          productEntryWeightCtrl.text =
                                              formatter.format((Global.toNumber(
                                                          productEntryWeightBahtCtrl
                                                              .text) *
                                                      15.16)
                                                  .toPrecision(2));
                                        } else {
                                          productEntryWeightCtrl.text = "";
                                        }
                                      }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              child: const Text("บันทึก"),
                              onPressed: () async {
                                if (productEntryWeightCtrl.text.isEmpty) {
                                  Alert.warning(context, 'คำเตือน',
                                      'กรุณาเพิ่มข้อมูลก่อน', 'OK');
                                  return;
                                }

                                if (selectedSell == null) {
                                  return;
                                }

                                selectedDetail?.weight = Global.toNumber(
                                    productEntryWeightCtrl.text);
                                selectedDetail?.weightBath = Global.toNumber(
                                    productEntryWeightBahtCtrl.text);

                                // motivePrint(selectedSell?.toJson());
                                // return;
                                final ProgressDialog pr = ProgressDialog(
                                    context,
                                    type: ProgressDialogType.normal,
                                    isDismissible: true,
                                    showLogs: true);
                                await pr.show();
                                pr.update(message: 'processing'.tr());
                                try {
                                  var result = await ApiServices.post(
                                      '/sell/confirm-adjust', Global.requestObj(selectedSell));
                                  // print(result!.data);
                                  if (result!.status == "success") {
                                    var detail = await ApiServices.post(
                                        '/selldetail/adjust', Global.requestObj(selectedDetail));
                                    // print(detail!.data);
                                    await pr.hide();
                                    if (detail?.status == "success") {
                                      motivePrint("Confirm completed");
                                      if (mounted) {
                                        Alert.success(context, 'Success'.tr(), 'Success', 'OK'.tr(),
                                            action: () {
                                              Navigator.of(context).pop();
                                              loadData();
                                            });
                                      }
                                    }
                                  } else {
                                    await pr.hide();
                                  }
                                  setState(() {});
                                } catch (e) {
                                  await pr.hide();
                                  if (mounted) {
                                    Alert.warning(context, 'Warning'.tr(),
                                        e.toString(), 'OK'.tr(),
                                        action: () {});
                                  }
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
