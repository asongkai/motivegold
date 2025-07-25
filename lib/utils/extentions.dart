import 'package:flutter/material.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/gold_data.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/util.dart';
extension ColorExtension on String {
  toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}


extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

extension DurationExtensions on Duration {
  /// Converts the duration into a readable string
  /// 05:15
  String toHoursMinutes() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    return "${_toTwoDigits(inHours)}:$twoDigitMinutes";
  }

  /// Converts the duration into a readable string
  /// 05:15:35
  String toHoursMinutesSeconds() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = _toTwoDigits(inSeconds.remainder(60));
    return "${_toTwoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _toTwoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}

// Extension method to calculate order totals from order details
extension OrderCalculations on List<OrderDetailModel> {
  /// Calculates the total price excluding tax from all order details
  double get totalPriceExcludeTax {
    return fold(0.0, (sum, detail) => sum + (detail.priceExcludeTax ?? 0.0));
  }

  /// Calculates the total price difference from all order details
  double get totalPriceDiff {
    return fold(0.0, (sum, detail) => sum + (detail.priceDiff ?? 0.0));
  }

  /// Calculates the total purchase price from all order details
  double get totalPurchasePrice {
    return fold(0.0, (sum, detail) => sum + (detail.purchasePrice ?? 0.0));
  }

  /// Calculates the total tax base from all order details
  double get totalTaxBase {
    return fold(0.0, (sum, detail) => sum + (detail.taxBase ?? 0.0));
  }

  /// Calculates the total tax amount from all order details
  double get totalTaxAmount {
    return fold(0.0, (sum, detail) => sum + (detail.taxAmount ?? 0.0));
  }

  /// Calculates the total price including tax from all order details
  double get totalPriceIncludeTax {
    return fold(0.0, (sum, detail) => sum + (detail.priceIncludeTax ?? 0.0));
  }

  /// Calculates the total commission from all order details
  double get totalCommission {
    return fold(0.0, (sum, detail) => sum + (detail.commission ?? 0.0));
  }

  /// Calculates the total weight in grams from all order details
  double get totalWeight {
    return fold(0.0, (sum, detail) => sum + (detail.weight ?? 0.0));
  }

  /// Calculates the total weight in baht from all order details
  double get totalWeightBath {
    return fold(0.0, (sum, detail) => sum + (detail.weightBath ?? 0.0));
  }
}

// Complete order processing system
class OrderProcessingService {
  /// Processes all orders in the global orders list
  static void processAllOrders({
    required String discount,
    required String addPrice,
    List<OrderModel>? orders,
    CustomerModel? customer,
    String? paymentMethod,
    GoldDataModel? goldDataModel,
  }) {
    final ordersList = orders ?? Global.orders;

    for (int i = 0; i < ordersList.length; i++) {
      processOrder(
        order: ordersList[i],
        discount: discount,
        addPrice: addPrice,
        customer: customer ?? Global.customer,
        paymentMethod: paymentMethod ?? Global.currentPaymentMethod,
        goldDataModel: goldDataModel ?? Global.goldDataModel,
      );
    }
  }

  /// Processes a single order with all calculations
  static void processOrder({
    required OrderModel order,
    required String discount,
    required String addPrice,
    CustomerModel? customer,
    String? paymentMethod,
    GoldDataModel? goldDataModel,
  }) {
    // Initialize basic order fields
    _initializeOrderFields(order, discount, addPrice, customer, paymentMethod);

    // Calculate order totals based on order type
    _calculateOrderTotals(order, goldDataModel);

    // Process all order details
    _processOrderDetails(order, goldDataModel);
  }

  static void _initializeOrderFields(
      OrderModel order,
      String discount,
      String addPrice,
      CustomerModel? customer,
      String? paymentMethod,
      ) {
    final now = DateTime.now();

    order.id = 0;
    order.createdDate = now;
    order.updatedDate = now;
    order.customerId = customer?.id;
    order.status = "0";
    order.discount = Global.toNumber(discount);
    order.addPrice = Global.toNumber(addPrice);
    order.paymentMethod = paymentMethod;
    order.attachment = null;
  }

  static void _calculateOrderTotals(OrderModel order, GoldDataModel? goldDataModel) {
    // Skip calculations for specific order types
    if (_shouldSkipOrderCalculations(order.orderTypeId)) {
      return;
    }

    if (_isOrderType2(order.orderTypeId)) {
      _setZeroOrderTotals(order);
    } else {
      _calculateOrderFinancials(order, goldDataModel);
    }
  }

  static bool _shouldSkipOrderCalculations(int? orderTypeId) {
    return orderTypeId == 5 || orderTypeId == 6 || orderTypeId == 1;
  }

  static bool _isOrderType2(int? orderTypeId) {
    return orderTypeId == 2;
  }

  static void _setZeroOrderTotals(OrderModel order) {
    order.priceIncludeTax = Global.getOrderTotal(order);
    order.purchasePrice = 0;
    order.priceDiff = 0;
    order.taxBase = 0;
    order.taxAmount = 0;
    order.priceExcludeTax = 0;
  }

  static void _calculateOrderFinancials(OrderModel order, GoldDataModel? goldDataModel) {
    final orderTotal = Global.getOrderTotal(order);
    final papunTotal = Global.getPapunTotal(order);
    final totalDifference = orderTotal - papunTotal;
    final taxBaseValue = totalDifference * 100 / 107;
    final taxAmountValue = taxBaseValue * getVatValue();

    order.priceIncludeTax = orderTotal;
    order.purchasePrice = papunTotal;
    order.priceDiff = totalDifference;
    order.taxBase = taxBaseValue;
    order.taxAmount = taxAmountValue;
    order.priceExcludeTax = orderTotal - taxAmountValue;
  }

  static void _processOrderDetails(OrderModel order, GoldDataModel? goldDataModel) {
    if (order.details == null) return;

    for (int j = 0; j < order.details!.length; j++) {
      _processOrderDetail(
        detail: order.details![j],
        orderId: order.id,
        orderTypeId: order.orderTypeId,
        goldDataModel: goldDataModel,
      );
    }
  }

  static void _processOrderDetail({
    required OrderDetailModel detail,
    int? orderId,
    int? orderTypeId,
    GoldDataModel? goldDataModel,
  }) {
    // Initialize basic detail fields
    _initializeDetailFields(detail, orderId);

    // Calculate unit cost
    _calculateDetailUnitCost(detail);

    // Calculate pricing based on order type
    _calculateDetailPricing(detail, orderTypeId, goldDataModel);

    // Set timestamps
    _setDetailTimestamps(detail);
  }

  static void _initializeDetailFields(OrderDetailModel detail, int? orderId) {
    detail.id = 0;
    detail.orderId = orderId;
  }

  static void _calculateDetailUnitCost(OrderDetailModel detail) {
    if (detail.priceIncludeTax != null &&
        detail.weight != null &&
        detail.weight! > 0) {
      detail.unitCost = detail.priceIncludeTax! / detail.weight!;
    }
  }

  static void _calculateDetailPricing(
      OrderDetailModel detail,
      int? orderTypeId,
      GoldDataModel? goldDataModel,
      ) {
    // Skip pricing calculations for specific order types
    if (_shouldSkipDetailPricingCalculations(orderTypeId)) {
      return;
    }

    if (_isOrderType2(orderTypeId)) {
      _setZeroDetailPricing(detail);
    } else {
      _calculateDetailFinancials(detail, goldDataModel);
    }
  }

  static bool _shouldSkipDetailPricingCalculations(int? orderTypeId) {
    return orderTypeId == 4 || orderTypeId == 1;
  }

  static void _setZeroDetailPricing(OrderDetailModel detail) {
    detail.purchasePrice = 0;
    detail.priceDiff = 0;
    detail.taxBase = 0;
    detail.taxAmount = 0;
    detail.priceExcludeTax = 0;
  }

  static void _calculateDetailFinancials(
      OrderDetailModel detail,
      GoldDataModel? goldDataModel,
      ) {
    if (detail.weight == null || detail.priceIncludeTax == null) return;

    final buyPrice = Global.getBuyPrice(detail.weight!, goldDataModel);
    final priceDifference = detail.priceIncludeTax! - buyPrice;
    final taxBaseValue = priceDifference * 100 / 107;
    final taxAmountValue = taxBaseValue * getVatValue();

    detail.purchasePrice = buyPrice;
    detail.priceDiff = priceDifference;
    detail.taxBase = taxBaseValue;
    detail.taxAmount = taxAmountValue;
    detail.priceExcludeTax = detail.priceIncludeTax! - taxAmountValue;
  }

  static void _setDetailTimestamps(OrderDetailModel detail) {
    final now = DateTime.now();
    detail.createdDate = now;
    detail.updatedDate = now;
  }
}

// Extension methods for cleaner usage
extension OrderProcessing on List<OrderModel> {
  /// Processes all orders in this list
  void processAll({
    required String discount,
    required String addPrice,
    CustomerModel? customer,
    String? paymentMethod,
    GoldDataModel? goldDataModel,
  }) {
    OrderProcessingService.processAllOrders(
      orders: this,
      discount: discount,
      addPrice: addPrice,
      customer: customer,
      paymentMethod: paymentMethod,
      goldDataModel: goldDataModel,
    );
  }
}

extension SingleOrderProcessing on OrderModel {
  /// Processes this single order
  void process({
    required String discount,
    required String addPrice,
    CustomerModel? customer,
    String? paymentMethod,
    GoldDataModel? goldDataModel,
  }) {
    OrderProcessingService.processOrder(
      order: this,
      discount: discount,
      addPrice: addPrice,
      customer: customer,
      paymentMethod: paymentMethod,
      goldDataModel: goldDataModel,
    );
  }
}