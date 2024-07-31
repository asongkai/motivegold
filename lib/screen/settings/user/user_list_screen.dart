import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/user.dart';
import 'package:motivegold/screen/settings/user/edit_user_screen.dart';
import 'package:motivegold/screen/settings/user/new_user_screen.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/empty.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  bool loading = false;
  List<UserModel>? list = [];
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
      var result = Global.user!.userType == 'ADMIN' ? await ApiServices.get('/user') :  await ApiServices.get('/user/by-company/${Global.user!.companyId}');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<UserModel> products = userListModelFromJson(data);
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
        title: const Text('ผู้ใช้'),
        actions: [
          if (Global.user!.userRole == 'Administrator')
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NewUserScreen(
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
                  'เพิ่มผู้ใช้',
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



  Widget dataCard(UserModel? list, int index) {
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
                  "${list!.username}",
                  style: const TextStyle(color: Colors.green, fontSize: 15),
                ),
                title: Text(
                  '${list.firstName} ${list.lastName}',
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle: Text('${list.email}'),
              ),
            ),
            if (list.username != 'admin')
            Expanded(
              flex: (Global.user!.userRole == 'Administrator') ? 1 : 0,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditUserScreen(
                                  showBackButton: true,
                                  user: list,
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
                  if (Global.user!.userRole == 'Administrator')
                  const Spacer(),
                  if (Global.user!.userRole == 'Administrator')
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

  void removeProduct(String id, int i) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var result = await ApiServices.delete('/user', id);
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
