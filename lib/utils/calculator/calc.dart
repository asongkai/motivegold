import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class Calc extends StatefulWidget {
  Calc({super.key, this.currentValue, this.closeCal, this.onChanged});
  
  double? currentValue;
  final Function()? closeCal;
  final Function(String? key, double? value, String? expression)? onChanged;

  @override
  State<Calc> createState() => _CalcState();
}

class _CalcState extends State<Calc> {
  late SimpleCalculator calc;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calc = SimpleCalculator(
      value: widget.currentValue ?? 0,
      hideExpression: false,
      hideSurroundingBorder: true,
      autofocus: true,
      closeCal: widget.closeCal,
      onChanged: widget.onChanged,
      onTappedDisplay: (value, details) {
        if (kDebugMode) {
          print('$value\t${details.globalPosition}');
        }
      },
      theme: const CalculatorThemeData(
        borderColor: Color(0xffcccccc),
        borderWidth: 4,
        displayColor: Color(0xffcccccc),
        displayStyle: TextStyle(fontSize: 80, color: Colors.black),
        expressionColor: Color(0xffcccccc),
        expressionStyle: TextStyle(fontSize: 20, color: Colors.black87),
        operatorColor: Colors.pink,
        operatorStyle: TextStyle(fontSize: 30, color: Colors.black87),
        commandColor: Colors.orange,
        commandStyle: TextStyle(fontSize: 30, color: Colors.black87),
        numColor: Colors.white70,
        numStyle: TextStyle(
            fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return calc;
  }
}
