import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/bank/bank.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/screen/settings/master/bank/add_bank_screen.dart';
import 'package:motivegold/screen/settings/master/bank/edit_bank_screen.dart';
import 'package:motivegold/screen/settings/master/location/amphure/add_amphure_screen.dart';
import 'package:motivegold/screen/settings/master/location/amphure/edit_amphure_screen.dart';
import 'package:motivegold/screen/settings/master/location/province/add_province_screen.dart';
import 'package:motivegold/screen/settings/master/location/province/edit_province_screen.dart';
import 'package:motivegold/screen/settings/master/location/tambon/add_tambon_screen.dart';
import 'package:motivegold/screen/settings/master/location/tambon/edit_tambon_screen.dart';
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
import 'package:sizer/sizer.dart';

class TambonScreen extends StatefulWidget {
  const TambonScreen({super.key});

  @override
  State<TambonScreen> createState() => _TambonScreenState();
}

class _TambonScreenState extends State<TambonScreen> {
  bool loading = false;
  List<TambonModel>? dataList = [];
  Screen? size;

  TextEditingController searchController = TextEditingController();
  List<TambonModel> filteredList = [];

  @override
  void initState() {
    super.initState();
    loadData();
    searchController.addListener(onSearchChanged);
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.get('/location/tambon');
      // motivePrint(result?.toJson());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<TambonModel> products = tambonModelFromJson(data);
        setState(() {
          dataList = products;
          filteredList = products;
          // Global.amphureList = products;
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged() {
    final String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredList = dataList ?? [];
      } else {
        filteredList = (dataList ?? []).where((item) {
          return item.nameEn != null
              ? item.nameEn!.toLowerCase().contains(query) ||
              item.nameTh!.toLowerCase().contains(query)
              : item.nameTh!.toLowerCase().contains(query);
        }).toList();
      }
    });
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
                  child: Text("จัดการตำบล",
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
                                    builder: (context) =>
                                    const AddTambonScreen(),
                                    fullscreenDialog: true))
                                .whenComplete(() {
                              loadData();
                            });
                          },
                          child: Container(
                            color: Colors.teal[900],
                            child: Padding(
                              padding:
                              const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'เพิ่มตำบล',
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
                    ))
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : dataList!.isEmpty
            ? const NoDataFoundWidget()
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'ค้นหาตำบล...'.tr(),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return productCard(filteredList, index);
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productCard(List<TambonModel>? list, int index) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: ListTile(
              title: Text(
                list![index].nameTh ?? '',
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                list[index].nameEn ?? '',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          if (Global.user!.userType == 'ADMIN')
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
                            builder: (context) => EditTambonScreen(
                                tambon: list[index], index: index),
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
                const SizedBox(
                  width: 10,
                ),
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
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          final ProgressDialog pr = ProgressDialog(context,
              type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
          await pr.show();
          pr.update(message: 'processing'.tr());
          try {
            var result = await ApiServices.delete('/location/tambon', id);
            motivePrint(result?.data);
            await pr.hide();
            if (result?.status == "success") {
              dataList!.removeAt(i);
              setState(() {});
            } else {
              if (mounted) {
                Alert.warning(context, 'Warning'.tr(),
                    result!.message ?? result.data, 'OK'.tr(),
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
