// import 'dart:typed_data';
//
// import 'package:motivegold/model/invoice.dart';
// import 'package:motivegold/utils/classes/number_to_thai_words.dart';
// import 'package:motivegold/utils/global.dart';
// import 'package:motivegold/utils/number_to_thai.dart';
// import 'package:motivegold/widget/pdf/components.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart';
// import 'package:flutter/services.dart' show rootBundle;
//
// Future<Uint8List> makeThengBrokerPdf(Invoice invoice) async {
//   var myTheme = ThemeData.withFont(
//     base: Font.ttf(
//         await rootBundle.load("assets/fonts/thai/NotoSansThai-Regular.ttf")),
//     bold: Font.ttf(
//         await rootBundle.load("assets/fonts/thai/NotoSansThai-Bold.ttf")),
//   );
//   final pdf = Document(theme: myTheme);
//   pdf.addPage(
//     MultiPage(
//       margin: const EdgeInsets.all(40),
//       pageFormat: PdfPageFormat.a4,
//       build: (context) {
//         return [
//           Column(
//             children: [
//               header(invoice.order, ' ใบเสร็จรับเงิน   /   ใบส่งของ'),
//               SizedBox(height: 10),
//               buyerSellerInfo(invoice.customer, invoice.order),
//               SizedBox(height: 10),
//               Divider(
//                 height: 1,
//                 borderStyle: BorderStyle.dashed,
//               ),
//               SizedBox(height: 10),
//               getThongThengTable(invoice.order),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     flex: 6,
//                     child: Center(
//                       child: Text(
//                         '( ${NumberToThaiWords.convertDouble(Global.getOrderTotal(invoice.order))} )',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                       flex: 4,
//                       child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text(
//                               'รวมทั้งสิ้น',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(width: 60),
//                             Text(
//                               Global.format(
//                                 Global.getOrderTotal(invoice.order),
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                           ])),
//                 ],
//               ),
//               height(),
//               divider(),
//               height(h: 1),
//               divider(),
//               SizedBox(height: 10),
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                 Text('เงื่อนไขการการชำระเงิน',
//                     style:
//                         TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                 Spacer(),
//                 Text(
//                     'ใบเสร็จรับเงินนี้จะสมบูรณ์ต่อเมื่อ  บริษัทฯได้รับเงินอย่างครบถ้วน')
//               ]),
//               getThongThengPaymentInfo(invoice.order, invoice.payments ?? []),
//               SizedBox(height: 10),
//               getThongThengSignatureInfo(invoice.customer, invoice.order.orderTypeId!),
//             ],
//           )
//         ];
//       },
//     ),
//   );
//   return pdf.save();
// }
//
// Widget paddedText(final String text,
//         {final TextAlign align = TextAlign.left,
//         final TextStyle style = const TextStyle(fontSize: 12)}) =>
//     Padding(
//       padding: const EdgeInsets.all(10),
//       child: Text(
//         text,
//         textAlign: align,
//         style: style,
//       ),
//     );
