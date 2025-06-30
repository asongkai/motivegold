import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/invoice.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/screen/pos/checkout_wholesale_summary_history_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/bill/preview_buy_theng_pdf.dart';
import 'package:motivegold/screen/pos/storefront/theng/bill/preview_pdf.dart';
import 'package:motivegold/screen/pos/storefront/theng/bill/preview_sell_theng_pdf.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/refill/preview.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/used/preview.dart';
import 'package:motivegold/screen/pos/wholesale/theng/refill/preview.dart';
import 'package:motivegold/screen/pos/wholesale/theng/used/preview.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/dropdown/CustomerDropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/CustomerDropDownObjectChildWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'checkout_summary_history_screen.dart';
import 'storefront/paphun/bill/preview_pdf.dart';

class ProductOrderHistoryScreen extends StatefulWidget {
  const ProductOrderHistoryScreen({super.key, this.productType});

  final ProductTypeModel? productType;

  @override
  State<ProductOrderHistoryScreen> createState() =>
      _ProductOrderHistoryScreenState();
}

class _ProductOrderHistoryScreenState extends State<ProductOrderHistoryScreen> {
  bool loading = false;
  List<OrderModel>? list = [];
  List<OrderModel?>? filterList = [];
  Screen? size;
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  ProductTypeModel? selectedOrderType;
  static ValueNotifier<dynamic>? orderTypeNotifier;

  CustomerModel? selectedCustomer;
  static ValueNotifier<dynamic>? customerNotifier;

  List<CustomerModel>? customers = [];
  bool loadingCustomer = false;

  @override
  void initState() {
    super.initState();
    selectedOrderType = widget.productType ?? orderTypes()[0];
    orderTypeNotifier = ValueNotifier<ProductTypeModel>(selectedOrderType ??
        ProductTypeModel(id: 0, code: '', name: 'เลือกประเภทธุรกรรม'));
    orderTypeNotifier = ValueNotifier<ProductTypeModel>(selectedOrderType ??
        ProductTypeModel(id: 0, code: '', name: 'เลือกประเภทธุรกรรม'));
    customerNotifier = ValueNotifier<CustomerModel?>(null);
    loadData();
    search();
  }

  void loadData() async {
    setState(() {
      loadingCustomer = true;
    });

    try {
      var result =
          await ApiServices.post('/customer/all', Global.requestObj({}));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<CustomerModel> products = customerListModelFromJson(data);
        if (products.isNotEmpty) {
          customers = products;
        } else {
          customers = [];
        }
        setState(() {});
      } else {
        customers = [];
      }
    } catch (e) {
      motivePrint(e.toString());
    }
    setState(() {
      loadingCustomer = false;
    });
  }

  void search() async {
    if (selectedOrderType == null &&
        selectedCustomer == null &&
        toDateCtrl.text.isEmpty &&
        toDateCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกตัวกรองข้อมูลก่อน', 'OK',
          action: () {});
      return;
    }

    setState(() {
      loading = true;
      filterList?.clear();
      Global.pairId = null;
      Global.orderIds!.clear();
    });
    try {
      var result = await ApiServices.post(
          '/order/all/search',
          Global.requestObj({
            "year": 0,
            "month": 0,
            "fromDate": fromDateCtrl.text.isNotEmpty
                ? DateTime.parse(fromDateCtrl.text).toString()
                : null,
            "toDate": toDateCtrl.text.isNotEmpty
                ? DateTime.parse(toDateCtrl.text).toString()
                : null,
            "orderTypeId": selectedOrderType?.id,
            "customerId": selectedCustomer?.id,
          }));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderModel> products = orderListModelFromJson(data);
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
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายการประวัติการซื้อขายทองคำ",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: loadingCustomer
            ? Center(
                child: LoadingProgress(),
              )
            : Column(
                children: [
                  Container(
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'เลือกประเภทธุรกรรม',
                                        style: TextStyle(
                                            fontSize: 30, color: textColor),
                                      ),
                                      SizedBox(
                                        height: 60,
                                        child:
                                            MiraiDropDownMenu<ProductTypeModel>(
                                          key: UniqueKey(),
                                          children: orderTypes()
                                              .where((e) => e.id != 7)
                                              .toList(),
                                          space: 4,
                                          maxHeight: 360,
                                          showSearchTextField: true,
                                          selectedItemBackgroundColor:
                                              Colors.transparent,
                                          emptyListMessage: 'ไม่มีข้อมูล',
                                          showSelectedItemBackgroundColor: true,
                                          itemWidgetBuilder: (
                                            int index,
                                            ProductTypeModel? project, {
                                            bool isItemSelected = false,
                                          }) {
                                            return DropDownItemWidget(
                                              project: project,
                                              isItemSelected: isItemSelected,
                                              firstSpace: 10,
                                              fontSize: size?.getWidthPx(10),
                                            );
                                          },
                                          onChanged:
                                              (ProductTypeModel value) async {
                                            selectedOrderType = value;
                                            orderTypeNotifier!.value = value;
                                            search();
                                          },
                                          child: DropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: size?.getWidthPx(10),
                                            projectValueNotifier:
                                                orderTypeNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'เลือกลูกค้า',
                                        style: TextStyle(
                                            fontSize: 30, color: textColor),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      SizedBox(
                                        height: 60,
                                        child: MiraiDropDownMenu<CustomerModel>(
                                          key: UniqueKey(),
                                          children: customers ?? [],
                                          space: 4,
                                          maxHeight: 360,
                                          showSearchTextField: true,
                                          selectedItemBackgroundColor:
                                              Colors.transparent,
                                          emptyListMessage: 'ไม่มีข้อมูล',
                                          showSelectedItemBackgroundColor: true,
                                          itemWidgetBuilder: (
                                            int index,
                                            CustomerModel? project, {
                                            bool isItemSelected = false,
                                          }) {
                                            return CustomerDropDownItemWidget(
                                              project: project,
                                              isItemSelected: isItemSelected,
                                              firstSpace: 10,
                                              fontSize: size?.getWidthPx(10),
                                            );
                                          },
                                          onChanged:
                                              (CustomerModel value) async {
                                            selectedCustomer = value;
                                            customerNotifier!.value = value;
                                            search();
                                          },
                                          child:
                                              CustomerDropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: size?.getWidthPx(10),
                                            projectValueNotifier:
                                                customerNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.calendar_today),
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
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (_) => SfDatePickerDialog(
                                          initialDate: DateTime.now(),
                                          onDateSelected: (date) {
                                            String formattedDate =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(date);
                                            setState(() {
                                              fromDateCtrl.text = formattedDate;
                                            });
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
                                    style: const TextStyle(fontSize: 38),
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.calendar_today),
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
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (_) => SfDatePickerDialog(
                                          initialDate: DateTime.now(),
                                          onDateSelected: (date) {
                                            String formattedDate =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(date);
                                            setState(() {
                                              toDateCtrl.text = formattedDate;
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        getProportionateScreenWidth(3.0),
                                    vertical: getProportionateScreenHeight(5.0),
                                  ),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                                Colors.red)),
                                    onPressed: () {
                                      selectedOrderType = null;
                                      selectedCustomer = null;
                                      fromDateCtrl.text = "";
                                      toDateCtrl.text = "";
                                      orderTypeNotifier =
                                          ValueNotifier<ProductTypeModel?>(
                                              null);
                                      customerNotifier =
                                          ValueNotifier<CustomerModel?>(null);
                                      filterList?.clear();
                                      setState(() {});
                                    },
                                    child: Text(
                                      'Reset'.tr(),
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        getProportionateScreenWidth(3.0),
                                    vertical: getProportionateScreenHeight(5.0),
                                  ),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                                bgColor3)),
                                    onPressed: search,
                                    child: Text(
                                      'ค้นหา'.tr(),
                                      style: const TextStyle(fontSize: 32),
                                    ),
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
                      padding: const EdgeInsets.all(8.0),
                      child: loading
                          ? const LoadingProgress()
                          : filterList!.isEmpty
                              ? Center(
                                  child: NoDataFoundWidget(),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filterList!.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return dataCard(filterList![index]!, index);
                                  }),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget dataCard(OrderModel order, int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // Handle card tap if needed
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
                          '#${order.orderId.toString()}',
                          style: TextStyle(fontSize: size?.getWidthPx(8)),
                        ),
                        Text(
                          'วันที่เอกสาร: ${Global.formatDate(order.orderDate.toString())}',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: size!.getWidthPx(6)),
                        ),
                        Text(
                          'วันที่บันทึกรายการ: ${Global.formatDate(order.createdDate.toString())}',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: size!.getWidthPx(6)),
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
                        ...order.details!.map(
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
                              paddedText(e.binLocationName ?? '',
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
                  width: 190,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            Global.pairId = order.pairId;
                            if (order.orderTypeId == 5 ||
                                order.orderTypeId == 6 ||
                                order.orderTypeId == 10 ||
                                order.orderTypeId == 11) {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CheckOutWholesaleSummaryHistoryScreen(),
                                          fullscreenDialog: true))
                                  .whenComplete(() {
                                // search();
                              });
                            } else {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CheckOutSummaryHistoryScreen(),
                                          fullscreenDialog: true))
                                  .whenComplete(() {
                                // search();
                              });
                            }
                          },
                          child: Container(
                            height: 50,
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
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () async {
                            Global.orderIds!.add(order.orderId);
                            if (Global.branch == null) {
                              Alert.warning(context, 'warning'.tr(),
                                  'กรุณาเลือกสาขาก่อนพิมพ์', 'OK'.tr(),
                                  action: () {});
                              return;
                            }
                            final ProgressDialog pr = ProgressDialog(context,
                                type: ProgressDialogType.normal,
                                isDismissible: true,
                                showLogs: true);
                            await pr.show();
                            pr.update(message: 'processing'.tr());
                            try {
                              var result = await ApiServices.post(
                                  '/order/print-order-list/${order.pairId}',
                                  Global.requestObj(null));
                              var data = jsonEncode(result?.data);
                              List<OrderModel> orders =
                                  orderListModelFromJson(data);
                              var payment = await ApiServices.post(
                                  '/order/payment/${order.pairId}',
                                  Global.requestObj(null));
                              Global.paymentList = paymentListModelFromJson(
                                  jsonEncode(payment?.data));
                              await pr.hide();
                              Invoice invoice = Invoice(
                                  order: order,
                                  customer: order.customer!,
                                  payments: Global.paymentList,
                                  orders: orders,
                                  items: order.details!);
                              if (order.orderTypeId == 1 ||
                                  order.orderTypeId == 2) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PdfPreviewPage(invoice: invoice),
                                  ),
                                );
                              } else if (order.orderTypeId == 5) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PreviewRefillGoldPage(
                                              invoice: invoice,
                                            )));
                              } else if (order.orderTypeId == 6) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PreviewSellUsedGoldPage(
                                              invoice: invoice,
                                            )));
                              } else if (order.orderTypeId == 3 ||
                                  order.orderTypeId == 33 ||
                                  order.orderTypeId == 8 ||
                                  order.orderTypeId == 9) {
                                if (mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PdfThengPreviewPage(invoice: invoice),
                                    ),
                                  );
                                }
                              } else if (order.orderTypeId == 10) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PreviewRefillThengGoldPage(
                                            invoice: invoice),
                                  ),
                                );
                              } else if (order.orderTypeId == 11) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PreviewSellUsedThengGoldPage(
                                            invoice: invoice),
                                  ),
                                );
                              } else if (order.orderTypeId == 4) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PreviewSellThengPdfPage(
                                            invoice: invoice),
                                  ),
                                );
                              } else if (order.orderTypeId == 44) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PreviewBuyThengPdfPage(
                                            invoice: invoice),
                                  ),
                                );
                              }
                            } catch (e) {
                              await pr.hide();
                            }
                          },
                          child: Container(
                            height: 50,
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
                  color: colorType(order),
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
                          (order.orderTypeId == 1)
                              ? Icons.check
                              : Icons.pending_actions,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Text(
                    dataType(order),
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
