
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/screen/landing_screen.dart';
import 'package:motivegold/screen/settings/branch/branch_list_screen.dart';
import 'package:motivegold/screen/settings/company/company_list_screen.dart';
import 'package:motivegold/screen/settings/master/orderType/order_type_list_screen.dart';
import 'package:motivegold/screen/settings/master/warehouse/location_list_screen.dart';
import 'package:motivegold/screen/settings/master_data_screen.dart';
import 'package:motivegold/screen/settings/pos-id/pos_id_screen.dart';
import 'package:motivegold/screen/settings/prefix/order_id_prefix.dart';
import 'package:motivegold/screen/settings/setting-value/setting_value.dart';
import 'package:motivegold/screen/settings/user/user_list_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/localbindings.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    // return Container();
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.94),
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: false,
          title: Text("ตั้งค่า",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
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
                            const OrderIdPrefixScreen()));
                  },
                  icons: Icons.numbers,
                  iconStyle: IconStyle(
                      backgroundColor: Colors.teal
                  ),
                  title:
                  'รหัสธุรกรรม',
                  subtitle:
                  "การตั้งค่า ID การทำธุรกรรม",
                  titleMaxLine: 1,
                  subtitleMaxLine: 1,
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                if (Global.user?.userType == 'COMPANY' && Global.user?.userRole == 'Administrator')
                  SettingsItem(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const PosIdScreen()));
                      // Alert.success(context, 'title', '${await getDeviceId()}', 'OK', action: () {});
                    },
                    icons: CupertinoIcons.italic,
                    iconStyle: IconStyle(
                        backgroundColor: Colors.teal
                    ),
                    title:
                    'POS ID',
                    subtitle:
                    "การตั้งค่า POS ID",
                    titleMaxLine: 1,
                    subtitleMaxLine: 1,
                    titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                    subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                  ),
                if (Global.user?.userType == 'COMPANY' && Global.user?.userRole == 'Administrator')
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
                            builder: (context) =>
                            const OrderTypeListScreen()));
                  },
                  icons: CupertinoIcons.pencil_outline,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.orange
                  ),
                  title:
                  'จัดการค่าเริ่มต้นของหน้าจอ',
                  subtitle:
                  "ตั้งค่าค่าเริ่มต้น",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                if (Global.user?.userType == 'ADMIN')
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const SettingValueScreen()));
                  },
                  icons: CupertinoIcons.pencil_outline,
                  iconStyle: IconStyle(
                      backgroundColor: Colors.blue.shade900
                  ),
                  title:
                  'Value Initial Setting',
                  subtitle:
                  "การตั้งค่ามูลค่า",
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
            // You can add a settings title
            SettingsGroup(
              settingsGroupTitle: "บัญชี",
              items: [
                SettingsItem(
                  onTap: () {
                    // print(Global.deviceDetail);
                    Alert.info(context, 'Warning'.tr(), 'ยืนยันการออกจากระบบ', 'OK'.tr(), action: () async {
                      var authObject = Global.requestObj({
                        "deviceDetail": Global.deviceDetail.toString()
                      });

                      // motivePrint(authObject);
                      // return;
                      final ProgressDialog pr = ProgressDialog(context,
                          type: ProgressDialogType.normal,
                          isDismissible: true,
                          showLogs: true);
                      await pr.show();
                      pr.update(message: 'processing'.tr());
                      try {
                        await ApiServices.post('/user/logout/${Global.user!.id}', authObject);
                        await pr.hide();
                        resetAtLogout();
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
                // SettingsItem(
                //   onTap: () {},
                //   icons: CupertinoIcons.delete_solid,
                //   title: "ลบบัญชี",
                //   titleStyle: const TextStyle(
                //     color: Colors.red,
                //     fontWeight: FontWeight.bold,
                //   ),
                //
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
