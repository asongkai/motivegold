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
import 'package:motivegold/utils/calculator/manager.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/config.dart';
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

class SellUsedGoldScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  final int cartCount;

  const SellUsedGoldScreen(
      {super.key, required this.refreshCart, required this.cartCount});

  @override
  State<SellUsedGoldScreen> createState() => _SellUsedGoldScreenState();
}

class _SellUsedGoldScreenState extends State<SellUsedGoldScreen> {
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
    // Sample data
    if (env == ENV.DEV) {
      orderDateCtrl.text = "01-02-2025";
      referenceNumberCtrl.text = "90803535";
      productSellThengPriceCtrl.text =
          Global.format(Global.toNumber(Global.goldDataModel?.theng?.sell));
      productBuyThengPriceCtrl.text = "0";
      productSellPriceCtrl.text = "0";
      productBuyPriceCtrl.text =
          Global.format(Global.toNumber(Global.goldDataModel?.paphun?.buy));
      // productBuyPricePerGramCtrl.text = Global.format(
      //     Global.toNumber(productBuyPriceCtrl.text) / getUnitWeightValue(selectedProduct?.id));
      // purchasePriceCtrl.text = Global.format(944603.10);
      priceIncludeTaxCtrl.text = Global.format(164946.60);
      productEntryWeightCtrl.text = Global.format(34.70);
      // productEntryWeightBahtCtrl.text =
      //     Global.format(Global.toNumber(productEntryWeightCtrl.text) / getUnitWeightValue(selectedProduct?.id));

      // gramChanged();
      // priceIncludeTaxChanged();
    }
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
              getUnitWeightValue(selectedProduct?.id));
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
    AppCalculatorManager.showCalculator(
      onClose: closeCal,
      onChanged: (key, value, expression) {
        if (key == 'ENT') {
          if (txt == 'gram') {
            productEntryWeightCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            gramChanged();
          }
          if (txt == 'price_include') {
            priceIncludeTaxCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            priceIncludeTaxChanged();
          }
          if (txt == 'price_exclude') {
            priceExcludeTaxCtrl.text =
                value != null ? "${Global.format(value)}" : "";
          }
          if (txt == 'purchase') {
            purchasePriceCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            purchasePriceChanged();
          }
          if (txt == 'price_diff') {
            priceDiffCtrl.text = value != null ? "${Global.format(value)}" : "";
          }
          if (txt == 'tax_amount') {
            taxAmountCtrl.text = value != null ? "${Global.format(value)}" : "";
          }
          if (txt == 'price_adj') {
            priceAdjCtrl.text = value != null ? "${Global.format(value)}" : "";
          }
          FocusScope.of(context).requestFocus(FocusNode());
          closeCal();
        }
        if (kDebugMode) {
          print('$key\t$value\t$expression');
        }
      },
    );
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
    AppCalculatorManager.hideCalculator();
    setState(() {
      showCal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: suBgColor,
        centerTitle: true,
        title: Text(
          'ขายทองเก่าร้านขายส่ง',
          style: TextStyle(
            fontSize: 16.sp, //16.sp,
            color: Colors.white,
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
                  color: Colors.white,
                ),
                Text(
                  'ราคาทองคำ',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
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
            : GestureDetector(
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
                                            builder: (_) => SfDatePickerDialog(
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
                                          Icons.calendar_month_outlined,
                                          size: 40,
                                        )),
                                    //icon of text field
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
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
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: buildTextFieldX(
                              labelText: "เลขที่อ้างอิง",
                              inputType: TextInputType.text,
                              enabled: true,
                              controller: referenceNumberCtrl,
                              fontSize: 16.sp),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'ทองคำแท่งขายออกบาทละ',
                                          style: TextStyle(
                                            fontSize: 15.sp, //fontSize,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    buildTextFieldX(
                                      bgColor: Colors.green.shade50,
                                      labelText: "",
                                      inputType: TextInputType.phone,
                                      controller: productSellThengPriceCtrl,
                                      fontSize: 16.sp,
                                      inputFormat: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            // You can change this color
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '1', // Your number here
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        // Space between circle and text
                                        Text(
                                          'ทองรูปพรรณรับซื้อกรัมละ',
                                          style: TextStyle(
                                            fontSize: 15.sp, //fontSize,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    buildTextFieldX(
                                        labelText: "",
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
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (Global.company?.stock == 1)
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
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      onChanged: (String value) {}),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            // You can change this color
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '2', // Your number here
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        // Space between circle and text
                                        Text(
                                          'น้ำหนักรวม (กรัม) ',
                                          style: TextStyle(
                                            fontSize: 15.sp, //fontSize,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    numberTextField(
                                        labelText: "",
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
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            // You can change this color
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '3', // Your number here
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        // Space between circle and text
                                        Text(
                                          'จำนวนเงินสุทธิ',
                                          style: TextStyle(
                                            fontSize: 15.sp, //fontSize,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    numberTextField(
                                      labelText: "",
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
                                  ],
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
                                        fontSize: 16.sp, color: textColor),
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
                                        fontSize: 16.sp, color: textColor),
                                  ),
                                )),
                            Expanded(
                              flex: 6,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: numberTextField(
                                    bgColor: Colors.grey.shade200,
                                    labelColor:
                                        Global.toNumber(priceDiffCtrl.text) > 0
                                            ? null
                                            : Colors.red,
                                    labelText: "",
                                    inputType: TextInputType.phone,
                                    controller: priceDiffCtrl,
                                    focusNode: priceDiffFocus,
                                    readOnly: priceDiffReadOnly,
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
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
                                        fontSize: 16.sp, color: textColor),
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
                                      ThousandsFormatter(allowFraction: true)
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
                                        fontSize: 16.sp, color: textColor),
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
                                          fontSize: 16.sp, color: textColor),
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
                                      ThousandsFormatter(allowFraction: true)
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

                        // Modern Remarks Section
                        const SizedBox(height: 20),
                        _buildModernRemarks(),

                        // Modern Attachment Section
                        const SizedBox(height: 20),
                        _buildModernAttachmentSection(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      persistentFooterButtons: [_buildModernFooterButtons()],
    );
  }

  // Modern Remarks Section
  Widget _buildModernRemarks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'หมายเหตุ',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: remarkCtrl,
            keyboardType: TextInputType.text,
            maxLines: 3,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'กรอกหมายเหตุ (ถ้ามี)',
              prefixIcon: Icon(Icons.note_add, color: suBgColor, size: 20),
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // Modern Attachment Section
  Widget _buildModernAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'แนบไฟล์ใบส่งสินค้า/ใบกำกับภาษี',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              _buildImageSelector(),
              const SizedBox(height: 16),
              _buildImagePreview(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelector() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [suBgColor, suBgColor.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: suBgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: showOptions,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'เลือกรูปภาพ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (Global.sellUsedAttach == null && Global.sellUsedAttachWeb == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'ไม่ได้เลือกรูปภาพ',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: kIsWeb
                  ? Image.memory(
                      base64Decode(Global.sellUsedAttachWeb!.split(",").last),
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      Global.sellUsedAttach!,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      Global.sellUsedAttach = null;
                      Global.sellUsedAttachWeb = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Footer Buttons
  Widget _buildModernFooterButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFooterButton(
              text: 'ชำระเงิน',
              icon: Icons.payments,
              color: Colors.blue[700]!,
              onPressed: () => _handleSave(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFooterButton(
              text: 'เคลียร์',
              icon: Icons.clear_all,
              color: Colors.red,
              onPressed: () {
                setState(() {
                  Global.usedSellDetail = [];
                  resetText();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFooterButton(
              text: 'บันทึก',
              icon: Icons.save,
              color: suBgColor,
              onPressed: () => _handleAddToCart(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddToCart() async {
    if (!_validateFields()) return;

    try {
      saveData();
      if (mounted) {
        resetText();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "เพิ่มลงรถเข็นสำเร็จ...",
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
            action: () {});
      }
    }
  }

  void _handleSave() async {
    if (!_validateFields()) return;

    try {
      saveData();
      if (mounted) {
        resetText();
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WholeSaleCheckOutScreen()))
            .whenComplete(() {
          Future.delayed(const Duration(milliseconds: 500), () async {
            widget.refreshCart(Global.ordersWholesale?.length.toString());
            writeCart();
            setState(() {});
          });
        });
      }
    } catch (e) {
      if (mounted) {
        Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
            action: () {});
      }
    }
  }

  bool _validateFields() {
    if (orderDateCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาป้อนวันที่ใบกำกับภาษี', 'OK');
      return false;
    }

    if (!checkDate(orderDateCtrl.text)) {
      Alert.warning(context, 'คำเตือน', 'วันที่ที่ป้อนมีรูปแบบไม่ถูกต้อง', 'OK',
          action: () {});
      return false;
    }

    if (productEntryWeightCtrl.text.isEmpty ||
        priceIncludeTaxCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเพิ่มข้อมูลก่อน', 'OK',
          action: () {});
      return false;
    }

    if (selectedFromLocation == null) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกคลังสินค้าต้นทาง', 'OK',
          action: () {});
      return false;
    }

    return true;
  }

  // Keep all original calculation and data methods unchanged
  // ฟังก์ชันกลางสำหรับคำนวณ (เพื่อลดการเขียนซ้ำ)
  void calculatePriceDifference() {
    if (purchasePriceCtrl.text.isNotEmpty &&
        priceIncludeTaxCtrl.text.isNotEmpty) {
      double netAmount =
          Global.toNumber(priceIncludeTaxCtrl.text); // จำนวนเงินสุทธิ
      double purchasePrice =
          Global.toNumber(purchasePriceCtrl.text); // หักราคารับซื้อทองประจำวัน
      double result = 0;

      if (netAmount > purchasePrice) {
        // สูตร: (สุทธิ - รับซื้อ) * 100 / 107
        result = (netAmount - purchasePrice) * 100 / 107;
      } else {
        // สูตร: สุทธิ - รับซื้อ
        result = netAmount - purchasePrice;
      }

      priceDiffCtrl.text = Global.format(result);
    } else {
      priceDiffCtrl.text = "";
    }

    getOtherAmount();
  }

// ฟังก์ชันเมื่อมีการเปลี่ยนค่าใน "จำนวนเงินสุทธิ"
  void priceIncludeTaxChanged() {
    calculatePriceDifference();
  }

// ฟังก์ชันเมื่อมีการเปลี่ยนค่าใน "ราคารับซื้อ"
  void purchasePriceChanged() {
    calculatePriceDifference();
  }

  void gramChanged() {
    if (productEntryWeightCtrl.text.isNotEmpty) {
      productEntryWeightBahtCtrl.text = Global.format(
          (Global.toNumber(productEntryWeightCtrl.text) /
              getUnitWeightValue(selectedProduct?.id)));
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
      taxAmountCtrl.text = Global.format(priceDiff * getVatValue());
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
              getUnitWeightValue(selectedProduct?.id));
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
        buyTPrice: Global.toNumber(productSellThengPriceCtrl.text) > 0
            ? Global.toNumber(productSellThengPriceCtrl.text) - 100
            : 0,
        sellPrice: Global.toNumber(productSellPriceCtrl.text),
        buyPrice: Global.toNumber(productBuyPriceCtrl.text),
        weight: Global.toNumber(productEntryWeightCtrl.text),
        weightBath: Global.toNumber(productEntryWeightBahtCtrl.text),
        weightAdj: Global.toNumber(priceAdjCtrl.text),
        weightBathAdj: Global.toNumber(priceAdjCtrl.text) /
            getUnitWeightValue(selectedProduct?.id),
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
        buyTPrice: Global.toNumber(productSellThengPriceCtrl.text) > 0
            ? Global.toNumber(productSellThengPriceCtrl.text) - 100
            : 0,
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
    Global.ordersWholesale?.add(OrderModel.fromJson(data));
    widget.refreshCart(Global.ordersWholesale?.length.toString());
    writeCart();
    Global.usedSellDetail!.clear();
  }
}
