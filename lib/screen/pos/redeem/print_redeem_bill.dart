import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/response.dart';
import 'package:motivegold/screen/pos/redeem/bill/preview.dart';
import 'package:motivegold/screen/pos/storefront/paphun/bill/preview_pdf.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/widget/product_list_tile.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class PrintRedeemBillScreen extends StatefulWidget {
  const PrintRedeemBillScreen({super.key});

  @override
  State<PrintRedeemBillScreen> createState() => _PrintRedeemBillScreenState();
}

class _PrintRedeemBillScreenState extends State<PrintRedeemBillScreen> {
  int currentIndex = 1;
  Screen? size;
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  bool loading = false;
  List<RedeemModel> redeems = [];

  @override
  void initState() {
    // implement initState
    super.initState();
    loadOrder();
  }

  void loadOrder() async {
    setState(() {
      loading = true;
    });
    try {
      Response? result;
      Response? payment;

      result = await ApiServices.post(
          '/redeem/redeem-list/${Global.pairId}', Global.requestObj(null));
      payment = await ApiServices.post(
          '/order/payment/${Global.pairId}', Global.requestObj(null));

      // motivePrint(payment?.toJson());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<RedeemModel> dump = redeemListModelFromJson(data);
        setState(() {
          redeems = dump;
          Global.paymentList =
              paymentListModelFromJson(jsonEncode(payment?.data));
        });
      } else {
        redeems = [];
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
          title: Text("พิมพ์บิล Redeem",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: redeems.isEmpty
                    ? const Center(
                        child: NoDataFoundWidget(),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          getProportionateScreenWidth(0.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SingleChildScrollView(
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              color: bgColor2,
                                            ),
                                            child: ListView.builder(
                                                itemCount: redeems.length,
                                                itemBuilder: (context, index) {
                                                  return _itemOrderList(
                                                      order: redeems[index],
                                                      index: index);
                                                }),
                                          ),
                                        ),
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
    );
  }

  void checkout() async {
    setState(() {});
  }

  Widget _itemOrderList({required RedeemModel order, required index}) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    ProductListTileData(
                      orderId: order.redeemId,
                      weight: null,
                      showTotal: false,
                      type: '',
                    ),
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      children: [
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('น้ำหนัก',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('ราคา',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                          ],
                        ),
                        ...order.details!.map(
                          (e) => TableRow(
                            decoration: const BoxDecoration(),
                            children: [
                              paddedTextBigXL(e.referenceNo ?? ''),
                              paddedText(Global.format(e.weight ?? 0),
                                  align: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                              paddedText(Global.format(e.paymentAmount ?? 0),
                                  align: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ],
                          ),
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'ผลรวมย่อย',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: size?.getWidthPx(8)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  Global.format(Global.getRedeemTotalWeight(
                                      order.details ?? [])),
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  Global.format(Global.getRedeemTotalPayment(
                                      order.details ?? [])),
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'ส่วนลด',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: size?.getWidthPx(8)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(Global.format(order.discount ?? 0),
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'ยอดรวมทั้งหมด',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: size?.getWidthPx(8)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  '${Global.format(Global.getRedeemTotalWeight(order.details ?? []))}',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  Global.format(Global.getRedeemSubPaymentTotal(
                                      order.details ?? [],
                                      discount: order.discount ?? 0)),
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // loadOrder();
                        // return;
                        final ProgressDialog pr = ProgressDialog(context,
                            type: ProgressDialogType.normal,
                            isDismissible: true,
                            showLogs: true);
                        await pr.show();
                        pr.update(message: 'processing'.tr());

                        try {
                          var payment = await ApiServices.post(
                              '/order/payment/${order.pairId}',
                              Global.requestObj(null));
                          await pr.hide();
                          Global.paymentList = paymentListModelFromJson(
                              jsonEncode(payment?.data));


                          InvoiceRedeem invoice = InvoiceRedeem(
                              order: order,
                              customer: order.customer!,
                              payments: Global.paymentList,
                              orders: redeems,
                              items: order.details!);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  PdfPreviewRedeemPage(invoice: invoice),
                            ),
                          );
                        } catch (e) {
                          motivePrint(e.toString());
                          await pr.hide();
                        }
                      },
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(
                          Icons.print,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // const Divider(),
        ],
      ),
    );
  }

  void removeProduct(int i) async {
    Global.ordersPapun!.removeAt(i);
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {});
    });
  }
}

class PaymentCard extends StatelessWidget {
  const PaymentCard(
      {Key? key, this.isSelected = false, this.title, this.image, this.action})
      : super(key: key);

  final bool? isSelected;
  final String? title;
  final String? image;
  final Function()? action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Stack(
        children: [
          Container(
            height: getProportionateScreenWidth(30),
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(8.0),
                vertical: getProportionateScreenHeight(8.0)),
            margin: EdgeInsets.only(
              bottom: getProportionateScreenHeight(8.0),
            ),
            decoration: BoxDecoration(
              color: isSelected! ? Colors.white : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(
                getProportionateScreenWidth(
                  4,
                ),
              ),
              boxShadow: [
                isSelected!
                    ? BoxShadow(
                        color: kShadowColor,
                        offset: Offset(
                          getProportionateScreenWidth(2),
                          getProportionateScreenWidth(4),
                        ),
                        blurRadius: 80,
                      )
                    : const BoxShadow(color: Colors.transparent),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: getProportionateScreenWidth(30),
                  height: getProportionateScreenWidth(30),
                  decoration: ShapeDecoration(
                    color: kGreyShade5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        getProportionateScreenWidth(8.0),
                      ),
                    ),
                  ),
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(image!,
                              fit: BoxFit.cover, width: 1000.0),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            "assets/images/no_image.png",
                            fit: BoxFit.cover,
                            width: 1000.0,
                          )),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(8),
                ),
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              ],
            ),
          ),
          if (isSelected!)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                child: const IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.teal,
                  ),
                  onPressed: null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
