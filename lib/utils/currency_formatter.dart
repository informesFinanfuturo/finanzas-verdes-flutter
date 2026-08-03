// utils/currency_formatter.dart

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {

  final formatter = NumberFormat('#,###', 'es_CO');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {

    if (newValue.text.isEmpty) {
      return newValue;
    }

    final clean =
    newValue.text.replaceAll('.', '');

    final number =
    int.tryParse(clean);

    if (number == null) {
      return oldValue;
    }

    final formatted =
    formatter.format(number)
        .replaceAll(',', '.');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}