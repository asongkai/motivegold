import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/screen/reports/accounting-books/paphun/refill-wholesale-paphun/refill_wholesale_paphun_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/paphun/sell-used-wholesale-paphun/sell_used_wholesale_paphun_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/paphun/sell-new-retail-paphun/sell_new_retail_paphun_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/paphun/buy-used-retail-paphun/buy_used_retail_paphun_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/refill-wholesale-theng/refill_wholesale_theng_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/sell-wholesale-theng/sell_wholesale_theng_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/sell-new-retail-theng/sell_new_retail_theng_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/buy-retail-theng/buy_retail_theng_report_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';

class AccountingBooksMenuScreen extends StatefulWidget {
  const AccountingBooksMenuScreen({super.key});

  @override
  State<AccountingBooksMenuScreen> createState() =>
      _AccountingBooksMenuScreenState();
}

class _AccountingBooksMenuScreenState extends State<AccountingBooksMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.94),
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("สมุดบัญชี",
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
              settingsGroupTitle: "ทองรูปพรรณ",
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const RefillWholesalePaphunReportScreen()));
                  },
                  icons: Icons.add_shopping_cart,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.amber[600]!,
                  ),
                  title: 'สมุดบัญชีซื้อทองรูปพรรณใหม่',
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
                                const SellNewRetailPaphunReportScreen()));
                  },
                  icons: Icons.storefront,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.teal[600]!,
                  ),
                  title: 'สมุดบัญชีขายทองรูปพรรณใหม่',
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
                                const BuyUsedRetailPaphunReportScreen()));
                  },
                  icons: Icons.shopping_basket,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.brown[600]!,
                  ),
                  title: 'สมุดบัญชีซื้อทองรูปพรรณเก่า',
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
                                const SellUsedWholesalePaphunReportScreen()));
                  },
                  icons: Icons.sell,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.orange[600]!,
                  ),
                  title: 'สมุดบัญชีขายทองรูปพรรณเก่า',
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
            SettingsGroup(
              settingsGroupTitle: "ทองคำแท่ง",
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const BuyRetailThengReportScreen()));
                  },
                  icons: Icons.shopping_basket,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.deepPurple[600]!,
                  ),
                  title: 'สมุดบัญชีซื้อคำแท่ง(หน้าร้าน)',
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
                                const SellNewRetailThengReportScreen()));
                  },
                  icons: Icons.storefront,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green[600]!,
                  ),
                  title: 'สมุดบัญชีขายทองคำแท่ง(หน้าร้าน)',
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
                                const RefillWholesaleThengReportScreen()));
                  },
                  icons: Icons.add_shopping_cart,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.blue[600]!,
                  ),
                  title: 'สมุดบัญชีซื้อทองคำแท่ง(ร้านค้าส่ง)',
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
                                const SellWholesaleThengReportScreen()));
                  },
                  icons: Icons.sell,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.indigo[600]!,
                  ),
                  title: 'สมุดบัญชีขายทองคำแท่ง(ร้านค้าส่ง)',
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
