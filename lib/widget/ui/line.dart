import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

Widget underlinedText({
  required String text,
  bool doubleLine = false,
  double underlineWidth = 100,
  TextStyle? textStyle,
  double textLineSpacing = 0,
  double lineSpacing = 1,
  CrossAxisAlignment axis = CrossAxisAlignment.start,
  FontWeight fontWeight = FontWeight.bold,
  PdfColor lineColor = PdfColors.grey900,
}) {
  return Column(
    crossAxisAlignment: axis,
    children: [
      Text(
        text,
        style: textStyle ?? TextStyle(fontSize: 10, fontWeight: fontWeight),
      ),
      SizedBox(height: textLineSpacing),
      Container(
        width: underlineWidth,
        height: 0.5,
        color: lineColor,
      ),
      if (doubleLine) ...[
        SizedBox(height: lineSpacing),
        Container(
          width: underlineWidth,
          height: 0.5,
          color: lineColor,
        ),
      ],
    ],
  );
}
