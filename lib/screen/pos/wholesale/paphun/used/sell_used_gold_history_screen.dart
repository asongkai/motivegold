import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:sizer/sizer.dart';
import 'preview.dart';

class SellUsedGoldHistoryScreen extends StatefulWidget {
  const SellUsedGoldHistoryScreen({super.key});

  @override
  State<SellUsedGoldHistoryScreen> createState() =>
      _SellUsedGoldHistoryScreenState();
}

class _SellUsedGoldHistoryScreenState extends State<SellUsedGoldHistoryScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;
  TextEditingController productEntryWeightCtrl = TextEditingController();
  TextEditingController productEntryWeightBahtCtrl = TextEditingController();
  TextEditingController sellIdCtrl = TextEditingController();
  TextEditingController dateCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  OrderModel? selectedSell;
  OrderDetailModel? selectedDetail;

  final TextEditingController yearCtrl = TextEditingController();
  final TextEditingController monthCtrl = TextEditingController();
  ValueNotifier<dynamic>? yearNotifier;
  ValueNotifier<dynamic>? monthNotifier;

  @override
  void initState() {
    super.initState();
    yearNotifier = ValueNotifier<int>(DateTime.now().year);
    monthNotifier = ValueNotifier<int>(DateTime.now().month);
    yearCtrl.text = DateTime.now().year.toString();
    monthCtrl.text = DateTime.now().month.toString();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post('/order/all/type/6',
          Global.reportRequestObj({"year": yearCtrl.text, "month": monthCtrl.text}));
      // print(result!.data);
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> products = orderListModelFromJson(data);
        setState(() {
          if (products.isNotEmpty) {
            orders = products;
            filterList = products;
          } else {
            orders!.clear();
            filterList!.clear();
          }
        });
      } else {
        orders = [];
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

  void search() async {
    if (yearCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกปี', 'OK');
      return;
    }

    if (monthCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกเดือน', 'OK');
      return;
    }

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายการประวัติการขายทองเก่า",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      getProportionateScreenWidth(
                        8,
                      ),
                    ),
                    topRight: Radius.circular(
                      getProportionateScreenWidth(
                        8,
                      ),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: getProportionateScreenWidth(0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ปี',
                                        style: TextStyle(
                                            fontSize: 16.sp),
                                      ),
                                      SizedBox(
                                        height: 70,
                                        child: MiraiDropDownMenu<int>(
                                          key: UniqueKey(),
                                          children: Global.genYear(),
                                          space: 4,
                                          maxHeight: 360,
                                          showSearchTextField: true,
                                          selectedItemBackgroundColor:
                                              Colors.transparent,
                                          emptyListMessage: 'ไม่มีข้อมูล',
                                          showSelectedItemBackgroundColor: true,
                                          itemWidgetBuilder: (
                                            int index,
                                            int? project, {
                                            bool isItemSelected = false,
                                          }) {
                                            return DropDownItemWidget(
                                              project: project,
                                              isItemSelected: isItemSelected,
                                              firstSpace: 10,
                                              fontSize: 16.sp,
                                            );
                                          },
                                          onChanged: (int value) {
                                            yearCtrl.text = value.toString();
                                            yearNotifier!.value = value;
                                            search();
                                          },
                                          child: DropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: 16.sp,
                                            projectValueNotifier: yearNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'เดือน',
                                        style: TextStyle(
                                            fontSize: 16.sp),
                                      ),
                                      SizedBox(
                                        height: 70,
                                        child: MiraiDropDownMenu<int>(
                                          key: UniqueKey(),
                                          children: Global.genMonth(),
                                          space: 4,
                                          maxHeight: 360,
                                          showSearchTextField: true,
                                          selectedItemBackgroundColor:
                                              Colors.transparent,
                                          emptyListMessage: 'ไม่มีข้อมูล',
                                          showSelectedItemBackgroundColor: true,
                                          itemWidgetBuilder: (
                                            int index,
                                            int? project, {
                                            bool isItemSelected = false,
                                          }) {
                                            return DropDownItemWidget(
                                              project: project,
                                              isItemSelected: isItemSelected,
                                              firstSpace: 10,
                                              fontSize: 16.sp,
                                            );
                                          },
                                          onChanged: (int value) {
                                            monthCtrl.text = value.toString();
                                            monthNotifier!.value = value;
                                            search();
                                          },
                                          child: DropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: 16.sp,
                                            projectValueNotifier:
                                                monthNotifier!,
                                          ),
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(3.0),
                          vertical: getProportionateScreenHeight(5.0),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(bgColor3)),
                          onPressed: search,
                          child: Text(
                            'ค้นหา'.tr(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              thickness: 1.0,
            ),
            loading
                ? Container(
                    margin: const EdgeInsets.only(top: 100),
                    child: const LoadingProgress())
                : filterList!.isEmpty
                    ? const NoDataFoundWidget()
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                              itemCount: filterList!.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) {
                                return dataCard(filterList![index]!, index);
                              }),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget dataCard(OrderModel sell, int index) {
    return GestureDetector(
      onTap: () async {
        final ProgressDialog pr = ProgressDialog(context,
            type: ProgressDialogType.normal,
            isDismissible: true,
            showLogs: true);
        await pr.show();
        pr.update(message: 'processing'.tr());

        try {
          var result = await ApiServices.post(
              '/order/print-order-list/${sell.pairId}',
              Global.requestObj(null));

          var data = jsonEncode(result?.data);
          List<OrderModel> orders = orderListModelFromJson(data);

          var payment = await ApiServices.post(
              '/order/payment/${sell.pairId}', Global.requestObj(null));
          Global.paymentList =
              paymentListModelFromJson(jsonEncode(payment?.data));

          await pr.hide();
          Invoice invoice = Invoice(
              order: sell,
              customer: sell.customer!,
              payments: Global.paymentList,
              orders: orders,
              items: sell.details!);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PreviewSellUsedGoldPage(
                        invoice: invoice,
                      )));
        } catch (e) {
          await pr.hide();
        }
      },
      child: Stack(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                            '#${sell.orderId.toString()}',
                            style: TextStyle(fontSize: size?.getWidthPx(8)),
                          ),
                          Text(
                            Global.formatDate(sell.orderDate.toString()),
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 16.sp),
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
                              // if (sell.orderStatus != null &&
                              //     sell.orderStatus == 'PENDING')
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Container(),
                                ),
                              ),
                            ],
                          ),
                          ...sell.details!.map(
                            (e) => TableRow(
                              decoration: const BoxDecoration(),
                              children: [
                                paddedText(e.productName,
                                    align: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: size?.getWidthPx(7))),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        paddedText('น้ำหนักขาย(กรัม)',
                                            align: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: size?.getWidthPx(7))),
                                        paddedText(Global.format(e.weight ?? 0),
                                            align: TextAlign.center,
                                            style: TextStyle(
                                                fontSize:
                                                    16.sp)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        paddedText('น้ำหนักสูญเสีย(กรัม)',
                                            align: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: size?.getWidthPx(7))),
                                        paddedText(
                                            Global.format(e.weightAdj ?? 0),
                                            align: TextAlign.center,
                                            style: TextStyle(
                                                fontSize:
                                                    16.sp)),
                                      ],
                                    ),
                                  ],
                                ),
                                paddedText('${e.binLocationName}',
                                    align: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: size?.getWidthPx(7))),
                                if (e.weightAdj != null && e.weightAdj! > 0)
                                  Container(),
                                if (e.weightAdj == null || e.weightAdj == 0)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedSell = sell;
                                            sellIdCtrl.text = sell.orderId;
                                            dateCtrl.text = Global.formatDate(
                                                sell.orderDate!.toString());
                                            productWeightCtrl.text =
                                                formatter.format(e.weight);
                                            productWeightBahtCtrl.text =
                                                formatter.format(e.weightBath);
                                            productEntryWeightCtrl.text = "";
                                            productEntryWeightBahtCtrl.text =
                                                "";
                                            selectedDetail = e;
                                          });
                                          // motivePrint(e.toJson());
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .change_circle_outlined,
                                                    color: Colors.white,
                                                  ),
                                                  Text('ปรับน้ำหนักสูญเสีย',
                                                      style: TextStyle(
                                                          fontSize: size!
                                                              .getWidthPx(6),
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
          ),
          // if (sell.orderStatus == 'PENDING')
          Positioned(
            right: 0,
            top: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.teal,
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
                      sell.orderStatus!,
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void adjustWeight(OrderDetailModel e) {
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
                                    labelColor: Colors.orange,
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
                                    labelColor: Colors.orange,
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
                                    labelColor: Colors.orange,
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
                                    labelColor: Colors.orange,
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
                                      labelText: "น้ำหนักสูญเสีย (gram)",
                                      inputType: TextInputType.number,
                                      labelColor: Colors.orange,
                                      controller: productEntryWeightCtrl,
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      onChanged: (String value) {
                                        if (productEntryWeightCtrl
                                            .text.isNotEmpty) {
                                          productEntryWeightBahtCtrl.text =
                                              Global.format((Global.toNumber(
                                                      productEntryWeightCtrl
                                                          .text) /
                                                  getUnitWeightValue()));
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
                                      labelText: "น้ำหนักสูญเสีย (บาททอง)",
                                      inputType: TextInputType.phone,
                                      labelColor: Colors.orange,
                                      controller: productEntryWeightBahtCtrl,
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      onChanged: (String value) {
                                        if (productEntryWeightBahtCtrl
                                            .text.isNotEmpty) {
                                          productEntryWeightCtrl.text =
                                              Global.format((Global.toNumber(
                                                      productEntryWeightBahtCtrl
                                                          .text) *
                                                  getUnitWeightValue()));
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

                                selectedDetail?.weightAdj = Global.toNumber(
                                    productEntryWeightCtrl.text);
                                selectedDetail?.weightBathAdj = Global.toNumber(
                                    productEntryWeightBahtCtrl.text);

                                // motivePrint(selectedSell?.toJson());
                                // return;

                                Alert.info(
                                    context,
                                    'ต้องการบันทึกข้อมูลหรือไม่?',
                                    '',
                                    'ตกลง', action: () async {
                                  final ProgressDialog pr = ProgressDialog(
                                      context,
                                      type: ProgressDialogType.normal,
                                      isDismissible: true,
                                      showLogs: true);
                                  await pr.show();
                                  pr.update(message: 'processing'.tr());
                                  try {
                                    var result = await ApiServices.post(
                                        '/order/confirm-adjust',
                                        Global.requestObj(selectedSell));
                                    // print(result!.data);
                                    if (result!.status == "success") {
                                      var detail = await ApiServices.post(
                                          '/orderdetail/adjust/sell',
                                          Global.requestObj(selectedDetail));
                                      // print(detail!.data);
                                      await pr.hide();
                                      if (detail?.status == "success") {
                                        motivePrint("Confirm completed");
                                        if (mounted) {
                                          Alert.success(context, 'Success'.tr(),
                                              'Success', 'OK'.tr(), action: () {
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
                                });
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
