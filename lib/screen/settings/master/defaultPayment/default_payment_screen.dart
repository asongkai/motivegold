import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/default/default_payment.dart';
import 'package:motivegold/model/order_type.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/response.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/payment/payment_default.dart';
import 'package:motivegold/widget/payment/payment_method.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:sizer/sizer.dart';

class DefaultPaymentScreen extends StatefulWidget {
  const DefaultPaymentScreen({super.key});

  @override
  State<DefaultPaymentScreen> createState() => _DefaultPaymentScreenState();
}

class _DefaultPaymentScreenState extends State<DefaultPaymentScreen> {
  bool loading = false;
  List<OrderTypeModel>? dataList = [];
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  Screen? size;

  @override
  void initState() {
    super.initState();
    Global.selectedPayment = null;
    Global.selectedBank = null;
    Global.selectedAccount = null;
    Global.currentPaymentMethod = null;
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post(
          '/defaultpayment/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderTypeModel> products = orderTypeModelFromJson(data);
        motivePrint(products.first.toJson());
        setState(() {
          dataList = products;
          Global.orderTypes = products;
        });
      } else {
        dataList = [];
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
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("ตั้งค่าค่าเริ่มต้น การชำระเงิน",
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : dataList!.isEmpty
            ? const NoDataFoundWidget()
            : Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: dataList!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              return modernPaymentCard(dataList, index);
            },
          ),
        ),
      ),
    );
  }

  Widget modernPaymentCard(List<OrderTypeModel>? list, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.payment_rounded,
                    color: Colors.purple[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'หน้าจอ ${list![index].name!}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Content Section with Button Inside
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Content
                  Expanded(
                    child: Column(
                      children: [
                        _buildPaymentInfoRow(
                          icon: Icons.credit_card_rounded,
                          label: 'วิธีการชำระเงินเริ่มต้น',
                          value: getPaymentType(list[index].paymentCode) ?? 'ยังไม่ได้กำหนด',
                          color: Colors.blue,
                        ),
                        if (list[index].paymentCode == 'TR') ...[
                          const SizedBox(height: 12),
                          _buildPaymentInfoRow(
                            icon: Icons.account_balance_rounded,
                            label: 'ธนาคาร',
                            value: list[index].payment?.bankName ?? 'ยังไม่ได้กำหนด',
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentInfoRow(
                            icon: Icons.account_box_rounded,
                            label: 'บัญชีธนาคาร',
                            value: list[index].payment?.accountName ?? 'ยังไม่ได้กำหนด',
                            color: Colors.orange,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Right Button - Inside the grey box
                  SizedBox(
                    width: 200,
                    child: KclButton(
                      text: 'ตั้งค่าเริ่มต้น',
                      icon: Icons.tune_rounded,
                      fullWidth: true,
                      onTap: () async {
                        modernPaymentDialog(list[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void modernPaymentDialog(OrderTypeModel model) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: (MediaQuery.of(context).orientation == Orientation.landscape)
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payment_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ตั้งค่าการชำระเงิน ${model.name}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Payment Selection
                        _buildSectionHeader(
                          icon: Icons.payment_rounded,
                          title: 'การชำระเงินเริ่มต้น',
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 16),
                        PaymentDefaultWidget(
                          payment: model.payment,
                        ),

                        const SizedBox(height: 32),

                        // Save Button
                        KclButton(
                          text: 'บันทึกการตั้งค่า',
                          icon: Icons.save_rounded,
                          fullWidth: true,
                          onTap: () => save(context, model),
                        ),
                      ],
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  void save(BuildContext context, OrderTypeModel model) {
    model.orderTypeId = model.id;
    model.paymentId = Global.selectedPayment?.id;
    model.paymentCode = Global.selectedPayment?.code;
    model.paymentName = Global.selectedPayment?.name;
    DefaultPaymentModel? paymentModel;
    if (model.payment == null) {
      paymentModel = DefaultPaymentModel(
        id: model.payment?.id ?? 0,
        companyId: Global.company?.id,
        branchId: Global.branch?.id,
        paymentId: Global.selectedPayment?.id,
        paymentCode: Global.selectedPayment?.code,
        bankId: Global.selectedBank?.id,
        bankName: Global.selectedBank?.name,
        accountNo: Global.selectedAccount?.accountNo,
        accountName: Global.selectedAccount?.name,
        orderTypeId: model.orderTypeId,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );
    } else {
      model.payment?.paymentCode = Global.selectedPayment?.code;
      model.payment?.paymentId = Global.selectedPayment?.id;
      model.payment?.bankId = Global.selectedBank?.id;
      model.payment?.bankName = Global.selectedBank?.name;
      model.payment?.accountNo = Global.selectedAccount?.accountNo;
      model.payment?.accountName = Global.selectedAccount?.name;
      model.payment?.orderTypeId = model.orderTypeId;
      paymentModel = model.payment;
    }

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          final ProgressDialog pr = ProgressDialog(context,
              type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
          await pr.show();
          pr.update(message: 'processing'.tr());
          try {
            var result = await ApiServices.post(
                '/defaultpayment/create', Global.requestObj(paymentModel));
            await pr.hide();
            if (result?.status == "success") {
              if (mounted) {
                loadData();
                Global.selectedPayment = null;
                Global.selectedBank = null;
                Global.selectedAccount = null;
                Global.currentPaymentMethod = null;
                Alert.success(context, 'Success'.tr(), '', 'OK'.tr(), action: () {
                  Navigator.of(context).pop();
                });
              }
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
        });
  }
}