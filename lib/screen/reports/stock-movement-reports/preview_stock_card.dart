import 'package:flutter/material.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/reports/stock-movement-reports/make_stock_card_pdf.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:printing/printing.dart';

import 'package:motivegold/model/stockmovement.dart';
import 'make_pdf.dart';

class PreviewStockCardReportPage extends StatelessWidget {
  final List<StockMovementModel> list;
  final int type;
  final ProductModel? productModel;
  final WarehouseModel? warehouseModel;
  final String? date;
  final StockMovementModel? stockMovementModel;
  const PreviewStockCardReportPage({super.key, required this.list, required this.type, this.productModel, this.warehouseModel, this.date, this.stockMovementModel});

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
        build: (context) => makeStockCardReportPdf(list, type, warehouseModel, productModel, date, stockMovementModel),
      ),
    );
  }
}