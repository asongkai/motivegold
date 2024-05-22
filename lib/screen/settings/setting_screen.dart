import 'dart:convert';

import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/user.dart';
import 'package:motivegold/screen/landing_screen.dart';
import 'package:motivegold/screen/products/product_list_screen.dart';
import 'package:motivegold/screen/refill/refill_gold_history_screen.dart';
import 'package:motivegold/screen/refill/refill_gold_menu_screen.dart';
import 'package:motivegold/screen/refill/refill_gold_stock_screen.dart';
import 'package:motivegold/screen/settings/auth_history_screen.dart';
import 'package:motivegold/screen/settings/branch/branch_list_screen.dart';
import 'package:motivegold/screen/settings/company/company_list_screen.dart';
import 'package:motivegold/screen/settings/master/warehouse/location_list_screen.dart';
import 'package:motivegold/screen/settings/master_data_screen.dart';
import 'package:motivegold/screen/settings/user/user_list_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_history_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_menu_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_screen.dart';
import 'package:motivegold/screen/used/sell_used_gold_history_screen.dart';
import 'package:motivegold/screen/used/sell_used_gold_menu_screen.dart';
import 'package:motivegold/screen/used/sell_used_gold_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../api/api_services.dart';
import '../../utils/alert.dart';
import '../../utils/constants.dart';
import '../../utils/global.dart';
import '../../utils/localbindings.dart';
import '../../utils/util.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(.94),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            // user card
            // SimpleUserCard(
            //   imageRadius: 10,
            //   userName: Global.user!.username!,
            //   userProfilePic: const AssetImage("assets/images/sample_profile.jpg"),
            // ),
            SettingsGroup(
              settingsGroupTitle: "เมนูหลัก",
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const CompanyListScreen()));
                  },
                  icons: CupertinoIcons.building_2_fill,
                  iconStyle: IconStyle(
                      backgroundColor: Colors.blue[700]
                  ),
                  title:
                  'บริษัท',
                  subtitle:
                  "ข้อมูลบริษัท",
                  titleMaxLine: 1,
                  subtitleMaxLine: 1,
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const BranchListScreen()));
                  },
                  icons: Icons.dataset,
                  iconStyle: IconStyle(
                      backgroundColor: Colors.orange
                  ),
                  title:
                  'สาขา',
                  subtitle:
                  "ข้อมูลสาขา",
                  titleMaxLine: 1,
                  subtitleMaxLine: 1,
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                if (Global.user?.userType == 'COMPANY')
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const LocationListScreen()));
                  },
                  icons: CupertinoIcons.circle_grid_3x3,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.teal
                  ),
                  title:
                  'คลังสินค้า',
                  subtitle:
                  "ข้อมูลคลังสินค้า",
                  titleMaxLine: 1,
                  subtitleMaxLine: 1,
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const UserListScreen()));
                  },
                  icons: Icons.people,
                  iconStyle: IconStyle(
                      backgroundColor: Colors.deepPurple
                  ),
                  title:
                  'ผู้ใช้',
                  subtitle:
                  "การจัดการผู้ใช้",
                  titleMaxLine: 1,
                  subtitleMaxLine: 1,
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MasterDataScreen()));
                  },
                  icons: Icons.settings_applications_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.lightGreen,
                  ),
                  title: 'ข้อมูลหลัก',
                  subtitle: "จัดการข้อมูลหลัก",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                // SettingsItem(
                //   onTap: () {
                //
                //   },
                //   icons: CupertinoIcons.pencil_outline,
                //   iconStyle: IconStyle(
                //     backgroundColor: Colors.orange
                //   ),
                //   title:
                //   'Gold Products',
                //   subtitle:
                //   "Manage Gold Products",
                //   titleMaxLine: 1,
                //   subtitleMaxLine: 1,
                // ),
                // SettingsItem(
                //   onTap: () {
                //
                //   },
                //   icons: CupertinoIcons.pencil_outline,
                //   iconStyle: IconStyle(
                //     backgroundColor: Colors.green
                //   ),
                //   title:
                //   'Gold Products',
                //   subtitle:
                //   "Manage Gold Products",
                //   titleMaxLine: 1,
                //   subtitleMaxLine: 1,
                // ),
                // SettingsItem(
                //   onTap: () {},
                //   icons: Icons.fingerprint,
                //   iconStyle: IconStyle(
                //     iconsColor: Colors.white,
                //     withBackground: true,
                //     backgroundColor: Colors.red,
                //   ),
                //   title: 'Privacy',
                //   subtitle: "Lock Ziar'App to improve your privacy",
                // ),
                // SettingsItem(
                //   onTap: () {},
                //   icons: Icons.dark_mode_rounded,
                //   iconStyle: IconStyle(
                //     iconsColor: Colors.white,
                //     withBackground: true,
                //     backgroundColor: Colors.red,
                //   ),
                //   title: 'Dark mode',
                //   subtitle: "Automatic",
                //   trailing: Switch.adaptive(
                //     value: false,
                //     onChanged: (value) {},
                //   ),
                // ),
              ],
            ),
            SettingsGroup(
              settingsGroupTitle: "ประวัติการทำรายการ",
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RefillGoldHistoryScreen()));
                  },
                  icons: Icons.view_list,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.teal,
                  ),
                  title: 'เติมทอง',
                  subtitle: "ประวัติการเติมทอง",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SellUsedGoldHistoryScreen()));
                  },
                  icons: Icons.view_list,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.orange,
                  ),
                  title: 'ขายทองเก่า',
                  subtitle: "ประวัติการขายทองเก่า",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TransferGoldHistoryScreen()));
                  },
                  icons: Icons.view_list,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.purple,
                  ),
                  title: 'โอนทอง',
                  subtitle: "ประวัติการโอนทอง",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),

            SettingsGroup(
              settingsGroupTitle: "รายงาน",
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthHistoryScreen()));
                  },
                  icons: Icons.featured_play_list_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.blue[500],
                  ),
                  title: 'บันทึกการเข้าถึงระบบ',
                  subtitle: "ประวัติการเข้าใช้ระบบ",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {

                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงานสต็อก',
                  subtitle: "รายงานสต็อคคลังสินค้า",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {

                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.brown,
                  ),
                  title: 'ขายทองเก่า',
                  subtitle: "รายงานขายทองเก่า",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {

                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงาน 001',
                  subtitle: "รายงาน 001",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {

                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงาน 002',
                  subtitle: "รายงาน 002",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {

                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงาน 003',
                  subtitle: "รายงาน 003",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {

                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงาน 004',
                  subtitle: "รายงาน 004",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {

                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงาน 005',
                  subtitle: "รายงาน 005",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            // You can add a settings title
            SettingsGroup(
              settingsGroupTitle: "บัญชี",
              items: [
                SettingsItem(
                  onTap: () {
                    // print(Global.deviceDetail);
                    Alert.info(context, 'Warning'.tr(), 'AreYouSure'.tr(), 'OK'.tr(), action: () async {


                      var authObject = Global.requestObj({
                        "deviceDetail": Global.deviceDetail.toString()
                      });

                      motivePrint(authObject);
                      // return;
                      final ProgressDialog pr = ProgressDialog(context,
                          type: ProgressDialogType.normal,
                          isDismissible: true,
                          showLogs: true);
                      await pr.show();
                      pr.update(message: 'processing'.tr());
                      try {
                        var result =
                        await ApiServices.post('/user/logout/${Global.user!.id}', authObject);
                        await pr.hide();
                        Global.isLoggedIn = false;
                        Global.user = UserModel();
                        LocalStorage.sharedInstance.setAuthStatus(key: Constants.isLoggedIn, value: "false");
                        if (mounted) {
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (_) => const LandingScreen()));
                        }
                      } catch (e) {
                        await pr.hide();
                      }

                    });
                  },
                  icons: Icons.exit_to_app_rounded,
                  title: "ออกจากระบบ",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {},
                  icons: CupertinoIcons.delete_solid,
                  title: "ลบบัญชี",
                  titleStyle: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
