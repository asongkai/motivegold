import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/product_list_tile.dart';
import 'package:select_dialog/select_dialog.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailAddressCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  TextEditingController? productTypeCtrl = TextEditingController();
  TextEditingController? productCtrl = TextEditingController();

  ProductTypeModel? selectedProductType;
  ProductModel? selectedProduct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ค้นหา'.tr()), automaticallyImplyLeading: false,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        getProportionateScreenWidth(
                          8,
                        ),
                      ),
                      topRight: Radius.circular(
                        getProportionateScreenWidth(
                          8,
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      getProportionateScreenWidth(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        SelectDialog.showModal<ProductTypeModel>(
                                          context,
                                          label: "เลือกประเภท",
                                          selectedValue: selectedProductType,
                                          alwaysShowScrollBar: true,
                                          items: productType(),
                                          searchBoxDecoration: const InputDecoration(hintText: "ค้นหา"),
                                          onChange: (ProductTypeModel? selected) {
                                            setState(() {
                                              productTypeCtrl?.text = selected!.code!;
                                            });
                                          },
                                        );
                                      },
                                      child: buildTextFieldBig(
                                          enabled: false,
                                          labelText: "ประเภทสินค้า",
                                          textColor: Colors.orange,
                                          controller: productTypeCtrl,
                                          option: true),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        SelectDialog.showModal<ProductModel>(
                                          context,
                                          label: "เลือกประเภท",
                                          selectedValue: selectedProduct,
                                          alwaysShowScrollBar: true,
                                          items: products(),
                                          searchBoxDecoration: const InputDecoration(hintText: "ค้นหา"),
                                          onChange: (ProductModel selected) {
                                            setState(() {
                                              productCtrl!.text = selected.productCode!;
                                            });
                                          },
                                        );
                                      },
                                      child: buildTextFieldBig(
                                          enabled: false,
                                          labelText: "รหัสสินค้า",
                                          textColor: Colors.orange,
                                          controller: productCtrl,
                                          option: true),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    buildTextFieldBig(
                                      labelText: 'ชื่อ'.tr(),
                                      validator: null,
                                      inputType: TextInputType.text,
                                      controller: firstNameCtrl,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    buildTextFieldBig(
                                      labelText: 'นามสกุล'.tr(),
                                      validator: null,
                                      inputType: TextInputType.text,
                                      controller: lastNameCtrl,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: TextField(
                                  controller: fromDateCtrl,
                                  style: const TextStyle(fontSize: 38),
                                  //editing controller of this TextField
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    //icon of text field
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                    labelText: "จากวันที่".tr(),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(8),
                                      ),
                                      borderSide: const BorderSide(
                                        color: kGreyShade3,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(2),
                                      ),
                                      borderSide: const BorderSide(
                                        color: kGreyShade3,
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  //set it true, so that user will not able to edit text
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        //DateTime.now() - not to allow to choose before today.
                                        lastDate: DateTime(2101));
                                    if (pickedDate != null) {
                                      print(
                                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                      String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                      print(
                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                      //you can implement different kind of Date Format here according to your requirement
                                      setState(() {
                                        fromDateCtrl.text =
                                            formattedDate; //set output date to TextField value.
                                      });
                                    } else {
                                      print("Date is not selected");
                                    }
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: TextField(
                                  controller: toDateCtrl,
                                  //editing controller of this TextField
                                  style: const TextStyle(fontSize: 38),
                                  //editing controller of this TextField
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    //icon of text field
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                    labelText: "ถึงวันที่".tr(),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(8),
                                      ),
                                      borderSide: const BorderSide(
                                        color: kGreyShade3,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        getProportionateScreenWidth(2),
                                      ),
                                      borderSide: const BorderSide(
                                        color: kGreyShade3,
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  //set it true, so that user will not able to edit text
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        //DateTime.now() - not to allow to choose before today.
                                        lastDate: DateTime(2101));
                                    if (pickedDate != null) {
                                      print(
                                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                      String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                      print(
                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                      //you can implement different kind of Date Format here according to your requirement
                                      setState(() {
                                        toDateCtrl.text =
                                            formattedDate; //set output date to TextField value.
                                      });
                                    } else {
                                      print("Date is not selected");
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(3.0),
                            vertical: getProportionateScreenHeight(5.0),
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(bgColor3)
                            ),
                            onPressed: () {

                            },
                            child: Text('ค้นหา'.tr(), style: const TextStyle(fontSize: 32),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      // color: bgColor4,
                    ),
                    child: ListView.builder(
                        itemCount: products().length,
                        itemBuilder: (context, index) {
                          return ProductListTileData(leftTitle: products()[index].productName, leftValue: products()[index].price.toString(), rightTitle: 'น้ำหนัก', rightValue: products()[index].weight.toString(),);
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemOrder({
    required String image,
    required String title,
    required String qty,
    required String price,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        formatter.format(double.parse(price)),
        style: const TextStyle(fontSize: 25),
      ),
      trailing: Text(qty),
    );
  }
}
