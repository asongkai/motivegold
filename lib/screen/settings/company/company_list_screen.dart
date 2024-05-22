import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/screen/settings/company/edit_company_screen.dart';
import 'package:motivegold/screen/settings/company/new_company_screen.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../../api/api_services.dart';
import '../../../utils/alert.dart';
import '../../../utils/global.dart';
import '../../../utils/util.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  bool loading = false;
  List<CompanyModel>? list = [];
  Screen? size;

  @override
  void initState() {
    super.initState();

    loadProducts();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result = Global.user!.userType == 'ADMIN' ? await ApiServices.get('/company') : await ApiServices.get('/company/${Global.user!.companyId}');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<CompanyModel> products = Global.user!.userType == 'ADMIN' ? companyListModelFromJson(data) : [CompanyModel.fromJson(result!.data)];
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

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('บริษัท'),
        actions: [
          if (Global.user!.userType == 'ADMIN')
          GestureDetector(
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NewCompanyScreen(
                                showBackButton: true,
                              ),
                          fullscreenDialog: true))
                  .whenComplete(() {
                loadProducts();
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.add,
                  size: 50,
                ),
                Text(
                  'เพิ่มบริษัทใหม่',
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
            : list!.isEmpty ? const EmptyContent() :  SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                        itemCount: list!.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return dataCard(list![index], index);
                        }),
                  ),
                ),
              ),
      ),
    );
  }

  Widget dataCard(CompanyModel? list, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: ListTile(
                leading: SizedBox(
                  width: 100,
                  child: Image.asset(
                    'assets/images/default_profile.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                trailing: Text(
                  "${list!.phone}",
                  style: const TextStyle(color: Colors.green, fontSize: 15),
                ),
                title: Text(
                  list.name,
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle: Text('${list.address}'),
              ),
            ),
            Expanded(
              flex: Global.user!.userType == 'ADMIN' ? 1 : 0,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditCompanyScreen(
                                showBackButton: true,
                                company: list,
                                index: index
                              ),
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
                  if (Global.user!.userType == 'ADMIN')
                  const Spacer(),
                  if (Global.user!.userType == 'ADMIN')
                  GestureDetector(
                    onTap: () {
                      removeProduct(list.id!, index);
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
      ),
    );
  }

  void removeProduct(int id, int i) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var result = await ApiServices.delete('/company', id);
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
