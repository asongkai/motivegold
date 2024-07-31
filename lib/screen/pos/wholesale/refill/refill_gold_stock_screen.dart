import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/wholesale/wholesale_checkout_screen.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:motivegold/api/api_services.dart';
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
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class RefillGoldStockScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  int cartCount;
  RefillGoldStockScreen({super.key, required this.refreshCart, required this.cartCount});

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
  TextEditingController warehouseCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    productTypeNotifier =
        ValueNotifier<ProductTypeModel>(ProductTypeModel(id: 0, name: 'เลือกประเภท'));
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey();
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('เติมทอง'),
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
                  style: TextStyle(fontSize: size.getWidthPx(6)),
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
            : Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: bgColor3.withAlpha(80),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.orange,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                resetText();
                                if (mounted) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                right: -40.0,
                                                top: -40.0,
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const CircleAvatar(
                                                    backgroundColor: Colors.red,
                                                    child: Icon(Icons.close),
                                                  ),
                                                ),
                                              ),
                                              Form(
                                                key: formKey,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                        FocusNode());
                                                  },
                                                  child: SizedBox(
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width *
                                                        3 /
                                                        4,
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 100,
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 5,
                                                                  child: Padding(
                                                                    padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                    child:
                                                                    SizedBox(
                                                                      height: 80,
                                                                      child: MiraiDropDownMenu<
                                                                          ProductModel>(
                                                                        key:
                                                                        UniqueKey(),
                                                                        children:
                                                                        productList,
                                                                        space: 4,
                                                                        maxHeight:
                                                                        360,
                                                                        showSearchTextField:
                                                                        true,
                                                                        selectedItemBackgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                        emptyListMessage: 'ไม่มีข้อมูล',
                                                                        showSelectedItemBackgroundColor:
                                                                        true,
                                                                        itemWidgetBuilder:
                                                                            (
                                                                            int index,
                                                                            ProductModel?
                                                                            project,
                                                                            {
                                                                              bool isItemSelected =
                                                                              false,
                                                                            }) {
                                                                          return DropDownItemWidget(
                                                                            project:
                                                                            project,
                                                                            isItemSelected:
                                                                            isItemSelected,
                                                                            firstSpace:
                                                                            10,
                                                                            fontSize:
                                                                            size
                                                                                .getWidthPx(
                                                                                6),
                                                                          );
                                                                        },
                                                                        onChanged:
                                                                            (
                                                                            ProductModel
                                                                            value) {
                                                                          productCodeCtrl
                                                                              .text =
                                                                              value
                                                                                  .productCode!
                                                                                  .toString();
                                                                          productNameCtrl
                                                                              .text =
                                                                              value
                                                                                  .name;
                                                                          selectedProduct =
                                                                              value;
                                                                          productNotifier!
                                                                              .value =
                                                                              value;
                                                                        },
                                                                        child:
                                                                        DropDownObjectChildWidget(
                                                                          key:
                                                                          GlobalKey(),
                                                                          fontSize:
                                                                          size
                                                                              .getWidthPx(
                                                                              6),
                                                                          projectValueNotifier:
                                                                          productNotifier!,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                            child: buildTextFieldBig(
                                                                labelText:
                                                                "รหัสสินค้า",
                                                                textColor:
                                                                Colors.orange,
                                                                controller:
                                                                productCodeCtrl,
                                                                enabled: false),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                  buildTextFieldBig(
                                                                      labelText:
                                                                      "น้ำหนัก (gram)",
                                                                      inputType:
                                                                      TextInputType
                                                                          .number,
                                                                      textColor:
                                                                      Colors
                                                                          .orange,
                                                                      controller:
                                                                      productWeightCtrl,
                                                                      inputFormat: [
                                                                        ThousandsFormatter(
                                                                            allowFraction: true)
                                                                      ],
                                                                      onChanged:
                                                                          (
                                                                          String
                                                                          value) {
                                                                        if (productWeightCtrl
                                                                            .text
                                                                            .isNotEmpty) {
                                                                          productSellPriceCtrl
                                                                              .text =
                                                                              Global
                                                                                  .getSellPrice(
                                                                                  Global
                                                                                      .toNumber(
                                                                                      productWeightCtrl
                                                                                          .text))
                                                                                  .toString();
                                                                          productBuyPriceCtrl
                                                                              .text =
                                                                              Global
                                                                                  .getBuyPrice(
                                                                                  Global
                                                                                      .toNumber(
                                                                                      productWeightCtrl
                                                                                          .text))
                                                                                  .toString();
                                                                          productWeightBahtCtrl
                                                                              .text =
                                                                              Global
                                                                                  .format(
                                                                                  (Global
                                                                                      .toNumber(
                                                                                      productWeightCtrl
                                                                                          .text) /
                                                                                      15.16));
                                                                        } else {
                                                                          productWeightBahtCtrl
                                                                              .text =
                                                                          "";
                                                                        }
                                                                      }),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                  buildTextFieldBig(
                                                                      labelText:
                                                                      "น้ำหนัก (บาททอง)",
                                                                      inputType:
                                                                      TextInputType
                                                                          .phone,
                                                                      textColor:
                                                                      Colors
                                                                          .orange,
                                                                      controller:
                                                                      productWeightBahtCtrl,
                                                                      inputFormat: [
                                                                        ThousandsFormatter(
                                                                            allowFraction: true)
                                                                      ],
                                                                      onChanged:
                                                                          (
                                                                          String
                                                                          value) {
                                                                        if (productWeightBahtCtrl
                                                                            .text
                                                                            .isNotEmpty) {
                                                                          productWeightCtrl
                                                                              .text =
                                                                              Global
                                                                                  .format(
                                                                                  (Global
                                                                                      .toNumber(
                                                                                      productWeightBahtCtrl
                                                                                          .text) *
                                                                                      15.16));
                                                                          productSellPriceCtrl
                                                                              .text =
                                                                              Global
                                                                                  .getSellPrice(
                                                                                  Global
                                                                                      .toNumber(
                                                                                      productWeightCtrl
                                                                                          .text))
                                                                                  .toString();
                                                                          productBuyPriceCtrl
                                                                              .text =
                                                                              Global
                                                                                  .getBuyPrice(
                                                                                  Global
                                                                                      .toNumber(
                                                                                      productWeightCtrl
                                                                                          .text))
                                                                                  .toString();
                                                                        } else {
                                                                          productWeightCtrl
                                                                              .text =
                                                                          "";
                                                                        }
                                                                      }),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            height: 100,
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 5,
                                                                  child: Padding(
                                                                    padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                    child:
                                                                    buildTextFieldBig(
                                                                      labelText:
                                                                      "ขายออก",
                                                                      inputType:
                                                                      TextInputType
                                                                          .phone,
                                                                      enabled:
                                                                      false,
                                                                      textColor:
                                                                      Colors
                                                                          .orange,
                                                                      controller:
                                                                      productSellPriceCtrl,
                                                                      inputFormat: [
                                                                        ThousandsFormatter(
                                                                            allowFraction:
                                                                            true)
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
                                                                    padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                    child: buildTextFieldBig(
                                                                        labelText:
                                                                        "รับซื้อ (ฐานภาษี)",
                                                                        inputType:
                                                                        TextInputType
                                                                            .number,
                                                                        textColor:
                                                                        Colors
                                                                            .orange,
                                                                        controller:
                                                                        productBuyPriceCtrl,
                                                                        inputFormat: [
                                                                          ThousandsFormatter(
                                                                              allowFraction:
                                                                              true)
                                                                        ],
                                                                        enabled:
                                                                        false),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 100,
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 5,
                                                                  child: Padding(
                                                                    padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                    child:
                                                                    SizedBox(
                                                                      height: 80,
                                                                      child: MiraiDropDownMenu<
                                                                          WarehouseModel>(
                                                                        key:
                                                                        UniqueKey(),
                                                                        children:
                                                                        warehouseList,
                                                                        space: 4,
                                                                        maxHeight:
                                                                        360,
                                                                        showSearchTextField:
                                                                        true,
                                                                        selectedItemBackgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                        emptyListMessage: 'ไม่มีข้อมูล',
                                                                        showSelectedItemBackgroundColor:
                                                                        true,
                                                                        itemWidgetBuilder:
                                                                            (
                                                                            int index,
                                                                            WarehouseModel?
                                                                            project,
                                                                            {
                                                                              bool isItemSelected =
                                                                              false,
                                                                            }) {
                                                                          return DropDownItemWidget(
                                                                            project:
                                                                            project,
                                                                            isItemSelected:
                                                                            isItemSelected,
                                                                            firstSpace:
                                                                            10,
                                                                            fontSize:
                                                                            size
                                                                                .getWidthPx(
                                                                                6),
                                                                          );
                                                                        },
                                                                        onChanged:
                                                                            (
                                                                            WarehouseModel
                                                                            value) {
                                                                          warehouseCtrl
                                                                              .text =
                                                                              value
                                                                                  .id!
                                                                                  .toString();
                                                                          selectedWarehouse =
                                                                              value;
                                                                          warehouseNotifier!
                                                                              .value =
                                                                              value;
                                                                        },
                                                                        child:
                                                                        DropDownObjectChildWidget(
                                                                          key:
                                                                          GlobalKey(),
                                                                          fontSize:
                                                                          size
                                                                              .getWidthPx(
                                                                              6),
                                                                          projectValueNotifier:
                                                                          warehouseNotifier!,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                            child: OutlinedButton(
                                                              child: const Text(
                                                                  "เพิ่ม"),
                                                              onPressed:
                                                                  () async {
                                                                if (productCodeCtrl
                                                                    .text
                                                                    .isEmpty) {
                                                                  Alert.warning(
                                                                      context,
                                                                      'คำเตือน',
                                                                      'กรุณาเพิ่มข้อมูลก่อน',
                                                                      'OK');
                                                                  return;
                                                                }

                                                                if (productWeightCtrl
                                                                    .text
                                                                    .isEmpty) {
                                                                  Alert.warning(
                                                                      context,
                                                                      'คำเตือน',
                                                                      'กรุณาเพิ่มข้อมูลก่อน',
                                                                      'OK');
                                                                  return;
                                                                }

                                                                if (warehouseCtrl
                                                                    .text
                                                                    .isEmpty) {
                                                                  Alert.warning(
                                                                      context,
                                                                      'คำเตือน',
                                                                      'กรุณาเพิ่มข้อมูลก่อน',
                                                                      'OK');
                                                                  return;
                                                                }

                                                                Global
                                                                    .refillOrderDetail!
                                                                    .add(
                                                                  OrderDetailModel(
                                                                    productName:
                                                                    selectedProduct!.name,
                                                                    productId: selectedProduct!
                                                                        .id,
                                                                    binLocationId: selectedWarehouse!.id,
                                                                    binLocationName: selectedWarehouse!.name,
                                                                    weight: Global
                                                                        .toNumber(
                                                                        productWeightCtrl
                                                                            .text),
                                                                    weightBath: Global
                                                                        .toNumber(
                                                                        productWeightBahtCtrl
                                                                            .text),
                                                                    commission: 0,
                                                                    taxBase: 0,
                                                                    priceIncludeTax:
                                                                    Global
                                                                        .toNumber(
                                                                        productBuyPriceCtrl
                                                                            .text),
                                                                  ),
                                                                );
                                                                setState(() {});
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                }
                                setState(() {});
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, size: 32),
                                  SizedBox(width: 6),
                                  Text(
                                    'เพิ่ม',
                                    style: TextStyle(fontSize: 32),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: bgColor2,
                              ),
                              child: ListView.builder(
                                  itemCount: Global.refillOrderDetail!.length,
                                  itemBuilder: (context, index) {
                                    return _itemOrderList(
                                        order: Global.refillOrderDetail![index],
                                        index: index);
                                  }),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: bgColor4,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        'ยอดรวม',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(8),
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF636564)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Text(
                                            "${Global.format(Global.getRefillWeightTotalAmount())} กรัม",
                                            style: TextStyle(
                                                fontSize: size.getWidthPx(8),
                                                fontWeight: FontWeight.bold,
                                                color: textColor2),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${Global.format(Global.getRefillWeightTotalAmount() / 15.16)} บาททอง",
                                            style: TextStyle(
                                                fontSize: size.getWidthPx(8),
                                                fontWeight: FontWeight.bold,
                                                color: textColor2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: bgColor4,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.teal,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (Global.refillOrderDetail!.isEmpty) {
                                            return;
                                          }

                                          final ProgressDialog pr = ProgressDialog(context,
                                              type: ProgressDialogType.normal,
                                              isDismissible: true,
                                              showLogs: true);
                                          await pr.show();
                                          pr.update(message: 'processing'.tr());
                                          try {
                                            var result = await ApiServices.post('/order/gen/5', Global.requestObj(null));
                                            await pr.hide();
                                            if (result!.status == "success") {
                                              OrderModel order = OrderModel(
                                                  orderId: result.data,
                                                  orderDate: DateTime.now().toUtc(),
                                                  details: Global.refillOrderDetail!,
                                                  orderTypeId: 5);
                                              final data = order.toJson();
                                              Global.orders
                                                  ?.add(OrderModel.fromJson(data));
                                              widget.refreshCart(
                                                  Global.orders?.length.toString());
                                              Global.refillOrderDetail!.clear();
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "เพิ่มลงรถเข็นสำเร็จ...",
                                                        style: TextStyle(
                                                            fontSize: 22),
                                                      ),
                                                      backgroundColor: Colors
                                                          .teal,
                                                    ));
                                              }
                                            } else {
                                              if (mounted) {
                                                Alert.warning(
                                                    context, 'Warning'.tr(), 'ไม่สามารถสร้างรหัสธุรกรรมได้ \nโปรดติดต่อฝ่ายสนับสนุน', 'OK'.tr(),
                                                    action: () {});
                                              }
                                            }

                                          } catch (e) {
                                            await pr.hide();
                                            if (mounted) {
                                              Alert.warning(
                                                  context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
                                                  action: () {});
                                            }
                                          }


                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.add, size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              'เพิ่มลงในรถเข็น',
                                              style: TextStyle(
                                                  fontSize: size.getWidthPx(8)),
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
                                          backgroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            Global.refillOrderDetail = [];
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.close, size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              'เคลียร์',
                                              style: TextStyle(
                                                  fontSize: size.getWidthPx(8)),
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
                                          backgroundColor: Colors.teal[700],
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (Global
                                              .refillOrderDetail!.isEmpty) {
                                            Alert.warning(context, 'คำเตือน',
                                                'กรุณาเพิ่มข้อมูลก่อน', 'OK');
                                            return;
                                          }

                                          final ProgressDialog pr = ProgressDialog(context,
                                              type: ProgressDialogType.normal,
                                              isDismissible: true,
                                              showLogs: true);
                                          await pr.show();
                                          pr.update(message: 'processing'.tr());
                                          try {
                                            var result = await ApiServices.post('/order/gen/5', Global.requestObj(null));
                                            await pr.hide();
                                            if (result!.status == "success") {
                                              OrderModel order = OrderModel(
                                                  orderId: result.data,
                                                  orderDate: DateTime.now().toUtc(),
                                                  details: Global.refillOrderDetail!,
                                                  orderTypeId: 5);
                                              final data = order.toJson();
                                              Global.orders
                                                  ?.add(OrderModel.fromJson(data));
                                              widget.refreshCart(
                                                  Global.orders?.length.toString());
                                              Global.refillOrderDetail!.clear();
                                              if (mounted) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                        const WholesaleCheckOutScreen()))
                                                    .whenComplete(() {
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500),
                                                          () async {
                                                        widget.refreshCart(
                                                            Global
                                                                .orders?.length
                                                                .toString());
                                                        setState(() {});
                                                      });
                                                });
                                              }
                                            } else {
                                              if (mounted) {
                                                Alert.warning(
                                                    context, 'Warning'.tr(), 'ไม่สามารถสร้างรหัสธุรกรรมได้ \nโปรดติดต่อฝ่ายสนับสนุน', 'OK'.tr(),
                                                    action: () {});
                                              }
                                            }

                                          } catch (e) {
                                            await pr.hide();
                                            if (mounted) {
                                              Alert.warning(
                                                  context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
                                                  action: () {});
                                            }
                                          }


                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.arrow_forward),
                                            const SizedBox(width: 6),
                                            Text(
                                              'ต่อไป',
                                              style: TextStyle(
                                                  fontSize: size.getWidthPx(8)),
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
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post('/product/refill', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        // motivePrint(data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post('/binlocation/all', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        setState(() {
          warehouseList = warehouses;
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

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productSellPriceCtrl.text = "";
    productBuyPriceCtrl.text = "";
    productWeightBahtCtrl.text = "";
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
  }

  removeProduct(index) {
    Global.refillOrderDetail!.removeAt(index);
    if (Global.refillOrderDetail!.isEmpty) {
      Global.refillOrderDetail!.clear();
    }
    setState(() {});
  }

  Widget _itemOrderList({required OrderDetailModel order, required index}) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: ListTile(
            title: ListTileData(
              leftTitle: order.productName,
              leftValue: '${order.weight!.toString()} กรัม',
              rightTitle: 'คลังสินค้า',
              rightValue: '${order.binLocationName}',
              single: null,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  removeProduct(index);
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
