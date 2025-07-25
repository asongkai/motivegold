import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:sizer/sizer.dart';

class TransferGoldScreen extends StatefulWidget {
  const TransferGoldScreen({super.key});

  @override
  State<TransferGoldScreen> createState() => _TransferGoldScreenState();
}

class _TransferGoldScreenState extends State<TransferGoldScreen>
    with SingleTickerProviderStateMixin {
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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    Global.transfer = null;
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void loadProducts() async {
    setState(() {
      progress = true;
    });
    try {
      var result =
          await ApiServices.post('/product/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post('/binlocation/all/branch',
          Global.requestObj({"branchId": Global.branch?.id}));
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
      productWeightBahtCtrl.text = formatter.format(
          Global.getTotalWeightByLocation(qtyLocationList) /
              getUnitWeightValue());
      qtyLocation = qtyLocationList.isNotEmpty ? qtyLocationList.first : null;
      motivePrint(qtyLocation?.toJson());
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void loadToWarehouse(int id) async {
    try {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      var result = await ApiServices.get('/binlocation/by-branch/$id');
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
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Text("โอนทองไปยังคลังสินค้าใหม่",
                      style: TextStyle(
                          fontSize: 16.sp,
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
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.money,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'ราคาทองคำ',
                                    style: TextStyle(
                                        fontSize: 18.sp, color: Colors.white),
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
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeaderSection(),
                      const SizedBox(height: 24),

                      // Main Content
                      _buildMainContent(formKey),
                      const SizedBox(height: 24),

                      // Transfer List
                      _buildTransferList(),
                      const SizedBox(height: 24),

                      // Summary Section
                      _buildSummarySection(),
                      const SizedBox(height: 24),

                      // Action Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[600]!, Colors.blue[800]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.swap_horiz,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer Gold',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'โอนทองระหว่างคลังสินค้า',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(GlobalKey formKey) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ข้อมูลการโอน',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Source Warehouse & Transfer Type
          Row(
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
                      selectedItemBackgroundColor: Colors.transparent,
                      emptyListMessage: 'ไม่มีข้อมูล',
                      showSelectedItemBackgroundColor: true,
                      itemWidgetBuilder: (int index, WarehouseModel? project,
                          {bool isItemSelected = false}) {
                        return DropDownItemWidget(
                          project: project,
                          isItemSelected: isItemSelected,
                          firstSpace: 10,
                          fontSize: 16.sp,
                        );
                      },
                      onChanged: (WarehouseModel value) {
                        warehouseCtrl.text = value.id!.toString();
                        selectedFromLocation = value;
                        fromWarehouseNotifier!.value = value;
                        if (productCodeCtrl.text != "") {
                          loadQtyByLocation(value.id!);
                          setState(() {});
                        }
                        if (selectedFromLocation != null) {
                          if (selectedTransferType != null &&
                              selectedTransferType!.code == 'BRANCH' &&
                              selectedBranch != null) {
                            loadToWarehouse(selectedBranch!.id!);
                            setState(() {});
                          } else {
                            loadToWarehouseNoId(selectedFromLocation!.id!);
                            setState(() {});
                          }
                        }
                        FocusScope.of(context).requestFocus(FocusNode());
                        setState(() {});
                      },
                      child: DropDownObjectChildWidget(
                        key: GlobalKey(),
                        fontSize: 16.sp,
                        projectValueNotifier: fromWarehouseNotifier!,
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
                    child: MiraiDropDownMenu<ProductTypeModel>(
                      key: UniqueKey(),
                      children: transferTypes(),
                      space: 4,
                      maxHeight: 360,
                      showSearchTextField: true,
                      selectedItemBackgroundColor: Colors.transparent,
                      emptyListMessage: 'ไม่มีข้อมูล',
                      showSelectedItemBackgroundColor: true,
                      itemWidgetBuilder: (int index, ProductTypeModel? project,
                          {bool isItemSelected = false}) {
                        return DropDownItemWidget(
                          project: project,
                          isItemSelected: isItemSelected,
                          firstSpace: 10,
                          fontSize: 16.sp,
                        );
                      },
                      onChanged: (ProductTypeModel project) {
                        selectedTransferType = project;
                        transferTypeNotifier!.value = project;
                        if (selectedTransferType != null &&
                            selectedTransferType!.code == 'BRANCH') {
                          loadBranches();
                          setState(() {});
                        } else {
                          branchList!.clear();
                          if (selectedToLocation != null) {
                            loadToWarehouseNoId(selectedFromLocation!.id!);
                            setState(() {});
                          }
                        }
                        setState(() {});
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: DropDownObjectChildWidget(
                        key: GlobalKey(),
                        fontSize: 16.sp,
                        projectValueNotifier: transferTypeNotifier!,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Branch & Destination Warehouse
          Row(
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
                        selectedItemBackgroundColor: Colors.transparent,
                        showSelectedItemBackgroundColor: true,
                        itemWidgetBuilder: (int index, BranchModel? project,
                            {bool isItemSelected = false}) {
                          return DropDownItemWidget(
                            project: project,
                            isItemSelected: isItemSelected,
                            firstSpace: 10,
                            fontSize: 16.sp,
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
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        child: DropDownObjectChildWidget(
                          key: GlobalKey(),
                          fontSize: 16.sp,
                          projectValueNotifier: branchNotifier!,
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
                      selectedItemBackgroundColor: Colors.transparent,
                      emptyListMessage: 'ไม่มีข้อมูล',
                      showSelectedItemBackgroundColor: true,
                      itemWidgetBuilder: (int index, WarehouseModel? project,
                          {bool isItemSelected = false}) {
                        return DropDownItemWidget(
                          project: project,
                          isItemSelected: isItemSelected,
                          firstSpace: 10,
                          fontSize: 16.sp,
                        );
                      },
                      onChanged: (WarehouseModel value) {
                        toWarehouseCtrl.text = value.id!.toString();
                        selectedToLocation = value;
                        toWarehouseNotifier!.value = value;
                      },
                      child: DropDownObjectChildWidget(
                        key: GlobalKey(),
                        fontSize: 16.sp,
                        projectValueNotifier: toWarehouseNotifier!,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Add Item Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showAddItemDialog(formKey),
              icon: const Icon(Icons.add_circle_outline, size: 24),
              label: Text(
                'เพิ่มรายการ',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: Colors.orange.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildTransferList() {
    if (Global.transferDetail!.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Text(
                'ยังไม่มีรายการโอน',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Text(
                'กดปุ่ม "เพิ่มรายการ" เพื่อเริ่มต้น',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  'รายการโอน',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${Global.transferDetail!.length} รายการ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: Global.transferDetail!.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _itemOrderListModern(
                transfer: Global.transfer!,
                detail: Global.transferDetail![index],
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _itemOrderListModern({
    required TransferModel transfer,
    required TransferDetailModel detail,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.productName ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTransferDisplayText(transfer),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildWeightChip(
                      '${formatter.format(detail.weight)} กรัม',
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildWeightChip(
                      '${formatter.format(detail.weightBath)} บาททอง',
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => removeProduct(index),
              icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[100]!, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: Colors.grey[700], size: 24),
              const SizedBox(width: 12),
              Text(
                'สรุปยอดรวม',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.scale,
                  title: 'น้ำหนักรวม',
                  value:
                      '${formatter.format(Global.getTransferWeightTotalAmount())} กรัม',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.monetization_on,
                  title: 'บาททองรวม',
                  value:
                      '${formatter.format(Global.getTransferWeightTotalAmount() / getUnitWeightValue())} บาททอง',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                Global.transferDetail = [];
              });
            },
            icon: const Icon(Icons.clear_all),
            label: Text(
              'เคลียร์ทั้งหมด',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.red.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              if (Global.transferDetail!.isEmpty) {
                Alert.warning(context, 'คำเตือน', 'กรุณาเพิ่มข้อมูลก่อน', 'OK');
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransferGoldCheckOutScreen(),
                ),
              ).whenComplete(() {
                resetTextAll();
                setState(() {});
              });
            },
            icon: const Icon(Icons.save),
            label: Text(
              'บันทึก',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.teal.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog(GlobalKey formKey) async {
    if (selectedFromLocation == null) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกคลังสินค้าต้นทาง', 'OK');
      return;
    }

    if (selectedTransferType == null) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกประเภทการโอน', 'OK');
      return;
    }

    if (selectedTransferType!.code == 'BRANCH') {
      if (selectedBranch == null) {
        Alert.warning(context, 'คำเตือน', 'กรุณาเลือกสาขาปลายทาง', 'OK');
        return;
      }
    }

    if (selectedToLocation == null) {
      Alert.warning(context, 'คำเตือน', 'กรุณาเลือกคลังสินค้าปลายทาง', 'OK');
      return;
    }



    if (Global.transfer == null) {
      final ProgressDialog pr = ProgressDialog(
        context,
        type: ProgressDialogType.normal,
        isDismissible: true,
        showLogs: true,
      );
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result =
            await ApiServices.post('/order/gen/7', Global.requestObj(null));
        await pr.hide();
        if (result!.status == "success") {
          TransferModel transfer = TransferModel(
            transferId: result.data,
            transferDate: DateTime.now(),
            binLocationId: int.parse(warehouseCtrl.text),
            toBinLocationId: int.parse(toWarehouseCtrl.text),
            fromBinLocationName: selectedFromLocation!.name,
            toBinLocationName: selectedToLocation!.name,
            toBranchId: selectedTransferType!.code == 'INTERNAL'
                ? Global.branch?.id
                : selectedBranch?.id,
            toBranchName: selectedBranch?.name ?? '',
            transferType: selectedTransferType!.code,
            details: Global.transferDetail!,
            orderTypeId: 7,
          );
          final data = transfer.toJson();
          motivePrint(data);
          Global.transfer = TransferModel.fromJson(data);

          resetText();
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    constraints: const BoxConstraints(maxHeight: 600),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.add_circle,
                                color: Colors.blue.shade600, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              'เพิ่มรายการสินค้า',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey.shade100,
                                foregroundColor: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Form(
                              key: formKey,
                              child: _buildAddItemForm(),
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
        } else {
          if (mounted) {
            Alert.warning(
              context,
              'Warning'.tr(),
              'ไม่สามารถสร้างรหัสธุรกรรมได้ \nโปรดติดต่อฝ่ายสนับสนุน',
              'OK'.tr(),
              action: () {},
            );
          }
        }
      } catch (e) {
        await pr.hide();
        if (mounted) {
          Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
              action: () {});
        }
      }
    }
  }

  Widget _buildAddItemForm() {
    return Column(
      children: [
        // Product Selection
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
                    child: MiraiDropDownMenu<ProductModel>(
                      key: UniqueKey(),
                      children: productList,
                      space: 4,
                      maxHeight: 360,
                      showSearchTextField: true,
                      selectedItemBackgroundColor: Colors.transparent,
                      emptyListMessage: 'ไม่มีข้อมูล',
                      showSelectedItemBackgroundColor: true,
                      itemWidgetBuilder: (int index, ProductModel? project,
                          {bool isItemSelected = false}) {
                        return DropDownItemWidget(
                          project: project,
                          isItemSelected: isItemSelected,
                          firstSpace: 10,
                          fontSize: 16.sp,
                        );
                      },
                      onChanged: (ProductModel value) {
                        productCodeCtrl.text = value.id!.toString();
                        productNameCtrl.text = value.name;
                        productNotifier!.value = value;
                        if (warehouseCtrl.text != "") {
                          loadQtyByLocation(selectedFromLocation!.id!);
                        }
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: DropDownObjectChildWidget(
                        key: GlobalKey(),
                        fontSize: 16.sp,
                        projectValueNotifier: productNotifier!,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Current Stock
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTextFieldBig(
                  labelText: "น้ำหนักทั้งหมด (gram)",
                  inputType: TextInputType.number,
                  enabled: false,
                  labelColor: Colors.orange,
                  controller: productWeightCtrl,
                  inputFormat: <TextInputFormatter>[
                    ThousandsFormatter(allowFraction: true)
                  ],
                  onChanged: (String value) {
                    if (productWeightCtrl.text.isNotEmpty) {
                      productWeightBahtCtrl.text = formatter.format(
                          (Global.toNumber(productWeightCtrl.text) /
                                  getUnitWeightValue())
                              .toPrecision(2));
                    } else {
                      productWeightBahtCtrl.text = "";
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTextFieldBig(
                  labelText: "น้ำหนักทั้งหมด (บาททอง)",
                  inputType: TextInputType.phone,
                  enabled: false,
                  labelColor: Colors.orange,
                  controller: productWeightBahtCtrl,
                  inputFormat: <TextInputFormatter>[
                    ThousandsFormatter(allowFraction: true)
                  ],
                  onChanged: (String value) {
                    if (productWeightBahtCtrl.text.isNotEmpty) {
                      productWeightCtrl.text = formatter.format(
                          (Global.toNumber(productWeightBahtCtrl.text) *
                                  getUnitWeightValue())
                              .toPrecision(2));
                    } else {
                      productWeightCtrl.text = "";
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Transfer Amount
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTextFieldBig(
                  labelText: "ป้อนน้ำหนัก (gram)",
                  inputType: TextInputType.number,
                  labelColor: Colors.orange,
                  controller: productEntryWeightCtrl,
                  inputFormat: <TextInputFormatter>[
                    ThousandsFormatter(allowFraction: true)
                  ],
                  onChanged: (String value) {
                    if (productEntryWeightCtrl.text.isNotEmpty) {
                      productEntryWeightBahtCtrl.text = formatter.format(
                          (Global.toNumber(productEntryWeightCtrl.text) /
                                  getUnitWeightValue())
                              .toPrecision(2));
                    } else {
                      productEntryWeightBahtCtrl.text = "";
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTextFieldBig(
                  labelText: "ป้อนน้ำหนัก (บาททอง)",
                  inputType: TextInputType.phone,
                  labelColor: Colors.orange,
                  controller: productEntryWeightBahtCtrl,
                  inputFormat: <TextInputFormatter>[
                    ThousandsFormatter(allowFraction: true)
                  ],
                  onChanged: (String value) {
                    if (productEntryWeightBahtCtrl.text.isNotEmpty) {
                      productEntryWeightCtrl.text = formatter.format(
                          (Global.toNumber(productEntryWeightBahtCtrl.text) *
                                  getUnitWeightValue())
                              .toPrecision(2));
                    } else {
                      productEntryWeightCtrl.text = "";
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Add Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (productEntryWeightCtrl.text.isEmpty) {
                Alert.warning(context, 'คำเตือน', 'กรุณาเพิ่มข้อมูลก่อน', 'OK');
                return;
              }

              if (toWarehouseCtrl.text.isEmpty) {
                Alert.warning(context, 'คำเตือน', 'กรุณาเพิ่มข้อมูลก่อน', 'OK');
                return;
              }

              if (Global.toNumber(productEntryWeightCtrl.text) >
                  Global.toNumber(productWeightCtrl.text)) {
                Alert.warning(context, 'คำเตือน',
                    'ไม่สามารถโอนเกินสต๊อกที่มีอยู่ได้', 'OK');
                return;
              }

              Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                  action: () async {
                Global.transferDetail!.add(
                  TransferDetailModel(
                    productName: productNameCtrl.text,
                    productId: int.parse(productCodeCtrl.text),
                    weight: Global.toNumber(productEntryWeightCtrl.text),
                    weightBath:
                        Global.toNumber(productEntryWeightBahtCtrl.text),
                    unitCost: qtyLocation?.unitCost ?? 0,
                    price: qtyLocation!.unitCost! *
                        Global.toNumber(productEntryWeightCtrl.text),
                  ),
                );
                Global.transfer!.details = Global.transferDetail;
                setState(() {});
                Navigator.of(context).pop();
              });
            },
            icon: const Icon(Icons.add_circle),
            label: Text(
              'เพิ่มรายการ',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    List<TextInputFormatter>? inputFormat,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        buildTextFieldBig(
          labelText: label,
          inputType: TextInputType.number,
          enabled: enabled,
          labelColor: enabled ? Colors.blue : Colors.grey,
          controller: controller,
          inputFormat: inputFormat,
          onChanged: onChanged,
        ),
      ],
    );
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productWeightBahtCtrl.text = "";
    productEntryWeightCtrl.text = "";
    productEntryWeightBahtCtrl.text = "";
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
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

  String _getTransferDisplayText(TransferModel transfer) {
    // Debug: Check what transfer type and data we have
    print('Transfer Type: ${transfer.transferType}');
    print('To Branch Name: ${transfer.toBranchName}');
    print('From Location: ${transfer.fromBinLocationName}');
    print('To Location: ${transfer.toBinLocationName}');

    // For BRANCH transfers - show: From Location → Branch Name (To Location)
    if (transfer.transferType == 'BRANCH' &&
        transfer.toBranchName != null &&
        transfer.toBranchName!.isNotEmpty &&
        transfer.toBranchName != '') {
      return '${transfer.fromBinLocationName} → ${transfer.toBranchName} (${transfer.toBinLocationName})';
    }
    // For INTERNAL transfers - show: From Location → To Location
    else {
      return '${transfer.fromBinLocationName} → ${transfer.toBinLocationName}';
    }
  }
}
