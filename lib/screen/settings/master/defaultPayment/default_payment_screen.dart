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
    // TODO: implement initState
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
      // motivePrint(Global.requestObj(null));
      var result = await ApiServices.post(
          '/defaultpayment/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        // Global.printLongString(data);
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
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("ตั้งค่าค่าเริ่มต้น การชำระเงิน",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : dataList!.isEmpty
                ? const NoDataFoundWidget()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: dataList!.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return productCard(dataList, index);
                        }),
                  ),
      ),
    );
  }

  Widget productCard(List<OrderTypeModel>? list, int index) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: ListTile(
              title: Text(
                'หน้าจอ ${list![index].name!}',
                style: const TextStyle(fontSize: 30),
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'วิธีการชำระเงินเริ่มต้น: ',
                        style: TextStyle(fontSize: 20),
                      ),
                      Flexible(
                          child: Text(
                        '${getPaymentType(list[index].paymentCode)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      )),
                    ],
                  ),
                  if (list[index].paymentCode == 'TR')
                    const SizedBox(
                      width: 20,
                    ),
                  if (list[index].paymentCode == 'TR')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ธนาคาร: ',
                          style: TextStyle(fontSize: 20),
                          overflow: TextOverflow.visible,
                        ),
                        Flexible(
                            child: Text(
                          '${list[index].payment?.bankName}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900),
                          overflow: TextOverflow.visible,
                        )),
                      ],
                    ),
                  if (list[index].paymentCode == 'TR')
                    const SizedBox(
                      width: 20,
                    ),
                  if (list[index].paymentCode == 'TR')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'บัญชีธนาคาร: ',
                          style: TextStyle(fontSize: 20),
                          overflow: TextOverflow.visible,
                        ),
                        Flexible(
                            child: Text(
                          '${list[index].payment?.accountName}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900),
                          overflow: TextOverflow.visible,
                        )),
                      ],
                    )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      productDialog(list[index]);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'ตั้งค่าเริ่มต้น',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
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
    );
  }

  void productDialog(OrderTypeModel model) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -50.0,
                  top: -50.0,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
                Form(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: SizedBox(
                      width: (MediaQuery.of(context).orientation ==
                              Orientation.landscape)
                          ? MediaQuery.of(context).size.width * 2 / 4
                          : MediaQuery.of(context).size.width * 3 / 4,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(color: btBgColor),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'หน้าจอ ${model.name}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: size?.getWidthPx(15),
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'การชำระเงินเริ่มต้น',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: size?.getWidthPx(10),
                                    color: textColor),
                              ),
                            ),
                            PaymentDefaultWidget(
                              payment: model.payment,
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: KclButton(
                                  text: 'บันทึก',
                                  icon: Icons.save_alt_outlined,
                                  fullWidth: true,
                                  onTap: () {
                                    save(context, model);
                                  },
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
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

    // motivePrint(warehouseModel?.toJson());
    // motivePrint(paymentModel?.toJson());

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        // motivePrint(Global.requestObj(model));
        var result = await ApiServices.post(
            '/defaultpayment/create', Global.requestObj(paymentModel));
        await pr.hide();
        // motivePrint(result?.toJson());
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
