import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/model/transfer_detail.dart';
import 'package:motivegold/screen/transfer/transfer_gold_checkout.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';

class TransferGoldScreen extends StatefulWidget {
  const TransferGoldScreen({super.key});

  @override
  State<TransferGoldScreen> createState() => _TransferGoldScreenState();
}

class _TransferGoldScreenState extends State<TransferGoldScreen> {
  bool progress = false;
  Screen? size;
  List<ProductModel> productList = [];
  List<WarehouseModel> fromWarehouseList = [];
  List<WarehouseModel> toWarehouseList = [];
  List<QtyLocationModel> qtyLocationList = [];
  QtyLocationModel? qtyLocation;
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
  TextEditingController transferTypeCtrl = TextEditingController();

  ProductTypeModel? selectedTransferType;
  ValueNotifier<dynamic>? transferTypeNotifier;
  ValueNotifier<dynamic>? fromWarehouseNotifier;
  ValueNotifier<dynamic>? toWarehouseNotifier;
  ValueNotifier<dynamic>? branchNotifier;
  ValueNotifier<dynamic>? productNotifier;

  TextEditingController branchCtrl = TextEditingController();
  BranchModel? selectedBranch;
  List<BranchModel>? branchList = [];

  @override
  void initState() {
    super.initState();
    selectedTransferType = transferTypes().first;
    transferTypeCtrl.text = selectedTransferType!.name!;
    transferTypeNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(id: 0, name: 'เลือกประเภทการโอน'));
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
      progress = true;
    });
    try {
      var result =
          await ApiServices.post('/product/all', Global.requestObj(null));
      // print(result!.data);
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/branch', Global.requestObj(null));
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
      motivePrint(e.toString());
    }
    setState(() {
      progress = false;
    });
  }

  void loadQtyByLocation(int id) async {
    try {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      var result = await ApiServices.get(
          '/qtybylocation/by-product-location/$id/${int.parse(productCodeCtrl.text)}');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        // motivePrint(data);
        List<QtyLocationModel> qtys = qtyLocationListModelFromJson(data);
        setState(() {
          qtyLocationList = qtys;
        });
      } else {
        qtyLocationList = [];
      }
      await pr.hide();

      productWeightCtrl.text =
          formatter.format(Global.getTotalWeightByLocation(qtyLocationList));
      productWeightBahtCtrl.text = formatter
          .format(Global.getTotalWeightByLocation(qtyLocationList) / getUnitWeightValue());
      qtyLocation = qtyLocationList.isNotEmpty ? qtyLocationList.first : null;
      // motivePrint(qtyLocation?.toJson());
      setState(() {});
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void loadToWarehouse(int id) async {
    // motivePrint(id);
    try {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      var result = await ApiServices.get('/binlocation/by-branch/$id');
      // motivePrint(result!.data);
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        setState(() {
          toWarehouseList = warehouseListModelFromJson(data);
        });
      } else {
        toWarehouseList = [];
      }
      await pr.hide();
      toWarehouseNotifier = ValueNotifier<WarehouseModel>(
          WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
      setState(() {});
      setState(() {});
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
      toWarehouseNotifier = ValueNotifier<WarehouseModel>(
          WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void loadBranches() async {
    try {
      branchNotifier = ValueNotifier<BranchModel>(
          BranchModel(id: 0, name: 'เลือกสาขาปลายทาง'));
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      var result = await ApiServices.get(
          '/branch/by-company-branch/${Global.user!.companyId}/${Global.user!.branchId}');
      // motivePrint(result!.data);
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        setState(() {
          branchList = branchListModelFromJson(data);
        });
      } else {
        setState(() {
          branchList = [];
        });
      }
      await pr.hide();
      toWarehouseList.clear();
      toWarehouseNotifier = ValueNotifier<WarehouseModel>(
          WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
      setState(() {});
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
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  flex: 4,
                  child: Text("โอนทองไปยังคลังสินค้าใหม่",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                          child: Container(
                            color: Colors.teal[900],
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.money,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'ราคาทองคำ',
                                    style: TextStyle(fontSize: size!.getWidthPx(8), color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: progress
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
                            height: 100,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 80,
                                      child: MiraiDropDownMenu<WarehouseModel>(
                                        key: UniqueKey(),
                                        children: fromWarehouseList,
                                        space: 4,
                                        maxHeight: 360,
                                        showSearchTextField: true,
                                        selectedItemBackgroundColor:
                                            Colors.transparent,
                                        emptyListMessage: 'ไม่มีข้อมูล',
                                        showSelectedItemBackgroundColor: true,
                                        itemWidgetBuilder: (
                                          int index,
                                          WarehouseModel? project, {
                                          bool isItemSelected = false,
                                        }) {
                                          return DropDownItemWidget(
                                            project: project,
                                            isItemSelected: isItemSelected,
                                            firstSpace: 10,
                                            fontSize: size!.getWidthPx(6),
                                          );
                                        },
                                        onChanged: (WarehouseModel value) {
                                          warehouseCtrl.text =
                                              value.id!.toString();
                                          selectedFromLocation = value;
                                          fromWarehouseNotifier!.value = value;
                                          if (productCodeCtrl.text != "") {
                                            loadQtyByLocation(value.id!);
                                            setState(() {});
                                          }
                                          if (selectedFromLocation != null) {
                                            if (selectedTransferType != null &&
                                                selectedTransferType!.code ==
                                                    'BRANCH' &&
                                                selectedBranch != null) {
                                              loadToWarehouse(
                                                  selectedBranch!.id!);
                                              setState(() {});
                                            } else {
                                              loadToWarehouseNoId(
                                                  selectedFromLocation!.id!);
                                              setState(() {});
                                            }
                                          }
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          setState(() {});
                                          setState(() {});
                                        },
                                        child: DropDownObjectChildWidget(
                                          key: GlobalKey(),
                                          fontSize: size!.getWidthPx(6),
                                          projectValueNotifier:
                                              fromWarehouseNotifier!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 80,
                                      child:
                                          MiraiDropDownMenu<ProductTypeModel>(
                                        key: UniqueKey(),
                                        children: transferTypes(),
                                        space: 4,
                                        maxHeight: 360,
                                        showSearchTextField: true,
                                        selectedItemBackgroundColor:
                                            Colors.transparent,
                                        emptyListMessage: 'ไม่มีข้อมูล',
                                        showSelectedItemBackgroundColor: true,
                                        itemWidgetBuilder: (
                                          int index,
                                          ProductTypeModel? project, {
                                          bool isItemSelected = false,
                                        }) {
                                          return DropDownItemWidget(
                                            project: project,
                                            isItemSelected: isItemSelected,
                                            firstSpace: 10,
                                            fontSize: size!.getWidthPx(6),
                                          );
                                        },
                                        onChanged: (ProductTypeModel project) {
                                          selectedTransferType = project;
                                          transferTypeNotifier!.value = project;
                                          if (selectedTransferType != null &&
                                              selectedTransferType!.code ==
                                                  'BRANCH') {
                                            loadBranches();
                                            setState(() {});
                                          } else {
                                            branchList!.clear();
                                            if (selectedToLocation != null) {
                                              loadToWarehouseNoId(
                                                  selectedFromLocation!.id!);
                                              setState(() {});
                                            }
                                          }
                                          setState(() {});
                                          setState(() {});
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                        },
                                        child: DropDownObjectChildWidget(
                                          key: GlobalKey(),
                                          fontSize: size!.getWidthPx(6),
                                          projectValueNotifier:
                                              transferTypeNotifier!,
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
                                if (branchList!.isNotEmpty &&
                                    selectedTransferType!.code == "BRANCH")
                                  Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 80,
                                        child: MiraiDropDownMenu<BranchModel>(
                                          key: UniqueKey(),
                                          children: branchList!,
                                          space: 4,
                                          maxHeight: 360,
                                          showSearchTextField: true,
                                          selectedItemBackgroundColor:
                                              Colors.transparent,
                                          showSelectedItemBackgroundColor: true,
                                          itemWidgetBuilder: (
                                            int index,
                                            BranchModel? project, {
                                            bool isItemSelected = false,
                                          }) {
                                            return DropDownItemWidget(
                                              project: project,
                                              isItemSelected: isItemSelected,
                                              firstSpace: 10,
                                              fontSize: size!.getWidthPx(6),
                                            );
                                          },
                                          onChanged: (BranchModel value) {
                                            selectedBranch = value;
                                            branchNotifier!.value = value;
                                            if (selectedBranch != null) {
                                              loadToWarehouse(value.id!);
                                              setState(() {});
                                            }
                                            setState(() {});
                                            setState(() {});
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          },
                                          child: DropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: size!.getWidthPx(6),
                                            projectValueNotifier:
                                                branchNotifier!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 80,
                                      child: MiraiDropDownMenu<WarehouseModel>(
                                        key: UniqueKey(),
                                        children: toWarehouseList,
                                        space: 4,
                                        maxHeight: 360,
                                        showSearchTextField: true,
                                        selectedItemBackgroundColor:
                                            Colors.transparent,
                                        emptyListMessage: 'ไม่มีข้อมูล',
                                        showSelectedItemBackgroundColor: true,
                                        itemWidgetBuilder: (
                                          int index,
                                          WarehouseModel? project, {
                                          bool isItemSelected = false,
                                        }) {
                                          return DropDownItemWidget(
                                            project: project,
                                            isItemSelected: isItemSelected,
                                            firstSpace: 10,
                                            fontSize: size!.getWidthPx(6),
                                          );
                                        },
                                        onChanged: (WarehouseModel value) {
                                          toWarehouseCtrl.text =
                                              value.id!.toString();
                                          selectedToLocation = value;
                                          toWarehouseNotifier!.value = value;
                                        },
                                        child: DropDownObjectChildWidget(
                                          key: GlobalKey(),
                                          fontSize: size!.getWidthPx(6),
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
                                if (selectedFromLocation == null) {
                                  Alert.warning(context, 'คำเตือน',
                                      'กรุณาเลือกคลังสินค้าต้นทาง', 'OK');
                                  return;
                                }

                                if (selectedTransferType == null) {
                                  Alert.warning(context, 'คำเตือน',
                                      'กรุณาเลือกประเภทการโอน', 'OK');
                                  return;
                                }

                                if (selectedToLocation == null) {
                                  Alert.warning(context, 'คำเตือน',
                                      'กรุณาเลือกคลังสินค้าปลายทาง', 'OK');
                                  return;
                                }

                                if (Global.transfer == null) {
                                  final ProgressDialog pr = ProgressDialog(
                                      context,
                                      type: ProgressDialogType.normal,
                                      isDismissible: true,
                                      showLogs: true);
                                  await pr.show();
                                  pr.update(message: 'processing'.tr());
                                  try {
                                    var result = await ApiServices.post(
                                        '/order/gen/7',
                                        Global.requestObj(null));
                                    await pr.hide();
                                    if (result!.status == "success") {
                                      TransferModel transfer = TransferModel(
                                          transferId: result.data,
                                          transferDate: DateTime.now(),
                                          binLocationId:
                                              int.parse(warehouseCtrl.text),
                                          toBinLocationId:
                                              int.parse(toWarehouseCtrl.text),
                                          fromBinLocationName:
                                              selectedFromLocation!.name,
                                          toBinLocationName:
                                              selectedToLocation!.name,
                                          toBranchId: selectedBranch != null
                                              ? selectedBranch!.id
                                              : 0,
                                          toBranchName: selectedBranch != null
                                              ? selectedBranch!.name
                                              : '',
                                          transferType:
                                              selectedTransferType!.code,
                                          details: Global.transferDetail!,
                                          orderTypeId: 7);
                                      final data = transfer.toJson();
                                      Global.transfer =
                                          TransferModel.fromJson(data);
                                    } else {
                                      if (mounted) {
                                        Alert.warning(
                                            context,
                                            'Warning'.tr(),
                                            'ไม่สามารถสร้างรหัสธุรกรรมได้ \nโปรดติดต่อฝ่ายสนับสนุน',
                                            'OK'.tr(),
                                            action: () {});
                                      }
                                    }
                                  } catch (e) {
                                    await pr.hide();
                                    if (mounted) {
                                      Alert.warning(context, 'Warning'.tr(),
                                          e.toString(), 'OK'.tr(),
                                          action: () {});
                                    }
                                  }
                                }
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            3 /
                                                            4,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 100,
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 5,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          80,
                                                                      child: MiraiDropDownMenu<
                                                                          ProductModel>(
                                                                        key:
                                                                            UniqueKey(),
                                                                        children:
                                                                            productList,
                                                                        space:
                                                                            4,
                                                                        maxHeight:
                                                                            360,
                                                                        showSearchTextField:
                                                                            true,
                                                                        selectedItemBackgroundColor:
                                                                            Colors.transparent,
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
                                                                            loadQtyByLocation(selectedFromLocation!.id!);
                                                                          }
                                                                          FocusScope.of(context)
                                                                              .requestFocus(FocusNode());
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
                                                                          inputType: TextInputType
                                                                              .number,
                                                                          enabled:
                                                                              false,
                                                                          textColor: Colors
                                                                              .orange,
                                                                          controller:
                                                                              productWeightCtrl,
                                                                          inputFormat: [
                                                                            ThousandsFormatter(allowFraction: true)
                                                                          ],
                                                                          onChanged:
                                                                              (String value) {
                                                                            if (productWeightCtrl.text.isNotEmpty) {
                                                                              productWeightBahtCtrl.text = formatter.format((Global.toNumber(productWeightCtrl.text) / getUnitWeightValue()).toPrecision(2));
                                                                            } else {
                                                                              productWeightBahtCtrl.text = "";
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
                                                                          inputType: TextInputType
                                                                              .phone,
                                                                          enabled:
                                                                              false,
                                                                          textColor: Colors
                                                                              .orange,
                                                                          controller:
                                                                              productWeightBahtCtrl,
                                                                          inputFormat: [
                                                                            ThousandsFormatter(allowFraction: true)
                                                                          ],
                                                                          onChanged:
                                                                              (String value) {
                                                                            if (productWeightBahtCtrl.text.isNotEmpty) {
                                                                              productWeightCtrl.text = formatter.format((Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue()).toPrecision(2));
                                                                            } else {
                                                                              productWeightCtrl.text = "";
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
                                                                          inputType: TextInputType
                                                                              .number,
                                                                          textColor: Colors
                                                                              .orange,
                                                                          controller:
                                                                              productEntryWeightCtrl,
                                                                          inputFormat: [
                                                                            ThousandsFormatter(allowFraction: true)
                                                                          ],
                                                                          onChanged:
                                                                              (String value) {
                                                                            if (productEntryWeightCtrl.text.isNotEmpty) {
                                                                              productEntryWeightBahtCtrl.text = formatter.format((Global.toNumber(productEntryWeightCtrl.text) / getUnitWeightValue()).toPrecision(2));
                                                                            } else {
                                                                              productEntryWeightBahtCtrl.text = "";
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
                                                                          inputType: TextInputType
                                                                              .phone,
                                                                          textColor: Colors
                                                                              .orange,
                                                                          controller:
                                                                              productEntryWeightBahtCtrl,
                                                                          inputFormat: [
                                                                            ThousandsFormatter(allowFraction: true)
                                                                          ],
                                                                          onChanged:
                                                                              (String value) {
                                                                            if (productEntryWeightBahtCtrl.text.isNotEmpty) {
                                                                              productEntryWeightCtrl.text = formatter.format((Global.toNumber(productEntryWeightBahtCtrl.text) * getUnitWeightValue()).toPrecision(2));
                                                                            } else {
                                                                              productEntryWeightCtrl.text = "";
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
                                                            child:
                                                                OutlinedButton(
                                                              child: const Text(
                                                                  "เพิ่ม"),
                                                              onPressed:
                                                                  () async {
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

                                                                Alert.info(
                                                                    context,
                                                                    'ต้องการบันทึกข้อมูลหรือไม่?',
                                                                    '',
                                                                    'ตกลง',
                                                                    action:
                                                                        () async {
                                                                  Global
                                                                      .transferDetail!
                                                                      .add(
                                                                    TransferDetailModel(
                                                                      productName:
                                                                          productNameCtrl
                                                                              .text,
                                                                      productId:
                                                                          int.parse(
                                                                              productCodeCtrl.text),
                                                                      weight: Global.toNumber(
                                                                          productEntryWeightCtrl
                                                                              .text),
                                                                      weightBath:
                                                                          Global.toNumber(
                                                                              productEntryWeightBahtCtrl.text),
                                                                      unitCost:
                                                                          qtyLocation?.unitCost ??
                                                                              0,
                                                                      price: qtyLocation!
                                                                              .unitCost! *
                                                                          Global.toNumber(
                                                                              productEntryWeightCtrl.text),
                                                                    ),
                                                                  );
                                                                  // motivePrint(TransferDetailModel(
                                                                  //   productName:
                                                                  //   productNameCtrl
                                                                  //       .text,
                                                                  //   productId:
                                                                  //   int.parse(
                                                                  //       productCodeCtrl.text),
                                                                  //   weight: Global.toNumber(
                                                                  //       productEntryWeightCtrl
                                                                  //           .text),
                                                                  //   weightBath:
                                                                  //   Global.toNumber(
                                                                  //       productEntryWeightBahtCtrl.text),
                                                                  //   unitCost:
                                                                  //   qtyLocation!.unitCost ??
                                                                  //       0,
                                                                  //   price: qtyLocation!
                                                                  //       .unitCost! *
                                                                  //       Global.toNumber(
                                                                  //           productEntryWeightCtrl.text),
                                                                  // ).toJson());
                                                                  Global.transfer!
                                                                          .details =
                                                                      Global
                                                                          .transferDetail;
                                                                  setState(
                                                                      () {});
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                });
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
                                  itemCount: Global.transferDetail!.length,
                                  itemBuilder: (context, index) {
                                    return _itemOrderList(
                                        transfer: Global.transfer!,
                                        detail: Global.transferDetail![index],
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
                                            "${formatter.format(Global.getTransferWeightTotalAmount())} กรัม",
                                            style: TextStyle(
                                                fontSize: size!.getWidthPx(8),
                                                fontWeight: FontWeight.bold,
                                                color: textColor2),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${formatter.format(Global.getTransferWeightTotalAmount() / getUnitWeightValue())} บาททอง",
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
                                            Global.transferDetail = [];
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
                                          if (Global.transferDetail!.isEmpty) {
                                            Alert.warning(context, 'คำเตือน',
                                                'กรุณาเพิ่มข้อมูลก่อน', 'OK');
                                            return;
                                          }

                                          Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const TransferGoldCheckOutScreen()))
                                              .whenComplete(() {
                                            resetTextAll();
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
    // warehouseCtrl.text = "";
    // toWarehouseCtrl.text = "";
    // transferTypeNotifier = ValueNotifier<ProductTypeModel>(
    //     ProductTypeModel(id: 0, name: 'เลือกประเภทการโอน'));
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    // fromWarehouseNotifier = ValueNotifier<WarehouseModel>(
    //     WarehouseModel(id: 0, name: 'เลือกคลังสินค้าต้นทาง'));
    // toWarehouseNotifier = ValueNotifier<WarehouseModel>(
    //     WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
    // branchNotifier = ValueNotifier<BranchModel>(
    //     BranchModel(id: 0, name: 'เลือกสาขาปลายทาง'));
  }

  resetTextAll() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productWeightBahtCtrl.text = "";
    productEntryWeightCtrl.text = "";
    productEntryWeightBahtCtrl.text = "";
    warehouseCtrl.text = "";
    toWarehouseCtrl.text = "";
    transferTypeNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(id: 0, name: 'เลือกประเภทการโอน'));
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    fromWarehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้าต้นทาง'));
    toWarehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
    branchNotifier = ValueNotifier<BranchModel>(
        BranchModel(id: 0, name: 'เลือกสาขาปลายทาง'));
  }

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.transferDetail!.removeAt(index);
      if (Global.transferDetail!.isEmpty) {
        Global.transferDetail!.clear();
      }
    });
    setState(() {});
  }

  Widget _itemOrderList(
      {required TransferModel transfer,
      required TransferDetailModel detail,
      required index}) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: ListTile(
            title: ListTileData(
              leftTitle:
                  '${transfer.fromBinLocationName} --- ${transfer.toBinLocationName}',
              leftValue: detail.weight!.toString(),
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
