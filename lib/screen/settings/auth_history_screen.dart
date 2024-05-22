import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/auth_log.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../api/api_services.dart';
import '../../utils/alert.dart';
import '../../utils/global.dart';
import '../../widget/text/expend_text.dart';

class AuthHistoryScreen extends StatefulWidget {
  const AuthHistoryScreen({super.key});

  @override
  State<AuthHistoryScreen> createState() => _AuthHistoryScreenState();
}

class _AuthHistoryScreenState extends State<AuthHistoryScreen> {
  bool loading = false;
  List<AuthLogModel>? productList = [];
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
      appBar: AppBar(
        title: const Text('ประวัติการเข้าใช้ระบบ'),
        actions: [
          GestureDetector(
            onTap: () {

            },
            child: Row(
              children: [
                const Icon(
                  Icons.add,
                  size: 50,
                ),
                Text(
                  'เพิ่มสินค้าใหม่',
                  style: TextStyle(fontSize: size.getWidthPx(6)),
                )
              ],
            ),
          ),
          const SizedBox(width: 20,)
        ],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : productList!.isEmpty ? const EmptyContent() : SingleChildScrollView(
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
      var result = await ApiServices.post('/authlog', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<AuthLogModel> products = authLogListModelFromJson(data);
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

  Widget productCard(List<AuthLogModel>? productList, int index) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: ListTile(
              leading: SizedBox(
                width: 100,
                child: Image.asset( productList![index].type!.toUpperCase() == 'LOGIN' ?
                  'assets/icons/icons8-checkmark.png' : 'assets/icons/icons8-close_window.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              trailing: Text(
                Global.formatDate(productList[index].date.toString()),
                style: const TextStyle(color: Colors.green, fontSize: 15),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productList[index].type!.toUpperCase(),
                    style: const TextStyle(fontSize: 20),
                  ),
                  Row(
                    children: [
                      Text('User ID: ${productList[index].user!.id}'),
                      const SizedBox(width: 20,),
                      Text('Username: ${productList[index].user!.username!}')
                    ],
                  )
                ],
              ),
              subtitle: ExpandableText(text: '${productList[index].deviceDetail}'),
            ),
          ),
        ],
      ),
    );
  }

  void removeProduct(int id, int i) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var result = await ApiServices.delete('/product', id);
      await pr.hide();
      if (result?.status == "success") {
        productList!.removeAt(i);
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
