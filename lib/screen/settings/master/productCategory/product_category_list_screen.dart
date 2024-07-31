import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/product_category.dart';
import 'package:motivegold/screen/settings/master/productCategory/add_product_category_screen.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'edit_product_category_screen.dart';


class ProductCategoryListScreen extends StatefulWidget {
  const ProductCategoryListScreen({super.key});

  @override
  State<ProductCategoryListScreen> createState() => _ProductCategoryListScreenState();
}

class _ProductCategoryListScreenState extends State<ProductCategoryListScreen> {
  bool loading = false;
  List<ProductCategoryModel>? list = [];
  Screen? size;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการหมวดสินค้า'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddProductCategoryScreen(
                      ),
                      fullscreenDialog: true))
                  .whenComplete(() {
                loadData();
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.add,
                  size: 50,
                ),
                Text(
                  'เพิ่มหมวดสินค้า',
                  style: TextStyle(fontSize: size.getWidthPx(6)),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : list!.isEmpty ? const EmptyContent() : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                    itemCount: list!.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return productCard(list, index);
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post('/productcategory/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductCategoryModel> products = productCategoryListModelFromJson(data);
        setState(() {
          list = products;
        });
      } else {
        list = [];
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

  Widget productCard(List<ProductCategoryModel>? list, int index) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: ListTile(
              leading: SizedBox(
                width: 100,
                child: Image.asset(
                  'assets/icons/price_tag.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              title: Text(
                list![index].name!,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProductCategoryScreen(
                                productCategory: list[index],
                                index: index
                            ),
                            fullscreenDialog: true))
                        .whenComplete(() {
                      loadData();
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
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    remove(list[index].id!, index);
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

  void remove(int id, int i) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var result = await ApiServices.delete('/productcategory', id);
      await pr.hide();
      if (result?.status == "success") {
        list!.removeAt(i);
        setState(() {
        });
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
  }
}
