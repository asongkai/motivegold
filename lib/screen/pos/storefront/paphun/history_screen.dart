import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'checkout_summary_history_screen.dart';
import 'preview_pdf.dart';

class PosOrderHistoryScreen extends StatefulWidget {
  const PosOrderHistoryScreen({super.key});

  @override
  State<PosOrderHistoryScreen> createState() => _PosOrderHistoryScreenState();
}

class _PosOrderHistoryScreenState extends State<PosOrderHistoryScreen> {
  bool loading = false;
  List<OrderModel>? list = [];
  List<OrderModel?>? filterList = [];
  Screen? size;
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
      Global.pairId = null;
      Global.orderIds!.clear();
    });
    try {
      var result =
          await ApiServices.post('/order/all', Global.requestObj(null));
      // Global.printLongString(result!.toJson().toString());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);

        List<OrderModel> products = orderListModelFromJson(data);
        // motivePrint(products.first);
        setState(() {
          list = products;
          filterList!.addAll(products);
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
        title: const Text('รายการประวัติการซื้อขายทองคำ'),
        actions: const [],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : Column(
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
                          top: getProportionateScreenWidth(10),
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
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: TextField(
                                      controller: fromDateCtrl,
                                      style: const TextStyle(fontSize: 38),
                                      //editing controller of this TextField
                                      decoration: InputDecoration(
                                        prefixIcon:
                                            const Icon(Icons.calendar_today),
                                        //icon of text field
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        suffixIcon: fromDateCtrl.text.isNotEmpty
                                            ? GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    fromDateCtrl.text = "";
                                                    toDateCtrl.text = "";
                                                    filterList = list;
                                                  });
                                                },
                                                child: const Icon(Icons.clear))
                                            : null,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                        labelText: "จากวันที่".tr(),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            getProportionateScreenWidth(8),
                                          ),
                                          borderSide: const BorderSide(
                                            color: kGreyShade3,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            getProportionateScreenWidth(2),
                                          ),
                                          borderSide: const BorderSide(
                                            color: kGreyShade3,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                      //set it true, so that user will not able to edit text
                                      onTap: () async {
                                        final pickedDate =
                                            await showBoardDateTimePicker(
                                                context: context,
                                                pickerType:
                                                    DateTimePickerType.date,
                                                initialDate: DateTime.now());
                                        if (pickedDate != null) {
                                          motivePrint(
                                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                          motivePrint(
                                              formattedDate); //formatted date output using intl package =>  2021-03-16
                                          //you can implement different kind of Date Format here according to your requirement
                                          setState(() {
                                            fromDateCtrl.text =
                                                formattedDate; //set output date to TextField value.
                                          });
                                        } else {
                                          motivePrint("Date is not selected");
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: TextField(
                                      controller: toDateCtrl,
                                      //editing controller of this TextField
                                      style: const TextStyle(fontSize: 38),
                                      //editing controller of this TextField
                                      decoration: InputDecoration(
                                        prefixIcon:
                                            const Icon(Icons.calendar_today),
                                        //icon of text field
                                        suffixIcon: toDateCtrl.text.isNotEmpty
                                            ? GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    toDateCtrl.text = "";
                                                    fromDateCtrl.text = "";
                                                    filterList = list;
                                                  });
                                                },
                                                child: const Icon(Icons.clear))
                                            : null,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                        labelText: "ถึงวันที่".tr(),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            getProportionateScreenWidth(8),
                                          ),
                                          borderSide: const BorderSide(
                                            color: kGreyShade3,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            getProportionateScreenWidth(2),
                                          ),
                                          borderSide: const BorderSide(
                                            color: kGreyShade3,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                      //set it true, so that user will not able to edit text
                                      onTap: () async {
                                        final pickedDate =
                                            await showBoardDateTimePicker(
                                                context: context,
                                                pickerType:
                                                    DateTimePickerType.date,
                                                initialDate: DateTime.now());
                                        if (pickedDate != null) {
                                          motivePrint(
                                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                          motivePrint(
                                              formattedDate); //formatted date output using intl package =>  2021-03-16
                                          //you can implement different kind of Date Format here according to your requirement
                                          setState(() {
                                            toDateCtrl.text =
                                                formattedDate; //set output date to TextField value.
                                          });
                                        } else {
                                          motivePrint("Date is not selected");
                                        }
                                      },
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
                                        MaterialStateProperty.all<Color>(
                                            bgColor3)),
                                onPressed: search,
                                child: Text(
                                  'ค้นหา'.tr(),
                                  style: const TextStyle(fontSize: 32),
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: filterList!.isEmpty
                          ? const EmptyContent()
                          : ListView.builder(
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

  void search() {
    if (fromDateCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกจากวันที่', 'OK');
      return;
    }

    if (toDateCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกถึงวันที่', 'OK');
      return;
    }

    var result = list?.map((e) {
      if (e.orderDate != null) {
        DateTime? orderDate = e.orderDate;

        if ((orderDate!.isAfter(DateTime.parse(fromDateCtrl.text)) ||
                orderDate == DateTime.parse(fromDateCtrl.text)) &&
            (orderDate == DateTime.parse(toDateCtrl.text) ||
                orderDate.isBefore(DateTime.parse(toDateCtrl.text)))) {
          return e;
        }
      }
    }).toList();
    result?.removeWhere((element) => element == null);

    filterList = result!;
    setState(() {});
  }

  Widget dataCard(OrderModel list, int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // Global.pairId = list.pairId;
            // Invoice invoice = Invoice(
            //     order: list, customer: list.customer!, items: list.details!);
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => PdfPreviewPage(invoice: invoice),
            //   ),
            // );
          },
          child: Card(
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
                          '#${list.orderId.toString()}',
                          style: TextStyle(fontSize: size?.getWidthPx(8)),
                        ),
                        Text(
                          Global.formatDate(list.orderDate.toString()),
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: size!.getWidthPx(5)),
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
                              paddedText(e.productName,
                                  align: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(7))),
                              paddedText(Global.format(e.weight!),
                                  align: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(7))),
                              paddedText(e.toBinLocationName ?? '',
                                  align: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(7))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Global.pairId = list.pairId;
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CheckOutSummaryHistoryScreen(),
                                        fullscreenDialog: true))
                                .whenComplete(() {
                              loadData();
                            });
                          },
                          child: Container(
                            height: 50,
                            // width: 60,
                            decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.grid_view_sharp,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'สรุปการจ่ายเงิน',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size!.getWidthPx(5)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Global.orderIds!.add(list.orderId);
                            Invoice invoice = Invoice(
                                order: list,
                                customer: list.customer!,
                                items: list.details!);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PdfPreviewPage(invoice: invoice),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            // width: 60,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.print,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'พิมพ์',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size!.getWidthPx(5)),
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
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: colorType(list),
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
                          (list.orderTypeId == 1)
                              ? Icons.check
                              : Icons.pending_actions,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Text(
                    dataType(list),
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
}
