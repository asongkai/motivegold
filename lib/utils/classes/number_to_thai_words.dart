class NumberToThaiWords {
  static const List<String> _units = [
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
  ];

  static const List<String> _tens = [
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

  static const List<String> _scales = [
    '',
    'สิบ',
    'ร้อย',
    'พัน',
    'หมื่น',
    'แสน',
    'ล้าน',
  ];

  static String _convertLessThanTenMillion(int number) {
    if (number == 0) {
      return '';
    }

    String result = '';
    int scaleIndex = 0;

    while (number > 0) {
      int remainder = number % 10;
      if (remainder != 0) {
        if (scaleIndex == 0) {
          result = _units[remainder] + result;
        } else if (scaleIndex == 1 && remainder == 1) {
          result = _tens[remainder] + result;
        } else if (scaleIndex == 1 && remainder == 2) {
          result = 'ยี่สิบ' + result;
        } else if (scaleIndex == 1) {
          result = _tens[remainder] + result;
        } else {
          result = _units[remainder] + _scales[scaleIndex] + result;
        }
      }
      number ~/= 10;
      scaleIndex++;
    }

    return result;
  }

  static String convert(int number) {
    if (number == 0) return 'ศูนย์';

    String result = '';
    int scaleIndex = 0;

    while (number > 0) {
      int remainder = number % 10000000; // Handle up to 10 million
      if (remainder != 0) {
        String temp = _convertLessThanTenMillion(remainder);
        if (scaleIndex > 0) {
          temp += _scales[scaleIndex + 5]; // Adjust for scales like ล้าน
        }
        result = temp + result;
      }
      number ~/= 10000000;
      scaleIndex++;
    }

    return result.trim();
  }

  static String convertDouble(double number) {
    int integerPart = number.toInt();
    int fractionalPart = ((number - integerPart) * 100).round();

    String integerWords = convert(integerPart);

    if (fractionalPart == 0) {
      return '$integerWordsบาทถ้วน'; // Use "บาทถ้วน" for whole numbers
    } else {
      String fractionalWords = convert(fractionalPart);
      return '$integerWordsบาท$fractionalWordsสตางค์';
    }
  }
}