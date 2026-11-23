import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:flutter/material.dart';

// FVE_PERFIL_USO_V2. Datos declarados. Compatible con fve_perfil_uso version 1.
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
  final List<String> modos;
  const _CampoUso(this.codigo, this.etiqueta, this.maximo, this.modos);

  bool visibleEn(String? modo) => modo != null && modos.contains(modo);
}

class _ConfigUso {
  final String pregunta;
  final String aclaracion;
  final List<_OpcionUso> opciones;
  final List<_CampoUso> campos;
  const _ConfigUso(this.pregunta, this.aclaracion, this.opciones, this.campos);
}

class _PerfilUsoActivoState extends State<PerfilUsoActivo> {
  String? _modo;
  final Map<String, double> _mediciones = {};

  static const _desconocido = _OpcionUso('desconocido', 'No se conoce');
  static const _apagado = _OpcionUso('apagado', 'Se apaga o desconecta al cerrar');
  static const _continuo = _OpcionUso('continuo', 'Permanece conectado las 24 horas');
  static const _continuoEncendido = _OpcionUso('continuo', 'Permanece encendido las 24 horas');
  static const _espera = _OpcionUso('espera', 'Queda encendido en espera o reposo');
  static const _parcial = _OpcionUso('parcial', 'Funciona algunas horas después del cierre');
  static const _sinUso = _OpcionUso('sin_uso', 'No se utiliza fuera del horario');
  static const _usoFuera = _OpcionUso('uso_fuera', 'Sí se utiliza fuera del horario');

  static const _horasUso = _CampoUso(
    'horas_uso_dia', 'Horas totales de uso al día (incluye fuera de horario)', 24,
    ['apagado', 'espera', 'parcial'],
  );
  static const _horasExtra = _CampoUso(
    'horas_fuera_horario_dia', 'Horas de uso después del cierre (incluidas en el total)', 24,
    ['parcial'],
  );
  static const _ciclos = _CampoUso(
    'ciclos_semana', 'Ciclos totales de uso por semana', 10000,
    ['sin_uso', 'uso_fuera'],
  );
  static const _minutosCiclo = _CampoUso(
    'minutos_ciclo', 'Duración aproximada de un ciclo (minutos)', 1440,
    ['sin_uso', 'uso_fuera'],
  );
  static const _minutosAgua = _CampoUso(
    'minutos_uso_dia', 'Minutos totales de uso al día', 1440,
    ['sin_uso', 'uso_fuera'],
  );
  static const _descargas = _CampoUso(
    'descargas_dia', 'Descargas totales del sanitario al día', 10000,
    ['sin_uso', 'uso_fuera'],
  );

  _ConfigUso _config(String tipo) {
    switch (tipo) {
      case 'Neveras':
        return const _ConfigUso(
          '¿La nevera permanece conectada cuando el establecimiento cierra?',
          'Conectada no significa que el compresor funcione sin parar: trabaja por ciclos.',
          [_continuo, _apagado, _parcial, _desconocido],
          [_horasExtra],
        );
      case 'Refrigeración':
        return const _ConfigUso(
          '¿El equipo de refrigeración permanece conectado fuera de la jornada?',
          'Si mantiene los productos fríos todo el tiempo, selecciona funcionamiento continuo.',
          [_continuo, _apagado, _parcial, _desconocido],
          [_horasExtra],
        );
      case 'Vitrinas':
        return const _ConfigUso(
          '¿La vitrina sigue consumiendo energía después del cierre?',
          'Considera refrigeración, calentamiento o iluminación, según el tipo de vitrina.',
          [_continuo, _apagado, _parcial, _desconocido],
          [_horasExtra],
        );
      case 'Iluminación':
        return const _ConfigUso(
          '¿Qué sucede con esta luminaria o grupo de luminarias al cerrar?',
          'Registra el comportamiento de las unidades descritas en este activo, no el de todo el negocio.',
          [_apagado, _continuoEncendido, _parcial, _desconocido],
          [_horasUso, _horasExtra],
        );
      case 'Climatización':
        return const _ConfigUso(
          '¿El aire acondicionado o ventilador permanece encendido al cerrar?',
          'Distingue entre apagado, modo de espera y funcionamiento fuera de la jornada.',
          [_apagado, _espera, _continuoEncendido, _parcial, _desconocido],
          [_horasUso, _horasExtra],
        );
      case 'Hornos':
        return const _ConfigUso(
          '¿Qué sucede con el horno al terminar la jornada?',
          'Estar encendido para mantener temperatura no equivale a estar cocinando.',
          [_apagado, _espera, _parcial, _desconocido],
          [_horasUso, _horasExtra],
        );
      case 'Televisores':
        return const _ConfigUso(
          '¿Qué sucede con el televisor cuando la empresa cierra?',
          'El modo de espera consume energía aunque la pantalla parezca apagada.',
          [_apagado, _espera, _continuoEncendido, _parcial, _desconocido],
          [_horasUso, _horasExtra],
        );
      case 'Lavadoras':
        return const _ConfigUso(
          '¿La lavadora realiza ciclos fuera del horario de atención?',
          'El uso se caracteriza mejor por ciclos que por horas de conexión.',
          [_sinUso, _usoFuera, _desconocido],
          [_ciclos, _minutosCiclo],
        );
      case 'Lava vajillas':
        return const _ConfigUso(
          '¿El lavavajillas realiza ciclos fuera del horario de atención?',
          'Indica los ciclos de lavado habituales, no las horas que permanece conectado.',
          [_sinUso, _usoFuera, _desconocido],
          [_ciclos, _minutosCiclo],
        );
      case 'Secadoras':
        return const _ConfigUso(
          '¿La secadora realiza ciclos fuera del horario de atención?',
          'Indica los ciclos de secado habituales, no las horas que permanece conectada.',
          [_sinUso, _usoFuera, _desconocido],
          [_ciclos, _minutosCiclo],
        );
      case 'Grifos':
        return const _ConfigUso(
          '¿Se utiliza este grifo fuera del horario de atención?',
          'Registra minutos de uso del punto de agua, no el tiempo que la llave queda instalada.',
          [_sinUso, _usoFuera, _desconocido],
          [_minutosAgua],
        );
      case 'Reductores de caudal':
        return const _ConfigUso(
          '¿Se utiliza fuera del horario el grifo o ducha con reductor?',
          'El reductor no funciona por horas; importa el tiempo de uso del punto de agua.',
          [_sinUso, _usoFuera, _desconocido],
          [_minutosAgua],
        );
      case 'Sanitarios':
        return const _ConfigUso(
          '¿Este sanitario se utiliza fuera del horario de atención?',
          'Para el consumo de agua se cuentan descargas, no horas conectado.',
          [_sinUso, _usoFuera, _desconocido],
          [_descargas],
        );
      default:
        return const _ConfigUso(
          '¿El activo permanece encendido o se utiliza después del cierre?',
          'Selecciona solo lo que conozcas sobre el uso real de este equipo.',
          [_apagado, _espera, _continuoEncendido, _parcial, _desconocido],
          [_horasUso, _horasExtra],
        );
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
      _cargar(widget.inicial);
    }
  }

  void _cargar(Map<String, dynamic>? data) {
    if (data == null || data['tipo_activo'] != widget.tipo) return;
    final guardado = data['modo']?.toString();
    if (!_config(widget.tipo).opciones.any((o) => o.valor == guardado)) return;
    _modo = guardado;
    final raw = data['mediciones'];
    if (raw is Map) {
      for (final entry in raw.entries) {
        final valor = entry.value;
        if (valor is num && valor.isFinite) {
          _mediciones[entry.key.toString()] = valor.toDouble();
        }
      }
    }
  }

  void _emitir() {
    if (_modo == null) {
      widget.onChanged(null);
      return;
    }
    final visibles = _config(widget.tipo).campos
        .where((campo) => campo.visibleEn(_modo))
        .map((campo) => campo.codigo).toSet();
    final validas = <String, double>{};
    for (final entry in _mediciones.entries) {
      if (visibles.contains(entry.key) && entry.value.isFinite) {
        validas[entry.key] = entry.value;
      }
    }
    widget.onChanged({
      'version': 1,
      'tipo_activo': widget.tipo,
      'modo': _modo,
      'mediciones': validas,
      'fuente': 'declarado_empresa',
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cfg = _config(widget.tipo);
    final dias = widget.horarioEmpresa is Map
        ? (widget.horarioEmpresa as Map)['dias'] : null;
    final tieneHorario = dias is Map && dias.isNotEmpty;
    final campos = cfg.campos.where((c) => c.visibleEn(_modo)).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.primary.withOpacity(0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Global.primary.withOpacity(0.17)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.schedule_outlined, size: 20, color: Global.primary),
            const SizedBox(width: 9),
            Expanded(child: Text('Uso y funcionamiento del equipo',
              style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 7),
          Text(tieneHorario
              ? 'Se usa como referencia el horario de la empresa. El uso de este equipo puede ser distinto.'
              : 'No hay horario empresarial disponible. Registra solo el uso que conozcas.',
            style: tema.textTheme.bodySmall),
          const SizedBox(height: 13),
          Text(cfg.pregunta, style: tema.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(cfg.aclaracion, style: tema.textTheme.bodySmall?.copyWith(
            color: tema.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey('modo-${widget.tipo}'),
            initialValue: _modo,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Comportamiento del activo',
              filled: true,
              fillColor: tema.colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: cfg.opciones.map((op) => DropdownMenuItem<String>(
              value: op.valor,
              child: Text(op.etiqueta, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (valor) {
              setState(() {
                if (valor != _modo) _mediciones.clear();
                _modo = valor;
              });
              _emitir();
            },
          ),
          if (_modo == 'continuo') ...[
            const SizedBox(height: 9),
            Text(widget.tipo == 'Neveras' || widget.tipo == 'Refrigeración'
                ? 'Si el equipo permanece conectado las 24 horas, no ingreses horas adicionales. El compresor opera por ciclos.'
                : 'El equipo permanece encendido o conectado según lo declarado. No necesitas calcular horas fuera de la jornada.',
              style: tema.textTheme.bodySmall),
          ],
          if (campos.isNotEmpty) ...[
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, limites) {
              final ancho = limites.maxWidth >= 610
                  ? (limites.maxWidth - 12) / 2 : limites.maxWidth;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                for (final campo in campos)
                  SizedBox(width: ancho, child: TextFormField(
                    key: ValueKey('${widget.tipo}-${_modo}-${campo.codigo}'),
                    initialValue: _mediciones[campo.codigo]?.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: campo.etiqueta,
                      helperText: 'Opcional. Solo valores conocidos o medidos.',
                      filled: true,
                      fillColor: tema.colorScheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (texto) {
                      if (texto == null || texto.trim().isEmpty) return null;
                      final numero = double.tryParse(texto.trim().replaceAll(',', '.'));
                      return numero == null || !numero.isFinite ||
                              numero < 0 || numero > campo.maximo
                          ? 'Valor válido: entre 0 y ${campo.maximo}' : null;
                    },
                    onChanged: (texto) {
                      final numero = double.tryParse(texto.trim().replaceAll(',', '.'));
                      if (numero == null || !numero.isFinite ||
                          numero < 0 || numero > campo.maximo) {
                        _mediciones.remove(campo.codigo);
                      } else {
                        _mediciones[campo.codigo] = numero;
                      }
                      _emitir();
                    },
                  )),
              ]);
            }),
          ],
          const SizedBox(height: 11),
          Text('Información declarada por la empresa. No reemplaza mediciones, '
              'no cambia automáticamente el consumo de la ficha técnica ni la elegibilidad.',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurface.withOpacity(0.65))),
        ],
      ),
    );
  }
}
