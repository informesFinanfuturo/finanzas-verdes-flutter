import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:intl/intl.dart';

class Utils {


  static String buildUrl(Map<String, dynamic> archivo) {
    String path = archivo["ubicacion"] ?? '';

    // asegurar que empieza con /api/
    if (!path.startsWith('/api/')) {
      path = '/$path';
    }

    return "http://20.169.169.108:4000$path";
  }

  static String formatFechaBonita(String fecha) {
    try {
      final date = DateTime.parse(fecha);

      return DateFormat(
        "d 'de' MMMM 'de' y",
        'es',
      ).format(date);
    } catch (e) {
      return fecha;
    }
  }

  static String formatMiles(dynamic value) {

    if (value == null) return '';

    final numero = num.tryParse(
      value.toString().replaceAll('.', ''),
    );

    if (numero == null) return '';

    return NumberFormat.decimalPattern('es_CO')
        .format(numero);
  }

  static String formatMoneyNum(num? value) {
    if (value == null) return '';

    return Utils.formatMiles(value);
  }

  static double? parseMoney(String text) {

    final clean =
    text.replaceAll('.', '');

    return double.tryParse(clean);
  }

  static String formatFechaCorta(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '';

    final date = DateTime.tryParse(fecha);
    if (date == null) return fecha;

    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];

    return '${date.day} ${meses[date.month - 1]} ${date.year}';
  }

  static String? fechaBackend(
      DateTime? fecha,
      ) {

    if (fecha == null) {
      return null;
    }

    return
      '${fecha.year}-'
          '${fecha.month.toString().padLeft(2, '0')}-'
          '${fecha.day.toString().padLeft(2, '0')}';
  }
}