import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/buy-new-gold-reports/preview.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';

class BuyNewGoldReportScreen extends StatefulWidget {
  const BuyNewGoldReportScreen({super.key});

  @override
  State<BuyNewGoldReportScreen> createState() => _BuyNewGoldReportScreenState();
}

class _BuyNewGoldReportScreenState extends State<BuyNewGoldReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // loadProducts();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });

    // if (fromDateCtrl.text.isEmpty) {
    //   Alert.warning(
    //       context, 'คำเตือน', 'กรุณาเลือกจากวันที่', 'OK', action: () {});
    //   return;
    // }
    // if (toDateCtrl.text.isEmpty) {
    //   Alert.warning(
    //       context, 'คำเตือน', 'กรุณาเลือกถึงวันที่', 'OK', action: () {});
    //   return;
    // }

    try {
      var result = await ApiServices.post(
          '/order/all/type/5',
          Global.requestObj({
            "year": 0,
            "month": 0,
            "fromDate": fromDateCtrl.text.isNotEmpty
                ? DateTime.parse(fromDateCtrl.text).toString()
                : null,
            "toDate": toDateCtrl.text.isNotEmpty
                ? DateTime.parse(toDateCtrl.text).toString()
                : null,
          }));
      // motivePrint(result?.toJson());
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

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  flex: 4,
                  child: Text("รายงานซื้อทองใหม่",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (fromDateCtrl.text.isEmpty) {
                              Alert.warning(
                                  context, 'คำเตือน', 'กรุณาเลือกจากวันที่', 'OK', action: () {});
                              return;
                            }
                            if (toDateCtrl.text.isEmpty) {
                              Alert.warning(
                                  context, 'คำเตือน', 'กรุณาเลือกถึงวันที่', 'OK', action: () {});
                              return;
                            }
                            if (filterList!.isEmpty) {
                              Alert.warning(
                                  context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK', action: () {});
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PreviewBuyNewGoldReportPage(
                                  orders: filterList!.reversed.toList(),
                                  type: 1,
                                  date: '${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}',
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.print,
                                  size: 50, color: Colors.white),
                              Text(
                                'พิมพ์',
                                style: TextStyle(
                                    fontSize: size.getWidthPx(8),
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
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
                        const SizedBox(
                          height: 20,
                        ),
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
                                                filterList = orders;
                                              });
                                            },
                                            child: const Icon(Icons.clear))
                                        : null,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    labelText: "จากวันที่".tr(),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(2),
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
                                    showDialog(
                                      context: context,
                                      builder: (_) => SfDatePickerDialog(
                                        initialDate: DateTime.now(),
                                        onDateSelected: (date) {
                                          motivePrint('You picked: $date');
                                          // Your logic here
                                          String formattedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(date);
                                          motivePrint(
                                              formattedDate); //formatted date output using intl package =>  2021-03-16
                                          //you can implement different kind of Date Format here according to your requirement
                                          setState(() {
                                            fromDateCtrl.text =
                                                formattedDate; //set output date to TextField value.
                                          });
                                          loadProducts();
                                        },
                                      ),
                                    );
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
                                                filterList = orders;
                                              });
                                            },
                                            child: const Icon(Icons.clear))
                                        : null,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    labelText: "ถึงวันที่".tr(),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(2),
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
                                    showDialog(
                                      context: context,
                                      builder: (_) => SfDatePickerDialog(
                                        initialDate: DateTime.now(),
                                        onDateSelected: (date) {
                                          motivePrint('You picked: $date');
                                          // Your logic here
                                          String formattedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(date);
                                          motivePrint(
                                              formattedDate); //formatted date output using intl package =>  2021-03-16
                                          //you can implement different kind of Date Format here according to your requirement
                                          setState(() {
                                            toDateCtrl.text =
                                                formattedDate; //set output date to TextField value.
                                          });
                                          loadProducts();
                                        },
                                      ),
                                    );
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
                                    WidgetStateProperty.all<Color>(bgColor3)),
                            onPressed: loadProducts,
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
                  : productCard(filterList!),
            ],
          )),
        ),
      ),
    );
  }

  Widget productCard(List<OrderModel?> ods) {
    return filterList!.isEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 100),
            child: const NoDataFoundWidget())
        : Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(color: Colors.grey[300]!),
                  children: [
                    TableRow(children: [
                      paddedTextBig('วัน/เดือน/ปี', align: TextAlign.center),
                      paddedTextBig('เลขที่ใบกํากับภาษี',
                          align: TextAlign.center),
                      paddedTextBig('ผู้ขาย', align: TextAlign.center),
                      paddedTextBig('เลขประจําตัวผู้เสียภาษี',
                          align: TextAlign.center),
                      paddedTextBig('น้ําหนัก', align: TextAlign.center),
                      paddedTextBig('หน่วย', align: TextAlign.center),
                      paddedTextBig('ยอดขายรวม\nภาษีมูลค่าเพิ่ม',
                          align: TextAlign.center),
                      paddedTextBig('มูลค่ายกเว้น', align: TextAlign.center),
                      paddedTextBig('ผลต่างรวม\nภาษีมูลค่าเพิ่ม',
                          align: TextAlign.center),
                      paddedTextBig('ฐานภาษีมูลค่าเพิ่ม',
                          align: TextAlign.center),
                      paddedTextBig('ภาษีมูลค่าเพิ่ม', align: TextAlign.center),
                      paddedTextBig('ยอดขายที่ไม่รวม\nภาษีมูลค่าเพิ่ม',
                          align: TextAlign.center),
                    ]),
                    ...ods.map((e) => TableRow(
                          decoration: const BoxDecoration(),
                          children: [
                            paddedTextBig(
                                Global.dateOnly(e!.orderDate.toString()),
                                align: TextAlign.center),
                            paddedTextBig(e.orderId, align: TextAlign.center),
                            paddedTextBig('${e.customer?.firstName} ${e.customer?.lastName}', align: TextAlign.center),
                            paddedTextBig(e.customer?.taxNumber != ''
                                ? e.customer?.taxNumber ?? ''
                                : e.customer?.idCard ?? '', align: TextAlign.center),
                            paddedTextBig(Global.format(getWeight(e)),
                                align: TextAlign.right),
                            paddedTextBig('กรัม', align: TextAlign.center),
                            paddedTextBig(Global.format(e.priceIncludeTax ?? 0),
                                align: TextAlign.right),
                            paddedTextBig(Global.format(e.purchasePrice ?? 0),
                                align: TextAlign.right),
                            paddedTextBig(Global.format(e.priceDiff ?? 0),
                                align: TextAlign.right),
                            paddedTextBig(Global.format(e.taxBase ?? 0),
                                align: TextAlign.right),
                            paddedTextBig(Global.format(e.taxAmount ?? 0),
                                align: TextAlign.right),
                            paddedTextBig(Global.format(e.priceExcludeTax ?? 0),
                                align: TextAlign.right)
                          ],
                        )),
                    TableRow(children: [
                      paddedTextBig('', style: const TextStyle(fontSize: 14)),
                      paddedTextBig(''),
                      paddedTextBig(''),
                      paddedTextBig('รวมท้ังหมด', align: TextAlign.right),
                      paddedTextBig(Global.format(getWeightTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(''),
                      paddedTextBig(Global.format(priceIncludeTaxTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(Global.format(purchasePriceTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(Global.format(priceDiffTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(Global.format(taxBaseTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(Global.format(taxAmountTotal(ods)),
                          align: TextAlign.right),
                      paddedTextBig(Global.format(priceExcludeTaxTotal(ods)),
                          align: TextAlign.right),
                    ])
                  ],
                ),
              ),
            ),
          );
  }
}
