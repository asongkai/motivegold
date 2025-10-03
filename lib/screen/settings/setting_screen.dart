import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/screen/landing_screen.dart';
import 'package:motivegold/screen/reports/auth-history/auth_history_screen.dart';
import 'package:motivegold/screen/settings/branch/branch_list_screen.dart';
import 'package:motivegold/screen/settings/company/company_list_screen.dart';
import 'package:motivegold/screen/settings/master/defaultPayment/default_payment_screen.dart';
import 'package:motivegold/screen/settings/master/defaultProduct/default_product_screen.dart';
import 'package:motivegold/screen/settings/master/warehouse/location_list_screen.dart';
import 'package:motivegold/screen/settings/master_data_screen.dart';
import 'package:motivegold/screen/settings/pawn/default/default_pawn_setting_screen.dart';
import 'package:motivegold/screen/settings/pos-id/pos_id_screen.dart';
import 'package:motivegold/screen/settings/prefix/order_id_prefix.dart';
import 'package:motivegold/screen/settings/setting-value/setting_menu.dart';
import 'package:motivegold/screen/settings/setting-value/vat_setting_screen.dart';
import 'package:motivegold/screen/settings/user/user_list_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
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
            SettingsGroup(
              settingsGroupTitle: "เมนูหลัก",
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CompanyListScreen()));
                  },
                  icons: Icons.business,
                  // Better for company/business
                  iconStyle: IconStyle(
                      backgroundColor:
                          Colors.blue[600]! // Professional blue for company
                      ),
                  title: 'บริษัท',
                  subtitle: "ข้อมูลบริษัท",
                  titleMaxLine: 1,
                  subtitleMaxLine: 1,
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BranchListScreen()));
                  },
                  icons: Icons.location_on,
                  // Better for branch/location
                  iconStyle: IconStyle(
                      backgroundColor: Colors.green[600]! // Green for locations
                      ),
                  title: 'สาขา',
                  subtitle: "ข้อมูลสาขา",
                  titleMaxLine: 1,
                  subtitleMaxLine: 1,
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
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
                    icons: Icons.tag,
                    // Better for ID/tags
                    iconStyle: IconStyle(
                        backgroundColor:
                            Colors.orange[600]! // Orange for ID management
                        ),
                    title: 'รหัสธุรกรรม',
                    subtitle: "การตั้งค่า ID การทำธุรกรรม",
                    titleMaxLine: 1,
                    subtitleMaxLine: 1,
                    titleStyle: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.grey.shade600),
                    subtitleStyle: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                if (Global.user?.userType == 'COMPANY' &&
                    Global.user?.userRole == 'Administrator')
                  SettingsItem(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PosIdScreen()));
                    },
                    icons: Icons.point_of_sale,
                    // Better for POS systems
                    iconStyle: IconStyle(
                        backgroundColor: Colors.purple[600]! // Purple for POS
                        ),
                    title: 'POS ID',
                    subtitle: "การตั้งค่า POS ID",
                    titleMaxLine: 1,
                    subtitleMaxLine: 1,
                    titleStyle: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.grey.shade600),
                    subtitleStyle: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                if (Global.user?.userType == 'COMPANY' &&
                    Global.user?.userRole == 'Administrator')
                  SettingsItem(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const LocationListScreen()));
                    },
                    icons: Icons.warehouse,
                    // Better for warehouse
                    iconStyle: IconStyle(
                        backgroundColor:
                            Colors.brown[600]! // Brown for warehouse
                        ),
                    title: 'คลังสินค้า',
                    subtitle: "ข้อมูลคลังสินค้า",
                    titleMaxLine: 1,
                    subtitleMaxLine: 1,
                    titleStyle: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.grey.shade600),
                    subtitleStyle: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserListScreen()));
                  },
                  icons: Icons.people,
                  // Good icon for users
                  iconStyle: IconStyle(
                      backgroundColor:
                          Colors.indigo[600]! // Indigo for user management
                      ),
                  title: 'ผู้ใช้',
                  subtitle: "การจัดการผู้ใช้",
                  titleMaxLine: 1,
                  subtitleMaxLine: 1,
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const DefaultProductScreen()));
                  },
                  icons: Icons.settings_applications,
                  // Better for application settings
                  iconStyle: IconStyle(
                      backgroundColor: Colors.teal[600]! // Teal for settings
                      ),
                  title: 'จัดการค่าเริ่มต้นของหน้าจอ',
                  subtitle: "ตั้งค่าค่าเริ่มต้น",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const DefaultPaymentScreen()));
                  },
                  icons: Icons.payment,
                  // Better for payment settings
                  iconStyle: IconStyle(
                      backgroundColor:
                          Colors.green[700]! // Green for money/payment
                      ),
                  title: 'จัดการค่าเริ่มต้นการชำระเงิน',
                  subtitle: "ตั้งค่าค่าเริ่มต้น การชำระเงิน",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const DefaultPawnSettingScreen()));
                  },
                  icons: Icons.remove_from_queue_outlined,
                  // Better for payment settings
                  iconStyle: IconStyle(
                      backgroundColor:
                      Colors.purple[700]! // Green for money/payment
                  ),
                  title: 'จัดการค่าเริ่มต้น ขายฝาก',
                  subtitle: "ตั้งค่าค่าเริ่มต้น ขายฝาก",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                if (Global.user?.userRole == 'Administrator')
                  SettingsItem(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SettingValueMenuScreen()));
                    },
                    icons: Icons.tune,
                    // Better for value/tuning settings
                    iconStyle: IconStyle(
                        backgroundColor: Colors
                            .deepPurple[600]! // Deep purple for admin settings
                        ),
                    title: 'Value Initial Setting',
                    subtitle: "การตั้งค่ามูลค่า",
                    titleStyle: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.grey.shade600),
                    subtitleStyle: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MasterDataScreen()));
                  },
                  icons: Icons.storage,
                  // Better for master data storage
                  iconStyle: IconStyle(
                    backgroundColor:
                        Colors.cyan[600]!, // Cyan for data management
                  ),
                  title: 'ข้อมูลหลัก',
                  subtitle: "จัดการข้อมูลหลัก",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            // Account section
            SettingsGroup(
              settingsGroupTitle: "บัญชี",
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthHistoryScreen()));
                  },
                  icons: Icons.history,
                  // Better for access history
                  iconStyle: IconStyle(
                    backgroundColor: Colors.grey[600]!, // Grey for history
                  ),
                  title: 'บันทึกการเข้าถึงระบบ',
                  subtitle: "ประวัติการเข้าใช้ระบบ",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    motivePrint('clicked');
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
                  icons: Icons.logout,
                  // Better for logout
                  iconStyle: IconStyle(
                    backgroundColor: Colors.red[600]!, // Red for logout/exit
                  ),
                  title: "ออกจากระบบ",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
