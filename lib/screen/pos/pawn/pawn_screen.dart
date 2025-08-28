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

class PawnScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  int cartCount;

  PawnScreen({super.key, required this.refreshCart, required this.cartCount});

  @override
  State<PawnScreen> createState() => _PawnScreenState();
}

class _PawnScreenState extends State<PawnScreen> {
  bool loading = false;
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  ProductTypeModel? selectedProductType;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? productTypeNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  TextEditingController orderDateCtrl = TextEditingController();
  TextEditingController customerNameCtrl = TextEditingController();
  TextEditingController customerPhoneCtrl = TextEditingController();
  TextEditingController customerIdCardCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController goldPriceCtrl = TextEditingController();
  TextEditingController loanAmountCtrl = TextEditingController();
  TextEditingController interestRateCtrl = TextEditingController();
  TextEditingController monthlyInterestCtrl = TextEditingController();
  TextEditingController contractMonthsCtrl = TextEditingController();
  TextEditingController totalInterestCtrl = TextEditingController();
  TextEditingController totalAmountCtrl = TextEditingController();
  TextEditingController remarkCtrl = TextEditingController();

  final boardCtrl = BoardDateTimeController();

  DateTime date = DateTime.now();
  String? txt;
  bool showCal = false;
  String? vatOption = 'Include';

  FocusNode goldPriceFocus = FocusNode();
  FocusNode weightFocus = FocusNode();
  FocusNode loanAmountFocus = FocusNode();
  FocusNode interestRateFocus = FocusNode();
  FocusNode contractMonthsFocus = FocusNode();

  bool goldPriceReadOnly = false;
  bool weightReadOnly = false;
  bool loanAmountReadOnly = false;
  bool interestRateReadOnly = false;
  bool contractMonthsReadOnly = false;

  @override
  void initState() {
    super.initState();

    // Sample data for development
    if (env == ENV.DEV) {
      orderDateCtrl.text = "01-06-2025";
      customerNameCtrl.text = "สมชาย ใจดี";
      customerPhoneCtrl.text = "0812345678";
      customerIdCardCtrl.text = "1234567890123";
      productNameCtrl.text = "สร้อยคอทอง";
      productWeightCtrl.text = "15.20";
      goldPriceCtrl.text = "40,000";
      loanAmountCtrl.text = "500,000";
      interestRateCtrl.text = "2.5";
      contractMonthsCtrl.text = "12";
    }

    Global.appBarColor = rfBgColor;
    productTypeNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(id: 0, name: 'เลือกประเภท'));
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    loadProducts();
    calculateInterest();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
      await ApiServices.post('/product/pawn', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
            selectedProduct = productList.where((e) => e.isDefault == 1).first;
            productNotifier = ValueNotifier<ProductModel>(
                selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
          }
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/type/PAWN/5', Global.requestObj(null));
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
    orderDateCtrl.dispose();
    customerNameCtrl.dispose();
    customerPhoneCtrl.dispose();
    customerIdCardCtrl.dispose();
    productNameCtrl.dispose();
    productWeightCtrl.dispose();
    goldPriceCtrl.dispose();
    loanAmountCtrl.dispose();
    interestRateCtrl.dispose();
    monthlyInterestCtrl.dispose();
    contractMonthsCtrl.dispose();
    totalInterestCtrl.dispose();
    totalAmountCtrl.dispose();
    remarkCtrl.dispose();
    goldPriceFocus.dispose();
    weightFocus.dispose();
    loanAmountFocus.dispose();
    interestRateFocus.dispose();
    contractMonthsFocus.dispose();
    super.dispose();
  }

  void openCal() {
    if (txt == 'weight') {
      weightReadOnly = true;
    }
    if (txt == 'gold_price') {
      goldPriceReadOnly = true;
    }
    if (txt == 'loan_amount') {
      loanAmountReadOnly = true;
    }
    if (txt == 'interest_rate') {
      interestRateReadOnly = true;
    }
    if (txt == 'contract_months') {
      contractMonthsReadOnly = true;
    }

    AppCalculatorManager.showCalculator(
      onClose: closeCal,
      onChanged: (key, value, expression) {
        if (key == 'ENT') {
          if (txt == 'weight') {
            productWeightCtrl.text = value != null ? "${Global.format(value)}" : "";
          }
          if (txt == 'gold_price') {
            goldPriceCtrl.text = value != null ? "${Global.format(value)}" : "";
          }
          if (txt == 'loan_amount') {
            loanAmountCtrl.text = value != null ? "${Global.format(value)}" : "";
          }
          if (txt == 'interest_rate') {
            interestRateCtrl.text = value != null ? "${Global.format(value)}" : "";
          }
          if (txt == 'contract_months') {
            contractMonthsCtrl.text = value != null ? "${Global.format(value)}" : "";
          }
          calculateInterest();
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
    weightReadOnly = false;
    goldPriceReadOnly = false;
    loanAmountReadOnly = false;
    interestRateReadOnly = false;
    contractMonthsReadOnly = false;
    AppCalculatorManager.hideCalculator();
    setState(() {
      showCal = false;
    });
  }

  void calculateInterest() {
    if (loanAmountCtrl.text.isNotEmpty &&
        interestRateCtrl.text.isNotEmpty &&
        contractMonthsCtrl.text.isNotEmpty) {

      double loanAmount = Global.toNumber(loanAmountCtrl.text);
      double interestRate = Global.toNumber(interestRateCtrl.text) / 100;
      double months = Global.toNumber(contractMonthsCtrl.text);

      double monthlyInterest = loanAmount * interestRate;
      double totalInterest = monthlyInterest * months;
      double totalAmount = loanAmount + totalInterest;

      monthlyInterestCtrl.text = Global.format(monthlyInterest);
      totalInterestCtrl.text = Global.format(totalInterest);
      totalAmountCtrl.text = Global.format(totalAmount);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF8E24AA), // Purple color from screenshot
        title: Text(
          'ขายฝาก',
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
                  color: Colors.white,
                ),
                Text(
                  'ราคาทองคำ',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                )
              ],
            ),
          ),
          const SizedBox(width: 20)
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFF3E5F5), // Light purple background
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // VAT Option Toggle (like in redeem screen)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  vatOption = 'Include';
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: vatOption == 'Include'
                                      ? const Color(0xFF8E24AA)
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      vatOption == 'Include' ? Icons.radio_button_checked : Icons.radio_button_off,
                                      color: vatOption == 'Include' ? Colors.white : Colors.grey[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Include',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: vatOption == 'Include'
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(width: 1, height: 56, color: Colors.grey[200]),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  vatOption = 'Exclude';
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: vatOption == 'Exclude'
                                      ? const Color(0xFF8E24AA)
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      vatOption == 'Exclude' ? Icons.radio_button_checked : Icons.radio_button_off,
                                      color: vatOption == 'Exclude' ? Colors.white : Colors.grey[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Exclude',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: vatOption == 'Exclude'
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Date and Customer Info Section
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('วันที่', style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
                              const SizedBox(height: 6),
                              MaskedTextField(
                                controller: orderDateCtrl,
                                mask: "##-##-####",
                                maxLength: 10,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: 16.sp),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'dd-mm-yyyy',
                                  prefixIcon: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => SfDatePickerDialog(
                                          initialDate: DateTime.now(),
                                          onDateSelected: (date) {
                                            String formattedDate = DateFormat('dd-MM-yyyy').format(date);
                                            setState(() {
                                              orderDateCtrl.text = formattedDate;
                                            });
                                          },
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.calendar_today, size: 20),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('เลขที่ใบขายฝาก', style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8E24AA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add, color: Colors.white, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ค้นหา',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
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

                  const SizedBox(height: 15),

                  // Customer Information
                  buildTextFieldX(
                    labelText: "ชื่อ / นามสกุล",
                    inputType: TextInputType.text,
                    enabled: true,
                    controller: customerNameCtrl,
                    fontSize: 16.sp,
                  ),

                  const SizedBox(height: 10),

                  buildTextFieldX(
                    labelText: "โทรศัพท์",
                    inputType: TextInputType.phone,
                    enabled: true,
                    controller: customerPhoneCtrl,
                    fontSize: 16.sp,
                  ),

                  const SizedBox(height: 15),

                  // Gold Information Section
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ดีงโก๊กหนัก (บล็อง)', style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              ),
                                            ),
                                            child: const Text('-'),
                                          ),
                                          const Expanded(
                                            child: SizedBox(),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: const BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                            ),
                                            child: const Text('+'),
                                          ),
                                        ],
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('กำหนดไถ่ถอน', style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
                              const SizedBox(height: 6),
                              buildTextFieldX(
                                labelText: "",
                                inputType: TextInputType.text,
                                enabled: true,
                                controller: TextEditingController(),
                                fontSize: 16.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Weight and Price Section
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8E24AA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'น้ำหนักทอง (กรัม)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              numberTextField(
                                labelText: "",
                                inputType: TextInputType.number,
                                controller: productWeightCtrl,
                                focusNode: weightFocus,
                                readOnly: weightReadOnly,
                                fontSize: 16.sp,
                                inputFormat: [ThousandsFormatter(allowFraction: true)],
                                clear: () {
                                  setState(() {
                                    productWeightCtrl.text = "";
                                  });
                                },
                                onTap: () {
                                  txt = 'weight';
                                  closeCal();
                                },
                                openCalc: () {
                                  if (!showCal) {
                                    txt = 'weight';
                                    weightFocus.requestFocus();
                                    openCal();
                                  }
                                },
                                onChanged: (String value) {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8E24AA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'น้ำหนักรวม (กรัม)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              buildTextFieldX(
                                labelText: "",
                                inputType: TextInputType.number,
                                enabled: false,
                                controller: TextEditingController(),
                                fontSize: 16.sp,
                                bgColor: Colors.grey[200],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Loan Amount Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E24AA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'จำนวนขายฝาก (บาท)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        numberTextField(
                          labelText: "",
                          inputType: TextInputType.number,
                          controller: loanAmountCtrl,
                          focusNode: loanAmountFocus,
                          readOnly: loanAmountReadOnly,
                          fontSize: 16.sp,
                          inputFormat: [ThousandsFormatter(allowFraction: true)],
                          clear: () {
                            setState(() {
                              loanAmountCtrl.text = "";
                            });
                            calculateInterest();
                          },
                          onTap: () {
                            txt = 'loan_amount';
                            closeCal();
                          },
                          openCalc: () {
                            if (!showCal) {
                              txt = 'loan_amount';
                              loanAmountFocus.requestFocus();
                              openCal();
                            }
                          },
                          onChanged: (String value) {
                            calculateInterest();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Interest Information
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: buildTextFieldX(
                            labelText: "วิธีคิดดอกเบี้ย",
                            inputType: TextInputType.text,
                            enabled: false,
                            controller: TextEditingController(text: "เงินต้น"),
                            fontSize: 16.sp,
                            bgColor: Colors.grey[200],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: buildTextFieldX(
                            labelText: "อัตราการคิดดอกเบี้ย",
                            inputType: TextInputType.text,
                            enabled: false,
                            controller: TextEditingController(text: "ร้อยละเดือนรวม"),
                            fontSize: 16.sp,
                            bgColor: Colors.grey[200],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Interest Rate and Contract Period
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ประเภททอง /%ทอง', style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
                              const SizedBox(height: 6),
                              numberTextField(
                                labelText: "",
                                inputType: TextInputType.number,
                                controller: interestRateCtrl,
                                focusNode: interestRateFocus,
                                readOnly: interestRateReadOnly,
                                fontSize: 16.sp,
                                inputFormat: [ThousandsFormatter(allowFraction: true)],
                                clear: () {
                                  setState(() {
                                    interestRateCtrl.text = "";
                                  });
                                  calculateInterest();
                                },
                                onTap: () {
                                  txt = 'interest_rate';
                                  closeCal();
                                },
                                openCalc: () {
                                  if (!showCal) {
                                    txt = 'interest_rate';
                                    interestRateFocus.requestFocus();
                                    openCal();
                                  }
                                },
                                onChanged: (String value) {
                                  calculateInterest();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8E24AA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'ผลประโยชน์ตอบแทนที่ดอกลอง',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              buildTextFieldX(
                                labelText: "",
                                inputType: TextInputType.number,
                                enabled: false,
                                controller: monthlyInterestCtrl,
                                fontSize: 16.sp,
                                bgColor: Colors.grey[200],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Category Selection (like in screenshot)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'หมวด',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: true,
                                onChanged: (value) {},
                                title: Text('สร้อย', style: TextStyle(fontSize: 14.sp)),
                                controlAffinity: ListTileControlAffinity.leading,
                                dense: true,
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                value: false,
                                onChanged: (value) {},
                                title: Text('แหวน', style: TextStyle(fontSize: 14.sp)),
                                controlAffinity: ListTileControlAffinity.leading,
                                dense: true,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: false,
                                onChanged: (value) {},
                                title: Text('ต่างหู/จี้', style: TextStyle(fontSize: 14.sp)),
                                controlAffinity: ListTileControlAffinity.leading,
                                dense: true,
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                value: false,
                                onChanged: (value) {},
                                title: Text('อื่นๆ', style: TextStyle(fontSize: 14.sp)),
                                controlAffinity: ListTileControlAffinity.leading,
                                dense: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Remarks Section
                  _buildModernRemarks(),

                  const SizedBox(height: 20),

                  // Attachment Section
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
              prefixIcon: Icon(Icons.note_add, color: const Color(0xFF8E24AA), size: 20),
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

  Widget _buildModernAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'แนบไฟล์',
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
          colors: [const Color(0xFF8E24AA), const Color(0xFF8E24AA).withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E24AA).withOpacity(0.3),
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
    if (Global.pawnAttach == null && Global.pawnAttachWeb == null) {
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
                base64Decode(Global.pawnAttachWeb!.split(",").last),
                fit: BoxFit.cover,
              )
                  : Image.file(
                Global.pawnAttach!,
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
                      Global.pawnAttach = null;
                      Global.pawnAttachWeb = null;
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
              text: '+ เพิ่ม',
              icon: Icons.add,
              color: Colors.blue[700]!,
              onPressed: () => _handleAddToCart(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFooterButton(
              text: 'x เคลียร์',
              icon: Icons.clear_all,
              color: Colors.red,
              onPressed: () {
                resetText();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFooterButton(
              text: 'บันทึก',
              icon: Icons.save,
              color: const Color(0xFF8E24AA),
              onPressed: () => _handleSave(),
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
            backgroundColor: const Color(0xFF8E24AA),
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
        // Navigate to pawn checkout screen
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const WholeSaleCheckOutScreen()))
            .whenComplete(() {
          Future.delayed(const Duration(milliseconds: 500), () async {
            widget.refreshCart(Global.pawnOrders?.length.toString());
            writePawnCart();
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
      Alert.warning(context, 'คำเตือน', 'กรุณาป้อนวันที่', 'OK');
      return false;
    }

    if (!checkDate(orderDateCtrl.text)) {
      Alert.warning(context, 'คำเตือน', 'วันที่ที่ป้อนมีรูปแบบไม่ถูกต้อง', 'OK');
      return false;
    }

    if (customerNameCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณากรอกชื่อลูกค้า', 'OK');
      return false;
    }

    if (productWeightCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณากรอกน้ำหนักทอง', 'OK');
      return false;
    }

    if (loanAmountCtrl.text.isEmpty) {
      Alert.warning(context, 'คำเตือน', 'กรุณากรอกจำนวนขายฝาก', 'OK');
      return false;
    }

    return true;
  }

  void saveData() {
    // Implementation similar to refill screen's saveData method
    // This would save pawn transaction data
    Global.pawnOrderDetail?.clear();
    // Add pawn order details here...

    OrderModel order = OrderModel(
        orderId: "",
        orderDate: Global.convertDate(orderDateCtrl.text),
        details: Global.pawnOrderDetail!,
        remark: remarkCtrl.text,
        attachment: getPawnAttachment(),
        orderTypeId: 6); // Pawn type ID
    final data = order.toJson();
    Global.pawnOrders?.add(OrderModel.fromJson(data));
    widget.refreshCart(Global.pawnOrders?.length.toString());
    writePawnCart();
    Global.pawnOrderDetail!.clear();
  }

  resetText() {
    orderDateCtrl.text = "";
    customerNameCtrl.text = "";
    customerPhoneCtrl.text = "";
    customerIdCardCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    goldPriceCtrl.text = "";
    loanAmountCtrl.text = "";
    interestRateCtrl.text = "";
    monthlyInterestCtrl.text = "";
    contractMonthsCtrl.text = "";
    totalInterestCtrl.text = "";
    totalAmountCtrl.text = "";
    remarkCtrl.text = "";
    Global.pawnAttach = null;
    Global.pawnAttachWeb = null;
    setState(() {});
  }

  final picker = ImagePicker();

  Future getImageFromGallery() async {
    if (!kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          Global.pawnAttach = File(pickedFile.path);
        });
      }
    } else {
      try {
        final result = await WebFilePicker.pickImage();
        if (result != null) {
          setState(() {
            Global.pawnAttachWeb = result;
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
          Global.pawnAttach = File(pickedFile.path);
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

  String? getPawnAttachment() {
    if (kIsWeb && Global.pawnAttachWeb != null) {
      return Global.pawnAttachWeb!.split(",").last;
    } else if (!kIsWeb && Global.pawnAttach != null) {
      return base64Encode(Global.pawnAttach!.readAsBytesSync());
    }
    return null;
  }

  // Placeholder functions - these would need to be implemented based on your app's cart system
  void writePawnCart() {
    // Implementation for writing pawn cart data
  }

  void getCart() {
    // Implementation for getting cart data
  }
}