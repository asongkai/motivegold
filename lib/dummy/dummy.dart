import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/product_type.dart';

List<ProductModel> products() {
  List<ProductModel> data = [];
  data.add(ProductModel(
    id: "1",
    productCode: 'NN1BS01',
    productName: 'ทองใหม่ สร้อยคอ style 01 1 บาท',
    price: 30700,
  ));
  data.add(ProductModel(
    id: "2",
    productCode: 'OG',
    productName: 'ทองเก่า (old gold) 2 สลึง',
    price: 14700,
  ));
  return data;
}

List<ProductTypeModel> productType() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(
    id: "1",
    code: 'BUY',
    name: 'Buy old gold from customer'
  ));
  data.add(ProductTypeModel(
    id: "2",
    code: 'SELL',
    name: 'Sell new gold to customer'
  ));
  data.add(ProductTypeModel(
      id: "3",
      code: 'USED GOLD',
      name: 'Customer deposit interest'
  ));
  return data;
}
