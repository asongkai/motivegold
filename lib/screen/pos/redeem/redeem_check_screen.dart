import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/redeem/redeem_detail.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/screen/customer/add_customer_screen.dart';
import 'package:motivegold/screen/customer/customer_screen.dart';
import 'package:motivegold/screen/pos/redeem/dialog/edit_redeem_item_dialog.dart';
import 'package:motivegold/screen/pos/redeem/print_redeem_bill.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/manager.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:motivegold/widget/calculate/calculator_button.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/payment/payment_method.dart';

import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sizer/sizer.dart';

class RedeemCheckOutScreen extends StatefulWidget {
  const RedeemCheckOutScreen({super.key});

  @override
  State<RedeemCheckOutScreen> createState() => _RedeemCheckOutScreenState();
}

class _RedeemCheckOutScreenState extends State<RedeemCheckOutScreen>
    with SingleTickerProviderStateMixin {
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  Screen? size;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  int? selectedOption = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    Global.currentOrderType = 0;
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
    Global.checkOutMode = "P";
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
    super.dispose();
    Global.discount = 0;
    Global.addPrice = 0;
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
          child: Global.redeems.isEmpty
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
                shadowColor: const Color(0xFF0F766E).withOpacity(0.3),
              ),
              onPressed: _handleSaveOrder,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "บันทึก".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
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
            color: Colors.black.withOpacity(0.04),
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
                  color: const Color(0xFF0F766E).withOpacity(0.1),
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
                  fontSize: 18.sp,
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
          if (loading)
            const SizedBox(
              height: 100,
              child: Center(child: ModernLoadingWidget()),
            ),
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
            loadCustomer();
          } else {
            Global.customer = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F766E).withOpacity(0.05) : Colors.transparent,
          borderRadius: value == 1
              ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
              : const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFD1D5DB),
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
                color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF374151),
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
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${Global.customer!.firstName} ${Global.customer!.lastName}",
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
                flex: 1,
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
            color: Colors.black.withOpacity(0.04),
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
                  color: const Color(0xFF0F766E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'รายการไถ่ถอน',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < Global.redeems.length; i++)
            _itemOrderList(order: Global.redeems[i], index: i),
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
            color: Colors.black.withOpacity(0.04),
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
                  color: const Color(0xFF0F766E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payments,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ราคา',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildTextFieldBig(
              labelText: "ส่วนลด (บาทไทย)",
              labelColor: Colors.orange,
              controller: discountCtrl,
              inputType: TextInputType.phone,
              inputFormat: [ThousandsFormatter(allowFraction: true)],
              onChanged: (value) {
                Global.discount = value.isNotEmpty ? Global.toNumber(value) : 0;
                setState(() {});
              }),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3B82F6), width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'จำนวนเงินรวมที่ลูกค้าต้องชำระ (บาท)',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${Global.format(Global.getRedeemPaymentTotal(Global.redeems, discount: Global.toNumber(discountCtrl.text)))} บาท',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
            color: Colors.black.withOpacity(0.04),
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
                  color: const Color(0xFF0F766E).withOpacity(0.1),
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
                  fontSize: 18.sp,
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
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'เพิ่ม',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    });
  }

  closeCal() {
    AppCalculatorManager.hideCalculator();
    setState(() {
    });
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
                      fontSize: size?.getWidthPx(8),
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
                      fontSize: size?.getWidthPx(8),
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
                      fontSize: size?.getWidthPx(8),
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
                      fontSize: size?.getWidthPx(8),
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
                      fontSize: size?.getWidthPx(8),
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
              color: const Color(0xFF0F766E).withOpacity(0.1),
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
                      fontSize: 18.sp,
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
                      fontSize: 18.sp,
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
                fontSize: size?.getWidthPx(8),
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
                fontSize: size?.getWidthPx(8),
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
                fontSize: size?.getWidthPx(8),
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
                fontSize: size?.getWidthPx(8),
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      editPayment(index);
                    },
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'แก้ไข',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      removePayment(index);
                    },
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'ลบ',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _itemOrderList({required RedeemModel order, required index}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ธุรกรรมไถ่ถอน - ขายฝาก',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${Global.format(Global.getRedeemTotalPayment(order.details!))} บาท',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F766E),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    )
                  ],
                ),
              ),
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
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(4),
                3: FlexColumnWidth(4),
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'น้ำหนัก',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size?.getWidthPx(8),
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
                          fontSize: size?.getWidthPx(8),
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
                          fontSize: size?.getWidthPx(8),
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
                      color: j % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
                    ),
                    children: [
                      paddedTextBigL('${j + 1}',
                          style: TextStyle(fontSize: size?.getWidthPx(8)),
                          align: TextAlign.center),
                      paddedTextBigL(Global.format(order.details![j].weight!),
                          align: TextAlign.right,
                          style: TextStyle(fontSize: size?.getWidthPx(8))),
                      paddedTextBigL(
                          Global.format(order.details![j].paymentAmount ?? 0) +
                              '  บาท',
                          align: TextAlign.right,
                          style: TextStyle(
                            fontSize: size?.getWidthPx(8),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Edit functionality
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditRedeemItemDialog(index: index, vatOption: order.details![j].vatOption ?? '', j: j,),
                                          fullscreenDialog: true))
                                      .whenComplete(() {
                                    setState(() {});
                                  });
                                },
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.edit, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'แก้ไข',
                                        style: TextStyle(fontSize: 12, color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  removeItem(index, j);
                                },
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.close, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'ลบ',
                                        style: TextStyle(fontSize: 12, color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
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
          if (index < Global.redeems.length - 1)
            Container(
              height: 10,
              color: Colors.white,
            ),
        ],
      ),
    );
  }

  void _handleSaveOrder() async {
    if (Global.customer == null) {
      if (mounted) {
        Alert.warning(
            context, 'Warning'.tr(), 'กรุณากรอกลูกค้า', 'OK'.tr(),
            action: () {});
        return;
      }
    }

    for (var i = 0; i < Global.redeems.length; i++) {
      Global.redeems[i].id = 0;
      Global.redeems[i].createdDate = DateTime.now();
      Global.redeems[i].updatedDate = DateTime.now();
      Global.redeems[i].customerId = Global.customer!.id!;
      Global.redeems[i].status = 0;
      Global.redeems[i].discount = Global.toNumber(discountCtrl.text);
      Global.redeems[i].qty = 1;
      Global.redeems[i].redemptionVat = 0;
      Global.redeems[i].weight =
          getRedeemWeightTotal(Global.redeems[i].details!);
      Global.redeems[i].weightBath =
          getRedeemWeightBahtTotal(Global.redeems[i].details!);
      Global.redeems[i].taxBase =
          getTaxBaseTotal(Global.redeems[i].details!);
      Global.redeems[i].taxAmount =
          getTaxAmountTotal(Global.redeems[i].details!);
      Global.redeems[i].depositAmount =
          getDepositAmountTotal(Global.redeems[i].details!);
      Global.redeems[i].redemptionValue =
          getRedemptionValueTotal(Global.redeems[i].details!);
      Global.redeems[i].redemptionVat =
          getRedemptionVatTotal(Global.redeems[i].details!);
      Global.redeems[i].benefitAmount =
          getBenefitAmountTotal(Global.redeems[i].details!);
      Global.redeems[i].paymentAmount =
          getPaymentAmountTotal(Global.redeems[i].details!);
      Global.redeems[i].attachment = null;
      for (var j = 0; j < Global.redeems[i].details!.length; j++) {
        Global.redeems[i].details![j].id = 0;
        Global.redeems[i].details![j].qty = 1;
        Global.redeems[i].details![j].productId = 0;
        Global.redeems[i].details![j].createdDate = DateTime.now();
        Global.redeems[i].details![j].updatedDate = DateTime.now();
      }
    }

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          final ProgressDialog pr = ProgressDialog(context,
              type: ProgressDialogType.normal,
              isDismissible: true,
              showLogs: true);
          await pr.show();
          pr.update(message: 'processing'.tr());
          try {
            if (Global.posOrder != null) {
              await reserveOrder(Global.posOrder!);
            }
            // Gen pair ID before submit
            var pair = await ApiServices.post(
                '/redeem/gen-pair/${Global.redeems.first.redeemTypeId}',
                Global.requestObj(null));

            print(pair?.toJson());
            if (pair?.status == "success") {
              await postPayment(pair?.data);
              await postOrder(pair?.data);
              Global.pairId = pair?.data;
              await pr.hide();
              if (mounted) {
                Global.redeems.clear();
                Global.discount = 0;
                Global.addPrice = 0;
                Global.customer = null;
                Global.paymentList?.clear();
                writeRedeemCart();
                setState(() {});
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrintRedeemBillScreen()));
              }
            } else {
              await pr.hide();
              if (mounted) {
                Alert.warning(context, 'Warning'.tr(),
                    'Unable to generate pairing ID', 'OK'.tr(),
                    action: () {});
              }
            }
          } catch (e, stack) {
            await pr.hide();
            if (mounted) {
              Alert.warning(
                  context, 'Warning'.tr(), stack.toString(), 'OK'.tr(),
                  action: () {});
            }
            return;
          }
        });
  }

  // Keep all your original methods unchanged
  Future postPayment(int pairId) async {
    if (Global.paymentList!.isNotEmpty) {
      var payment = await ApiServices.post(
          '/order/gen-payment/${Global.redeems.first.redeemTypeId}',
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
    await Future.forEach<RedeemModel>(Global.redeems, (e) async {
      e.pairId = pairId;
      var result =
      await ApiServices.post('/redeem/create', Global.requestObj(e));
      motivePrint(result?.toJson());
      if (result?.status == "success") {
        var order = redeemModelFromJson(jsonEncode(result?.data));
        int? id = order.id;
        await Future.forEach<RedeemDetailModel>(e.details!, (f) async {
          f.redeemId = id;
          var detail =
          await ApiServices.post('/redeemdetail', Global.requestObj(f));
          motivePrint(detail?.toJson());
          if (detail?.status == "success") {
            motivePrint("Order completed");
          }
        });
      }
    });
  }

  void removeProduct(int i) async {
    Global.redeems.removeAt(i);
    if (Global.redeems.isEmpty) {
      Global.customer = null;
      Global.discount = 0;
      Global.addPrice = 0;
      Global.paymentList?.clear();
    }
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {});
    });
  }

  void removeItem(int i, int j) async {
    Global.redeems[i].details!.removeAt(j);
    if (Global.redeems[i].details!.isEmpty) {
      Global.redeems.removeAt(i);
      removeRedeemCart();
    }
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
                                    '${Global.format(Global.getRedeemPaymentTotal(Global.redeems, discount: Global.toNumber(discountCtrl.text)))}',
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
                              Alert.warning(
                                  context, 'Warning'.tr(), 'กรุณากรอกชื่อบนบัตร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.cardExpireDateCtrl.text.trim().isEmpty) {
                              Alert.warning(
                                  context, 'Warning'.tr(), 'กรุณากรอกวันหมดอายุบัตร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.cardNumberCtrl.text.trim().isEmpty) {
                              Alert.warning(
                                  context, 'Warning'.tr(), 'กรุณากรอกเลขที่บัตรเครดิต', 'OK'.tr(),
                                  action: () {});
                              return;
                            }
                          }

                          if (Global.currentPaymentMethod == "TR" || Global.currentPaymentMethod == "DP") {
                            if (Global.selectedBank == null) {
                              Alert.warning(
                                  context, 'Warning'.tr(), 'กรุณาเลือกธนาคาร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.selectedAccount == null) {
                              Alert.warning(
                                  context, 'Warning'.tr(), 'กรุณาเลือกบัญชีธนาคาร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }
                          }
                          Alert.info(
                            context,
                            'ต้องการบันทึกข้อมูลหรือไม่?',
                            '',
                            'ตกลง',
                            action: () async {
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
                                    ? DateTime.parse(
                                    Global.cardExpireDateCtrl.text)
                                    : null,
                                amount: Global.toNumber(Global.amountCtrl.text),
                                referenceNumber: Global.refNoCtrl.text,
                                attachement: Global.paymentAttachment != null
                                    ? Global.imageToBase64(
                                    Global.paymentAttachment!)
                                    : null,
                              );

                              Global.paymentList?[i] = payment;

                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          );
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
    if (result?.status == "success") {
      // motivePrint("Reverse completed");
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
                                    '${Global.format(Global.getRedeemPaymentTotal(Global.redeems, discount: Global.toNumber(discountCtrl.text)))}',
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
                        child: const PaymentMethodWidget(),
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
                              Alert.warning(
                                  context, 'Warning'.tr(), 'กรุณากรอกชื่อบนบัตร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.cardExpireDateCtrl.text.trim().isEmpty) {
                              Alert.warning(
                                  context, 'Warning'.tr(), 'กรุณากรอกวันหมดอายุบัตร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.cardNumberCtrl.text.trim().isEmpty) {
                              Alert.warning(
                                  context, 'Warning'.tr(), 'กรุณากรอกเลขที่บัตรเครดิต', 'OK'.tr(),
                                  action: () {});
                              return;
                            }
                          }

                          if (Global.currentPaymentMethod == "TR" || Global.currentPaymentMethod == "DP") {
                            if (Global.selectedBank == null) {
                              Alert.warning(
                                  context, 'Warning'.tr(), 'กรุณาเลือกธนาคาร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }

                            if (Global.selectedAccount == null) {
                              Alert.warning(
                                  context, 'Warning'.tr(), 'กรุณาเลือกบัญชีธนาคาร', 'OK'.tr(),
                                  action: () {});
                              return;
                            }
                          }
                          Alert.info(
                            context,
                            'ต้องการบันทึกข้อมูลหรือไม่?',
                            '',
                            'ตกลง',
                            action: () async {
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
                                    ? DateTime.parse(
                                    Global.cardExpireDateCtrl.text)
                                    : null,
                                amount: Global.toNumber(Global.amountCtrl.text),
                                referenceNumber: Global.refNoCtrl.text,
                                attachement: Global.paymentAttachment != null
                                    ? Global.imageToBase64(
                                    Global.paymentAttachment!)
                                    : null,
                              );

                              Global.paymentList?.add(payment);

                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          );
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

  void loadCustomer() async {
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
}

class ModernLoadingWidget extends StatelessWidget {
  const ModernLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
      strokeWidth: 3,
    );
  }
}

class ModernEmptyState extends StatelessWidget {
  const ModernEmptyState({Key? key}) : super(key: key);

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
              color: isSelected!
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
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