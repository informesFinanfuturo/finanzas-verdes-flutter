import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Entrada reutilizable de la ficha del equipo existente.
/// Mantiene la validacion en la interfaz; el backend valida otra vez al guardar.
class CampoTecnicoVerde extends StatelessWidget {
  final Map<String, dynamic> campo;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool obligatorio;

  const CampoTecnicoVerde({
    super.key,
    required this.campo,
    required this.controller,
    this.onChanged,
    this.obligatorio = false,
  });

  static bool _esNumero(Map<String, dynamic> campo) =>
      campo['tipo'] == 'numero' || campo['tipo'] == 'entero';

  static bool _esEntero(Map<String, dynamic> campo) =>
      campo['tipo'] == 'entero';

  static String? validar(
    Map<String, dynamic> campo,
    String? texto, {
    bool obligatorio = false,
  }) {
    final raw = (texto ?? '').trim();
    if (raw.isEmpty) {
      return obligatorio ? 'Este dato es necesario para revisar el reemplazo.' : null;
    }
    if (!_esNumero(campo)) return raw.length <= 200 ? null : 'Máximo 200 caracteres.';
    final valor = num.tryParse(raw.replaceAll(',', '.'));
    if (valor == null || !valor.isFinite || valor < 0) {
      return 'Ingresa un número válido, sin letras.';
    }
    if (_esEntero(campo) && valor != valor.roundToDouble()) {
      return 'Ingresa un número entero.';
    }
    if (campo['codigo'] == 'anio_equipo_anterior') {
      final maximo = DateTime.now().year + 1;
      if (valor < 1900 || valor > maximo) {
        return 'Ingresa un año entre 1900 y $maximo.';
      }
    }
    return null;
  }

  static dynamic valorParaGuardar(Map<String, dynamic> campo, String texto) {
    final raw = texto.trim();
    if (!_esNumero(campo)) return raw;
    return num.parse(raw.replaceAll(',', '.'));
  }

  static List<TextInputFormatter> _formato(Map<String, dynamic> campo) {
    if (!_esNumero(campo)) return const [];
    final esEntero = _esEntero(campo);
    final patron = esEntero
        ? RegExp(r'^\d*$')
        : RegExp(r'^\d*(?:[.,]\d*)?$');
    return [
      TextInputFormatter.withFunction((anterior, nuevo) {
        return patron.hasMatch(nuevo.text) ? nuevo : anterior;
      }),
      if (campo['codigo'] == 'anio_equipo_anterior')
        LengthLimitingTextInputFormatter(4),
    ];
  }

  static String? _unidad(String codigo) {
    switch (codigo) {
      case 'consumo_actual_kwh_mes': return 'kWh/mes';
      case 'consumo_actual_kwh_ciclo': return 'kWh/ciclo';
      case 'capacidad_actual_l': return 'litros';
      case 'descarga_anterior_l': return 'litros';
      case 'caudal_anterior_l_min': return 'L/min';
      case 'potencia_anterior_w': return 'W';
      case 'horas_dia': return 'h/día';
      case 'dias_anio': return 'días/año';
      case 'ciclos_semana': return 'ciclos/sem';
      case 'minutos_dia': return 'min/día';
      default: return null;
    }
  }

  static String _etiqueta(Map<String, dynamic> campo) {
    final original = campo['etiqueta']?.toString() ?? 'Dato técnico';
    final unidad = _unidad(campo['codigo']?.toString() ?? '');
    if (unidad == null) return original;
    // El sufijo representa la unidad, sin duplicarla en la etiqueta.
    return original.replaceFirst(' ($unidad)', '').replaceFirst(' (litros)', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final numeric = _esNumero(campo);
    final entero = _esEntero(campo);
    final unidad = _unidad(campo['codigo']?.toString() ?? '');
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: numeric
          ? TextInputType.numberWithOptions(decimal: !entero)
          : TextInputType.text,
      inputFormatters: _formato(campo),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (texto) => validar(campo, texto, obligatorio: obligatorio),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: _etiqueta(campo),
        hintText: campo['codigo'] == 'anio_equipo_anterior'
            ? 'Ej. 2022'
            : numeric ? '0' : 'Escribe el dato',
        helperText: obligatorio ? 'Necesario para revisar el reemplazo' : null,
        suffixText: unidad,
        suffixStyle: TextStyle(color: tema.colorScheme.onSurface.withOpacity(0.65)),
        filled: true,
        fillColor: tema.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tema.dividerColor.withOpacity(0.7)),
        ),
      ),
    );
  }
}
