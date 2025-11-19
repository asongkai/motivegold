import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/screen/reports/redeem-reports/redeem_single_reports_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';

class PawnReportMenuScreen extends StatefulWidget {
  const PawnReportMenuScreen({super.key});

  @override
  State<PawnReportMenuScreen> createState() => _PawnReportMenuScreenState();
}

class _PawnReportMenuScreenState extends State<PawnReportMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.94),
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายงานขายฝาก",
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
              settingsGroupTitle: "รายงาน",
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const RedeemSingleReportScreen()));
                  },
                  icons: Icons.redeem, // Perfect for redeem/pawn reports
                  iconStyle: IconStyle(
                    backgroundColor:
                        Colors.deepPurple[600]!, // Deep purple for pawn/redeem
                  ),
                  title: 'รายงานภาษีขายตามสัญญาขายฝากทองคำรูปพรรณใหม่ 96.5% ',
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
