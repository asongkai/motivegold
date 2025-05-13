import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/product_category.dart';
import 'package:motivegold/screen/settings/master/productCategory/add_product_category_screen.dart';
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
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  flex: 4,
                  child: Text("รายการหมวดสินค้า",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                if (Global.user!.userRole == 'Administrator')
                Expanded(
                    flex: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                                    'เพิ่มหมวดสินค้า',
                                    style: TextStyle(fontSize: size.getWidthPx(8), color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : list!.isEmpty ? const NoDataFoundWidget() : SingleChildScrollView(
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
                const SizedBox(width: 10,),
                if (Global.user!.userRole == 'Administrator')
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
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง', action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result = await ApiServices.delete('/productcategory', id);
        await pr.hide();
        if (result?.status == "success") {
          list!.removeAt(i);
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
