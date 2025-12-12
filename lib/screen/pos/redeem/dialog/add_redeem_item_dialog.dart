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
import 'package:motivegold/model/redeem/redeem_detail.dart';
import 'package:motivegold/screen/gold/gold_mini_widget.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/wholesale/wholesale_checkout_screen.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/calculator/manager.dart';
import 'package:motivegold/utils/cart/cart.dart';
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
import 'package:motivegold/widget/appbar/appbar.dart' show CustomAppBar;
import 'package:motivegold/widget/appbar/title_content.dart' show TitleContent;
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/ui/text_header.dart';
import 'package:sizer/sizer.dart';

class AddRedeemItemDialog extends StatefulWidget {
  const AddRedeemItemDialog({super.key, required this.vatOption});

  final String vatOption;

  @override
  State<AddRedeemItemDialog> createState() => _AddRedeemItemDialogState();
}

class _AddRedeemItemDialogState extends State<AddRedeemItemDialog> {
  bool loading = false;
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  ProductTypeModel? selectedProductType;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? productTypeNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  TextEditingController weightGramCtrl = TextEditingController();
  TextEditingController weightBahtCtrl = TextEditingController();

  TextEditingController referenceNumberCtrl = TextEditingController();

  TextEditingController redeemValueCtrl = TextEditingController();
  TextEditingController depositAmountCtrl = TextEditingController();
  TextEditingController benefitReceiveCtrl = TextEditingController();
  TextEditingController benefitTotalCtrl = TextEditingController();

  TextEditingController orderDateCtrl = TextEditingController();
  final boardCtrl = BoardDateTimeController();

  double totalAmount = 0;

  DateTime date = DateTime.now();
  String? txt;

  FocusNode depositAmountFocus = FocusNode();
  FocusNode gramFocus = FocusNode();
  FocusNode redemptionValueFocus = FocusNode();
  FocusNode benefitReceiveFocus = FocusNode();
  FocusNode benefitTotalFocus = FocusNode();
  FocusNode priceDiffFocus = FocusNode();
  FocusNode taxAmountFocus = FocusNode();

  bool depositAmountReadOnly = false;
  bool gramReadOnly = false;
  bool redemptionValueReadOnly = false;
  bool benefitReceiveReadOnly = false;
  bool benefitTotalReadOnly = false;
  bool priceDiffReadOnly = false;
  bool taxAmountReadOnly = false;

  @override
  void initState() {
    // implement initState
    super.initState();

    // Sample data
    // referenceNumberCtrl.text = "90803535";
    // orderDateCtrl.text = "01-02-2025";
    // referenceNumberCtrl.text = "90803535";
    // redeemValueCtrl.text = Global.format(54500);
    // depositAmountCtrl.text = Global.format(50500);
    // weightGramCtrl.text = Global.format(15.16);
    Global.appBarColor = rfBgColor;
    selectedProduct = Global.productList
        .where((e) => e.type == 'NEW')
        .cast<ProductModel?>()
        .firstOrNull;
    // motivePrint(selectedProduct?.toJson());
    redeemValueChanged();
    getCart();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    weightGramCtrl.dispose();
    weightBahtCtrl.dispose();
    referenceNumberCtrl.dispose();
    redeemValueCtrl.dispose();
    depositAmountCtrl.dispose();
    benefitReceiveCtrl.dispose();
    benefitTotalCtrl.dispose();
    orderDateCtrl.dispose();
    depositAmountFocus.dispose();
    gramFocus.dispose();
    redemptionValueFocus.dispose();
    benefitReceiveFocus.dispose();
    benefitTotalFocus.dispose();
    priceDiffFocus.dispose();
    taxAmountFocus.dispose();
  }

  void openCal() {
    if (txt == 'purchase') {
      benefitReceiveReadOnly = true;
    }
    if (txt == 'gram') {
      gramReadOnly = true;
    }
    if (txt == 'price_include') {
      depositAmountReadOnly = true;
    }
    if (txt == 'price_exclude') {
      redemptionValueReadOnly = true;
    }
    if (txt == 'price_diff') {
      priceDiffReadOnly = true;
    }
    if (txt == 'tax_amount') {
      taxAmountReadOnly = true;
    }
    AppCalculatorManager.showCalculator(
      inputTarget: txt,
      onClose: closeCal,
      onChanged: (key, value, expression) {
        if (key == 'ENT') {
          if (txt == 'gram') {
            weightGramCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            gramChanged();
          }
          if (txt == 'deposit_amount') {
            depositAmountCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            depositAmountChanged();
          }
          if (txt == 'redemption_value') {
            redeemValueCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            redeemValueChanged();
          }
          if (txt == 'benefit_receive') {
            benefitReceiveCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            benefitReceiveChanged();
          }
          if (txt == 'benefit_total') {
            benefitTotalCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            benefitTotalChanged();
          }
          FocusScope.of(context).requestFocus(FocusNode());
          closeCal();
        }
        if (kDebugMode) {
          print('$key\t$value\t$expression');
        }
      },
    );
    setState(() {});
  }

  void closeCal() {
    benefitReceiveReadOnly = false;
    gramReadOnly = false;
    depositAmountReadOnly = false;
    redemptionValueReadOnly = false;
    priceDiffReadOnly = false;
    taxAmountReadOnly = false;
    AppCalculatorManager.hideCalculator();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: const CustomAppBar(
        height: 220,
        hasChild: false,
        child: TitleContent(
          backButton: true,
        ),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      posHeaderText(
                          context, stmBgColor, 'ธุรกรรมไถ่ถอน - ขายฝาก'),
                      if (selectedProduct != null)
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: GoldMiniWidget(
                            product: selectedProduct!,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child: SizedBox(
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'เลขที่ขายฝาก',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 16.sp, color: textColor),
                                    ),
                                  )),
                              Expanded(
                                flex: 4,
                                child: buildTextFieldBig(
                                    labelText: "",
                                    inputType: TextInputType.text,
                                    enabled: true,
                                    controller: referenceNumberCtrl,
                                    fontSize: 18.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child: SizedBox(
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'น้ำหนักรวม (กรัม)',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 16.sp, color: textColor),
                                    ),
                                  )),
                              Expanded(
                                flex: 4,
                                child: numberTextField(
                                    labelText: "",
                                    inputType: TextInputType.number,
                                    controller: weightGramCtrl,
                                    focusNode: gramFocus,
                                    readOnly: gramReadOnly,
                                    fontSize: 18.sp,
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                    clear: () {
                                      setState(() {
                                        weightGramCtrl.text = "";
                                      });
                                      gramChanged();
                                    },
                                    onTap: () {
                                      txt = 'gram';
                                      closeCal();
                                    },
                                    openCalc: () {
                                      txt = 'gram';
                                      gramFocus.requestFocus();
                                      openCal();
                                    },
                                    onChanged: (String value) {
                                      gramChanged();
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child: SizedBox(
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'มูลค่าขายฝาก',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 16.sp, color: textColor),
                                    ),
                                  )),
                              Expanded(
                                flex: 4,
                                child: numberTextField(
                                    labelText: "",
                                    inputType: TextInputType.phone,
                                    controller: depositAmountCtrl,
                                    focusNode: depositAmountFocus,
                                    readOnly: depositAmountReadOnly,
                                    fontSize: 18.sp,
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                    clear: () {
                                      setState(() {
                                        depositAmountCtrl.text = "";
                                      });
                                      depositAmountChanged();
                                    },
                                    onTap: () {
                                      txt = 'deposit_amount';
                                      closeCal();
                                    },
                                    openCalc: () {
                                      txt = 'deposit_amount';
                                      depositAmountFocus.requestFocus();
                                      openCal();
                                    },
                                    onFocusChange: (bool value) {
                                      if (!value) {
                                        depositAmountChanged();
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child: SizedBox(
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'มูลค่าสินไถ่',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 16.sp, color: textColor),
                                    ),
                                  )),
                              Expanded(
                                flex: 4,
                                child: numberTextField(
                                  labelText: "",
                                  inputType: TextInputType.phone,
                                  controller: redeemValueCtrl,
                                  focusNode: redemptionValueFocus,
                                  readOnly: redemptionValueReadOnly,
                                  fontSize: 18.sp,
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                  clear: () {
                                    setState(() {
                                      redeemValueCtrl.text = "";
                                    });
                                    redeemValueChanged();
                                  },
                                  onTap: () {
                                    txt = 'redemption_value';
                                    closeCal();
                                  },
                                  openCalc: () {
                                    txt = 'redemption_value';
                                    redemptionValueFocus.requestFocus();
                                    openCal();
                                  },
                                  onFocusChange: (bool value) {
                                    if (!value) {
                                      redeemValueChanged();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.vatOption == 'Include')
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16),
                          child: SizedBox(
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'ผลประโยชน์รวม',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 16.sp, color: textColor),
                                      ),
                                    )),
                                Expanded(
                                  flex: 4,
                                  child: numberTextField(
                                    labelText: "",
                                    inputType: TextInputType.phone,
                                    controller: benefitTotalCtrl,
                                    focusNode: benefitTotalFocus,
                                    readOnly: benefitTotalReadOnly,
                                    fontSize: 18.sp,
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                    clear: () {
                                      setState(() {
                                        benefitTotalCtrl.text = "";
                                      });
                                      benefitTotalChanged();
                                    },
                                    onTap: () {
                                      txt = 'benefit_total';
                                      closeCal();
                                    },
                                    openCalc: () {
                                      txt = 'benefit_total';
                                      benefitTotalFocus.requestFocus();
                                      openCal();
                                    },
                                    onFocusChange: (bool value) {
                                      if (!value) {
                                        benefitTotalChanged();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child: SizedBox(
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'ผลประโยชน์ที่รับวันนี้',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 16.sp, color: textColor),
                                    ),
                                  )),
                              Expanded(
                                flex: 4,
                                child: numberTextField(
                                  labelText: "",
                                  inputType: TextInputType.phone,
                                  controller: benefitReceiveCtrl,
                                  focusNode: benefitReceiveFocus,
                                  readOnly: benefitReceiveReadOnly,
                                  fontSize: 18.sp,
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                  clear: () {
                                    setState(() {
                                      benefitReceiveCtrl.text = "";
                                    });
                                    benefitReceiveChanged();
                                  },
                                  onTap: () {
                                    txt = 'benefit_receive';
                                    closeCal();
                                  },
                                  openCalc: () {
                                    txt = 'benefit_receive';
                                    benefitReceiveFocus.requestFocus();
                                    openCal();
                                  },
                                  onFocusChange: (bool value) {
                                    if (!value) {
                                      benefitReceiveChanged();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFB22222),
                                        // Dark red border like in the image
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'จำนวนเงินรวมที่ลูกค้าต้องชำระ (บาท)',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(
                                                0xFF1A237E), // Dark blue color for text
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${Global.format(totalAmount)}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: Color(
                                                    0xFF1A237E), // Dark blue color for amount
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth: double.infinity, minHeight: 60),
                  child: MaterialButton(
                    color: Colors.redAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            "ยกเลิก",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth: double.infinity, minHeight: 60),
                  child: MaterialButton(
                    color: stmBgColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.save,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            "บันทึก",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () async {
                      if (weightGramCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณาใส่น้ำหนัก', 'OK');
                        return;
                      }

                      if (depositAmountCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณากรอกมูลค่าขายฝาก', 'OK');
                        return;
                      }

                      if (redeemValueCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณากรอกมูลค่าสินไถ่', 'OK');
                        return;
                      }

                      if (referenceNumberCtrl.text.isEmpty) {
                        Alert.info(
                            context, 'ต้องการบันทึกข้อมูลหรือไม่?', 'ไม่มีการระบุเลขที่ขายฝาก ต้องการบันทึกหรือไม่', 'ตกลง',
                            action: () async {
                          saveRedeemItem();
                        });
                        return;
                      }

                      Alert.info(
                          context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                          action: () async {
                        saveRedeemItem();
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void saveRedeemItem() {
    Global.redeemSingleDetail!.add(
      RedeemDetailModel.fromJson(
        jsonDecode(
          jsonEncode(
            RedeemDetailModel(
              productId: selectedProduct?.id,
              weight: Global.toNumber(weightGramCtrl.text),
              weightBath: Global.toNumber(weightBahtCtrl.text),
              taxBase: Global.toNumber(redeemValueCtrl.text) -
                  Global.toNumber(depositAmountCtrl.text),
              taxAmount: (Global.toNumber(redeemValueCtrl.text) -
                      Global.toNumber(depositAmountCtrl.text)) *
                  getVatValue(),
              depositAmount: Global.toNumber(depositAmountCtrl.text),
              redemptionValue: Global.toNumber(redeemValueCtrl.text),
              redemptionVat: ((Global.toNumber(redeemValueCtrl.text) -
                          Global.toNumber(depositAmountCtrl.text)) *
                      getVatValue()) +
                  Global.toNumber(redeemValueCtrl.text),
              benefitAmount: Global.toNumber(benefitReceiveCtrl.text) != 0
                  ? Global.toNumber(benefitReceiveCtrl.text)
                  : Global.toNumber(redeemValueCtrl.text) -
                      Global.toNumber(depositAmountCtrl.text),
              paymentAmount: totalAmount,
              taxBaseAmount: widget.vatOption == 'Include'
                  ? Global.toNumber(benefitTotalCtrl.text)
                  : (Global.toNumber(redeemValueCtrl.text) -
                      Global.toNumber(depositAmountCtrl.text) +
                      (Global.toNumber(redeemValueCtrl.text) -
                              Global.toNumber(depositAmountCtrl.text)) *
                          getVatValue()),
              qty: 1,
              referenceNo: referenceNumberCtrl.text,
              vatOption: widget.vatOption,
            ),
          ),
        ),
      ),
    );
    setState(() {});
    Navigator.of(context).pop();
  }

  void gramChanged() {
    if (weightGramCtrl.text.isNotEmpty) {
      weightBahtCtrl.text = Global.format(
          (Global.toNumber(weightGramCtrl.text) /
              getUnitWeightValue(selectedProduct?.id)));
    } else {
      weightBahtCtrl.text = "";
    }
    getOtherAmount();
  }

  void depositAmountChanged() {
    if (widget.vatOption == 'Include' &&
        benefitTotalCtrl.text.isNotEmpty &&
        depositAmountCtrl.text.isNotEmpty) {
      redeemValueCtrl.text = Global.format(
          Global.toNumber(depositAmountCtrl.text) +
              (Global.toNumber(benefitTotalCtrl.text) * 100 / 107));
    }
    getOtherAmount();
  }

  void redeemValueChanged() {
    getOtherAmount();
  }

  void benefitReceiveChanged() {
    getOtherAmount();
  }

  void benefitTotalChanged() {
    if (widget.vatOption == 'Include' &&
        benefitTotalCtrl.text.isNotEmpty &&
        depositAmountCtrl.text.isNotEmpty) {
      redeemValueCtrl.text = Global.format(
          Global.toNumber(depositAmountCtrl.text) +
              (Global.toNumber(benefitTotalCtrl.text) * 100 / 107));
    }
    getOtherAmount();
  }

  void getOtherAmount() {
    calTotal();
  }

  void calTotal() {
    if (widget.vatOption == "Exclude") {
      if (benefitReceiveCtrl.text.isNotEmpty &&
          Global.toNumber(benefitReceiveCtrl.text) > 0) {
        totalAmount = Global.toNumber(depositAmountCtrl.text) +
            Global.toNumber(benefitReceiveCtrl.text);
      } else {
        totalAmount = Global.toNumber(redeemValueCtrl.text);
      }
    } else {
      totalAmount = Global.toNumber(depositAmountCtrl.text) +
          Global.toNumber(benefitReceiveCtrl.text);
    }
    setState(() {});
  }

  resetText() {
    weightGramCtrl.text = "";
    depositAmountCtrl.text = "";
    weightBahtCtrl.text = "";
    redeemValueCtrl.text = "";
    benefitReceiveCtrl.text = "";
    referenceNumberCtrl.text = "";
    orderDateCtrl.text = "";
    Global.refillAttach = null;
    setState(() {});
  }
}
