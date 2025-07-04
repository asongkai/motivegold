import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masked_text/masked_text.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/screen/pos/wholesale/wholesale_checkout_screen.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/config.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';

import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:sizer/sizer.dart';

// Platform-specific imports
import 'package:motivegold/widget/payment/web_file_picker.dart'
    if (dart.library.io) 'package:motivegold/widget/payment/mobile_file_picker.dart';

class EditSellUsedGoldScreen extends StatefulWidget {
  final int index;
  final int? j;

  const EditSellUsedGoldScreen({super.key, required this.index, this.j});

  @override
  State<EditSellUsedGoldScreen> createState() => _EditSellUsedGoldScreenState();
}

class _EditSellUsedGoldScreenState extends State<EditSellUsedGoldScreen> {
  bool loading = false;
  Screen? size;
  List<ProductModel> productList = [];
  List<WarehouseModel> fromWarehouseList = [];
  List<WarehouseModel> toWarehouseList = [];
  List<QtyLocationModel> qtyLocationList = [];
  WarehouseModel? selectedFromLocation;
  WarehouseModel? selectedToLocation;

  TextEditingController productCodeCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  TextEditingController productEntryWeightCtrl = TextEditingController();
  TextEditingController productEntryWeightBahtCtrl = TextEditingController();
  TextEditingController productBuyPricePerGramCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  TextEditingController referenceNumberCtrl = TextEditingController();
  TextEditingController remarkCtrl = TextEditingController();
  TextEditingController priceAdjCtrl = TextEditingController();

  TextEditingController productSellThengPriceCtrl = TextEditingController();
  TextEditingController productBuyThengPriceCtrl = TextEditingController();
  TextEditingController priceExcludeTaxCtrl = TextEditingController();
  TextEditingController priceIncludeTaxCtrl = TextEditingController();
  TextEditingController priceDiffCtrl = TextEditingController();
  TextEditingController taxBaseCtrl = TextEditingController();
  TextEditingController taxAmountCtrl = TextEditingController();
  TextEditingController purchasePriceCtrl = TextEditingController();

  TextEditingController toWarehouseCtrl = TextEditingController();
  TextEditingController productSellPriceCtrl = TextEditingController();
  TextEditingController productBuyPriceCtrl = TextEditingController();

  TextEditingController priceExcludeTaxTotalCtrl = TextEditingController();
  TextEditingController priceIncludeTaxTotalCtrl = TextEditingController();
  TextEditingController priceDiffTotalCtrl = TextEditingController();
  TextEditingController taxBaseTotalCtrl = TextEditingController();
  TextEditingController taxAmountTotalCtrl = TextEditingController();
  TextEditingController purchasePriceTotalCtrl = TextEditingController();

  TextEditingController orderDateCtrl = TextEditingController();

  ProductModel? selectedProduct;
  ValueNotifier<dynamic>? fromWarehouseNotifier;
  ValueNotifier<dynamic>? toWarehouseNotifier;
  ValueNotifier<dynamic>? branchNotifier;
  ValueNotifier<dynamic>? productNotifier;

  String? txt;
  bool showCal = false;

  FocusNode priceIncludeTaxFocus = FocusNode();
  FocusNode gramFocus = FocusNode();
  FocusNode priceExcludeTaxFocus = FocusNode();
  FocusNode purchasePriceFocus = FocusNode();
  FocusNode priceDiffFocus = FocusNode();
  FocusNode taxAmountFocus = FocusNode();
  FocusNode priceAdjFocus = FocusNode();

  bool priceIncludeTaxReadOnly = false;
  bool gramReadOnly = false;
  bool priceExcludeTaxReadOnly = false;
  bool purchasePriceReadOnly = false;
  bool priceDiffReadOnly = false;
  bool taxAmountReadOnly = false;
  bool priceAdjReadOnly = false;

  @override
  void initState() {
    // implement initState

    super.initState();
    // Sample data
    if (env == ENV.DEV) {
      // orderDateCtrl.text = "01-02-2025";
      // referenceNumberCtrl.text = "90803535";
      // productSellThengPriceCtrl.text =
      //     Global.format(Global.toNumber(Global.goldDataModel?.theng?.sell));
      // productBuyThengPriceCtrl.text = "0";
      // productSellPriceCtrl.text = "0";
      // productBuyPriceCtrl.text =
      //     Global.format(Global.toNumber(Global.goldDataModel?.paphun?.buy));
      // productBuyPricePerGramCtrl.text = Global.format(
      //     Global.toNumber(productBuyPriceCtrl.text) / getUnitWeightValue());
      // // purchasePriceCtrl.text = Global.format(944603.10);
      // priceIncludeTaxCtrl.text = Global.format(1464946.60);
      // productEntryWeightCtrl.text = Global.format(434.70);
      // productEntryWeightBahtCtrl.text =
      //     Global.format(434.70 / getUnitWeightValue());
      //
      // gramChanged();
    }

    Global.appBarColor = suBgColor;
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    fromWarehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้าต้นทาง'));
    toWarehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
    branchNotifier = ValueNotifier<BranchModel>(
        BranchModel(id: 0, name: 'เลือกสาขาปลายทาง'));
    loadProducts();
    getCart();

    orderDateCtrl.text = Global.formatDateD(
        Global.ordersWholesale![widget.index].orderDate.toString());
    referenceNumberCtrl.text =
        Global.ordersWholesale![widget.index].referenceNo ?? '';
    productSellThengPriceCtrl.text =
        Global.format(Global.ordersWholesale![widget.index].sellTPrice ?? 0);
    productBuyPricePerGramCtrl.text =
        Global.ordersWholesale![widget.index].buyPrice == null
            ? "0"
            : Global.format(Global.ordersWholesale![widget.index].buyPrice! /
                getUnitWeightValue());
    motivePrint(Global.ordersWholesale![widget.index].buyPrice);
    productBuyPriceCtrl.text =
        Global.format(Global.ordersWholesale![widget.index].buyPrice ?? 0);
    productEntryWeightCtrl.text = Global.format(
        Global.ordersWholesale![widget.index].details![widget.j!].weight ?? 0);
    priceIncludeTaxCtrl.text = Global.format(Global
            .ordersWholesale![widget.index]
            .details![widget.j!]
            .priceIncludeTax ??
        0);
    priceExcludeTaxCtrl.text = Global.format(Global
            .ordersWholesale![widget.index]
            .details![widget.j!]
            .priceExcludeTax ??
        0);
    purchasePriceCtrl.text = Global.format(Global
            .ordersWholesale![widget.index].details![widget.j!].purchasePrice ??
        0);
    priceDiffCtrl.text = Global.format(
        Global.ordersWholesale![widget.index].details![widget.j!].priceDiff ??
            0);
    taxAmountCtrl.text = Global.format(
        Global.ordersWholesale![widget.index].details![widget.j!].taxAmount ??
            0);
    taxBaseCtrl.text = Global.format(
        Global.ordersWholesale![widget.index].details![widget.j!].taxBase ?? 0);
    priceAdjCtrl.text = Global.format(
        Global.ordersWholesale![widget.index].details![widget.j!].weightAdj ??
            0);
    remarkCtrl.text = Global.ordersWholesale![widget.index].remark ?? '';

    purchasePriceChanged();
    priceIncludeTaxChanged();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    productCodeCtrl.dispose();
    productNameCtrl.dispose();
    productWeightCtrl.dispose();
    productWeightBahtCtrl.dispose();
    productEntryWeightCtrl.dispose();
    productEntryWeightBahtCtrl.dispose();
    warehouseCtrl.dispose();

    productSellThengPriceCtrl.dispose();
    productBuyThengPriceCtrl.dispose();
    priceExcludeTaxCtrl.dispose();
    priceIncludeTaxCtrl.dispose();
    priceDiffCtrl.dispose();
    taxBaseCtrl.dispose();
    taxAmountCtrl.dispose();
    purchasePriceCtrl.dispose();

    toWarehouseCtrl.dispose();
    productSellPriceCtrl.dispose();
    productBuyPriceCtrl.dispose();

    priceExcludeTaxTotalCtrl.dispose();
    priceIncludeTaxTotalCtrl.dispose();
    priceDiffTotalCtrl.dispose();
    taxBaseTotalCtrl.dispose();
    taxAmountTotalCtrl.dispose();
    purchasePriceTotalCtrl.dispose();

    orderDateCtrl.dispose();
    referenceNumberCtrl.dispose();
    priceAdjCtrl.dispose();

    priceIncludeTaxFocus.dispose();
    gramFocus.dispose();
    priceExcludeTaxFocus.dispose();
    purchasePriceFocus.dispose();
    priceDiffFocus.dispose();
    taxAmountFocus.dispose();
    priceAdjFocus.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      if (!kIsWeb) {
        Global.sellUsedAttach =
            Global.ordersWholesale![widget.index].attachment != null
                ? await Global.createFileFromString(
                    Global.ordersWholesale![widget.index].attachment ?? '')
                : null;
      } else {
        Global.sellUsedAttachWeb =
            Global.ordersWholesale![widget.index].attachment;
      }

      var result = await ApiServices.post(
          '/product/type/USED/6', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
            selectedProduct = productList.where((e) => e.isDefault == 1).first;
            // motivePrint(selectedProduct?.toJson());
            productNotifier = ValueNotifier<ProductModel>(
                selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
            productCodeCtrl.text =
                (selectedProduct != null ? selectedProduct!.productCode : '')!;
            productNameCtrl.text =
                selectedProduct != null ? selectedProduct!.name : '';
          }
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/type/USED/6', Global.requestObj(null));
      // print(warehouse!.data);
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        setState(() {
          fromWarehouseList = warehouseListModelFromJson(data);
          if (fromWarehouseList.isNotEmpty) {
            selectedFromLocation =
                fromWarehouseList.where((e) => e.isDefault == 1).first;
            selectedFromLocation ??= fromWarehouseList.first;
            fromWarehouseNotifier = ValueNotifier<WarehouseModel>(
                selectedFromLocation ??
                    WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));

            loadToWarehouseNoId(selectedFromLocation!.id!);
            loadQtyByLocation(selectedFromLocation!.id!);
          } else {
            toWarehouseList = warehouseListModelFromJson(data);
          }
        });
      } else {
        fromWarehouseList = [];
        toWarehouseList = [];
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

  Future<void> loadQtyByLocation(int id) async {
    try {
      var result = await ApiServices.get(
          '/qtybylocation/by-product-location/$id/${selectedProduct!.id}');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<QtyLocationModel> qtys = qtyLocationListModelFromJson(data);
        setState(() {
          qtyLocationList = qtys;
        });
      } else {
        qtyLocationList = [];
      }

      productWeightCtrl.text =
          Global.format(Global.getTotalWeightByLocation(qtyLocationList));
      productWeightBahtCtrl.text = Global.format(
          Global.getTotalWeightByLocation(qtyLocationList) /
              getUnitWeightValue());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void loadToWarehouseNoId(int id) async {
    try {
      setState(() {
        toWarehouseList.clear();
        toWarehouseCtrl.text = "";
      });
      var data =
          fromWarehouseList.where((element) => element.id != id).toList();
      toWarehouseList.addAll(data);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          toWarehouseNotifier = ValueNotifier<WarehouseModel>(
              WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void openCal() {
    if (txt == 'purchase') {
      purchasePriceReadOnly = true;
    }
    if (txt == 'gram') {
      gramReadOnly = true;
    }
    if (txt == 'price_include') {
      priceIncludeTaxReadOnly = true;
    }
    if (txt == 'price_exclude') {
      priceExcludeTaxReadOnly = true;
    }
    if (txt == 'price_diff') {
      priceDiffReadOnly = true;
    }
    if (txt == 'tax_amount') {
      taxAmountReadOnly = true;
    }
    if (txt == 'price_adj') {
      priceAdjReadOnly = true;
    }
    setState(() {
      showCal = true;
    });
  }

  void closeCal() {
    purchasePriceReadOnly = false;
    gramReadOnly = false;
    priceIncludeTaxReadOnly = false;
    priceExcludeTaxReadOnly = false;
    priceDiffReadOnly = false;
    taxAmountReadOnly = false;
    priceAdjReadOnly = false;
    setState(() {
      showCal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: suBgColor,
        centerTitle: true,
        title: Text(
          'ขายทองเก่าร้านขายส่ง',
          style: TextStyle(
            fontSize: 16.sp, //16.sp,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GoldPriceScreen(
                            showBackButton: true,
                          ),
                      fullscreenDialog: true));
            },
            child: Row(
              children: [
                const Icon(
                  Icons.money,
                  size: 50,
                ),
                Text(
                  'ราคาทองคำ',
                  style: TextStyle(fontSize: 16.sp),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      closeCal();
                    },
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: suBgColorLight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 60,
                                    child: MiraiDropDownMenu<ProductModel>(
                                      key: UniqueKey(),
                                      children: productList,
                                      space: 4,
                                      maxHeight: 360,
                                      showSearchTextField: true,
                                      selectedItemBackgroundColor:
                                          Colors.transparent,
                                      emptyListMessage: 'ไม่มีข้อมูล',
                                      showSelectedItemBackgroundColor: true,
                                      itemWidgetBuilder: (
                                        int index,
                                        ProductModel? project, {
                                        bool isItemSelected = false,
                                      }) {
                                        return DropDownItemWidget(
                                          project: project,
                                          isItemSelected: isItemSelected,
                                          firstSpace: 10,
                                          fontSize: 16.sp, //16.sp,
                                        );
                                      },
                                      onChanged: (ProductModel value) {
                                        productCodeCtrl.text =
                                            value.productCode!.toString();
                                        productNameCtrl.text = value.name;
                                        selectedProduct = value;
                                        productNotifier!.value = value;
                                      },
                                      child: DropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: 16.sp, //16.sp,
                                        projectValueNotifier: productNotifier!,
                                      ),
                                    ),
                                  ),
                                )),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: MaskedTextField(
                                      controller: orderDateCtrl,
                                      mask: "##-##-####",
                                      maxLength: 10,
                                      keyboardType: TextInputType.number,
                                      //editing controller of this TextField
                                      style: TextStyle(
                                          fontSize: 16.sp, //16.sp,
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white70,
                                        hintText: 'dd-mm-yyyy',
                                        labelStyle: TextStyle(
                                            fontSize: 16.sp, //16.sp,
                                            color: Colors.blue[900],
                                            fontWeight: FontWeight.w900),
                                        prefixIcon: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    SfDatePickerDialog(
                                                  initialDate: DateTime.now(),
                                                  onDateSelected: (date) {
                                                    motivePrint(
                                                        'You picked: $date');
                                                    // Your logic here
                                                    String formattedDate =
                                                        DateFormat('dd-MM-yyyy')
                                                            .format(date);
                                                    motivePrint(
                                                        formattedDate); //formatted date output using intl package =>  2021-03-16
                                                    //you can implement different kind of Date Format here according to your requirement
                                                    setState(() {
                                                      orderDateCtrl.text =
                                                          formattedDate; //set output date to TextField value.
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                            child: const Icon(
                                              Icons.calendar_today,
                                              size: 40,
                                            )),
                                        //icon of text field
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                        labelText: "วันที่ใบกำกับภาษี",
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
                                      //set it true, so that user will not able to edit text
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: buildTextFieldX(
                                  labelText: "เลขที่อ้างอิง",
                                  inputType: TextInputType.text,
                                  enabled: true,
                                  controller: referenceNumberCtrl,
                                  fontSize: 16.sp),
                            ),
                            const SizedBox(
                              height: 0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: buildTextFieldX(
                                      bgColor: Colors.green.shade50,
                                      labelText: "ทองคำแท่งขายออกบาทละ",
                                      inputType: TextInputType.phone,
                                      controller: productSellThengPriceCtrl,
                                      fontSize: 16.sp,
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: buildTextFieldX(
                                        labelText: "ทองรูปพรรณรับซื้อกรัมละ",
                                        inputType: TextInputType.number,
                                        controller: productBuyPricePerGramCtrl,
                                        fontSize: 16.sp,
                                        inputFormat: [
                                          ThousandsFormatter(
                                              allowFraction: true)
                                        ],
                                        onChanged: (value) {
                                          onPerGramChanged();
                                        }),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: buildTextField(
                                        labelText:
                                            "น้ำหนักรวม (กรัม) ในคลังสินค้า: ${selectedFromLocation?.name}",
                                        inputType: TextInputType.number,
                                        controller: productWeightCtrl,
                                        enabled: false,
                                        fontSize: 16.sp,
                                        labelColor: Colors.black87,
                                        inputFormat: [
                                          ThousandsFormatter(
                                              allowFraction: true)
                                        ],
                                        onChanged: (String value) {}),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: numberTextField(
                                        labelText: "น้ำหนักรวม (กรัม) ",
                                        inputType: TextInputType.number,
                                        controller: productEntryWeightCtrl,
                                        focusNode: gramFocus,
                                        readOnly: gramReadOnly,
                                        fontSize: 16.sp,
                                        inputFormat: [
                                          ThousandsFormatter(
                                              allowFraction: true)
                                        ],
                                        clear: () {
                                          setState(() {
                                            productEntryWeightCtrl.text = "";
                                          });
                                          gramChanged();
                                        },
                                        onTap: () {
                                          txt = 'gram';
                                          closeCal();
                                        },
                                        openCalc: () {
                                          if (!showCal) {
                                            txt = 'gram';
                                            gramFocus.requestFocus();
                                            openCal();
                                          }
                                        },
                                        onChanged: (String value) {
                                          gramChanged();
                                        }),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: numberTextField(
                                      labelText: "จำนวนเงินสุทธิ",
                                      inputType: TextInputType.phone,
                                      controller: priceIncludeTaxCtrl,
                                      focusNode: priceIncludeTaxFocus,
                                      readOnly: priceIncludeTaxReadOnly,
                                      fontSize: 16.sp,
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      clear: () {
                                        setState(() {
                                          priceIncludeTaxCtrl.text = "";
                                        });
                                        priceIncludeTaxChanged();
                                      },
                                      onTap: () {
                                        txt = 'price_include';
                                        closeCal();
                                      },
                                      openCalc: () {
                                        if (!showCal) {
                                          txt = 'price_include';
                                          priceIncludeTaxFocus.requestFocus();
                                          openCal();
                                        }
                                      },
                                      onChanged: (String value) {
                                        // priceIncludeTaxChanged();
                                      },
                                      onFocusChange: (value) {
                                        if (!value) {
                                          priceIncludeTaxChanged();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'หักราคารับซื้อทองประจำวัน',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: textColor),
                                      ),
                                    )),
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: numberTextField(
                                      bgColor: Colors.grey.shade200,
                                      labelText: "",
                                      inputType: TextInputType.phone,
                                      controller: purchasePriceCtrl,
                                      focusNode: purchasePriceFocus,
                                      readOnly: purchasePriceReadOnly,
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      clear: () {
                                        setState(() {
                                          purchasePriceCtrl.text = "";
                                        });
                                        purchasePriceChanged();
                                      },
                                      onTap: () {
                                        txt = 'purchase';
                                        closeCal();
                                      },
                                      openCalc: () {
                                        if (!showCal) {
                                          txt = 'purchase';
                                          purchasePriceFocus.requestFocus();
                                          openCal();
                                        }
                                      },
                                      onChanged: (String value) {
                                        // purchasePriceChanged();
                                      },
                                      onFocusChange: (value) {
                                        if (!value) {
                                          purchasePriceChanged();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'จำนวนส่วนต่างฐานภาษี',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: textColor),
                                      ),
                                    )),
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: numberTextField(
                                        bgColor: Colors.grey.shade200,
                                        labelColor: Global.toNumber(
                                                    priceDiffCtrl.text) >
                                                0
                                            ? null
                                            : Colors.red,
                                        labelText: "",
                                        inputType: TextInputType.phone,
                                        controller: priceDiffCtrl,
                                        focusNode: priceDiffFocus,
                                        readOnly: priceDiffReadOnly,
                                        inputFormat: [
                                          ThousandsFormatter(
                                              allowFraction: true)
                                        ],
                                        clear: () {
                                          setState(() {
                                            priceDiffCtrl.text = "";
                                          });
                                        },
                                        onTap: () {
                                          txt = 'price_diff';
                                          closeCal();
                                        },
                                        openCalc: () {
                                          if (!showCal) {
                                            txt = 'price_diff';
                                            priceDiffFocus.requestFocus();
                                            openCal();
                                          }
                                        },
                                        onChanged: (String value) {}),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'ภาษีมูลค่าเพิ่ม 7%',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: textColor),
                                      ),
                                    )),
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: numberTextField(
                                        bgColor: Colors.grey.shade200,
                                        labelText: "",
                                        inputType: TextInputType.phone,
                                        controller: taxAmountCtrl,
                                        focusNode: taxAmountFocus,
                                        readOnly: taxAmountReadOnly,
                                        inputFormat: [
                                          ThousandsFormatter(
                                              allowFraction: true)
                                        ],
                                        clear: () {
                                          setState(() {
                                            taxAmountCtrl.text = "";
                                          });
                                        },
                                        onTap: () {
                                          txt = 'tax_amount';
                                          closeCal();
                                        },
                                        openCalc: () {
                                          if (!showCal) {
                                            txt = 'tax_amount';
                                            taxAmountFocus.requestFocus();
                                            openCal();
                                          }
                                        },
                                        onChanged: (String value) {}),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'ราคารวมก่อนภาษี',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: textColor),
                                      ),
                                    )),
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: numberTextField(
                                      bgColor: Colors.grey.shade200,
                                      labelText: "",
                                      inputType: TextInputType.phone,
                                      controller: priceExcludeTaxCtrl,
                                      focusNode: priceExcludeTaxFocus,
                                      readOnly: priceExcludeTaxReadOnly,
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      clear: () {
                                        setState(() {
                                          priceExcludeTaxCtrl.text = "";
                                        });
                                      },
                                      onTap: () {
                                        txt = 'price_exclude';
                                        closeCal();
                                      },
                                      openCalc: () {
                                        if (!showCal) {
                                          txt = 'price_exclude';
                                          priceExcludeTaxFocus.requestFocus();
                                          openCal();
                                        }
                                      },
                                      onChanged: (String value) {},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'น้ำหนักสูญเสีย (กรัม) ',
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: textColor),
                                        ),
                                      )),
                                  Expanded(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: numberTextField(
                                        labelText: "",
                                        inputType: TextInputType.number,
                                        controller: priceAdjCtrl,
                                        focusNode: priceAdjFocus,
                                        readOnly: priceAdjReadOnly,
                                        inputFormat: [
                                          ThousandsFormatter(
                                              allowFraction: true)
                                        ],
                                        clear: () {
                                          setState(() {
                                            priceAdjCtrl.text = "";
                                          });
                                        },
                                        onTap: () {
                                          txt = 'price_adj';
                                          closeCal();
                                        },
                                        openCalc: () {
                                          if (!showCal) {
                                            txt = 'price_adj';
                                            priceAdjFocus.requestFocus();
                                            openCal();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: buildTextFieldX(
                                        labelText: "หมายเหตุ",
                                        inputType: TextInputType.text,
                                        controller: remarkCtrl,
                                        fontSize: 16.sp),
                                  ),
                                ),
                              ],
                            ),
                            // Attachment
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'แนบไฟล์ใบส่งสินค้า/ใบกำกับภาษี',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    color: textColor),
                              ),
                            ),
                            SizedBox(
                              width: size?.wp(30),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                  onPressed: showOptions,
                                  icon: const Icon(
                                    Icons.add_a_photo_outlined,
                                  ),
                                  label: Text(
                                    'เลือกรูปภาพ',
                                    style: TextStyle(
                                        fontSize: 16.sp),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Global.sellUsedAttach == null && Global.sellUsedAttachWeb == null
                                    ? Text(
                                  'ไม่ได้เลือกรูปภาพ',
                                  style: TextStyle(fontSize: 16.sp),
                                )
                                    : Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width / 4,
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: kIsWeb
                                              ? Image.memory(base64Decode(Global.sellUsedAttachWeb!.split(",").last))
                                              : Image.file(Global.sellUsedAttach!),
                                        ),
                                        Positioned(
                                          right: 0.0,
                                          top: 0.0,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                Global.sellUsedAttach = null;
                                                Global.sellUsedAttachWeb = null;
                                              });
                                            },
                                            child: const CircleAvatar(
                                              backgroundColor: Colors.red,
                                              child: Icon(Icons.close),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showCal)
                    DragArea(
                        closeCal: closeCal,
                        child: Container(
                            width: 350,
                            height: 500,
                            padding: const EdgeInsets.all(5),
                            decoration:
                                const BoxDecoration(color: Color(0xffcccccc)),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Calc(
                                  closeCal: closeCal,
                                  onChanged: (key, value, expression) {
                                    if (key == 'ENT') {
                                      if (txt == 'gram') {
                                        productEntryWeightCtrl.text =
                                            value != null
                                                ? "${Global.format(value)}"
                                                : "";
                                        gramChanged();
                                      }
                                      if (txt == 'price_include') {
                                        priceIncludeTaxCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                        priceIncludeTaxChanged();
                                      }
                                      if (txt == 'price_exclude') {
                                        priceExcludeTaxCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                      }
                                      if (txt == 'purchase') {
                                        purchasePriceCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                        purchasePriceChanged();
                                      }
                                      if (txt == 'price_diff') {
                                        priceDiffCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                      }
                                      if (txt == 'tax_amount') {
                                        taxAmountCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                      }
                                      if (txt == 'price_adj') {
                                        priceAdjCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                      }
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      closeCal();
                                    }
                                    if (kDebugMode) {
                                      print('$key\t$value\t$expression');
                                    }
                                  },
                                ),
                                Positioned(
                                  right: -35.0,
                                  top: -35.0,
                                  child: InkWell(
                                    onTap: closeCal,
                                    child: const CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )))
                ],
              ),
      ),
      persistentFooterButtons: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: suBgColorLight,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          Global.usedSellDetail = [];
                          resetText();
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'เคลียร์',
                            style: TextStyle(fontSize: 16.sp),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: suBgColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (orderDateCtrl.text.isEmpty) {
                          Alert.warning(context, 'คำเตือน',
                              'กรุณาป้อนวันที่ใบกำกับภาษี', 'OK');
                          return;
                        }

                        if (!checkDate(orderDateCtrl.text)) {
                          Alert.warning(context, 'คำเตือน',
                              'วันที่ที่ป้อนมีรูปแบบไม่ถูกต้อง', 'OK',
                              action: () {});
                          return;
                        }

                        if (productEntryWeightCtrl.text.isEmpty ||
                            priceIncludeTaxCtrl.text.isEmpty) {
                          Alert.warning(
                              context, 'คำเตือน', 'กรุณาเพิ่มข้อมูลก่อน', 'OK',
                              action: () {});
                          return;
                        }

                        if (selectedFromLocation == null) {
                          Alert.warning(context, 'คำเตือน',
                              'กรุณาเลือกคลังสินค้าต้นทาง', 'OK',
                              action: () {});
                          return;
                        }

                        Alert.info(
                            context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                            action: () async {
                          try {
                            saveData();
                            if (mounted) {
                              resetText();
                              Future.delayed(const Duration(milliseconds: 500),
                                  () async {
                                writeCart();
                                setState(() {});
                              });
                              Navigator.of(context).pop();
                              // Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //             builder: (context) =>
                              //                 const WholeSaleCheckOutScreen()))
                              //     .whenComplete(() {
                              //   Future.delayed(
                              //       const Duration(milliseconds: 500),
                              //       () async {
                              //     writeCart();
                              //     setState(() {});
                              //   });
                              // });
                            }
                          } catch (e) {
                            if (mounted) {
                              Alert.warning(context, 'Warning'.tr(),
                                  e.toString(), 'OK'.tr(),
                                  action: () {});
                            }
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save),
                          const SizedBox(width: 6),
                          Text(
                            'บันทึก',
                            style: TextStyle(fontSize: 16.sp),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void priceIncludeTaxChanged() {
    if (purchasePriceCtrl.text.isNotEmpty &&
        priceIncludeTaxCtrl.text.isNotEmpty) {
      priceDiffCtrl.text = Global.format(
          (Global.toNumber(priceIncludeTaxCtrl.text) -
              Global.toNumber(purchasePriceCtrl.text)));
    } else {
      priceDiffCtrl.text = "";
    }
    getOtherAmount();
  }

  void purchasePriceChanged() {
    if (purchasePriceCtrl.text.isNotEmpty &&
        priceIncludeTaxCtrl.text.isNotEmpty) {
      priceDiffCtrl.text = Global.format(
          (Global.toNumber(priceIncludeTaxCtrl.text) -
              Global.toNumber(purchasePriceCtrl.text)));
    } else {
      priceDiffCtrl.text = "";
    }
    getOtherAmount();
  }

  void gramChanged() {
    if (productEntryWeightCtrl.text.isNotEmpty) {
      productEntryWeightBahtCtrl.text = Global.format(
          (Global.toNumber(productEntryWeightCtrl.text) /
              getUnitWeightValue()));
      purchasePriceCtrl.text = Global.format(
          Global.toNumber(productEntryWeightCtrl.text) *
              Global.toNumber(productBuyPricePerGramCtrl.text));
    } else {
      productEntryWeightBahtCtrl.text = "";
      purchasePriceCtrl.text = "";
    }
  }

  void getOtherAmount() {
    double priceDiff = Global.toNumber(priceDiffCtrl.text);
    double priceIncludeTax = Global.toNumber(priceIncludeTaxCtrl.text);
    if (priceDiff <= 0) {
      taxAmountCtrl.text = '0';
    } else {
      taxAmountCtrl.text = Global.format(priceDiff * 7 / 107);
    }

    priceExcludeTaxCtrl.text =
        Global.format(priceIncludeTax - Global.toNumber(taxAmountCtrl.text));

    taxBaseCtrl.text = Global.toNumber(priceDiffCtrl.text) < 0
        ? "0"
        : Global.format(Global.toNumber(priceDiffCtrl.text) * 100 / 107);

    calTotal();
  }

  onPerGramChanged() {
    if (productBuyPricePerGramCtrl.text.isNotEmpty) {
      productBuyPriceCtrl.text = Global.format(
          Global.toNumber(productBuyPricePerGramCtrl.text) *
              getUnitWeightValue());
    }
  }

  resetText() {
    productWeightCtrl.text = "";
    productEntryWeightCtrl.text = "";
    priceIncludeTaxCtrl.text = "";
    productWeightBahtCtrl.text = "";
    productEntryWeightBahtCtrl.text = "";
    priceExcludeTaxCtrl.text = "";
    purchasePriceCtrl.text = "";
    priceDiffCtrl.text = "";
    taxAmountCtrl.text = "";
    remarkCtrl.text = "";
    productSellThengPriceCtrl.text = "";
    productBuyPricePerGramCtrl.text = "";
    referenceNumberCtrl.text = "";
    orderDateCtrl.text = "";
    productBuyThengPriceCtrl.text = "";
    productSellPriceCtrl.text = "";
    productBuyPriceCtrl.text = "";
    priceIncludeTaxTotalCtrl.text = "";
    priceExcludeTaxTotalCtrl.text = "";
    purchasePriceTotalCtrl.text = "";
    priceDiffTotalCtrl.text = "";
    taxAmountTotalCtrl.text = "";
    taxBaseTotalCtrl.text = "";
    Global.sellUsedAttach = null;
    Global.sellUsedAttachWeb = null;
    Global.usedSellDetail?.clear();
    setState(() {});
  }

  void calTotal() {
    purchasePriceTotalCtrl.text = purchasePriceCtrl.text;
    priceIncludeTaxTotalCtrl.text = priceIncludeTaxCtrl.text;
    priceDiffTotalCtrl.text = priceDiffCtrl.text;
    taxBaseTotalCtrl.text = taxBaseCtrl.text;
    taxAmountTotalCtrl.text = taxAmountCtrl.text;
    priceExcludeTaxTotalCtrl.text = priceExcludeTaxCtrl.text;
    setState(() {});
  }

  final picker = ImagePicker();

  //Image Picker function to get image from gallery
//   Future getImageFromGallery() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     setState(() {
//       if (pickedFile != null) {
//         Global.sellUsedAttach = File(pickedFile.path);
//       }
//     });
//   }
//
// //Image Picker function to get image from camera
//   Future getImageFromCamera() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//
//     setState(() {
//       if (pickedFile != null) {
//         Global.sellUsedAttach = File(pickedFile.path);
//       }
//     });
//   }

  Future getImageFromGallery() async {
    if (!kIsWeb) {
      // Mobile platform
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          Global.sellUsedAttach = File(pickedFile.path);
        });
      }
    } else {
      // Web platform - use platform-specific implementation
      try {
        final result = await WebFilePicker.pickImage();
        if (result != null) {
          setState(() {
            Global.sellUsedAttachWeb = result;
          });
        }
      } catch (e) {
        if (mounted) {
          Alert.warning(context, "Error", "Failed to select image: $e", "OK",
              action: () {});
        }
      }
    }
  }

  Future getImageFromCamera() async {
    if (!kIsWeb) {
      // Mobile platform
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          Global.sellUsedAttach = File(pickedFile.path);
        });
      }
    } else {
      // On web, camera isn't directly accessible via InputElement easily.
      Alert.warning(context, "ไม่รองรับ",
          "การถ่ายภาพจากกล้องบนเว็บยังไม่พร้อมใช้งาน", "OK",
          action: () {});
    }
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('คลังภาพ'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('ถ่ายรูป'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  void saveData() {
    Global.usedSellDetail!.clear();
    Global.usedSellDetail!.add(
      OrderDetailModel(
        productName: selectedProduct!.name,
        productId: selectedProduct!.id,
        binLocationId: selectedFromLocation!.id,
        toBinLocationId: selectedToLocation?.id,
        binLocationName: selectedFromLocation!.name,
        toBinLocationName: selectedToLocation?.name,
        sellTPrice: Global.toNumber(productSellThengPriceCtrl.text),
        buyTPrice: Global.toNumber(productBuyThengPriceCtrl.text),
        sellPrice: Global.toNumber(productSellPriceCtrl.text),
        buyPrice: Global.toNumber(productBuyPriceCtrl.text),
        weight: Global.toNumber(productEntryWeightCtrl.text),
        weightBath: Global.toNumber(productEntryWeightBahtCtrl.text),
        weightAdj: Global.toNumber(priceAdjCtrl.text),
        weightBathAdj:
            Global.toNumber(priceAdjCtrl.text) / getUnitWeightValue(),
        commission: 0,
        unitCost: Global.toNumber(priceIncludeTaxCtrl.text) /
            Global.toNumber(productEntryWeightCtrl.text),
        priceIncludeTax: Global.toNumber(priceIncludeTaxCtrl.text),
        priceExcludeTax: Global.toNumber(priceExcludeTaxCtrl.text),
        purchasePrice: Global.toNumber(purchasePriceCtrl.text),
        priceDiff: Global.toNumber(priceDiffCtrl.text),
        taxBase: Global.toNumber(taxBaseCtrl.text),
        taxAmount: Global.toNumber(taxAmountCtrl.text),
      ),
    );

    OrderModel order = OrderModel(
        orderId: "",
        orderDate: Global.convertDate(orderDateCtrl.text),
        details: Global.usedSellDetail!,
        referenceNo: referenceNumberCtrl.text,
        remark: remarkCtrl.text,
        sellTPrice: Global.toNumber(productSellThengPriceCtrl.text),
        buyTPrice: Global.toNumber(productBuyThengPriceCtrl.text),
        sellPrice: Global.toNumber(productSellPriceCtrl.text),
        buyPrice: Global.toNumber(productBuyPriceCtrl.text),
        weight: Global.toNumber(productEntryWeightCtrl.text),
        priceIncludeTax: Global.toNumber(priceIncludeTaxTotalCtrl.text),
        priceExcludeTax: Global.toNumber(priceExcludeTaxTotalCtrl.text),
        purchasePrice: Global.toNumber(purchasePriceTotalCtrl.text),
        priceDiff: Global.toNumber(priceDiffTotalCtrl.text),
        taxBase: Global.toNumber(taxBaseTotalCtrl.text),
        taxAmount: Global.toNumber(taxAmountTotalCtrl.text),
        orderTypeId: 6,
        attachment: getSellUsedAttachment(),
        orderStatus: 'PENDING');
    final data = order.toJson();
    // motivePrint(data);
    // return;
    Global.ordersWholesale?[widget.index] = OrderModel.fromJson(data);
    writeCart();
    Global.usedSellDetail!.clear();
  }
}
