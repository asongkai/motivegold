import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/model/response.dart';
import 'package:motivegold/screen/pos/storefront/theng/preview_pdf.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/widget/product_list_tile.dart';
import 'paphun/preview_pdf.dart';

class PrintBillScreen extends StatefulWidget {
  const PrintBillScreen({super.key});

  @override
  State<PrintBillScreen> createState() => _PrintBillScreenState();
}

class _PrintBillScreenState extends State<PrintBillScreen> {
  int currentIndex = 1;
  Screen? size;
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  bool loading = false;
  List<OrderModel> orders = [];

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
      if (Global.pairId == null) {
        result = await ApiServices.post(
            '/order/order-list', encoder.convert(Global.orderIds));
      } else {
        result = await ApiServices.post(
            '/order/print-order-list/${Global.pairId}',
            Global.requestObj(null));
        payment = await ApiServices.post(
            '/order/payment/${Global.pairId}', Global.requestObj(null));
      }
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> dump = orderListModelFromJson(data);
        setState(() {
          orders = dump;
          Global.payment = PaymentModel.fromJson(payment?.data);
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
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: Text('พิมพ์บิล'.tr()),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: orders.isEmpty
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
                                                itemCount: orders.length,
                                                itemBuilder: (context, index) {
                                                  return _itemOrderList(
                                                      order: orders[index],
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

  Widget _itemOrderList({required OrderModel order, required index}) {
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
                      orderId: order.orderId,
                      weight: null,
                      showTotal: false,
                      type: order.orderTypeName,
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
                              paddedTextBigXL(e.productName),
                              paddedText(Global.format(e.weight!),
                                  align: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                              paddedText(Global.format(e.priceIncludeTax!),
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
                                  Global.format(
                                      Global.getOrderWeightTotalAmountApi(
                                          order.details)),
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  Global.format(
                                      Global.getOrderSubTotalAmountApi(
                                          order.details)),
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
                              child: Text('${Global.format(Global.getOrderTotalWeight(order.details!))}',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: size?.getWidthPx(8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  Global.format(
                                      Global.getOrderGrantTotalAmountApi(
                                          Global.getOrderSubTotalAmountApi(
                                              order.details),
                                          order.discount)),
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
                      onTap: () {
                        Invoice invoice = Invoice(
                            order: order,
                            customer: order.customer!,
                            payment: Global.payment,
                            items: order.details!);

                        if (order.orderTypeId == 1 || order.orderTypeId == 2) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  PdfPreviewPage(invoice: invoice),
                            ),
                          );
                        }

                        if (order.orderTypeId == 3 || order.orderTypeId == 4 || order.orderTypeId == 8) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  PdfThengPreviewPage(invoice: invoice),
                            ),
                          );
                        }

                        if (order.orderTypeId == 33 || order.orderTypeId == 44 || order.orderTypeId == 9) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  PdfThengPreviewPage(invoice: invoice),
                            ),
                          );
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
    Global.orders!.removeAt(i);
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
              color: isSelected! ? Colors.white : Colors.white.withOpacity(0.5),
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
