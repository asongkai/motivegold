import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/pos_id.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/settings/master/warehouse/edit_location_screen.dart';
import 'package:motivegold/screen/settings/pos-id/configure_pos_id_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';

class PosIdScreen extends StatefulWidget {
  const PosIdScreen({super.key});

  @override
  State<PosIdScreen> createState() => _PosIdScreenState();
}

class _PosIdScreenState extends State<PosIdScreen> {
  bool loading = false;
  PosIdModel? posIdModel;
  Screen? size;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.get(
          '/company/configure/pos/id/get/${await getDeviceId()}');
      // print(result!.data);
      if (result?.status == "success") {
        var data = PosIdModel.fromJson(result?.data);
        setState(() {
          posIdModel = data;
          Global.posIdModel = data;
        });
      } else {
        posIdModel = null;
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
        title: const Text('คลังสินค้า'),
        actions: const [
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : posIdModel == null
                ? Center(
                    child: KclButton(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConfigurePosIDScreen(
                                        posIdModel: posIdModel),
                                    fullscreenDialog: true))
                            .whenComplete(() {
                          loadData();
                        });
                      },
                      icon: Icons.add,
                      text: 'Config POS ID',
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: productCard(),
                    ),
                  ),
      ),
    );
  }

  Widget productCard() {
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
                'POS ID: ${posIdModel?.posId}',
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Text('Device ID: ${posIdModel?.deviceId}'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (Global.user!.userRole == 'Administrator')
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConfigurePosIDScreen(
                                        posIdModel: posIdModel),
                                    fullscreenDialog: true))
                            .whenComplete(() {
                          loadData();
                        });
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            Text(
                              'แก้ไข',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                if (Global.user!.userRole == 'Administrator')
                  const SizedBox(
                    width: 10,
                  ),
                if (Global.user!.userRole == 'Administrator')
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        removeProduct();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            Text(
                              'ลบ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )
                          ],
                        ),
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

  void removeProduct() async {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result = await ApiServices.post(
            '/company/configure/pos/id/delete/${posIdModel?.id}',
            Global.requestObj(null));
        motivePrint(result?.toJson());
        await pr.hide();
        if (result?.status == "success") {
          loadData();
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
