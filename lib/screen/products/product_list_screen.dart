import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:sizer/sizer.dart';
import 'edit_product_screen.dart';
import 'new_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool loading = false;
  List<ProductModel>? productList = [];
  Screen? size;

  @override
  void initState() {
    super.initState();

    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
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
                const Text("สินค้า",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w900)),
                if (Global.user!.userRole == 'Administrator')
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NewProductScreen(
                                        showBackButton: true,
                                      ),
                                  fullscreenDialog: true))
                          .whenComplete(() {
                        loadProducts();
                      });
                    },
                    child: Container(
                      color: Colors.teal[900],
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              size: 50,
                              color: Colors.white,
                            ),
                            Text(
                              'เพิ่มสินค้าใหม่',
                              style: TextStyle(
                                  fontSize: 14.sp, //16.sp,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : productList!.isEmpty
                ? const NoDataFoundWidget()
                : SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                          itemCount: productList!.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            return productCard(productList, index);
                          }),
                    ),
                  ),
      ),
    );
  }

  void loadProducts() async {
    setState(() {
      loading = true;
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
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    setState(() {
      loading = false;
    });
  }

  Widget productCard(List<ProductModel>? productList, int index) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: ListTile(
              leading: SizedBox(
                width: 100,
                child: Image.asset(
                  'assets/icons/gold/gold.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              trailing: Text(
                "${productList![index].productType != null ? productList[index].productType!.name : ''}",
                style: const TextStyle(color: Colors.green, fontSize: 15),
              ),
              title: Text(
                productList[index].name,
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                  '${productList[index].productCategory != null ? productList[index].productCategory!.name : ''}'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (Global.user!.userRole == 'Administrator')
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProductScreen(
                                    showBackButton: true,
                                    product: productList[index],
                                    index: index),
                                fullscreenDialog: true))
                        .whenComplete(() {
                      loadProducts();
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (Global.user!.userRole == 'Administrator')
                GestureDetector(
                  onTap: () {
                    removeProduct(productList[index].id!, index);
                  },
                  child: Container(
                    height: 50,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void removeProduct(int id, int i) async {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result = await ApiServices.delete('/product', id);
        await pr.hide();
        if (result?.status == "success") {
          productList!.removeAt(i);
          setState(() {});
        } else {
          if (mounted) {
            Alert.warning(context, 'Warning'.tr(), result!.message!, 'OK'.tr(),
                action: () {});
          }
        }
      } catch (e) {
        await pr.hide();
        if (mounted) {
          Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
              action: () {});
        }
      }
    });
  }
}
