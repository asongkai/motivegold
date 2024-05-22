import 'dart:convert';

// import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/screen/used/sell_used_gold_checkout.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:motivegold/utils/extentions.dart';
import '../../api/api_services.dart';
import '../../constants/colors.dart';
import '../../model/branch.dart';
import '../../model/order.dart';
import '../../model/order_detail.dart';
import '../../model/product.dart';
import '../../model/warehouseModel.dart';
import '../../utils/alert.dart';
import '../../utils/global.dart';
import '../../utils/responsive_screen.dart';
import '../../utils/util.dart';
import '../../widget/dropdown/DropDownItemWidget.dart';
import '../../widget/dropdown/DropDownObjectChildWidget.dart';
import '../../widget/list_tile_data.dart';
import '../../widget/loading/loading_progress.dart';
import '../gold/gold_price_screen.dart';

class SellUsedGoldScreen extends StatefulWidget {
  const SellUsedGoldScreen({super.key});

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
  TextEditingController warehouseCtrl = TextEditingController();
  TextEditingController toWarehouseCtrl = TextEditingController();

  ProductModel? selectedProduct;
  ValueNotifier<dynamic>? fromWarehouseNotifier;
  ValueNotifier<dynamic>? toWarehouseNotifier;
  ValueNotifier<dynamic>? branchNotifier;
  ValueNotifier<dynamic>? productNotifier;

  @override
  void initState() {
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    fromWarehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้าต้นทาง'));
    toWarehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
    branchNotifier = ValueNotifier<BranchModel>(
        BranchModel(id: 0, name: 'เลือกสาขาปลายทาง'));
    loadProducts();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
          await ApiServices.post('/product/type/USED', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
      } else {
        productList = [];
      }

      var warehouse =
          await ApiServices.post('/binlocation/all', Global.requestObj(null));
      // print(warehouse!.data);
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        setState(() {
          fromWarehouseList = warehouseListModelFromJson(data);
          toWarehouseList = warehouseListModelFromJson(data);
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

  void loadQtyByLocation(int id) async {
    try {
      var result = await ApiServices.get(
          '/qtybylocation/by-product-location/$id/${int.parse(productCodeCtrl.text)}');
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
          formatter.format(Global.getTotalWeightByLocation(qtyLocationList));
      productWeightBahtCtrl.text = formatter
          .format(Global.getTotalWeightByLocation(qtyLocationList) / 15.16);
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

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey();
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ขายทองเก่า'),
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
                  style: TextStyle(fontSize: size!.getWidthPx(6)),
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
                              onPressed: () {
                                if (Global.order == null) {
                                  OrderModel order = OrderModel(
                                      orderId: generateRandomString(10),
                                      orderDate: DateTime.now().toUtc(),
                                      details: Global.usedSellDetail!,
                                      orderTypeId: 0);
                                  final data = order.toJson();
                                  Global.order = OrderModel.fromJson(data);
                                }
                                resetText();
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
                                                  width: MediaQuery.of(context)
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
                                                                      emptyListMessage:
                                                                          'ไม่มีข้อมูล',
                                                                      showSelectedItemBackgroundColor:
                                                                          true,
                                                                      itemWidgetBuilder:
                                                                          (
                                                                        int index,
                                                                        ProductModel?
                                                                            project, {
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
                                                                              size!.getWidthPx(6),
                                                                        );
                                                                      },
                                                                      onChanged:
                                                                          (ProductModel
                                                                              value) {
                                                                        productCodeCtrl.text = value
                                                                            .id!
                                                                            .toString();
                                                                        productNameCtrl.text =
                                                                            value.name;
                                                                        productNotifier!.value =
                                                                            value;
                                                                        if (warehouseCtrl.text !=
                                                                            "") {
                                                                          loadQtyByLocation(
                                                                              selectedFromLocation!.id!);
                                                                        }
                                                                      },
                                                                      child:
                                                                          DropDownObjectChildWidget(
                                                                        key:
                                                                            GlobalKey(),
                                                                        fontSize:
                                                                            size!.getWidthPx(6),
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
                                                                          fromWarehouseList,
                                                                      space: 4,
                                                                      maxHeight:
                                                                          360,
                                                                      showSearchTextField:
                                                                          true,
                                                                      selectedItemBackgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      emptyListMessage:
                                                                          'ไม่มีข้อมูล',
                                                                      showSelectedItemBackgroundColor:
                                                                          true,
                                                                      itemWidgetBuilder:
                                                                          (
                                                                        int index,
                                                                        WarehouseModel?
                                                                            project, {
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
                                                                              size!.getWidthPx(6),
                                                                        );
                                                                      },
                                                                      onChanged:
                                                                          (WarehouseModel
                                                                              value) {
                                                                        warehouseCtrl.text = value
                                                                            .id!
                                                                            .toString();
                                                                        selectedFromLocation =
                                                                            value;
                                                                        fromWarehouseNotifier!.value =
                                                                            value;
                                                                        if (productCodeCtrl.text !=
                                                                            "") {
                                                                          loadQtyByLocation(
                                                                              value.id!);
                                                                        }
                                                                        if (selectedFromLocation !=
                                                                            null) {
                                                                          loadToWarehouseNoId(
                                                                              selectedFromLocation!.id!);
                                                                        }
                                                                      },
                                                                      child:
                                                                          DropDownObjectChildWidget(
                                                                        key:
                                                                            GlobalKey(),
                                                                        fontSize:
                                                                            size!.getWidthPx(6),
                                                                        projectValueNotifier:
                                                                            fromWarehouseNotifier!,
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
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    buildTextFieldBig(
                                                                        labelText:
                                                                            "น้ำหนักทั้งหมด (gram)",
                                                                        inputType:
                                                                            TextInputType
                                                                                .number,
                                                                        enabled:
                                                                            false,
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
                                                                            (String
                                                                                value) {
                                                                          if (productWeightCtrl
                                                                              .text
                                                                              .isNotEmpty) {
                                                                            productWeightBahtCtrl.text =
                                                                                formatter.format((Global.toNumber(productWeightCtrl.text) / 15.16).toPrecision(2));
                                                                          } else {
                                                                            productWeightBahtCtrl.text =
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
                                                                            "น้ำหนักทั้งหมด (บาททอง)",
                                                                        inputType:
                                                                            TextInputType
                                                                                .phone,
                                                                        enabled:
                                                                            false,
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
                                                                            (String
                                                                                value) {
                                                                          if (productWeightBahtCtrl
                                                                              .text
                                                                              .isNotEmpty) {
                                                                            productWeightCtrl.text =
                                                                                formatter.format((Global.toNumber(productWeightBahtCtrl.text) * 15.16).toPrecision(2));
                                                                          } else {
                                                                            productWeightCtrl.text =
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
                                                                            "ป้อนน้ำหนัก (gram)",
                                                                        inputType:
                                                                            TextInputType
                                                                                .number,
                                                                        textColor:
                                                                            Colors
                                                                                .orange,
                                                                        controller:
                                                                            productEntryWeightCtrl,
                                                                        inputFormat: [
                                                                          ThousandsFormatter(
                                                                              allowFraction: true)
                                                                        ],
                                                                        onChanged:
                                                                            (String
                                                                                value) {
                                                                          if (productEntryWeightCtrl
                                                                              .text
                                                                              .isNotEmpty) {
                                                                            productEntryWeightBahtCtrl.text =
                                                                                formatter.format((Global.toNumber(productEntryWeightCtrl.text) / 15.16).toPrecision(2));
                                                                          } else {
                                                                            productEntryWeightBahtCtrl.text =
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
                                                                            "ป้อนน้ำหนัก (บาททอง)",
                                                                        inputType:
                                                                            TextInputType
                                                                                .phone,
                                                                        textColor:
                                                                            Colors
                                                                                .orange,
                                                                        controller:
                                                                            productEntryWeightBahtCtrl,
                                                                        inputFormat: [
                                                                          ThousandsFormatter(
                                                                              allowFraction: true)
                                                                        ],
                                                                        onChanged:
                                                                            (String
                                                                                value) {
                                                                          if (productEntryWeightBahtCtrl
                                                                              .text
                                                                              .isNotEmpty) {
                                                                            productEntryWeightCtrl.text =
                                                                                formatter.format((Global.toNumber(productEntryWeightBahtCtrl.text) * 15.16).toPrecision(2));
                                                                          } else {
                                                                            productEntryWeightCtrl.text =
                                                                                "";
                                                                          }
                                                                        }),
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
                                                                          toWarehouseList,
                                                                      space: 4,
                                                                      maxHeight:
                                                                          360,
                                                                      showSearchTextField:
                                                                          true,
                                                                      selectedItemBackgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      emptyListMessage:
                                                                          'ไม่มีข้อมูล',
                                                                      showSelectedItemBackgroundColor:
                                                                          true,
                                                                      itemWidgetBuilder:
                                                                          (
                                                                        int index,
                                                                        WarehouseModel?
                                                                            project, {
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
                                                                              size!.getWidthPx(6),
                                                                        );
                                                                      },
                                                                      onChanged:
                                                                          (WarehouseModel
                                                                              value) {
                                                                        toWarehouseCtrl.text = value
                                                                            .id!
                                                                            .toString();
                                                                        selectedToLocation =
                                                                            value;
                                                                        toWarehouseNotifier!.value =
                                                                            value;
                                                                      },
                                                                      child:
                                                                          DropDownObjectChildWidget(
                                                                        key:
                                                                            GlobalKey(),
                                                                        fontSize:
                                                                            size!.getWidthPx(6),
                                                                        projectValueNotifier:
                                                                            toWarehouseNotifier!,
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
                                                          child: OutlinedButton(
                                                            child: const Text(
                                                                "เพิ่ม"),
                                                            onPressed:
                                                                () async {
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

                                                              if (productEntryWeightCtrl
                                                                  .text
                                                                  .isEmpty) {
                                                                Alert.warning(
                                                                    context,
                                                                    'คำเตือน',
                                                                    'กรุณาเพิ่มข้อมูลก่อน',
                                                                    'OK');
                                                                return;
                                                              }

                                                              if (toWarehouseCtrl
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
                                                                  .usedSellDetail!
                                                                  .add(
                                                                OrderDetailModel(
                                                                  productName:
                                                                      productNameCtrl
                                                                          .text,
                                                                  productId: int.parse(
                                                                      productCodeCtrl
                                                                          .text),
                                                                  binLocationId:
                                                                      int.parse(
                                                                          warehouseCtrl
                                                                              .text),
                                                                  toBinLocationId:
                                                                      int.parse(
                                                                          toWarehouseCtrl
                                                                              .text),
                                                                  binLocationName:
                                                                      selectedFromLocation!
                                                                          .name,
                                                                  toBinLocationName:
                                                                      selectedToLocation!
                                                                          .name,
                                                                  weight: Global
                                                                      .toNumber(
                                                                          productEntryWeightCtrl
                                                                              .text),
                                                                  weightBath: Global
                                                                      .toNumber(
                                                                          productEntryWeightBahtCtrl
                                                                              .text),
                                                                  commission: 0,
                                                                  taxBase: 0,
                                                                  priceIncludeTax:
                                                                      Global.getSellPrice(
                                                                          Global.toNumber(
                                                                              productEntryWeightCtrl.text)),
                                                                ),
                                                              );
                                                              Global.order!
                                                                      .details =
                                                                  Global
                                                                      .usedSellDetail;
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
                                  itemCount: Global.usedSellDetail!.length,
                                  itemBuilder: (context, index) {
                                    return _itemOrderList(
                                        order: Global.usedSellDetail![index],
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
                                            fontSize: size!.getWidthPx(8),
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF636564)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Text(
                                            "${formatter.format(Global.getUsedSellWeightTotalAmount())} กรัม",
                                            style: TextStyle(
                                                fontSize: size!.getWidthPx(8),
                                                fontWeight: FontWeight.bold,
                                                color: textColor2),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${formatter.format(Global.getUsedSellWeightTotalAmount() / 15.16)} บาททอง",
                                            style: TextStyle(
                                                fontSize: size!.getWidthPx(8),
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
                                            Global.usedSellDetail = [];
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
                                                  fontSize:
                                                      size!.getWidthPx(8)),
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
                                          if (Global.usedSellDetail!.isEmpty) {
                                            Alert.warning(context, 'คำเตือน',
                                                'กรุณาเพิ่มข้อมูลก่อน', 'OK');
                                            return;
                                          }

                                          Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SellUsedGoldCheckOutScreen()))
                                              .whenComplete(() {
                                            setState(() {});
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.save),
                                            const SizedBox(width: 6),
                                            Text(
                                              'บันทึก',
                                              style: TextStyle(
                                                  fontSize:
                                                      size!.getWidthPx(8)),
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

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productWeightBahtCtrl.text = "";
    productEntryWeightCtrl.text = "";
    productEntryWeightBahtCtrl.text = "";
    warehouseCtrl.text = "";
    toWarehouseCtrl.text = "";
  }

  removeProduct(index) {
    Global.usedSellDetail!.removeAt(index);
    if (Global.usedSellDetail!.isEmpty) {
      Global.usedSellDetail!.clear();
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
              leftTitle:
                  '${order.binLocationName} --- ${order.toBinLocationName}',
              leftValue: order.weight!.toString(),
              rightTitle: '',
              rightValue: '',
              single: true,
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
