import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

const List<Color> _kDefaultRainbowColors = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

class LoadingProgress extends StatelessWidget {
  const LoadingProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 100,
        width: 100,
        child: LoadingIndicator(
          indicatorType: Indicator.ballRotateChase, /// Required, The loading type of the widget
          colors: _kDefaultRainbowColors,       /// Optional, The color collections
          strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
          // backgroundColor: Colors.black,      /// Optional, Background of the widget
          // pathBackgroundColor: Colors.black   /// Optional, the stroke backgroundColor
        ),
      ),
    );
  }
}
