import 'package:flutter/material.dart';
import 'package:motivegold/model/activity_log.dart';
import 'package:motivegold/screen/reports/activity-log/make_pdf.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';

class PreviewActivityLogPage extends StatelessWidget {
  final List<ActivityLogModel> activities;
  final String dateRange;

  const PreviewActivityLogPage({
    super.key,
    required this.activities,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("พิมพ์เอกสาร",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: PdfPreview(
        build: (context) => makeActivityLogPdf(activities, dateRange),
      ),
    );
  }
}
