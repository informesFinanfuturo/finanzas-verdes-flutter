import 'package:flutter/material.dart';

// FVE_PERFIL_USO_V1. Captura declaraciones, no mediciones verificadas.
class PerfilUsoActivo extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic>? inicial;
  final dynamic horarioEmpresa;
  final ValueChanged<Map<String, dynamic>?> onChanged;

  const PerfilUsoActivo({
    super.key,
    required this.tipo,
    this.inicial,
    this.horarioEmpresa,
    required this.onChanged,
  });

  @override
  State<PerfilUsoActivo> createState() => _PerfilUsoActivoState();
}

class _OpcionUso {
  final String valor;
  final String etiqueta;
  const _OpcionUso(this.valor, this.etiqueta);
}

class _CampoUso {
  final String codigo;
  final String etiqueta;
  final double maximo;
  const _CampoUso(this.codigo, this.etiqueta, this.maximo);
}

class _ConfigUso {
  final String pregunta;
  final List<_OpcionUso> opciones;
  final List<_CampoUso> campos;
  const _ConfigUso(this.pregunta, this.opciones, this.campos);
}

class _PerfilUsoActivoState extends State<PerfilUsoActivo> {
  String? _modo;
  final Map<String, double> _mediciones = {};

  static const _sinDato = _OpcionUso('desconocido', 'No se conoce');
  static const _opApagado = _OpcionUso('apagado', 'Se apaga por completo');
  static const _opContinuo = _OpcionUso('continuo', 'Permanece funcionando');
  static const _opEspera = _OpcionUso('espera', 'Queda en modo de espera');
  static const _opParcial = _OpcionUso('parcial', 'Funciona algunas horas adicionales');
  static const _opSinUso = _OpcionUso('sin_uso', 'No se utiliza fuera del horario');
  static const _opUsoFuera = _OpcionUso('uso_fuera', 'Sí se utiliza fuera del horario');
  static const _horaDia = _CampoUso('horas_uso_dia', 'Horas de uso efectivo por día (si se conocen)', 24);
  static const _horaFuera = _CampoUso('horas_fuera_horario_dia', 'Horas de uso fuera del horario por día', 24);
  static const _ciclos = _CampoUso('ciclos_semana', 'Ciclos por semana', 10000);
  static const _minutosCiclo = _CampoUso('minutos_ciclo', 'Minutos por ciclo', 1440);
  static const _minutosAgua = _CampoUso('minutos_uso_dia', 'Minutos de uso de agua al día', 1440);
  static const _descargas = _CampoUso('descargas_dia', 'Descargas de sanitario por día', 10000);
  static const _usos = _CampoUso('usos_dia', 'Veces que se utiliza por día', 10000);
  static const _fraccion = _CampoUso('porcentaje_encendido_fuera', 'Porcentaje de equipos que quedan encendidos (%)', 100);

  _ConfigUso _config(String tipo) {
    switch (tipo) {
      case 'Neveras':
        return const _ConfigUso('¿La nevera sigue conectada y refrigerando cuando la empresa cierra?',
            [_opContinuo, _opApagado, _opParcial, _sinDato], [_horaFuera]);
      case 'Refrigeración':
        return const _ConfigUso('¿El sistema de refrigeración continúa operando fuera del horario?',
            [_opContinuo, _opApagado, _opParcial, _sinDato], [_horaFuera]);
      case 'Vitrinas':
        return const _ConfigUso('¿La vitrina mantiene encendida la refrigeración o iluminación después del cierre?',
            [_opContinuo, _opApagado, _opParcial, _sinDato], [_horaFuera]);
      case 'Iluminación':
        return const _ConfigUso('¿Qué sucede con las luminarias al cerrar el establecimiento?',
            [_opApagado, _opContinuo, _opParcial, _sinDato], [_horaDia, _horaFuera, _fraccion]);
      case 'Climatización':
        return const _ConfigUso('¿Se apaga el aire acondicionado o ventilación cuando termina la jornada?',
            [_opApagado, _opEspera, _opContinuo, _opParcial, _sinDato], [_horaDia, _horaFuera]);
      case 'Hornos':
        return const _ConfigUso('¿Se apaga el horno completamente después del servicio, o continúa calentando?',
            [_opApagado, _opContinuo, _opParcial, _sinDato], [_horaDia, _horaFuera]);
      case 'Televisores':
        return const _ConfigUso('¿El televisor se apaga completamente, queda en espera o sigue encendido?',
            [_opApagado, _opEspera, _opContinuo, _sinDato], [_horaDia]);
      case 'Lavadoras':
        return const _ConfigUso('¿Se realizan ciclos de lavado después del cierre?',
            [_opSinUso, _opUsoFuera, _sinDato], [_ciclos, _minutosCiclo]);
      case 'Lava vajillas':
        return const _ConfigUso('¿Se realizan ciclos de lavado de vajilla fuera del horario de atención?',
            [_opSinUso, _opUsoFuera, _sinDato], [_ciclos, _minutosCiclo]);
      case 'Secadoras':
        return const _ConfigUso('¿La secadora sigue realizando ciclos después del cierre?',
            [_opSinUso, _opUsoFuera, _sinDato], [_ciclos, _minutosCiclo]);
      case 'Grifos':
        return const _ConfigUso('¿Se utilizan los grifos fuera del horario de atención?',
            [_opSinUso, _opUsoFuera, _sinDato], [_minutosAgua, _usos]);
      case 'Reductores de caudal':
        return const _ConfigUso('¿El punto de agua con reductor se utiliza fuera del horario?',
            [_opSinUso, _opUsoFuera, _sinDato], [_minutosAgua, _usos]);
      case 'Sanitarios':
        return const _ConfigUso('¿Los sanitarios se utilizan fuera del horario de atención?',
            [_opSinUso, _opUsoFuera, _sinDato], [_descargas]);
      default:
        return const _ConfigUso('¿El activo se usa o consume recursos fuera del horario de la empresa?',
            [_opApagado, _opEspera, _opContinuo, _opParcial, _sinDato], [_horaDia, _horaFuera]);
    }
  }

  @override
  void initState() {
    super.initState();
    _cargar(widget.inicial);
  }

  @override
  void didUpdateWidget(covariant PerfilUsoActivo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tipo != widget.tipo) {
      _modo = null;
      _mediciones.clear();
      // No notificar durante build. Al elegir una opción se enviará el perfil nuevo.
    }
  }

  void _cargar(Map<String, dynamic>? data) {
    if (data == null || data['tipo_activo'] != widget.tipo) return;
    _modo = data['modo']?.toString();
    final campos = data['mediciones'];
    if (campos is Map) {
      for (final entry in campos.entries) {
        if (entry.value is num) _mediciones[entry.key.toString()] = (entry.value as num).toDouble();
      }
    }
  }

  void _emitir() {
    if (_modo == null) {
      widget.onChanged(null);
      return;
    }
    widget.onChanged({
      'version': 1,
      'tipo_activo': widget.tipo,
      'modo': _modo,
      'mediciones': Map<String, double>.from(_mediciones),
      'fuente': 'declarado_empresa',
    });
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config(widget.tipo);
    final dias = widget.horarioEmpresa is Map ? (widget.horarioEmpresa as Map)['dias'] : null;
    final tieneHorario = dias is Map && dias.isNotEmpty;
    final visibles = cfg.campos.where((c) =>
        c.codigo != 'horas_fuera_horario_dia' && c.codigo != 'porcentaje_encendido_fuera'
            || _modo == 'parcial' || _modo == 'continuo' || _modo == 'uso_fuera').toList();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Uso real del activo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(tieneHorario
                ? 'Se tomará como referencia el horario registrado de la empresa. '
                    'Las horas reales del equipo pueden ser diferentes.'
                : 'La empresa todavía no tiene horario registrado. '
                    'Puedes registrar el uso, pero faltará la referencia horaria.',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            Text(cfg.pregunta, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              key: ValueKey('modo-${widget.tipo}'),
              initialValue: _modo,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Comportamiento fuera del horario'),
              items: cfg.opciones.map((o) => DropdownMenuItem<String>(
                value: o.valor, child: Text(o.etiqueta, overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: (v) {
                setState(() {
                  if (v != _modo) _mediciones.clear();
                  _modo = v;
                });
                _emitir();
              },
            ),
            if (_modo != null) ...[
              const SizedBox(height: 8),
              for (final campo in visibles) ...[
                const SizedBox(height: 8),
                TextFormField(
                  key: ValueKey('${widget.tipo}-${campo.codigo}'),
                  initialValue: _mediciones[campo.codigo]?.toString(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: campo.etiqueta,
                    helperText: 'Opcional: indica solo valores conocidos o medidos.',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    return n == null || n < 0 || n > campo.maximo
                        ? 'Ingresa un valor entre 0 y ${campo.maximo}' : null;
                  },
                  onChanged: (v) {
                    final n = double.tryParse(v.trim().replaceAll(',', '.'));
                    if (n == null || n < 0 || n > campo.maximo) {
                      _mediciones.remove(campo.codigo);
                    } else {
                      _mediciones[campo.codigo] = n;
                    }
                    _emitir();
                  },
                ),
              ],
            ],
            const SizedBox(height: 8),
            const Text('Estas respuestas son declaradas y no modifican '
                'automáticamente la ficha técnica ni la elegibilidad verde.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
