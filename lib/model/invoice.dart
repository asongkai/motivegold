import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/payment.dart';

class Invoice {
  final CustomerModel customer;
  final OrderModel order;
  final PaymentModel? payment;
  final List<OrderDetailModel> items;

  Invoice({
    required this.customer,
    required this.items,
    required this.order,
    this.payment
  });

}