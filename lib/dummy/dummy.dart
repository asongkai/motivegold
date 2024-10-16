import 'package:motivegold/model/product_type.dart';

List<ProductTypeModel> productTypes() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(id: 1, code: 'NEW', name: 'ทองใหม่'));
  data.add(ProductTypeModel(id: 2, code: 'USED', name: 'ทองเก่า'));
  data.add(ProductTypeModel(id: 3, code: 'BAR', name: 'ทองคำแท่ง'));
  data.add(ProductTypeModel(id: 4, code: 'BARM', name: 'ทองคำแท่ง (จับคู่)'));
  return data;
}

List<ProductTypeModel> transferTypes() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(id: 1, code: 'INTERNAL', name: 'ภายใน'));
  data.add(ProductTypeModel(id: 2, code: 'BRANCH', name: 'ระหว่างสาขา'));
  return data;
}

List<ProductTypeModel> userRoles() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(id: 1, code: 'Administrator', name: 'ผู้บริหาร'));
  data.add(ProductTypeModel(id: 2, code: 'Employee', name: 'พนักงานทั่วไป'));
  data.add(ProductTypeModel(id: 3, code: 'Seller', name: 'พนักงานขาย'));
  return data;
}

List<ProductTypeModel> userTypes() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(id: 1, code: 'ADMIN', name: 'ผู้ดูแลระบบ'));
  data.add(ProductTypeModel(id: 2, code: 'COMPANY', name: 'บริษัท'));
  return data;
}

List<ProductTypeModel> paymentTypes() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(id: 1, code: 'CA', name: 'Cash/เงินสด'));
  data.add(ProductTypeModel(id: 2, code: 'TR', name: 'Transfer/เงินโอน'));
  data.add(ProductTypeModel(id: 3, code: 'CR', name: 'Credit card/บัตรเครดิต'));
  data.add(ProductTypeModel(id: 4, code: 'OTH', name: 'Other/อื่นๆ'));
  return data;
}
