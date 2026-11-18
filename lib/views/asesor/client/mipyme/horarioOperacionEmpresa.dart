import 'package:flutter/material.dart';

// FVE_HORARIO_EMPRESA_V2: horario global con excepciones por dia.
// El JSON permanece compatible con el backend version 1: {version: 1, dias: {}}.
// Las horas declaradas NO equivalen automaticamente a horas de consumo.
class HorarioOperacionEmpresa extends StatefulWidget {
  final Map<String, dynamic>? inicial;
  final ValueChanged<Map<String, dynamic>?> onChanged;

  const HorarioOperacionEmpresa({
    super.key,
    this.inicial,
    required this.onChanged,
  });

  @override
  State<HorarioOperacionEmpresa> createState() =>
      _HorarioOperacionEmpresaState();
}

class _HorarioOperacionEmpresaState extends State<HorarioOperacionEmpresa> {
  static const Map<String, String> _nombres = {
    'lunes': 'Lunes',
    'martes': 'Martes',
    'miercoles': 'Miércoles',
    'jueves': 'Jueves',
    'viernes': 'Viernes',
    'sabado': 'Sábado',
    'domingo': 'Domingo',
  };

  static const List<String> _laborables = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
  ];

  final Map<String, Map<String, String>> _dias = {};
  final Set<String> _personalizados = {};
  String _inicioGeneral = '08:00';
  String _finGeneral = '18:00';

  @override
  void initState() {
    super.initState();
    _cargar(widget.inicial);
    // Un registro nuevo debe guardar el horario predeterminado incluso si
    // la persona no toca los controles de esta seccion.
    if (widget.inicial == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _emitir();
      });
    }
  }

  void _cargar(Map<String, dynamic>? data) {
    _dias.clear();
    _personalizados.clear();
    _inicioGeneral = '08:00';
    _finGeneral = '18:00';
    final raw = data?['dias'];
    if (raw is Map) {
      for (final dia in _nombres.keys) {
        final turno = raw[dia];
        if (turno is Map &&
            _horaValida(turno['inicio']) &&
            _horaValida(turno['fin'])) {
          _dias[dia] = {
            'inicio': turno['inicio'].toString(),
            'fin': turno['fin'].toString(),
          };
        }
      }
      if (_dias.isNotEmpty) {
        // Identificar el horario mas frecuente entre los dias registrados,
        // priorizando los laborables si hay un empate.
        final frecuencia = <String, int>{};
        for (final dia in _nombres.keys) {
          final horario = _dias[dia];
          if (horario == null) continue;
          final clave = '${horario['inicio']}|${horario['fin']}';
          frecuencia[clave] = (frecuencia[clave] ?? 0) +
              (_laborables.contains(dia) ? 10 : 1);
        }
        String? principal;
        var mayor = -1;
        for (final entrada in frecuencia.entries) {
          if (entrada.value > mayor) {
            principal = entrada.key;
            mayor = entrada.value;
          }
        }
        final partes = principal?.split('|');
        if (partes != null && partes.length == 2) {
          _inicioGeneral = partes[0];
          _finGeneral = partes[1];
        }
        for (final entrada in _dias.entries) {
          if (entrada.value['inicio'] != _inicioGeneral ||
              entrada.value['fin'] != _finGeneral) {
            _personalizados.add(entrada.key);
          }
        }
      }
    } else {
      // Empresa sin horario previo o empresa nueva: lunes a viernes.
      for (final dia in _laborables) {
        _dias[dia] = {'inicio': _inicioGeneral, 'fin': _finGeneral};
      }
    }
  }

  bool _horaValida(dynamic valor) {
    if (valor is! String) return false;
    return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(valor);
  }

  void _emitir() {
    widget.onChanged(_dias.isEmpty
        ? null
        : {
            'version': 1,
            'dias': Map<String, dynamic>.fromEntries(
              _dias.entries.map(
                (e) => MapEntry(e.key, Map<String, String>.from(e.value)),
              ),
            ),
          });
  }

  TimeOfDay _parsear(String valor) {
    final partes = valor.split(':');
    return TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 8,
      minute: int.tryParse(partes[1]) ?? 0,
    );
  }

  String _formato(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _seleccionarHora({String? dia, required String campo}) async {
    final valor = dia == null
        ? (campo == 'inicio' ? _inicioGeneral : _finGeneral)
        : (_dias[dia]?[campo] ??
            (campo == 'inicio' ? _inicioGeneral : _finGeneral));
    final elegido = await showTimePicker(
      context: context,
      initialTime: _parsear(valor),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (!mounted || elegido == null) return;
    final nuevoValor = _formato(elegido);
    setState(() {
      if (dia == null) {
        if (campo == 'inicio') {
          _inicioGeneral = nuevoValor;
        } else {
          _finGeneral = nuevoValor;
        }
        for (final entrada in _dias.entries) {
          if (!_personalizados.contains(entrada.key)) {
            entrada.value['inicio'] = _inicioGeneral;
            entrada.value['fin'] = _finGeneral;
          }
        }
      } else {
        _dias[dia]![campo] = nuevoValor;
      }
    });
    _emitir();
  }

  void _cambiarDia(String dia, bool seleccionado) {
    setState(() {
      if (seleccionado) {
        _dias[dia] = {'inicio': _inicioGeneral, 'fin': _finGeneral};
      } else {
        _dias.remove(dia);
        _personalizados.remove(dia);
      }
    });
    _emitir();
  }

  void _cambiarPersonalizacion(String dia, bool personalizada) {
    setState(() {
      if (personalizada) {
        _personalizados.add(dia);
      } else {
        _personalizados.remove(dia);
        _dias[dia] = {'inicio': _inicioGeneral, 'fin': _finGeneral};
      }
    });
    _emitir();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Horario de funcionamiento',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Selecciona los días de operación y establece un horario general. '
                'Solo personaliza los días que tengan un horario diferente.'),
            const SizedBox(height: 16),
            const Text('Horario general',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 7),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _seleccionarHora(campo: 'inicio'),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text('Apertura $_inicioGeneral'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _seleccionarHora(campo: 'fin'),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text('Cierre $_finGeneral'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Días de funcionamiento',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 7,
              children: [
                for (final entrada in _nombres.entries)
                  FilterChip(
                    label: Text(entrada.value),
                    selected: _dias.containsKey(entrada.key),
                    onSelected: (activo) => _cambiarDia(entrada.key, activo),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (_dias.isNotEmpty)
              ExpansionTile(
                key: const PageStorageKey('fve_horarios_especiales'),
                initiallyExpanded: _personalizados.isNotEmpty,
                title: const Text('Horarios especiales (opcional)'),
                subtitle: const Text('Cambia solo el día que abra o cierre a otra hora'),
                tilePadding: EdgeInsets.zero,
                children: [
                  for (final dia in _nombres.keys)
                    if (_dias.containsKey(dia))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(_nombres[dia]!),
                              subtitle: Text(_personalizados.contains(dia)
                                  ? 'Horario personalizado'
                                  : 'Usa el horario general'),
                              value: _personalizados.contains(dia),
                              onChanged: (valor) =>
                                  _cambiarPersonalizacion(dia, valor),
                            ),
                            if (_personalizados.contains(dia))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _seleccionarHora(
                                          dia: dia, campo: 'inicio'),
                                      icon: const Icon(Icons.schedule, size: 16),
                                      label: Text('Abre ${_dias[dia]!['inicio']}'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _seleccionarHora(
                                          dia: dia, campo: 'fin'),
                                      icon: const Icon(Icons.schedule, size: 16),
                                      label: Text('Cierra ${_dias[dia]!['fin']}'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                ],
              ),
            const SizedBox(height: 8),
            const Text('Si la hora de cierre es igual o anterior a la apertura, '
                'se interpreta que el turno termina al día siguiente. '
                'Un horario no equivale automáticamente a horas de consumo.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

String resumenHorarioEmpresa(dynamic horario) {
  if (horario is! Map || horario['dias'] is! Map) return 'No registrado';
  final dias = horario['dias'] as Map;
  if (dias.isEmpty) return 'No registrado';
  int minutos(String raw) {
    final p = raw.split(':');
    if (p.length != 2) return -1;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) return -1;
    return h * 60 + m;
  }
  var totalMinutos = 0;
  for (final raw in dias.values) {
    if (raw is! Map) continue;
    final inicio = minutos(raw['inicio']?.toString() ?? '');
    final fin = minutos(raw['fin']?.toString() ?? '');
    if (inicio < 0 || fin < 0) continue;
    totalMinutos += fin <= inicio ? (fin + 1440 - inicio) : (fin - inicio);
  }
  final horas = totalMinutos / 60;
  final texto = horas == horas.roundToDouble()
      ? horas.toInt().toString()
      : horas.toStringAsFixed(1);
  return '${dias.length} día(s), $texto horas semanales declaradas';
}
