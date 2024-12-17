import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/button.dart';
import 'package:motivegold/utils/global.dart';

class CalcApp extends StatefulWidget {
  const CalcApp(
      {super.key,
      required this.closeCal,
      required this.currentCtrl,
      required this.onChanged});

  final Function() closeCal;
  final TextEditingController currentCtrl;
  final Function() onChanged;

  @override
  CalcAppState createState() => CalcAppState();
}

class CalcAppState extends State<CalcApp> {
  String _history = '';
  String _expression = '';
  final NumberFormat numberFormat = NumberFormat();

  void numClick(String text) {
    setState(() {
      _expression += text;
    });
  }

  void allClear(String text) {
    setState(() {
      _history = '';
      _expression = '';
    });
  }

  void clear(String text) {
    removeDigit();
  }

  void removeDigit() {
    if (_expression.length == 1 ||
        (_expression.startsWith(numberFormat.symbols.MINUS_SIGN) &&
            _expression.length == 2)) {
      allClear('');
    } else {
      _expression = _expression.substring(0, _expression.length - 1);
    }
  }

  void evaluate(String text) {
    Parser p = Parser();
    Expression exp = p.parse(_expression);
    ContextModel cm = ContextModel();

    setState(() {
      _history = _expression;
      _expression = Global.format(exp.evaluate(EvaluationType.REAL, cm));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _expression = widget.currentCtrl.text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(color: Colors.black54),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: const Alignment(1.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                _history,
                style: GoogleFonts.rubik(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF545F61),
                  ),
                ),
              ),
            ),
          ),
          Container(
            alignment: const Alignment(1.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _expression,
                style: GoogleFonts.rubik(
                  textStyle: const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalcButton(
                value: 'AC',
                text: Text(
                  'AC',
                  style: GoogleFonts.rubik(
                    textStyle: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFFf7921e),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                callback: allClear,
              ),
              CalcButton(
                value: 'C',
                text: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFf7921e),
                ),
                callback: clear,
              ),
              CalcButton(
                value: '%',
                text: Text(
                  '%',
                  style: GoogleFonts.rubik(
                    textStyle: const TextStyle(
                        fontSize: 28,
                        color: Color(0xFFf7921e),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '/',
                text: Text(
                  '/',
                  style: GoogleFonts.rubik(
                    textStyle: const TextStyle(
                        fontSize: 28,
                        color: Color(0xFFf7921e),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                callback: numClick,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalcButton(
                value: '7',
                text: Text(
                  '7',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '8',
                text: Text(
                  '8',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '9',
                text: Text(
                  '9',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '*',
                text: Text(
                  '*',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(
                          fontSize: 28,
                          color: Color(0xFFf7921e),
                          fontWeight: FontWeight.w500)),
                ),
                callback: numClick,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalcButton(
                value: '4',
                text: Text(
                  '4',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '5',
                text: Text(
                  '5',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '6',
                text: Text(
                  '6',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '-',
                text: Text(
                  '-',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(
                          fontSize: 28,
                          color: Color(0xFFf7921e),
                          fontWeight: FontWeight.w500)),
                ),
                callback: numClick,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalcButton(
                value: '1',
                text: Text(
                  '1',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '2',
                text: Text(
                  '2',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '3',
                text: Text(
                  '3',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '+',
                text: Text(
                  '+',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(
                          fontSize: 28,
                          color: Color(0xFFf7921e),
                          fontWeight: FontWeight.w500)),
                ),
                callback: numClick,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalcButton(
                value: '00',
                text: Text(
                  '00',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 26)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '0',
                text: Text(
                  '0',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '.',
                text: Text(
                  '.',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(fontSize: 28)),
                ),
                callback: numClick,
              ),
              CalcButton(
                value: '=',
                text: Text(
                  '=',
                  style: GoogleFonts.rubik(
                      textStyle: const TextStyle(
                          fontSize: 28,
                          color: Color(0xFFf7921e),
                          fontWeight: FontWeight.w500)),
                ),
                callback: evaluate,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(5),
                child: SizedBox(
                  width: 370,
                  height: 85,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    onPressed: () {
                      if (_expression.isEmpty) {
                        Alert.warning(context, 'title', 'message', 'buttonText',
                            action: () {});
                        return;
                      }
                      Parser p = Parser();
                      Expression exp = p.parse(_expression);
                      ContextModel cm = ContextModel();
                      widget.currentCtrl.text =
                          Global.format(exp.evaluate(EvaluationType.REAL, cm));
                      widget.onChanged();
                    },
                    color: const Color(0xFF414141),
                    textColor: Colors.white,
                    child: const Icon(
                      Icons.check,
                      size: 50,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
