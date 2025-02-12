import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/bank/bank.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/screen/settings/master/bank/add_bank_screen.dart';
import 'package:motivegold/screen/settings/master/bank/edit_bank_screen.dart';
import 'package:motivegold/screen/settings/master/productType/add_product_type_screen.dart';
import 'package:motivegold/screen/settings/master/productType/edit_product_type_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';


class BankListScreen extends StatefulWidget {
  const BankListScreen({super.key});

  @override
  State<BankListScreen> createState() => _BankListScreenState();
}

class _BankListScreenState extends State<BankListScreen> {
  bool loading = false;
  List<BankModel>? dataList = [];
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
        title: const Text('จัดการธนาคาร'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddBankScreen(
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
                  'เพิ่มธนาคาร',
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
            : dataList!.isEmpty ? const NoDataFoundWidget() : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                    itemCount: dataList!.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return productCard(dataList, index);
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
      var result = await ApiServices.post('/bank/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<BankModel> products = bankModelFromJson(data);
        setState(() {
          dataList = products;
          Global.bankList = products;
        });
      } else {
        dataList = [];
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

  Widget productCard(List<BankModel>? list, int index) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: ListTile(
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditBankScreen(
                                bank: list[index],
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
        var result = await ApiServices.post('/bank/$id', Global.requestObj(null));
        motivePrint(result?.data);
        await pr.hide();
        if (result?.status == "success") {
          dataList!.removeAt(i);
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
    });


  }
}
