import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/storefront/checkout_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/dialog/buy_dialog.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/ui/text_header.dart';
import 'package:sizer/sizer.dart';

class BuyThengScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  final Function(dynamic value) refreshHold;
  int cartCount;

  BuyThengScreen(
      {super.key,
      required this.refreshCart,
      required this.refreshHold,
      required this.cartCount});

  @override
  State<BuyThengScreen> createState() => _BuyThengScreenState();
}

class _BuyThengScreenState extends State<BuyThengScreen>
    with TickerProviderStateMixin {
  bool loading = false;
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  List<QtyLocationModel> qtyLocationList = [];
  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  TextEditingController productCodeCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  TextEditingController productWeightRemainCtrl = TextEditingController();
  TextEditingController productWeightBahtRemainCtrl = TextEditingController();
  TextEditingController productCommissionCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productPriceTotalCtrl = TextEditingController();
  final TextEditingController reserveDateCtrl = TextEditingController();
  TextEditingController marketPriceTotalCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  final controller = BoardDateTimeController();
  DateTime date = DateTime.now();
  late Screen size;

  @override
  void initState() {
    super.initState();
    Global.appBarColor = btBgColor;
    Global.currentRedeemType = 0;
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));

    // Initialize animation controller and animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    // Start animation after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController?.forward();
    });

    sumBuyThengTotal();
    loadProducts();
    getCart();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    warehouseCtrl.dispose();
    marketPriceTotalCtrl.dispose();
    reserveDateCtrl.dispose();
    productPriceTotalCtrl.dispose();
    productPriceCtrl.dispose();
    productCommissionCtrl.dispose();
    productWeightBahtRemainCtrl.dispose();
    productWeightRemainCtrl.dispose();
    productWeightBahtCtrl.dispose();
    productWeightCtrl.dispose();
    productNameCtrl.dispose();
    productCodeCtrl.dispose();
    super.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
          await ApiServices.post('/product/type/BAR', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
        if (productList.isNotEmpty) {
          selectedProduct = productList.first;
          productCodeCtrl.text =
              (selectedProduct != null ? selectedProduct?.productCode! : "")!;
          productNameCtrl.text =
              (selectedProduct != null ? selectedProduct?.name : "")!;
          productNotifier = ValueNotifier<ProductModel>(
              selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
        }
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/sell', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        warehouseList = warehouses;
        selectedWarehouse = warehouseList.first;
        warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ??
            WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
        setState(() {});
        await loadQtyByLocation(selectedWarehouse!.id!);
      } else {
        warehouseList = [];
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

  Future<void> loadQtyByLocation(int id) async {
    try {
      var result = await ApiServices.get(
          '/qtybylocation/by-product-location/$id/${selectedProduct!.id}');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<QtyLocationModel> qtys = qtyLocationListModelFromJson(data);
        setState(() {
          qtyLocationList = qtys;
        });
      } else {
        qtyLocationList = [];
      }

      productWeightRemainCtrl.text =
          formatter.format(Global.getTotalWeightByLocation(qtyLocationList));
      productWeightBahtRemainCtrl.text = formatter.format(
          Global.getTotalWeightByLocation(qtyLocationList) /
              getUnitWeightValue());
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildModernAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SafeArea(
          child: loading
              ? const LoadingProgress()
              : _fadeAnimation != null
                  ? FadeTransition(
                      opacity: _fadeAnimation!,
                      child: _buildMainContent(),
                    )
                  : _buildMainContent(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: btBgColor,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: titleText(context, 'ซื้อทองแท่ง'),
      actions: [
        Container(
          margin: const EdgeInsets.all(6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ราคาทองคำ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildAddItemButton(),
              const Spacer(), // This will push the button to the left
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildOrderList()),
          const SizedBox(height: 16),
          _buildTotalSection(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [btBgColor, btBgColor.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: btBgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BuyDialog(),
                          fullscreenDialog: true))
                  .whenComplete(() {
                setState(() {});
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'เพิ่มสินค้าใหม่',
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

  Widget _buildOrderList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (Global.buyThengOrderDetail!.isNotEmpty) _buildListHeader(),
          Expanded(
            child: Global.buyThengOrderDetail!.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: Global.buyThengOrderDetail!.length,
                    itemBuilder: (context, index) {
                      return _buildModernOrderItem(
                        order: Global.buyThengOrderDetail![index],
                        index: index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: btBgColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('ลำดับ', flex: 1),
          _buildHeaderCell('รายการ', flex: 3),
          _buildHeaderCell('น้ำหนัก (บาท)', flex: 2),
          _buildHeaderCell('จำนวนเงิน', flex: 3),
          _buildHeaderCell('จัดการ', flex: 2),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: btBgColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีทองคำแท่งในรายการซื้อ',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เพิ่มทองคำแท่งเพื่อเริ่มการซื้อ',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOrderItem(
      {required OrderDetailModel order, required int index}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildItemCell('${index + 1}', flex: 1),
          _buildItemCell(order.productName, flex: 3, isProductName: true),
          _buildItemCell(
              '${Global.format(order.weight! / getUnitWeightValue())} บาท',
              flex: 2),
          _buildItemCell(Global.format(order.priceIncludeTax!),
              flex: 3, isMoney: true),
          _buildActionCell(index, flex: 2),
        ],
      ),
    );
  }

  Widget _buildItemCell(String text,
      {required int flex, bool isProductName = false, bool isMoney = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: isProductName ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          color: isMoney ? btBgColor : Colors.grey[800],
          fontWeight: isMoney ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionCell(int index, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            icon: Icons.delete_outline,
            color: Colors.red[600]!,
            onTap: () => removeProduct(index),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8,),
              Text('ลบ')
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ยอดรวมทั้งหมด',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: btBgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${Global.format(Global.buyThengSubTotal)} บาท",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: btBgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildModernButton(
            text: 'ระงับการสั่งซื้อ',
            icon: Icons.pause_circle_outline,
            color: Colors.orange[600]!,
            onPressed: () async {
              if (Global.buyThengOrderDetail!.isEmpty) {
                return;
              }

              OrderModel order = OrderModel(
                  orderId: "",
                  orderDate: DateTime.now(),
                  details: Global.buyThengOrderDetail!,
                  orderTypeId: 44);

              final data = order.toJson();
              Global.holdOrder(OrderModel.fromJson(data));
              Future.delayed(const Duration(milliseconds: 500), () async {
                String holds = (await Global.getHoldList()).length.toString();
                widget.refreshHold(holds);
                setState(() {});
              });

              Global.buyThengOrderDetail!.clear();
              setState(() {
                Global.buyThengSubTotal = 0;
                Global.buyThengTax = 0;
                Global.buyThengTotal = 0;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "ระงับการสั่งซื้อสำเร็จ...",
                    style: TextStyle(fontSize: 18),
                  ),
                  backgroundColor: Colors.orange[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModernButton(
            text: 'เพิ่มลงรถเข็น/ชำระเงิน',
            icon: Icons.shopping_cart_checkout,
            color: btBgColor,
            onPressed: () async {
              if (Global.buyThengOrderDetail!.isEmpty) {
                return;
              }

              try {
                if (Global.sellThengOrderDetail!.isNotEmpty) {
                  OrderModel order = OrderModel(
                      orderId: "",
                      orderDate: DateTime.now(),
                      details: Global.sellThengOrderDetail!,
                      orderTypeId: 4);
                  final data = order.toJson();
                  Global.ordersTheng?.add(OrderModel.fromJson(data));
                  widget.refreshCart(Global.ordersTheng?.length.toString());
                  writeCart();
                  Global.sellThengOrderDetail!.clear();
                  setState(() {
                    Global.sellThengSubTotal = 0;
                    Global.sellThengTax = 0;
                    Global.sellThengTotal = 0;
                  });
                }

                OrderModel order = OrderModel(
                    orderId: "",
                    orderDate: DateTime.now(),
                    details: Global.buyThengOrderDetail!,
                    orderTypeId: 44);
                final data = order.toJson();
                Global.ordersTheng?.add(OrderModel.fromJson(data));
                widget.refreshCart(Global.ordersTheng?.length.toString());
                writeCart();
                Global.buyThengOrderDetail!.clear();
                setState(() {
                  Global.buyThengSubTotal = 0;
                  Global.buyThengTax = 0;
                  Global.buyThengTotal = 0;
                });

                if (mounted) {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CheckOutScreen()))
                      .whenComplete(() {
                    Future.delayed(const Duration(milliseconds: 500), () async {
                      String holds =
                          (await Global.getHoldList()).length.toString();
                      widget.refreshHold(holds);
                      widget.refreshCart(Global.ordersTheng?.length.toString());
                      writeCart();
                      setState(() {});
                    });
                  });
                }
              } catch (e) {
                if (mounted) {
                  Alert.warning(
                      context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
                      action: () {});
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton({
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
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
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

  // Keep all the original methods unchanged
  void comChanged() {
    if (productPriceCtrl.text.isNotEmpty &&
        productCommissionCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text =
          "${Global.format(Global.toNumber(productCommissionCtrl.text) + Global.toNumber(productPriceCtrl.text))}";
      setState(() {});
    }
  }

  void priceChanged() {
    if (productPriceCtrl.text.isNotEmpty &&
        productCommissionCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text = Global.format(
          Global.toNumber(productCommissionCtrl.text) +
              Global.toNumber(productPriceCtrl.text));
      setState(() {});
    }
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text = formatter.format(
          (Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue()));
      marketPriceTotalCtrl.text = Global.format(
          Global.getBuyThengPrice(Global.toNumber(productWeightCtrl.text)));
      productPriceCtrl.text = marketPriceTotalCtrl.text;
      productPriceTotalCtrl.text = productCommissionCtrl.text.isNotEmpty
          ? '${Global.format(Global.toNumber(productCommissionCtrl.text) + Global.toNumber(productPriceCtrl.text))}'
          : Global.format(Global.toNumber(productPriceCtrl.text)).toString();
    } else {
      productWeightCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      productPriceCtrl.text = "";
      productPriceTotalCtrl.text = "";
    }
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productCommissionCtrl.text = "";
    productPriceCtrl.text = "";
    productPriceTotalCtrl.text = "";
    productWeightBahtCtrl.text = "";
    reserveDateCtrl.text = "";
    productWeightRemainCtrl.text = "";
    productWeightBahtRemainCtrl.text = "";
    marketPriceTotalCtrl.text = "";
    warehouseCtrl.text = "";
    selectedProduct = productList.first;
    productCodeCtrl.text =
        (selectedProduct != null ? selectedProduct?.productCode! : "")!;
    productNameCtrl.text =
        (selectedProduct != null ? selectedProduct?.name : "")!;
    productNotifier = ValueNotifier<ProductModel>(
        selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        selectedWarehouse ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
  }

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.buyThengOrderDetail!.removeAt(index);
      if (Global.buyThengOrderDetail!.isEmpty) {
        Global.buyThengOrderDetail!.clear();
      }
      sumBuyThengTotal();
      setState(() {});
    });
  }
}
