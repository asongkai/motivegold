import 'dart:convert';
import 'dart:io';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masked_text/masked_text.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/wholesale/wholesale_checkout_screen.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/refill/dialog/refill_dialog.dart';
import 'package:motivegold/utils/calculator/calc.dart';
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

class EditRefillGoldStockScreen extends StatefulWidget {
  final int index;
  final int? j;

  const EditRefillGoldStockScreen({super.key, required this.index, this.j});

  @override
  State<EditRefillGoldStockScreen> createState() =>
      _EditRefillGoldStockScreenState();
}

class _EditRefillGoldStockScreenState extends State<EditRefillGoldStockScreen> {
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
    // implement initState
    super.initState();

    Global.appBarColor = rfBgColor;
    productTypeNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(id: 0, name: 'เลือกประเภท'));
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    loadProducts();
    getCart();

    orderDateCtrl.text = Global.formatDateD(
        Global.ordersWholesale![widget.index].orderDate.toString());
    referenceNumberCtrl.text =
        Global.ordersWholesale![widget.index].referenceNo ?? '';
    productSellThengPriceCtrl.text =
        Global.format(Global.ordersWholesale![widget.index].sellTPrice ?? 0);
    productBuyPriceCtrl.text =
        Global.format(Global.ordersWholesale![widget.index].buyPrice ?? 0);
    productBuyPricePerGramCtrl.text = Global.format(
        Global.toNumber(productBuyPriceCtrl.text) / getUnitWeightValue());

    productWeightCtrl.text = Global.format(
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
    remarkCtrl.text = Global.ordersWholesale![widget.index].remark ?? '';

    priceExcludeTaxChanged();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      // motivePrint(Global.ordersWholesale![widget.index].attachement);
      Global.refillAttach =
          Global.ordersWholesale![widget.index].attachment != null
              ? await Global.createFileFromString(
                  Global.ordersWholesale![widget.index].attachment ?? '')
              : null;
      // var result = await ApiServices.post('/product/type/NEW/5', Global.requestObj(null));
      var result =
          await ApiServices.post('/product/refill', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        // motivePrint(data);
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
      // motivePrint(warehouse?.toJson());
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
    // TODO: implement dispose
    super.dispose();
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
    setState(() {
      showCal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: rfBgColor,
        title: Text(
          'เติมทอง – ซื้อทองรูปพรรณใหม่ 96.5%',
          style: TextStyle(
            fontSize: 16.sp, //size.getWidthPx(10),
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
                  style:
                      TextStyle(fontSize: size.getWidthPx(6), color: textColor),
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
                        // height: size.hp(100),
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
                              height: 10,
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
                                          fontSize: size.getWidthPx(10),
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
                                        fontSize: size.getWidthPx(10),
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
                                          fontSize: size.getWidthPx(12)),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white70,
                                        hintText: 'dd-mm-yyyy',
                                        labelStyle: TextStyle(
                                            fontSize: size.getWidthPx(12),
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
                                  fontSize: size.getWidthPx(12)),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: buildTextFieldX(
                                        bgColor: Colors.green.shade50,
                                        labelText: "ทองคำแท่งขายออกบาทละ",
                                        inputType: TextInputType.number,
                                        controller: productSellThengPriceCtrl,
                                        fontSize: size.getWidthPx(12),
                                        inputFormat: [
                                          ThousandsFormatter(
                                              allowFraction: true)
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
                                        fontSize: size.getWidthPx(12),
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
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: numberTextField(
                                        labelText: "น้ำหนักรวม (กรัม)",
                                        inputType: TextInputType.number,
                                        controller: productWeightCtrl,
                                        focusNode: gramFocus,
                                        readOnly: gramReadOnly,
                                        fontSize: size.getWidthPx(12),
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
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: numberTextField(
                                        labelText: "จำนวนเงินสุทธิ",
                                        inputType: TextInputType.phone,
                                        controller: priceIncludeTaxCtrl,
                                        focusNode: priceIncludeTaxFocus,
                                        readOnly: priceIncludeTaxReadOnly,
                                        fontSize: size.getWidthPx(12),
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
                                              fontSize: size.getWidthPx(10),
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
                                              fontSize: size.getWidthPx(10),
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
                                              fontSize: size.getWidthPx(10),
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
                                              fontSize: size.getWidthPx(10),
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
                            SizedBox(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: buildTextFieldX(
                                        labelText: "หมายเหตุ",
                                        inputType: TextInputType.text,
                                        controller: remarkCtrl,
                                        fontSize: size.getWidthPx(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Attachment
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'แนบไฟล์ใบส่งสินค้า/ใบกำกับภาษี',
                                style: TextStyle(
                                    fontSize: size.getWidthPx(12),
                                    color: textColor),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: size?.wp(30),
                                child: ElevatedButton.icon(
                                  onPressed: showOptions,
                                  icon: const Icon(
                                    Icons.add_a_photo_outlined,
                                  ),
                                  label: Text(
                                    'เลือกรูปภาพ',
                                    style:
                                        TextStyle(fontSize: size.getWidthPx(8)),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Global.refillAttach == null
                                    ? Text(
                                        'ไม่ได้เลือกรูปภาพ',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(10)),
                                      )
                                    : SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4,
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.file(
                                                  Global.refillAttach!),
                                            ),
                                            Positioned(
                                              right: 0.0,
                                              top: 0.0,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    Global.refillAttach = null;
                                                  });
                                                },
                                                child: const CircleAvatar(
                                                  backgroundColor: Colors.red,
                                                  child: Icon(Icons.close),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
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
                                        productWeightCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                        gramChanged();
                                      }
                                      if (txt == 'price_include') {
                                        priceIncludeTaxCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
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
            color: rfBgColorLight,
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
                          Global.refillOrderDetail = [];
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
                            style: TextStyle(fontSize: size.getWidthPx(10)),
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
                        backgroundColor: rfBgColor,
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

                        if (selectedProduct == null) {
                          Alert.warning(
                              context, 'คำเตือน', 'กรุณาเลือกสินค้า', 'OK',
                              action: () {});
                          return;
                        }

                        if (selectedWarehouse == null) {
                          Alert.warning(context, 'คำเตือน',
                              'ยังไม่ได้ตั้งค่าโกดังเริ่มต้น', 'OK',
                              action: () {});
                          return;
                        }

                        if (productWeightCtrl.text.isEmpty) {
                          Alert.warning(
                              context, 'คำเตือน', 'กรุณากรอกน้ำหนัก', 'OK',
                              action: () {});
                          return;
                        }

                        if (priceExcludeTaxCtrl.text.isEmpty) {
                          Alert.warning(context, 'คำเตือน',
                              'ราคารวมค่ากำเหน็จก่อนภาษี', 'OK',
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
                              //
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
                          const Icon(
                            Icons.save,
                            color: textColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'บันทึก',
                            style: TextStyle(
                                fontSize: size.getWidthPx(10),
                                color: textColor),
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
    setState(() {});
  }

  final picker = ImagePicker();

  //Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        Global.refillAttach = File(pickedFile.path);
      }
    });
  }

//Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        Global.refillAttach = File(pickedFile.path);
      }
    });
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
        attachment: Global.refillAttach != null
            ? Global.imageToBase64(Global.refillAttach!)
            : null,
        orderTypeId: 5);
    final data = order.toJson();
    Global.ordersWholesale?[widget.index] = OrderModel.fromJson(data);
    writeCart();
    Global.refillOrderDetail!.clear();
  }
}
