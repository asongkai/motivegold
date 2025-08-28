import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/pawn/rate_int.dart';
import 'package:motivegold/screen/settings/pawn/rateint/add_rate_int_screen.dart';
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
import 'edit_rate_int_screen.dart';

class RateIntListScreen extends StatefulWidget {
  const RateIntListScreen({super.key});

  @override
  State<RateIntListScreen> createState() => _RateIntListScreenState();
}

class _RateIntListScreenState extends State<RateIntListScreen> {
  bool loading = false;
  List<RateIntModel>? list = [];
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
                  child: Text("รายการอัตราดอกเบี้ย",
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
                                      builder: (context) => const AddRateIntScreen(),
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
                                      'เพิ่มอัตราดอกเบี้ย',
                                      style: TextStyle(
                                          fontSize: 14.sp,
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
            : list!.isEmpty
            ? const NoDataFoundWidget()
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                    itemCount: list!.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return rateIntCard(list, index);
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
      var result = await ApiServices.post('/rateint/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<RateIntModel> rateInts = rateIntListModelFromJson(data);
        setState(() {
          list = rateInts;
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

  Widget rateIntCard(List<RateIntModel>? list, int index) {
    final NumberFormat formatter = NumberFormat('#,##0.00');

    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: ListTile(
              // leading: SizedBox(
              //   width: 100,
              //   child: Image.asset(
              //     'assets/icons/interest_rate.png', // You may need to add this icon
              //     fit: BoxFit.fitHeight,
              //   ),
              // ),
              title: Text(
                list![index].name!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'จำนวนเงิน: ${formatter.format(list[index].amountFrom)} - ${formatter.format(list[index].amountTo)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'อัตราดอกเบี้ย: ${list[index].rate}%',
                    style: const TextStyle(fontSize: 16, color: Colors.green),
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
                if (Global.user!.userRole == 'Administrator')
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditRateIntScreen(
                                  rateInt: list[index], index: index),
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
                const SizedBox(width: 10),
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
        var result = await ApiServices.delete('/rateint', id);
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