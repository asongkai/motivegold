import 'dart:convert';
import 'dart:io';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masked_text/masked_text.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/wholesale/wholesale_checkout_screen.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/calculator/manager.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/config.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:sizer/sizer.dart';

// Platform-specific imports
import 'package:motivegold/widget/payment/web_file_picker.dart' if (dart.library.io) 'package:motivegold/widget/payment/mobile_file_picker.dart';

class RefillGoldStockScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  int cartCount;

  RefillGoldStockScreen(
      {super.key, required this.refreshCart, required this.cartCount});

  @override
  State<RefillGoldStockScreen> createState() => _RefillGoldStockScreenState();
}

class _RefillGoldStockScreenState extends State<RefillGoldStockScreen> {
  bool loading = false;
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  ProductTypeModel? selectedProductType;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? productTypeNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  TextEditingController productCodeCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  TextEditingController productSellPriceCtrl = TextEditingController();
  TextEditingController productBuyPriceCtrl = TextEditingController();
  TextEditingController productBuyPricePerGramCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  TextEditingController referenceNumberCtrl = TextEditingController();
  TextEditingController remarkCtrl = TextEditingController();

  TextEditingController productSellThengPriceCtrl = TextEditingController();
  TextEditingController productBuyThengPriceCtrl = TextEditingController();

  TextEditingController priceExcludeTaxCtrl = TextEditingController();
  TextEditingController priceIncludeTaxCtrl = TextEditingController();
  TextEditingController priceDiffCtrl = TextEditingController();
  TextEditingController taxBaseCtrl = TextEditingController();
  TextEditingController taxAmountCtrl = TextEditingController();
  TextEditingController purchasePriceCtrl = TextEditingController();

  TextEditingController priceExcludeTaxTotalCtrl = TextEditingController();
  TextEditingController priceIncludeTaxTotalCtrl = TextEditingController();
  TextEditingController priceDiffTotalCtrl = TextEditingController();
  TextEditingController taxBaseTotalCtrl = TextEditingController();
  TextEditingController taxAmountTotalCtrl = TextEditingController();
  TextEditingController purchasePriceTotalCtrl = TextEditingController();

  TextEditingController orderDateCtrl = TextEditingController();
  final boardCtrl = BoardDateTimeController();

  DateTime date = DateTime.now();
  String? txt;
  bool showCal = false;

  FocusNode priceIncludeTaxFocus = FocusNode();
  FocusNode gramFocus = FocusNode();
  FocusNode priceExcludeTaxFocus = FocusNode();
  FocusNode purchasePriceFocus = FocusNode();
  FocusNode priceDiffFocus = FocusNode();
  FocusNode taxAmountFocus = FocusNode();
  FocusNode taxBaseFocus = FocusNode();

  bool priceIncludeTaxReadOnly = false;
  bool gramReadOnly = false;
  bool priceExcludeTaxReadOnly = false;
  bool purchasePriceReadOnly = false;
  bool priceDiffReadOnly = false;
  bool taxAmountReadOnly = false;
  bool taxBaseReadOnly = false;

  @override
  void initState() {
    super.initState();

    // Sample data
    if (env == ENV.DEV) {
      orderDateCtrl.text = "01-06-2025";
      referenceNumberCtrl.text = "90803535";
      productSellThengPriceCtrl.text =
          Global.format(Global.toNumber(Global.goldDataModel?.theng?.sell));
      productBuyThengPriceCtrl.text = "0";
      productSellPriceCtrl.text = "0";
      productBuyPriceCtrl.text =
          Global.format(Global.toNumber(Global.goldDataModel?.paphun?.buy));
      productBuyPricePerGramCtrl.text = Global.format(
          Global.toNumber(productBuyPriceCtrl.text) / getUnitWeightValue());

      productWeightCtrl.text = Global.format(270);
      purchasePriceCtrl.text = Global.format(
          Global.toNumber(productWeightCtrl.text) *
              Global.toNumber(productBuyPricePerGramCtrl.text));
      priceIncludeTaxCtrl.text = Global.format(929918.17);
    }

    Global.appBarColor = rfBgColor;
    productTypeNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(id: 0, name: 'เลือกประเภท'));
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    loadProducts();
    getCart();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
      await ApiServices.post('/product/refill', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        motivePrint(data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
            selectedProduct = productList.where((e) => e.isDefault == 1).first;
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
          '/binlocation/all/type/NEW/5', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        setState(() {
          warehouseList = warehouses;
          selectedWarehouse =
              warehouseList.where((e) => e.isDefault == 1).first;
          warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ??
              WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
        });
      } else {
        warehouseList = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    productCodeCtrl.dispose();
    productNameCtrl.dispose();
    productWeightCtrl.dispose();
    productWeightBahtCtrl.dispose();
    productSellPriceCtrl.dispose();
    productBuyPriceCtrl.dispose();
    warehouseCtrl.dispose();
    referenceNumberCtrl.dispose();
    productSellThengPriceCtrl.dispose();
    productBuyThengPriceCtrl.dispose();
    priceExcludeTaxCtrl.dispose();
    priceIncludeTaxCtrl.dispose();
    priceDiffCtrl.dispose();
    taxBaseCtrl.dispose();
    taxAmountCtrl.dispose();
    purchasePriceCtrl.dispose();
    priceExcludeTaxTotalCtrl.dispose();
    priceIncludeTaxTotalCtrl.dispose();
    priceDiffTotalCtrl.dispose();
    taxBaseTotalCtrl.dispose();
    taxAmountTotalCtrl.dispose();
    purchasePriceTotalCtrl.dispose();
    orderDateCtrl.dispose();
    priceIncludeTaxFocus.dispose();
    gramFocus.dispose();
    priceExcludeTaxFocus.dispose();
    purchasePriceFocus.dispose();
    priceDiffFocus.dispose();
    taxAmountFocus.dispose();
    super.dispose();
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
    if (txt == 'tax_base') {
      taxBaseReadOnly = true;
    }
    if (txt == 'tax_amount') {
      taxAmountReadOnly = true;
    }
    AppCalculatorManager.showCalculator(
      onClose: closeCal,
      onChanged: (key, value, expression) {
        if (key == 'ENT') {
          if (txt == 'gram') {
            productWeightCtrl.text = value != null
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
            priceExcludeTaxChanged();
          }
          if (txt == 'purchase') {
            purchasePriceCtrl.text = value != null
                ? "${Global.format(value)}"
                : "";
          }
          if (txt == 'tax_base') {
            taxBaseCtrl.text = value != null
                ? "${Global.format(value)}"
                : "";
          }
          if (txt == 'tax_amount') {
            taxAmountCtrl.text = value != null
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
    taxBaseReadOnly = false;
    taxAmountReadOnly = false;
    AppCalculatorManager.hideCalculator();
    setState(() {
      showCal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: rfBgColor,
        title: Text(
          'เติมทอง – ซื้อทองรูปพรรณใหม่ 96.5%',
          style: TextStyle(
            fontSize: 16.sp,
            color: textColor,
          ),
        ),
        centerTitle: true,
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
                  color: textColor,
                ),
                Text(
                  'ราคาทองคำ',
                  style: TextStyle(fontSize: 16.sp, color: textColor),
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
                    color: rfBgColorLight,
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
                                        fontSize: 16.sp,
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
                                      fontSize: 16.sp,
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
                                style: TextStyle(
                                    fontSize: 16.sp),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  hintText: 'dd-mm-yyyy',
                                  labelStyle: TextStyle(
                                      fontSize: 16.sp,
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
                                                  String formattedDate =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(date);
                                                  motivePrint(formattedDate);
                                                  setState(() {
                                                    orderDateCtrl.text =
                                                        formattedDate;
                                                  });
                                                },
                                              ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.calendar_today,
                                        size: 40,
                                      )),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Row(children: [ // Space between circle and text
                                    Text('ทองคำแท่งขายออกบาทละ', style: TextStyle(
                                      fontSize: 15.sp, //fontSize,
                                      color: textColor,
                                    ),),
                                  ],),
                                  SizedBox(height: 8,),
                                  buildTextFieldX(
                                    bgColor: Colors.green.shade50,
                                    labelText: "",
                                    inputType: TextInputType.number,
                                    controller: productSellThengPriceCtrl,
                                    fontSize: 16.sp,
                                    inputFormat: [
                                      ThousandsFormatter(
                                          allowFraction: true)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Row(children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.red, // You can change this color
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
                                    SizedBox(width: 8), // Space between circle and text
                                    Text('ทองรูปพรรณรับซื้อกรัมละ', style: TextStyle(
                                      fontSize: 15.sp, //fontSize,
                                      color: textColor,
                                    ),),
                                  ],),
                                  SizedBox(height: 6,),
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
                                      if (value.isNotEmpty) {
                                        productBuyPriceCtrl.text =
                                            Global.format(
                                                Global.toNumber(value) *
                                                    getUnitWeightValue());
                                        gramChanged();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Row(children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.red, // You can change this color
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
                                    SizedBox(width: 8), // Space between circle and text
                                    Text('น้ำหนักรวม (กรัม)', style: TextStyle(
                                      fontSize: 15.sp, //fontSize,
                                      color: textColor,
                                    ),),
                                  ],),
                                  SizedBox(height: 6,),
                                  numberTextField(
                                      labelText: "",
                                      inputType: TextInputType.number,
                                      controller: productWeightCtrl,
                                      focusNode: gramFocus,
                                      readOnly: gramReadOnly,
                                      fontSize: 16.sp,
                                      inputFormat: [
                                        ThousandsFormatter(
                                            allowFraction: true)
                                      ],
                                      clear: () {
                                        setState(() {
                                          productWeightCtrl.text = "";
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
                          ),
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Row(children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.red, // You can change this color
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
                                    SizedBox(width: 8), // Space between circle and text
                                    Text('จำนวนเงินสุทธิ', style: TextStyle(
                                      fontSize: 15.sp, //fontSize,
                                      color: textColor,
                                    ),),
                                  ],),
                                  SizedBox(height: 6,),
                                  numberTextField(
                                      labelText: "",
                                      inputType: TextInputType.phone,
                                      controller: priceIncludeTaxCtrl,
                                      focusNode: priceIncludeTaxFocus,
                                      readOnly: priceIncludeTaxReadOnly,
                                      fontSize: 16.sp,
                                      inputFormat: [
                                        ThousandsFormatter(
                                            allowFraction: true)
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
                                      onFocusChange: (bool value) {
                                        if (!value) {
                                          priceIncludeTaxChanged();
                                        }
                                      }),
                                ],
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
                                    'ราคารวมค่ากำเหน็จก่อนภาษี',
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
                                    ThousandsFormatter(
                                        allowFraction: true)
                                  ],
                                  clear: () {
                                    setState(() {
                                      priceExcludeTaxCtrl.text = "";
                                    });
                                    priceExcludeTaxChanged();
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
                                  onFocusChange: (bool value) {
                                    if (!value) {
                                      priceExcludeTaxChanged();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        child: Row(
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
                                      ThousandsFormatter(
                                          allowFraction: true)
                                    ],
                                    clear: () {
                                      setState(() {
                                        purchasePriceCtrl.text = "";
                                      });
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
                                    onChanged: (String value) {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        child: Row(
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
                                    labelText: "",
                                    inputType: TextInputType.phone,
                                    controller: taxBaseCtrl,
                                    focusNode: taxBaseFocus,
                                    readOnly: taxBaseReadOnly,
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
                                      txt = 'tax_base';
                                      closeCal();
                                    },
                                    openCalc: () {
                                      if (!showCal) {
                                        txt = 'tax_base';
                                        taxBaseFocus.requestFocus();
                                        openCal();
                                      }
                                    },
                                    onChanged: (String value) {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        child: Row(
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
              prefixIcon: Icon(Icons.note_add, color: rfBgColor, size: 20),
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
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
          colors: [rfBgColor, rfBgColor.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: rfBgColor.withOpacity(0.3),
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
                  color: textColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'เลือกรูปภาพ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
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
    if (Global.refillAttach == null && Global.refillAttachWeb == null) {
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
                base64Decode(Global.refillAttachWeb!.split(",").last),
                fit: BoxFit.cover,
              )
                  : Image.file(
                Global.refillAttach!,
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
                      Global.refillAttach = null;
                      Global.refillAttachWeb = null;
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
                  Global.refillOrderDetail = [];
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
              color: rfBgColor,
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
      Alert.warning(context, 'คำเตือน', 'วันที่ที่ป้อนมีรูปแบบไม่ถูกต้อง', 'OK');
      return false;
    }

    if (selectedProduct == null) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกสินค้า', 'OK');
      return false;
    }

    if (selectedWarehouse == null) {
      Alert.warning(context, 'คำเตือน', 'ยังไม่ได้ตั้งค่าโกดังเริ่มต้น', 'OK');
      return false;
    }

    if (productWeightCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณากรอกน้ำหนัก', 'OK');
      return false;
    }

    if (priceExcludeTaxCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณากรอกราคารวมค่ากำเหน็จก่อนภาษี', 'OK');
      return false;
    }

    if (priceIncludeTaxTotalCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณากรอกจำนวนเงินสุทธิ', 'OK');
      return false;
    }

    return true;
  }

  // Keep all the original calculation and data methods unchanged
  void gramChanged() {
    if (productWeightCtrl.text.isNotEmpty &&
        productBuyPricePerGramCtrl.text.isNotEmpty) {
      purchasePriceCtrl.text = Global.format(
          Global.toNumber(productWeightCtrl.text) *
              Global.toNumber(productBuyPricePerGramCtrl.text));
      productWeightBahtCtrl.text = Global.format(
          (Global.toNumber(productWeightCtrl.text) / getUnitWeightValue()));
    } else {
      productWeightBahtCtrl.text = "";
    }
    getOtherAmount();
  }

  void priceIncludeTaxChanged() {
    if (priceIncludeTaxCtrl.text.isNotEmpty &&
        purchasePriceCtrl.text.isNotEmpty) {
      priceDiffCtrl.text = Global.format(
          (Global.toNumber(priceIncludeTaxCtrl.text) -
              Global.toNumber(purchasePriceCtrl.text)));
    } else {
      priceDiffCtrl.text = "";
    }
    getOtherAmount();
  }

  void priceExcludeTaxChanged() {
    getOtherAmount();
  }

  void getOtherAmount() {
    taxBaseCtrl.text = Global.toNumber(priceDiffCtrl.text) < 0
        ? "0"
        : Global.format(Global.toNumber(priceDiffCtrl.text) * 100 / 107);

    double priceDiff = Global.toNumber(priceDiffCtrl.text);
    if (priceDiff <= 0) {
      taxAmountCtrl.text = '0';
    } else {
      taxAmountCtrl.text = Global.format(Global.toNumber(priceDiffCtrl.text) * 7 / 107);
    }

    priceExcludeTaxCtrl.text = Global.format(
        Global.toNumber(priceIncludeTaxCtrl.text) -
            Global.toNumber(taxAmountCtrl.text));

    calTotal();
  }

  void calTotal() {
    purchasePriceTotalCtrl.text = purchasePriceCtrl.text;
    priceIncludeTaxTotalCtrl.text = priceIncludeTaxCtrl.text;
    priceExcludeTaxTotalCtrl.text = priceExcludeTaxCtrl.text;
    taxAmountTotalCtrl.text = taxAmountCtrl.text;
    taxBaseTotalCtrl.text = taxBaseCtrl.text;
    priceDiffTotalCtrl.text = priceDiffCtrl.text;
    setState(() {});
  }

  resetText() {
    productWeightCtrl.text = "";
    priceIncludeTaxCtrl.text = "";
    productWeightBahtCtrl.text = "";
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
    taxBaseCtrl.text = "";
    Global.refillAttach = null;
    Global.refillAttachWeb = null;
    setState(() {});
  }

  final picker = ImagePicker();

  Future getImageFromGallery() async {
    if (!kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          Global.refillAttach = File(pickedFile.path);
        });
      }
    } else {
      try {
        final result = await WebFilePicker.pickImage();
        if (result != null) {
          setState(() {
            Global.refillAttachWeb = result;
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
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          Global.refillAttach = File(pickedFile.path);
        });
      }
    } else {
      Alert.warning(context, "ไม่รองรับ", "การถ่ายภาพจากกล้องบนเว็บยังไม่พร้อมใช้งาน", "OK",
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
              Navigator.of(context).pop();
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('ถ่ายรูป'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  void saveData() {
    Global.refillOrderDetail?.clear();
    Global.refillOrderDetail!.add(OrderDetailModel(
      productName: selectedProduct!.name,
      productId: selectedProduct!.id,
      binLocationId: selectedWarehouse!.id,
      binLocationName: selectedWarehouse!.name,
      sellTPrice: Global.toNumber(productSellThengPriceCtrl.text),
      buyTPrice: Global.toNumber(productBuyThengPriceCtrl.text),
      sellPrice: Global.toNumber(productSellPriceCtrl.text),
      buyPrice: Global.toNumber(productBuyPriceCtrl.text),
      weight: Global.toNumber(productWeightCtrl.text),
      weightBath: Global.toNumber(productWeightBahtCtrl.text),
      commission: 0,
      unitCost: Global.toNumber(priceExcludeTaxCtrl.text) /
          Global.toNumber(productWeightCtrl.text),
      priceIncludeTax: Global.toNumber(priceIncludeTaxCtrl.text),
      priceExcludeTax: Global.toNumber(priceExcludeTaxCtrl.text),
      purchasePrice: Global.toNumber(purchasePriceCtrl.text),
      priceDiff: Global.toNumber(priceDiffCtrl.text),
      taxBase: Global.toNumber(taxBaseCtrl.text),
      taxAmount: Global.toNumber(taxAmountCtrl.text),
    ));

    OrderModel order = OrderModel(
        orderId: "",
        orderDate: Global.convertDate(orderDateCtrl.text),
        details: Global.refillOrderDetail!,
        referenceNo: referenceNumberCtrl.text,
        remark: remarkCtrl.text,
        sellTPrice: Global.toNumber(productSellThengPriceCtrl.text),
        buyTPrice: Global.toNumber(productBuyThengPriceCtrl.text),
        sellPrice: Global.toNumber(productSellPriceCtrl.text),
        buyPrice: Global.toNumber(productBuyPriceCtrl.text),
        priceIncludeTax: Global.toNumber(priceIncludeTaxTotalCtrl.text),
        priceExcludeTax: Global.toNumber(priceExcludeTaxTotalCtrl.text),
        purchasePrice: Global.toNumber(purchasePriceTotalCtrl.text),
        priceDiff: Global.toNumber(priceDiffTotalCtrl.text),
        taxBase: Global.toNumber(taxBaseTotalCtrl.text),
        taxAmount: Global.toNumber(taxAmountTotalCtrl.text),
        attachment: getRefillAttachment(),
        orderTypeId: 5);
    final data = order.toJson();
    Global.ordersWholesale?.add(OrderModel.fromJson(data));
    widget.refreshCart(Global.ordersWholesale?.length.toString());
    writeCart();
    Global.refillOrderDetail!.clear();
  }
}