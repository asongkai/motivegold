import 'package:flutter/material.dart';
import 'package:motivegold/model/auth_log.dart';
import 'package:printing/printing.dart';

import 'make_pdf.dart';


class PreviewAuthHistoryPage extends StatelessWidget {
  final List<AuthLogModel> invoice;
  const PreviewAuthHistoryPage({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('พิมพ์เอกสาร'),
      ),
      body: PdfPreview(
        build: (context) => makeAuthLogPdf(invoice),
      ),
    );
  }
}