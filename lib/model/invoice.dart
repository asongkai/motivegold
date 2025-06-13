import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/payment.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/redeem/redeem_detail.dart';

class Invoice {
  final CustomerModel customer;
  final OrderModel order;
  final PaymentModel? payment;
  final List<OrderDetailModel> items;
  final List<PaymentModel>? payments;
  final List<OrderModel>? orders;

  Invoice({
    required this.customer,
    required this.items,
    required this.order,
    this.payment,
    this.payments,
    this.orders,
  });
}

class InvoiceRedeem {
  final CustomerModel customer;
  final RedeemModel order;
  final PaymentModel? payment;
  final List<RedeemDetailModel> items;
  final List<PaymentModel>? payments;
  final List<RedeemModel>? orders;

  InvoiceRedeem({
    required this.customer,
    required this.items,
    required this.order,
    this.payment,
    this.payments,
    this.orders,
  });
}
