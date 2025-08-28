import 'package:motivegold/model/product_type.dart';

List<ProductTypeModel> productTypes() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(id: 1, code: 'NEW', name: 'ทองใหม่'));
  data.add(ProductTypeModel(id: 2, code: 'USED', name: 'ทองเก่า'));
  data.add(ProductTypeModel(id: 3, code: 'BAR', name: 'ทองคำแท่ง'));
  data.add(ProductTypeModel(id: 4, code: 'BARM', name: 'ทองคำแท่ง (จับคู่)'));
  data.add(ProductTypeModel(id: 5, code: 'PKG', name: 'บรรจุภัณฑ์'));
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
  data.add(ProductTypeModel(id: 5, code: 'DP', name: 'Deposit/ฝากธนาคาร'));
  return data;
}

List<ProductTypeModel> customerTypes() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(id: 1, code: 'company', name: 'นิติบุคคล'));
  data.add(ProductTypeModel(id: 2, code: 'general', name: 'บุคคลธรรมดา'));
  return data;
}

List<ProductTypeModel> bankAccountTypes() {
  List<ProductTypeModel> data = [];
  data.add(
      ProductTypeModel(id: 1, code: 'SA', name: 'ออมทรัพย์ (Savings Account)'));
  data.add(ProductTypeModel(
      id: 2, code: 'FA', name: 'ฝากประจำ (Fixed Deposit Account)'));
  data.add(ProductTypeModel(
      id: 3, code: 'CA', name: 'กระแสรายวัน (Current Account)'));
  return data;
}

List<ProductTypeModel> orderTypes() {
  List<ProductTypeModel> data = [];
  // data.add(ProductTypeModel(id: null, code: null, name: "ทั้งหมด"));
  data.add(ProductTypeModel(id: 1, code: 'SN', name: "ขายทองรูปพรรณใหม่"));
  data.add(ProductTypeModel(id: 2, code: 'BU', name: "รับซื้อทองรูปพรรณเก่า"));
  data.add(ProductTypeModel(id: 3, code: 'SMB', name: "ขายทองแท่ง (จับคู่)"));
  data.add(ProductTypeModel(id: 33, code: 'SB', name: "ซื้อทองแท่ง (จับคู่)"));
  data.add(ProductTypeModel(id: 4, code: 'BMB', name: 'ขายทองแท่ง'));
  data.add(ProductTypeModel(id: 44, code: 'BB', name: "ซื้อทองแท่ง"));
  data.add(ProductTypeModel(id: 5, code: 'RF', name: "เติมทองรูปพรรณกับร้านค้าส่ง"));
  data.add(ProductTypeModel(id: 6, code: 'SU', name: "ขายทองรูปพรรณเก่าให้ร้านค้าส่ง"));
  data.add(ProductTypeModel(id: 7, code: 'TR', name: "โอนทอง"));
  data.add(
      ProductTypeModel(id: 8, code: 'SBB', name: "ขายทองแท่งกับโบรกเกอร์"));
  data.add(
      ProductTypeModel(id: 9, code: 'BBB', name: "ซื้อทองแท่งกับโบรกเกอร์"));
  data.add(ProductTypeModel(
      id: 10, code: 'RFB', name: "เติมทองคำแท่งกับร้านค้าส่ง"));
  data.add(ProductTypeModel(
      id: 11, code: 'SUB', name: "ขายทองคำแท่งเก่าให้ร้านค้าส่ง"));
  return data;
}

List<ProductTypeModel> redeemTypes() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(id: 1, code: 'RED', name: "ไถ่ถอน - ขายฝาก"));
  return data;
}


List<ProductTypeModel> pawnPrinciples() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(id: 1, code: 'Tic_minus_int', name: "มูลค่าขายฝากลบผลประโยชน์สะสม"));
  data.add(ProductTypeModel(id: 1, code: 'Tic_price', name: "มูลค่าขายฝาก"));
  return data;
}

List<ProductTypeModel> intMethods() {
  List<ProductTypeModel> data = [];
  data.add(ProductTypeModel(id: 1, code: 'Month', name: "เดือน"));
  data.add(ProductTypeModel(id: 2, code: 'Day', name: "วัน"));
  data.add(ProductTypeModel(id: 3, code: 'Hour', name: "ปี"));
  return data;
}
