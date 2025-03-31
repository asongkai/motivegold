import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/bank/bank.dart';
import 'package:motivegold/model/bank/bank_account.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/screen/settings/master/bank/add_bank_screen.dart';
import 'package:motivegold/screen/settings/master/bank/edit_bank_screen.dart';
import 'package:motivegold/screen/settings/master/bankAccount/add_bank_account_screen.dart';
import 'package:motivegold/screen/settings/master/bankAccount/edit_bank_account_screen.dart';
import 'package:motivegold/screen/settings/master/productType/add_product_type_screen.dart';
import 'package:motivegold/screen/settings/master/productType/edit_product_type_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
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


class BankAccountListScreen extends StatefulWidget {
  const BankAccountListScreen({super.key});

  @override
  State<BankAccountListScreen> createState() => _BankAccountListScreenState();
}

class _BankAccountListScreenState extends State<BankAccountListScreen> {
  bool loading = false;
  List<BankAccountModel>? dataList = [];
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
                  child: Text("จัดการบัญชีธนาคาร",
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddBankAccountScreen(
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
                                    'เพิ่มบัญชีธนาคาร',
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
            : dataList!.isEmpty ? const NoDataFoundWidget() : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    const SizedBox(height: 50, child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex: 2,
                            child: Text(
                              "รหัสธนาคาร",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Expanded(flex: 2,
                            child: Text(
                              "เลขที่บัญชี",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Expanded(flex: 2,
                            child: Text(
                              "ชื่อบัญชี",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Expanded(flex: 2,
                            child: Text(
                              "ประเภทบัญชี",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Expanded(flex: 2,
                            child: Text(
                              " ",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),),
                    Expanded(
                      child: ListView.builder(
                          itemCount: dataList!.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            return productCard(dataList, index);
                          }),
                    ),
                  ],
                ),
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
      var result = await ApiServices.post('/bankaccount/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<BankAccountModel> products = bankAccountModelFromJson(data);
        setState(() {
          dataList = products;
          Global.accountList = products;
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

  Widget productCard(List<BankAccountModel>? list, int index) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 8,
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 2,
                      child: Text(
                        "${list![index].bankCode}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Expanded(flex: 2,
                      child: Text(
                        "${list[index].accountNo}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Expanded(flex: 2,
                      child: Text(
                        "${list[index].name}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Expanded(flex: 2,
                      child: Text(
                        "${displayAccountType(list[index].accountType)}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
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
                              builder: (context) => EditBankAccountScreen(
                                  account: list[index],
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
        const Divider(thickness: 1, height: 5,)
      ],
    );
  }

  void remove(int id, int i) async {

    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง', action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result = await ApiServices.post('/bankaccount/$id', Global.requestObj(null));
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

  displayAccountType(String? accountType) {
    var data = bankAccountTypes().where((e) => e.code == accountType).toList();
    if (data.isNotEmpty) {
      return data.first.name;
    }
    return null;
  }
}
