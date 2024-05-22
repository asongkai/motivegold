///
///A class handle convert number to words
///
class NumberToWordThai {
  NumberToWordThai._();

  static const String _zero = 'ศูนย์'; //0
  static const String _ed = 'เอ็ด'; //1
  static const String _hundred = 'ร้อย'; //100
  static const String _thousand = 'พัน'; //1000
  static const String _tenthousand = 'หมื่น'; //10 000
  static const String _hundredthousand = 'แสน'; //100 000
  static const String _million = 'ล้าน'; //1000 000
  static const String _billion = 'พันล้าน'; //1000 000 000

  ///numNames
  static const List<String> _numNames = [
    '',
    'หนึ่ง',
    'สอง',
    'สาม',
    'สี่',
    'ห้า',
    'หก',
    'เจ็ด',
    'แปด',
    'เก้า',
    'สิบ',
    'สิบเอ็ด',
    'สิบสอง',
    'สิบสาม',
    'สิบสี่',
    'สิบห้า',
    'สิบหก',
    'สิบเจ็ด',
    'สิบแปด',
    'สิบเก้า',
    'ยี่สิบ'
  ];

  ///tensNames
  static const List<String> _tensNames = [
    '',
    'สิบ',
    'ยี่สิบ',
    'สามสิบ',
    'สี่สิบ',
    'ห้าสิบ',
    'หกสิบ',
    'เจ็ดสิบ',
    'แปดสิบ',
    'เก้าสิบ',
  ];

  /// convertLessThanOneThousand
  static String _convertLessThanOneThousand(int number,
      [bool isLastThreeDigits = false]) {
    String soFar = '';

    if (number % 100 <= 20) {
      soFar = _numNames[number % 100];
      number = (number ~/ 100).toInt();
    } else {
      soFar = _numNames[number % 10];
      if (soFar == _numNames[1]) {
        soFar = _ed;
      }
      number = (number ~/ 10).toInt();
      soFar = _tensNames[number % 10] + soFar;
      number = (number ~/ 10).toInt();
    }
    if (number == 0) {
      return soFar;
    }
    return _numNames[number] + _hundred + soFar;
  }

  ///handle converter
  static String convert(int number) {
    // 0 to 999 999 999 999
    if (number == 0) {
      return _zero;
    }
    final String strNumber = number.toString().padLeft(12, '0');
    // XXXnnnnnnnnn
    final int billions = int.parse(strNumber.substring(0, 3));
    // nnnXXXnnnnnn
    final int millions = int.parse(strNumber.substring(3, 6));
    // nnnnnnXXXnnn
    final int hundredThousands = int.parse(strNumber.substring(6, 7));

    final int tenThousands = int.parse(strNumber.substring(7, 8));

    // nnnnnnnnnXXX
    final int thousands = int.parse(strNumber.substring(8, 9));

    // nnnnnnnnnXXX
    final int hundred = int.parse(strNumber.substring(9, 12));

    final String tradBillions = _getBillions(billions);
    String result = tradBillions;

    final String tradMillions = _getMillions(millions);
    result = result + tradMillions;

    final String tradHundredThousands = _getHundredThousands(hundredThousands);
    result = result + tradHundredThousands;

    final String tradTenThousands = _getTenThousands(tenThousands);
    result = result + tradTenThousands;

    final String tradThousands = _getThousands(thousands);
    result = result + tradThousands;

    String tradThousand;
    tradThousand = _convertLessThanOneThousand(hundred, true);
    result = result + tradThousand;

    // remove extra spaces!
    result =
        result.replaceAll(RegExp('\\s+'), ' ').replaceAll('\\b\\s{2,}\\b', ' ');
    return result.trim();
  }

  ///get Billions
  static String _getBillions(int billions) {
    String tradBillions;
    switch (billions) {
      case 0:
        tradBillions = '';
        break;
      case 1:
        tradBillions = _convertLessThanOneThousand(billions) + _billion;
        break;
      default:
        tradBillions = _convertLessThanOneThousand(billions) + _billion;
    }
    return tradBillions;
  }

  ///get Millions
  static String _getMillions(int millions) {
    String tradMillions;
    switch (millions) {
      case 0:
        tradMillions = '';
        break;
      case 1:
        tradMillions = _convertLessThanOneThousand(millions) + _million;
        break;
      default:
        tradMillions = _convertLessThanOneThousand(millions) + _million;
    }
    return tradMillions;
  }

  ///get Hundred Thousands
  static String _getHundredThousands(int hundredThousands) {
    String tradHundredThousands;
    switch (hundredThousands) {
      case 0:
        tradHundredThousands = '';
        break;
      case 1:
        tradHundredThousands =
            _convertLessThanOneThousand(hundredThousands) + _hundredthousand;
        break;
      default:
        tradHundredThousands =
            _convertLessThanOneThousand(hundredThousands) + _hundredthousand;
    }

    return tradHundredThousands;
  }

  static String _getTenThousands(int tenThousands) {
    String tradTenThousands;
    switch (tenThousands) {
      case 0:
        tradTenThousands = '';
        break;
      case 1:
        tradTenThousands =
            _convertLessThanOneThousand(tenThousands) + _tenthousand;
        break;
      default:
        tradTenThousands =
            _convertLessThanOneThousand(tenThousands) + _tenthousand;
    }

    return tradTenThousands;
  }

  static String _getThousands(int hundredThousands) {
    String tradHundredThousands;
    switch (hundredThousands) {
      case 0:
        tradHundredThousands = '';
        break;
      case 1:
        tradHundredThousands =
            _convertLessThanOneThousand(hundredThousands) + _thousand;
        break;
      default:
        tradHundredThousands =
            _convertLessThanOneThousand(hundredThousands) + _thousand;
    }

    return tradHundredThousands;
  }
}