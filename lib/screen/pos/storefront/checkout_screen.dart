// (updated) checkout_screen.dart
import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/default/default_payment.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/screen/customer/add_customer_screen.dart';
import 'package:motivegold/screen/customer/customer_screen.dart';
import 'package:motivegold/screen/pos/storefront/paphun/dialog/add_buy_item_dialog.dart';
import 'package:motivegold/screen/pos/storefront/paphun/dialog/add_sell_item_dialog.dart';
import 'package:motivegold/screen/pos/storefront/paphun/dialog/edit_buy_dialog.dart';
import 'package:motivegold/screen/pos/storefront/paphun/dialog/edit_sell_dialog.dart';
import 'package:motivegold/screen/pos/storefront/print_bill_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/calculator/manager.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/classes/painter.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:motivegold/widget/calculate/calculate_button.dart';
import 'package:motivegold/widget/calculate/calculator_button.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/payment/payment_method.dart';
import 'package:motivegold/widget/price_breakdown.dart';

import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sizer/sizer.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen>
    with SingleTickerProviderStateMixin {
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  TextEditingController addPriceCtrl = TextEditingController();
  Screen? size;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  int? selectedOption = 0;
  bool loading = false;

  DefaultPaymentModel? defaultPayment;

  bool showCal = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    Global.discount = 0;
    Global.addPrice = 0;
    Global.customer = null;
    Global.selectedPayment = null;
    Global.currentPaymentMethod = null;
    Global.paymentAttachment = null;
    Global.cardNameCtrl.text = "";
    Global.cardExpireDateCtrl.text = "";
    Global.bankCtrl.text = "";
    Global.refNoCtrl.text = "";
    Global.paymentDateCtrl.text = Global.dateOnlyT(DateTime.now().toString());
    Global.paymentDetailCtrl.text = "";
    Global.paymentList?.clear();
    Global.checkOutMode = "O";

    // Load default payment and then set default KYC radio selection based on business rules
    loadDefaultPayment().then((_) {
      _setDefaultKycSelection();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    discountCtrl.dispose();
    addPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> loadDefaultPayment() async {
    int orderTypeId = 0;
    if (Global.currentOrderType == 1) {
      if (Global.payToCustomerOrShopValue(
              Global.orders,
              Global.toNumber(discountCtrl.text),
              Global.toNumber(addPriceCtrl.text)) <
          0) {
        orderTypeId = 2;
      } else {
        orderTypeId = 1;
      }
    }

    if (Global.currentOrderType == 2) {
      if (Global.payToCustomerOrShopValue(
              Global.orders,
              Global.toNumber(discountCtrl.text),
              Global.toNumber(addPriceCtrl.text)) <
          0) {
        orderTypeId = 33;
      } else {
        orderTypeId = 3;
      }
    }

    if (Global.currentOrderType == 3) {
      if (Global.payToCustomerOrShopValue(
              Global.orders,
              Global.toNumber(discountCtrl.text),
              Global.toNumber(addPriceCtrl.text)) <
          0) {
        orderTypeId = 44;
      } else {
        orderTypeId = 4;
      }
    }

    if (Global.currentOrderType == 4) {
      if (Global.payToCustomerOrShopValue(
              Global.orders,
              Global.toNumber(discountCtrl.text),
              Global.toNumber(addPriceCtrl.text)) <
          0) {
        orderTypeId = 9;
      } else {
        orderTypeId = 8;
      }
    }

    if (Global.currentOrderType == 5) {
      if (Global.payToCustomerOrShopValue(
              Global.orders,
              Global.toNumber(discountCtrl.text),
              Global.toNumber(addPriceCtrl.text)) <
          0) {
        orderTypeId = 5;
      } else {
        orderTypeId = 6;
      }
    }

    if (Global.currentOrderType == 6) {
      if (Global.payToCustomerOrShopValue(
              Global.orders,
              Global.toNumber(discountCtrl.text),
              Global.toNumber(addPriceCtrl.text)) <
          0) {
        orderTypeId = 10;
      } else {
        orderTypeId = 11;
      }
    }

    var payment = await ApiServices.post(
        '/defaultpayment/by-order-type/$orderTypeId', Global.requestObj(null));
    // Guard motivePrint to avoid sending null to platform channel (esp. web)
    if (payment != null) {
      motivePrint(payment.toJson());
    }
    if (payment?.status == "success") {
      var data = DefaultPaymentModel.fromJson(payment?.data);
      setState(() {
        defaultPayment = data;
      });
    }
  }

  // Determine KYC radio default when page opens based on business rules:
  // - If there's any Used Gold (orderTypeId == 2) -> default to "สำแดงตน" (selectedOption = 0)
  // - Else (non used gold): if amount > limit -> default to "สำแดงตน", else default to "ไม่สำแดงตน"
  // Additionally, if default becomes "สำแดงตน" we attempt to load the walkin customer (as prior logic did).
  void _setDefaultKycSelection() {
    Global.customer = null;
    var amount = Global.payToCustomerOrShopValue(Global.orders,
        Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text));

    var checkSellUsedGold = Global.orders.where((e) => e.orderTypeId == 2);
    bool hasUsedGold = checkSellUsedGold.isNotEmpty;

    if (hasUsedGold) {
      // Used gold: Always default to สำแดงตน (0) regardless of Force/Optional
      // This matches the table where both บังคับ and ไม่บังคับ show ✓ for warning
      selectedOption = 0;
    } else {
      // Non-used gold: Check amount vs KYC limit
      if (amount > getMaxKycValue()) {
        // Amount > Limit: default to สำแดงตน (0)
        selectedOption = 0;
      } else {
        // Amount <= Limit: default to ไม่สำแดงตน (1)
        selectedOption = 1;
      }
    }

    // If default is สำแดงตน (0), try to load the walkin customer
    if (selectedOption == 1) {
      loadWalkInCustomer();
    }

    setState(() {});
  }

  openCal() {
    AppCalculatorManager.showCalculator(
      onClose: closeCal,
      onChanged: (key, value, expression) {
        if (key == 'ENT') {
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

  closeCal() {
    AppCalculatorManager.hideCalculator();
    setState(() {
      showCal = false;
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
          title: Text("ชำระเงิน",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Global.orders.isEmpty
              ? const ModernEmptyState()
              : _fadeAnimation != null
                  ? FadeTransition(
                      opacity: _fadeAnimation!,
                      child: _buildContent(),
                    )
                  : _buildContent(),
        ),
      ),
      persistentFooterButtons: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 70,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF0F766E).withValues(alpha: 0.3),
              ),
              onPressed: _handleSaveOrder,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "บันทึก".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.save_alt_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildCustomerSection(),
            const SizedBox(height: 16),
            _buildOrderSection(),
            const SizedBox(height: 16),
            _buildPricingSection(),
            const SizedBox(height: 16),
            _buildPaymentSection(),
            SizedBox(
              height: Global.paymentAttachment == null ? 100 : 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ลูกค้า',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Flexible(child: _buildRadioOption(1, 'ไม่สำแดงตน')),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Flexible(child: _buildRadioOption(0, 'สำแดงตน')),
              ],
            ),
          ),
          if (loading) ...[
            const SizedBox(height: 16),
            const Center(child: ModernLoadingWidget()),
          ],
          if (selectedOption == 0) ...[
            const SizedBox(height: 16),
            _buildCustomerInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildRadioOption(int value, String title) {
    bool isSelected = selectedOption == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = value;
          if (value == 1) {
            loadWalkInCustomer();
          } else {
            Global.customer = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0F766E).withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: value == 1
              ? const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12)),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0F766E)
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF0F766E)
                    : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Global.customer == null
          ? Row(
              children: [
                Expanded(flex: 5, child: Container()),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      KclButton(
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddCustomerScreen(),
                                      fullscreenDialog: true))
                              .whenComplete(() {
                            setState(() {});
                          });
                        },
                        text: 'เพิ่ม',
                        fullWidth: true,
                        icon: Icons.add,
                      ),
                      const SizedBox(
                        height: 8,
                        width: 8,
                      ),
                      KclButton(
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomerScreen(
                                            selected: true,
                                            type: "C",
                                          ),
                                      fullscreenDialog: true))
                              .whenComplete(() {
                            setState(() {});
                          });
                        },
                        text: 'ค้นหา',
                        icon: Icons.search,
                        fullWidth: true,
                        color: Colors.deepOrange,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${getCustomerName(Global.customer!)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${Global.customer!.phoneNumber}",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                              fontSize: 14.sp,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${Global.customer!.email}",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                              fontSize: 14.sp,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${Global.customer!.address}",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF374151),
                              fontSize: 14.sp,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${getWorkId(Global.customer!)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF374151),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          KclButton(
                            onTap: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddCustomerScreen(),
                                          fullscreenDialog: true))
                                  .whenComplete(() {
                                setState(() {});
                              });
                            },
                            text: 'เพิ่ม',
                            fullWidth: true,
                            icon: Icons.add,
                          ),
                          const SizedBox(
                            height: 8,
                            width: 8,
                          ),
                          KclButton(
                            onTap: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CustomerScreen(
                                                selected: true,
                                                type: "C",
                                              ),
                                          fullscreenDialog: true))
                                  .whenComplete(() {
                                setState(() {});
                              });
                            },
                            text: 'ค้นหา',
                            icon: Icons.search,
                            fullWidth: true,
                            color: Colors.deepOrange,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildOrderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'รายการสั่งซื้อ',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < Global.orders.length; i++)
            _itemOrderList(order: Global.orders[i], index: i),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ราคา',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          if (Global.payToCustomerOrShopValue(
                  Global.orders,
                  Global.toNumber(discountCtrl.text),
                  Global.toNumber(addPriceCtrl.text)) <
              0)
            const SizedBox(height: 20),
          if (Global.payToCustomerOrShopValue(
                  Global.orders,
                  Global.toNumber(discountCtrl.text),
                  Global.toNumber(addPriceCtrl.text)) <
              0)
            buildTextFieldBig(
                labelText: "ร้านทองเพิ่มให้ (บาท)",
                labelColor: Colors.orange,
                controller: addPriceCtrl,
                inputType: TextInputType.phone,
                inputFormat: [ThousandsFormatter(allowFraction: true)],
                onChanged: (value) {
                  Global.addPrice =
                      value.isNotEmpty ? Global.toNumber(value) : 0;
                  setState(() {});
                }),
          if (Global.payToCustomerOrShopValue(
                  Global.orders,
                  Global.toNumber(discountCtrl.text),
                  Global.toNumber(addPriceCtrl.text)) >
              0)
            const SizedBox(height: 20),
          if (Global.payToCustomerOrShopValue(
                  Global.orders,
                  Global.toNumber(discountCtrl.text),
                  Global.toNumber(addPriceCtrl.text)) >
              0)
            buildTextFieldBig(
                labelText: "ร้านทองลดให้ (บาท)",
                labelColor: Colors.orange,
                controller: discountCtrl,
                inputType: TextInputType.phone,
                inputFormat: [ThousandsFormatter(allowFraction: true)],
                onChanged: (value) {
                  Global.discount =
                      value.isNotEmpty ? Global.toNumber(value) : 0;
                  setState(() {});
                }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                PriceBreakdown(
                  title: 'จำนวนเงินที่ต้องชำระ'.tr(),
                  price:
                      '${Global.format(Global.getPaymentTotal(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text)))} บาท',
                ),
                PriceBreakdown(
                  title:
                      '${Global.getPayTittle(Global.payToCustomerOrShopValue(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text)))}',
                  price:
                      '${Global.payToCustomerOrShop(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text))}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'วิธีการชำระเงิน'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0F766E),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    setState(() {
                      resetPaymentData();
                    });
                    paymentDialog();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'เพิ่ม',
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CalculatorButton(onTap: openCal),
            ],
          ),
          const SizedBox(height: 16),
          if (Global.paymentList!.isNotEmpty) _buildPaymentList(),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F766E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'ลำดับ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'วิธีการชำระเงิน',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'วันที่ชำระเงิน',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'จำนวนเงิน',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'การดำเนินการ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: Global.paymentList!.length,
            itemBuilder: (context, index) {
              return _paymentItemList(
                  order: Global.paymentList![index], index: index);
            },
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Expanded(flex: 1, child: SizedBox()),
                const Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: Text(
                    'ทั้งหมด',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF0F766E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${Global.format(getPaymentTotal())}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF0F766E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Expanded(flex: 3, child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentItemList({required PaymentModel order, required index}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              order.paymentMethod ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              Global.formatDateNT(order.paymentDate.toString()),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              Global.format(order.amount ?? 0),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: KclButton(
                    onTap: () {
                      editPayment(index);
                    },
                    text: '',
                    icon: Icons.edit,
                    color: const Color(0xFF059669),
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: KclButton(
                    onTap: () {
                      removePayment(index);
                    },
                    text: '',
                    icon: Icons.delete_outline,
                    color: const Color(0xFFDC2626),
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _itemOrderList({required OrderModel order, required index}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  '${getOrderListTitle(order)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${Global.format(Global.getOrderTotalAmount(order.details!))} บาท',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F766E),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              if (order.orderTypeId == 1 || order.orderTypeId == 2)
                Expanded(
                  flex: 3,
                  child: KclButton(
                    onTap: () {
                      if (order.orderTypeId == 1) {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddSellItemDialog(
                                          index: index,
                                        ),
                                    fullscreenDialog: true))
                            .whenComplete(() {
                          setState(() {});
                        });
                      }

                      if (order.orderTypeId == 2) {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddBuyItemDialog(
                                          index: index,
                                        ),
                                    fullscreenDialog: true))
                            .whenComplete(() {
                          setState(() {});
                        });
                      }
                    },
                    text: 'เพิ่มรายการ',
                    icon: Icons.add,
                  ),
                )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Table(
              border: TableBorder.all(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(3),
                4: FlexColumnWidth(4),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F766E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'น้ำหนัก',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'ราคา',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'การดำเนินการ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                for (int j = 0; j < order.details!.length; j++)
                  TableRow(
                    decoration: BoxDecoration(
                      color:
                          j % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
                    ),
                    children: [
                      paddedTextBigL('${j + 1}',
                          style: TextStyle(fontSize: 14.sp),
                          align: TextAlign.center),
                      paddedTextBigL(order.details![j].productName,
                          style: TextStyle(fontSize: 14.sp)),
                      paddedTextBigL(
                          order.orderTypeId == 4 ||
                                  order.orderTypeId == 44 ||
                                  order.orderTypeId == 10 ||
                                  order.orderTypeId == 11
                              ? Global.format4(order.details![j].weight!)
                              : Global.format(order.details![j].weight!),
                          align: TextAlign.right,
                          style: TextStyle(fontSize: 14.sp)),
                      paddedTextBigL(
                          Global.format(order.details![j].priceIncludeTax!) +
                              '  บาท',
                          align: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14.sp,
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (order.orderTypeId == 1 ||
                                order.orderTypeId == 2)
                              Expanded(
                                child: KclButton(
                                  onTap: () {
                                    if (order.orderTypeId == 1) {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditSaleDialog(
                                                        index: index,
                                                        j: j,
                                                      ),
                                                  fullscreenDialog: true))
                                          .whenComplete(() {
                                        setState(() {});
                                      });
                                    } else {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditBuyDialog(
                                                        index: index,
                                                        j: j,
                                                      ),
                                                  fullscreenDialog: true))
                                          .whenComplete(() {
                                        setState(() {});
                                      });
                                    }
                                  },
                                  text: '',
                                  icon: Icons.edit,
                                  color: const Color(0xFF059669),
                                  fullWidth: true,
                                ),
                              ),
                            if (order.orderTypeId == 1 ||
                                order.orderTypeId == 2)
                              const SizedBox(width: 8),
                            Expanded(
                              child: KclButton(
                                onTap: () {
                                  removeItem(index, j);
                                },
                                text: '',
                                icon: Icons.delete_outline,
                                color: const Color(0xFFDC2626),
                                fullWidth: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (index < Global.orders.length - 1)
            Container(
              height: 10,
              color: Colors.white,
            ),
        ],
      ),
    );
  }

  void _handleSaveOrder() async {
    if (Global.customer == null && selectedOption == 0) {
      Alert.warning(context, 'Warning'.tr(), 'กรุณากรอกลูกค้า', 'OK'.tr(),
          action: () {});
      return;
    }

    if (Global.paymentList!.isEmpty) {
      if (mounted) {
        Alert.warning(
            context, 'Warning'.tr(), 'กรุณาเพิ่มการชำระเงินก่อน', 'OK'.tr(),
            action: () {});
        return;
      }
    }

    var amount = Global.payToCustomerOrShopValue(Global.orders,
        Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text));

    if (getPaymentTotal() >
        Global.toNumber(Global.format(Global.getPaymentTotal(
            Global.orders,
            Global.toNumber(discountCtrl.text),
            Global.toNumber(addPriceCtrl.text))))) {
      if (mounted) {
        Alert.warning(
            context,
            'Warning'.tr(),
            amount >= 0
                ? 'ยอดชำระมากกว่าจำนวนเงินรวม'
                : 'ยอดจ่ายมากกว่าจำนวนเงินรวม',
            'OK'.tr(),
            action: () {});
        return;
      }
    }

    if (getPaymentTotal() <
        Global.toNumber(Global.format(Global.getPaymentTotal(
            Global.orders,
            Global.toNumber(discountCtrl.text),
            Global.toNumber(addPriceCtrl.text))))) {
      if (mounted) {
        Alert.warning(
            context,
            'Warning'.tr(),
            amount >= 0
                ? 'ยอดชำระน้อยกว่าจำนวนเงินรวม'
                : 'ยอดจ่ายน้อยกว่าจำนวนเงินรวม',
            'OK'.tr(),
            action: () {});
        return;
      }
    }

    var kycValidation = validateKycRequirements();

    // Check if validation has a blocking message
    if (kycValidation.message.isNotEmpty && kycValidation.isBlocked) {
      Alert.warning(context, 'Warning'.tr(), kycValidation.message, 'OK'.tr(),
          action: () {});
      return;
    }

    // For Rules 5 & 6 (Used Gold + Optional), combine warning with save confirmation
    if (kycValidation.message.isNotEmpty && !kycValidation.isBlocked) {
      Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', kycValidation.message,
          'บันทึก', action: () async {
        await _proceedWithSave();
      });
      return;
    }

    // Normal save confirmation for cases without warnings
    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      await _proceedWithSave();
    });
  }

// Extract the save logic to a separate method
  Future<void> _proceedWithSave() async {
    // Continue with the original save logic...
    OrderProcessingService.processAllOrders(
      discount: discountCtrl.text,
      addPrice: addPriceCtrl.text,
    );

    // Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
    //     action: () async {
    // ... rest of the original save logic
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      if (Global.posOrder != null) {
        await reserveOrder(Global.posOrder!);
      }
      var pair = await ApiServices.post(
          '/order/gen-pair/${Global.orders.first.orderTypeId}',
          Global.requestObj(null));

      if (pair?.status == "success") {
        await postPayment(pair?.data);
        await postOrder(pair?.data);
        Global.orderIds = Global.orders.map((e) => e.orderId).toList();
        Global.pairId = pair?.data;
        await pr.hide();
        if (mounted) {
          Global.orders.clear();
          Global.customer = null;
          Global.posOrder = null;
          Global.paymentList?.clear();
          writeCart();
          setState(() {});
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const PrintBillScreen()));
        }
      } else {
        if (mounted) {
          Alert.warning(context, 'Warning'.tr(),
              'Unable to generate pairing ID', 'OK'.tr(),
              action: () {});
        }
      }
    } catch (e) {
      await pr.hide();
      if (mounted) {
        Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
            action: () {});
      }
      return;
    }
    // });
  }

  // Keep all your original methods unchanged (postPayment, postOrder, removeProduct, etc.)
  Future postPayment(int pairId) async {
    if (Global.paymentList!.isNotEmpty) {
      var payment = await ApiServices.post(
          '/order/gen-payment/${Global.orders.first.orderTypeId}',
          Global.requestObj(null));

      if (payment?.status == "success") {
        for (int i = 0; i < Global.paymentList!.length; i++) {
          var result = await ApiServices.post(
              '/order/payment',
              Global.requestObj(
                PaymentModel(
                    id: 0,
                    pairId: pairId,
                    paymentId: payment?.data,
                    paymentMethod: Global.paymentList![i].paymentMethod,
                    paymentDate: Global.paymentList![i].paymentDate!,
                    bankId: Global.paymentList![i].bankId,
                    bankName: Global.paymentList![i].bankName,
                    accountName: Global.paymentList![i].accountName,
                    accountNo: Global.paymentList![i].accountNo,
                    amount: Global.paymentList![i].amount,
                    referenceNumber: Global.paymentList![i].referenceNumber,
                    cardName: Global.paymentList![i].cardName,
                    cardNo: Global.paymentList![i].cardNo,
                    cardExpiryDate: Global.paymentList![i].cardExpiryDate,
                    paymentDetail: Global.paymentList![i].paymentDetail,
                    attachement: Global.paymentList![i].attachement,
                    createdDate: DateTime.now(),
                    updatedDate: DateTime.now()),
              ));
          if (result?.status == "success") {
            motivePrint("Payment completed");
          }
        }
      }
    }
  }

  Future postOrder(int pairId) async {
    await Future.forEach<OrderModel>(Global.orders, (e) async {
      e.pairId = pairId;
      var result =
          await ApiServices.post('/order/create', Global.requestObj(e));
      if (result?.status == "success") {
        var order = orderModelFromJson(jsonEncode(result?.data));
        int? id = order.id;
        await Future.forEach<OrderDetailModel>(e.details!, (f) async {
          f.orderId = id;
          var detail =
              await ApiServices.post('/orderdetail', Global.requestObj(f));
          if (detail?.status == "success") {
            motivePrint("Order completed");
          }
        });
      }
    });
  }

  void removeProduct(int i) async {
    Global.orders.removeAt(i);
    if (Global.orders.isEmpty) {
      Global.customer = null;
      Global.paymentList?.clear();
    }
    loadDefaultPayment();
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {});
    });
  }

  void removeItem(int i, int j) async {
    Global.orders[i].details!.removeAt(j);
    if (Global.orders[i].details!.isEmpty) {
      Global.orders.removeAt(i);
      removeCart();
    }
    loadDefaultPayment();
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {});
    });
  }

  void removePayment(int i) async {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.paymentList!.removeAt(i);
      Future.delayed(const Duration(milliseconds: 500), () async {
        setState(() {});
      });
    });
  }

  void editPayment(int i) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modern Header with auto height
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.edit_note,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'แก้ไขวิธีการชำระเงิน',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${Global.payToCustomerOrShop(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text))}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content Area
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: PaymentMethodWidget(
                          index: i,
                          payment: defaultPayment,
                        ),
                      ),
                    ),

                    // Modern Update Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor:
                              const Color(0xFF059669).withValues(alpha: 0.3),
                        ),
                        onPressed: () async {
                          if (Global.currentPaymentMethod == "CR") {
                            if (Global.cardNameCtrl.text.trim().isEmpty) {
                              Alert.warning(context, 'Warning'.tr(),
                                  'กรุณากรอกชื่อบนบัตร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.cardExpireDateCtrl.text.trim().isEmpty) {
                              Alert.warning(context, 'Warning'.tr(),
                                  'กรุณากรอกวันหมดอายุบัตร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.cardNumberCtrl.text.trim().isEmpty) {
                              Alert.warning(context, 'Warning'.tr(),
                                  'กรุณากรอกเลขที่บัตรเครดิต', 'OK'.tr(),
                                  action: () {});
                              return;
                            }
                          }

                          if (Global.currentPaymentMethod == "TR" ||
                              Global.currentPaymentMethod == "DP") {
                            if (Global.selectedBank == null) {
                              Alert.warning(context, 'Warning'.tr(),
                                  'กรุณาเลือกธนาคาร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.selectedAccount == null) {
                              Alert.warning(context, 'Warning'.tr(),
                                  'กรุณาเลือกบัญชีธนาคาร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }
                          }
                          // Alert.info(
                          //   context,
                          //   'ต้องการบันทึกข้อมูลหรือไม่?',
                          //   '',
                          //   'ตกลง',
                          //   action: () async {
                          var payment = PaymentModel(
                            paymentMethod: Global.currentPaymentMethod,
                            pairId: Global.pairId,
                            paymentDate:
                                DateTime.parse(Global.paymentDateCtrl.text),
                            paymentDetail: Global.paymentDetailCtrl.text,
                            bankId: Global.selectedBank?.id,
                            bankName: Global.selectedBank?.name,
                            accountNo: Global.selectedAccount?.accountNo,
                            accountName: Global.selectedAccount?.name,
                            cardName: Global.cardNameCtrl.text,
                            cardNo: Global.cardNumberCtrl.text,
                            cardExpiryDate:
                                Global.cardExpireDateCtrl.text.isNotEmpty
                                    ? DateTime.parse(Global.convertToFullDate(
                                        Global.cardExpireDateCtrl.text)!)
                                    : null,
                            amount: Global.toNumber(Global.amountCtrl.text),
                            referenceNumber: Global.refNoCtrl.text,
                            attachement: getPaymentAttachment(),
                          );

                          Global.paymentList?[i] = payment;

                          setState(() {});
                          Navigator.of(context).pop();
                          //   },
                          // );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "อัปเดต",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Modern Close Button
                Positioned(
                  right: -12,
                  top: -12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> reserveOrder(OrderModel order) async {
    var result =
        await ApiServices.post('/order/reserve', Global.requestObj(order));
    if (result != null) {
      motivePrint(result.toJson());
    }
    if (result?.status == "success") {
      motivePrint("Reverse completed");
    }
  }

  void paymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modern Header with auto height
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.payment,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'เลือกวิธีการชำระเงิน',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${Global.payToCustomerOrShop(Global.orders, Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text))}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content Area
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: PaymentMethodWidget(
                          payment: defaultPayment,
                        ),
                      ),
                    ),

                    // Modern Save Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF0F766E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor:
                              const Color(0xFF0F766E).withValues(alpha: 0.3),
                        ),
                        onPressed: () async {
                          if (Global.currentPaymentMethod == "CR") {
                            if (Global.cardNameCtrl.text.trim().isEmpty) {
                              Alert.warning(context, 'Warning'.tr(),
                                  'กรุณากรอกชื่อบนบัตร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.cardExpireDateCtrl.text.trim().isEmpty) {
                              Alert.warning(context, 'Warning'.tr(),
                                  'กรุณากรอกวันหมดอายุบัตร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.cardNumberCtrl.text.trim().isEmpty) {
                              Alert.warning(context, 'Warning'.tr(),
                                  'กรุณากรอกเลขที่บัตรเครดิต', 'OK'.tr(),
                                  action: () {});
                              return;
                            }
                          }

                          if (Global.currentPaymentMethod == "TR" ||
                              Global.currentPaymentMethod == "DP") {
                            if (Global.selectedBank == null) {
                              Alert.warning(context, 'Warning'.tr(),
                                  'กรุณาเลือกธนาคาร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.selectedAccount == null) {
                              Alert.warning(context, 'Warning'.tr(),
                                  'กรุณาเลือกบัญชีธนาคาร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }
                          }

                          // Alert.info(
                          //   context,
                          //   'ต้องการบันทึกข้อมูลหรือไม่?',
                          //   '',
                          //   'ตกลง',
                          //   action: () async {
                          var payment = PaymentModel(
                            paymentMethod: Global.currentPaymentMethod,
                            pairId: Global.pairId,
                            paymentDate:
                                DateTime.parse(Global.paymentDateCtrl.text),
                            paymentDetail: Global.paymentDetailCtrl.text,
                            bankId: Global.selectedBank?.id,
                            bankName: Global.selectedBank?.name,
                            accountNo: Global.selectedAccount?.accountNo,
                            accountName: Global.selectedAccount?.name,
                            cardName: Global.cardNameCtrl.text,
                            cardNo: Global.cardNumberCtrl.text,
                            cardExpiryDate:
                                Global.cardExpireDateCtrl.text.isNotEmpty
                                    ? DateTime.parse(Global.convertToFullDate(
                                        Global.cardExpireDateCtrl.text)!)
                                    : null,
                            amount: Global.toNumber(Global.amountCtrl.text),
                            referenceNumber: Global.refNoCtrl.text,
                            attachement: getPaymentAttachment(),
                          );

                          Global.paymentList?.add(payment);

                          setState(() {});
                          Navigator.of(context).pop();
                          // },
                          // );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.save_alt_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "บันทึก",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Modern Close Button
                Positioned(
                  right: -12,
                  top: -12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  getPaymentAttachment() {
    if (!kIsWeb && Global.paymentAttachment != null) {
      return Global.imageToBase64(Global.paymentAttachment!);
    }

    if (kIsWeb && Global.paymentAttachmentWeb != null) {
      return Global.paymentAttachmentWeb;
    }
  }

  getPaymentTotal() {
    if (Global.paymentList!.isEmpty) {
      return 0;
    }

    double amount = 0;
    for (int j = 0; j < Global.paymentList!.length; j++) {
      double price = Global.paymentList![j].amount ?? 0;
      amount += price;
    }
    return amount;
  }

  void loadWalkInCustomer() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.get('/customer/walkin');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        setState(() {
          Global.customer = customerModelFromJson(data);
        });
      } else {
        Global.customer = null;
      }
    } catch (e) {
      motivePrint(e.toString());
    }
    setState(() {
      loading = false;
    });
  }

  // Updated validation logic implementing the business rules:
  //
  // Used Gold + Force + Amount > Limit: Customer identification required and block save record
  // Used Gold + Force + Amount ≤ Limit: Customer identification required and block save record
  // Non Used Gold + Amount > Limit: default to สำแดงตน (handled on init)
  // Non Used Gold + Amount <= Limit: default to ไม่สำแดงตน (handled on init)
  // Used Gold + Optional + Amount > Limit: Warning customer identification but can continue save record
  // Used Gold + Optional + Amount ≤ Limit: No restrictions
  // Used Gold: Force case always requires customer identification (block)
  ValidationResult validateKycRequirements() {
    var amount = Global.payToCustomerOrShopValue(Global.orders,
        Global.toNumber(discountCtrl.text), Global.toNumber(addPriceCtrl.text));

    var checkSellUsedGold = Global.orders.where((e) => e.orderTypeId == 2);
    bool hasUsedGold = checkSellUsedGold.isNotEmpty;
    bool customerNotIdentified =
        selectedOption == 1 || (selectedOption == 0 && Global.customer == null);

    // According to the table:
    // การแสดงตนเมื่อรับซื้อของเก่า (Used Gold scenarios)
    if (hasUsedGold) {
      if (Global.kycSettingModel?.kycOption?.toLowerCase() == 'force') {
        // บังคับ (Force): Always warn + block if customer not identified
        if (customerNotIdentified) {
          return ValidationResult(
              isValid: false,
              isBlocked: true,
              message:
                  'กรุณาสำแดงตนข้อมูลลูกค้า - การรับซื้อทองเก่าต้องสำแดงตนเมื่อตั้งค่าเป็นบังคับ');
        }
      } else {
        // ไม่บังคับ (Optional): Always warn but don't block
        if (customerNotIdentified) {
          return ValidationResult(
              isValid: true,
              isBlocked: false,
              message: 'คำเตือน: การรับซื้อทองเก่าแนะนำให้สำแดงตน');
        }
      }
    }

    // มูลค่า KYC (Amount-based KYC scenarios for non-used gold)
    if (!hasUsedGold) {
      if (amount <= getMaxKycValue()) {
        // น้อยกว่าหรือเท่ากับ Limit KYC: No warning, allow to proceed
        // No action needed - user can save without warning
      } else {
        // มากกว่า Limit KYC: Warn + block if customer not identified
        if (customerNotIdentified) {
          return ValidationResult(
              isValid: false,
              isBlocked: true,
              message:
                  'กรุณาสำแดงตนข้อมูลลูกค้า - จำนวนเงิน ${Global.format(amount < 0 ? -amount : amount)} บาท เกินกว่าขั้นสูงสุด ${Global.format(getMaxKycValue())} บาท');
        }
      }
    }

    // Additional check for Force KYC setting (applies to all transactions)
    // if (Global.kycSettingModel?.kycOption?.toLowerCase() == 'force') {
    //   if (customerNotIdentified) {
    //     return ValidationResult(
    //         isValid: false,
    //         isBlocked: true,
    //         message: 'กรุณาสำแดงตนข้อมูลลูกค้า - สาขานี้กำหนดให้สำแดงตนทุกครั้ง');
    //   }
    // }

    return ValidationResult(isValid: true, isBlocked: false, message: '');
  }
}

// Add this class at the top of your file or in a separate file:
class ValidationResult {
  final bool isValid;
  final bool isBlocked;
  final String message;

  ValidationResult({
    required this.isValid,
    required this.isBlocked,
    required this.message,
  });
}

class ModernLoadingWidget extends StatelessWidget {
  const ModernLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
      strokeWidth: 3,
    );
  }
}

class ModernEmptyState extends StatelessWidget {
  const ModernEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ไม่มีรายการในตะกร้า',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'เพิ่มสินค้าเพื่อดำเนินการชำระเงิน',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
