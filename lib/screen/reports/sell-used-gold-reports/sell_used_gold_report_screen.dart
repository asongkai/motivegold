import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/reports/sell-used-gold-reports/preview.dart';
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
import 'package:sizer/sizer.dart';
class SellUsedGoldReportScreen extends StatefulWidget {
  const SellUsedGoldReportScreen({super.key});

  @override
  State<SellUsedGoldReportScreen> createState() =>
      _SellUsedGoldReportScreenState();
}

class _SellUsedGoldReportScreenState extends State<SellUsedGoldReportScreen> {
  bool loading = false;
  List<OrderModel>? orders = [];
  List<OrderModel?>? filterList = [];
  Screen? size;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/order/all/type/6',
          Global.reportRequestObj({
            "year": 0,
            "month": 0,
            "fromDate": fromDateCtrl.text.isNotEmpty
                ? DateTime.parse(fromDateCtrl.text).toString()
                : null,
            "toDate": toDateCtrl.text.isNotEmpty
                ? DateTime.parse(toDateCtrl.text).toString()
                : null,
          }));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> products = orderListModelFromJson(data);
        if (products.isNotEmpty) {
          orders = products;
          filterList = products;
        } else {
          orders!.clear();
          filterList!.clear();
        }
        setState(() {});
      } else {
        orders = [];
      }
    } catch (e) {
      motivePrint(e.toString());
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
                  child: Text("รายงานขายทองเก่า",
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
                                  context, 'คำเตือน', 'ไม่มีข้อมูล', 'OK');
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PreviewSellUsedGoldReportPage(
                                  orders: filterList!.reversed.toList(),
                                  type: 1,
                                  date:
                                      '${Global.formatDateNT(fromDateCtrl.text)} - ${Global.formatDateNT(toDateCtrl.text)}',
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
                                    fontSize: 16.sp,
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
                      paddedTextBigL('วัน/เดือน/ปี', align: TextAlign.center),
                      paddedTextBigL('เลขท่ีใบสําคัญรับเงิน',
                          align: TextAlign.center),
                      paddedTextBigL('ผู้ซื้อ', align: TextAlign.center),
                      paddedTextBigL('เลขประจําตัวผู้เสียภาษี',
                          align: TextAlign.center),
                      paddedTextBigL('รายการสินค้า', align: TextAlign.center),
                      paddedTextBigL('น้ําหนัก (กรัม)',
                          align: TextAlign.center),
                      paddedTextBigL('จํานวนเงิน (บาท)',
                          align: TextAlign.center),
                    ]),
                    ...ods.map((e) => TableRow(
                          decoration: const BoxDecoration(),
                          children: [
                            paddedTextBigL(
                                Global.dateOnly(e!.orderDate.toString()),
                                align: TextAlign.center),
                            paddedTextBigL(e.orderId, align: TextAlign.center),
                            paddedTextBigL(
                                '${e.customer!.firstName!} ${e.customer!.lastName!}',
                                align: TextAlign.center),
                            paddedTextBigL(e.customer?.taxNumber != ''
                                ? e.customer?.taxNumber ?? ''
                                : e.customer?.idCard ?? '', align: TextAlign.center),
                            paddedTextBigL('ทองเก่า', align: TextAlign.center),
                            paddedTextBigL(
                                '${Global.format(getWeight(e))}/${Global.format(getWeight(e))}',
                                align: TextAlign.right),
                            paddedTextBigL(
                                Global.format(e.priceIncludeTax ?? 0),
                                align: TextAlign.right)
                          ],
                        )),
                    TableRow(children: [
                      paddedTextBigL('', style: const TextStyle(fontSize: 14)),
                      paddedTextBigL(''),
                      paddedTextBigL(''),
                      paddedTextBigL(''),
                      paddedTextBigL('รวมท้ังหมด', align: TextAlign.right),
                      paddedTextBigL(
                          '${Global.format(getWeightTotal(ods))}/${Global.format(getWeightTotal(ods))}',
                          align: TextAlign.right),
                      paddedTextBigL(Global.format(priceIncludeTaxTotal(ods)),
                          align: TextAlign.right),
                    ])
                  ],
                ),
              ),
            ),
          );
  }
}
