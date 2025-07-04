import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/auth_log.dart';
import 'package:motivegold/screen/reports/auth-history/preview.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/text/expend_text.dart';
import 'package:sizer/sizer.dart';

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
                  child: Text("ประวัติการเข้าใช้ระบบ",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PreviewAuthHistoryPage(
                                    invoice: productList!),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.print,
                                  size: 50, color: Colors.white),
                              Text(
                                'พิมพ์',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.white),
                              )
                            ],
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
      var result = await ApiServices.post('/authlog', Global.requestObj(null));
      motivePrint(result?.toJson());
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
                child: Image.asset(
                  productList![index].type!.toUpperCase() == 'LOGIN' ||
                          productList[index].type!.toUpperCase() == "ACTIVE" ||
                          productList[index].type!.toUpperCase() == "OPEN"
                      ? 'assets/icons/icons8-checkmark.png'
                      : 'assets/icons/icons8-close_window.png',
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
                      const SizedBox(
                        width: 20,
                      ),
                      Text('Username: ${productList[index].user!.username!}')
                    ],
                  )
                ],
              ),
              subtitle:
                  ExpandableText(text: '${productList[index].deviceDetail}'),
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
  }
}
