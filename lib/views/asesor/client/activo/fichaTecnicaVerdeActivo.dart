import 'dart:async';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/models/api/fveInventarioApi.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/campoTecnicoVerde.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/perfilUsoActivo.dart';
import 'package:flutter/material.dart';

/// Datos tecnicos opcionales del equipo actual, dentro de su ficha de Activos.
class FichaTecnicaVerdeActivo extends StatefulWidget {
  final int? idActivo;
  final String tipo;
  final String nombre;
  final ValueChanged<Map<String, dynamic>?> onChanged;
  final bool aplicarSugerenciasIA;
  final Map<String, dynamic>? perfilUsoInicial;
  final dynamic horarioEmpresa;
  final ValueChanged<Map<String, dynamic>?>? onPerfilUsoChanged;

  const FichaTecnicaVerdeActivo({
    super.key,
    required this.idActivo,
    required this.tipo,
    required this.nombre,
    required this.onChanged,
    this.aplicarSugerenciasIA = false,
    this.perfilUsoInicial,
    this.horarioEmpresa,
    this.onPerfilUsoChanged,
  });

  @override
  State<FichaTecnicaVerdeActivo> createState() => _FichaTecnicaVerdeActivoState();
}

class _FichaTecnicaVerdeActivoState extends State<FichaTecnicaVerdeActivo> {
  bool _cargando = true;
  String? _error;
  Map<String, dynamic>? _ficha;
  final Map<String, TextEditingController> _control = {};
  final Map<String, Map<String, dynamic>> _referenciasPendientes = {};
  Timer? _debounce;
  bool _dirty = false;
  int _version = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(covariant FichaTecnicaVerdeActivo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idActivo != widget.idActivo ||
        oldWidget.tipo != widget.tipo || oldWidget.nombre != widget.nombre) {
      if (oldWidget.idActivo != widget.idActivo || oldWidget.tipo != widget.tipo) {
        _dirty = false;
        widget.onChanged(null);
      }
      if (!_dirty) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 400), _cargar);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in _control.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> _cargar() async {
    final version = ++_version;
    setState(() { _cargando = true; _error = null; });
    try {
      final ficha = widget.idActivo != null
          ? await consultarFichaActivoFveApi(widget.idActivo!)
          : await clasificarActivoFveApi(tipo: widget.tipo, nombre: widget.nombre);
      if (!mounted || version != _version) return;
      Map<String, dynamic> finalFicha = ficha;
      if (widget.idActivo != null) {
        final auto = await clasificarActivoFveApi(tipo: widget.tipo, nombre: widget.nombre);
        if (!mounted || version != _version) return;
        if (auto['codigo_taxonomia'] != ficha['codigo_taxonomia']) finalFicha = auto;
      }
      if (_dirty) return;
      for (final c in _control.values) { c.dispose(); }
      _control.clear();
      final datos = finalFicha['datos_tecnicos'] is Map
          ? Map<String, dynamic>.from(finalFicha['datos_tecnicos'] as Map)
          : <String, dynamic>{};
      final campos = finalFicha['campos_existentes'] as List<dynamic>? ?? [];
      for (final raw in campos) {
        final campo = Map<String, dynamic>.from(raw as Map);
        final clave = campo['codigo'].toString();
        _control[clave] = TextEditingController(text: datos[clave]?.toString() ?? '');
      }
      // Precarga exclusivamente sugerencias nuevas con evidencia. No se guardan
      // en la caracterizacion hasta que el asesor revise y guarde la ficha.
      int precargados = 0;
      final sugerencias = finalFicha["sugerencias_ia"];
      if (widget.aplicarSugerenciasIA && sugerencias is Map) {
        final definiciones = {
          for (final raw in campos)
            (raw as Map)["codigo"].toString(): Map<String, dynamic>.from(raw),
        };
        for (final entry in sugerencias.entries) {
          final clave = entry.key.toString();
          final control = _control[clave];
          final definicion = definiciones[clave];
          if (control == null || definicion == null || control.text.trim().isNotEmpty) continue;
          final valor = entry.value.toString();
          if (CampoTecnicoVerde.validar(definicion, valor) != null) continue;
          control.text = valor;
          precargados++;
        }
      }
      _referenciasPendientes.clear();
      setState(() => _ficha = finalFicha);
      // Referencias del informe: precarga VISUAL, pero no pasan al guardado
      // hasta que el asesor confirme que son datos del equipo real.
      if (widget.aplicarSugerenciasIA) _proponerReferencias();
      if (precargados > 0) {
        _cambio();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("IA sugirio $precargados datos tecnicos. Revisalos y pulsa Guardar para confirmarlos."),
          ));
        }
      }
    } catch (e) {
      if (mounted && version == _version) setState(() => _error = e.toString());
    } finally {
      if (mounted && version == _version) setState(() => _cargando = false);
    }
  }

  void _cambio() {
    _dirty = true;
    final valores = <String, dynamic>{};
    for (final entry in _control.entries) {
      final texto = entry.value.text.trim();
      // No enviar estimaciones del informe como hechos por accidente.
      if (texto.isNotEmpty && !_referenciasPendientes.containsKey(entry.key)) {
        valores[entry.key] = texto;
      }
    }
    widget.onChanged(valores);
  }

  void _proponerReferencias() {
    final sugerencias = _ficha?['referencias_ia'];
    if (sugerencias is! Map || sugerencias.isEmpty) return;
    final campos = _ficha?['campos_existentes'] as List<dynamic>? ?? [];
    final definiciones = {
      for (final c in campos)
        (c as Map)['codigo'].toString(): Map<String, dynamic>.from(c),
    };
    int nuevos = 0;
    for (final entry in sugerencias.entries) {
      final clave = entry.key.toString();
      if (entry.value is! Map) continue;
      final sugerencia = Map<String, dynamic>.from(entry.value as Map);
      final campo = _control[clave];
      final definicion = definiciones[clave];
      if (campo == null || definicion == null || campo.text.trim().isNotEmpty) continue;
      final valor = sugerencia['valor']?.toString() ?? '';
      if (CampoTecnicoVerde.validar(definicion, valor) != null || valor.isEmpty) continue;
      campo.text = valor;
      _referenciasPendientes[clave] = sugerencia;
      nuevos++;
    }
    if (nuevos > 0 && mounted) setState(() {});
  }

  void _confirmarReferencias() {
    if (_referenciasPendientes.isEmpty) return;
    setState(() => _referenciasPendientes.clear());
    _cambio();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Datos confirmados para este activo. Pulsa Guardar para conservarlos.'),
    ));
  }

  void _descartarReferencias() {
    for (final clave in _referenciasPendientes.keys) {
      _control[clave]?.clear();
    }
    setState(() => _referenciasPendientes.clear());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Se descartaron las referencias sin verificar.'),
    ));
  }

  void _sugerir() {
    final raw = _ficha?['sugerencias'];
    if (raw is! Map || raw.isEmpty) return;
    final campos = _ficha?['campos_existentes'] as List<dynamic>? ?? [];
    final definiciones = {
      for (final c in campos)
        (c as Map)['codigo'].toString(): Map<String, dynamic>.from(c),
    };
    int aplicados = 0;
    for (final entry in raw.entries) {
      final clave = entry.key.toString();
      final campo = _control[clave];
      final definicion = definiciones[clave];
      if (campo == null || definicion == null || campo.text.trim().isNotEmpty) continue;
      final sugerido = entry.value.toString();
      if (CampoTecnicoVerde.validar(definicion, sugerido) != null) continue;
      campo.text = sugerido;
      aplicados++;
    }
    if (aplicados > 0) {
      _cambio();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Revisa los datos sugeridos antes de guardarlos.'),
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final categoria = _ficha?['taxonomia'];
    final cat = categoria is Map ? categoria : null;
    final campos = _ficha?['campos_existentes'] as List<dynamic>? ?? [];
    final sugerencias = _ficha?['sugerencias'];
    return Card(
      elevation: 0,
      color: Global.container,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tema.dividerColor.withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Global.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.tune_outlined, color: Global.primary, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Características técnicas',
                style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text('Datos del equipo actual',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurface.withOpacity(0.7))),
            ])),
            if (_cargando) const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2)),
          ]),
          const SizedBox(height: 16),
          Text('Completa solo la información que conozcas. El registro del activo puede guardarse sin estos datos.',
            style: tema.textTheme.bodyMedium),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: tema.colorScheme.error)),
            TextButton.icon(onPressed: _cargar, icon: const Icon(Icons.refresh),
              label: const Text('Reintentar')),
          ] else if (!_cargando && cat == null) ...[
            const SizedBox(height: 12),
            Text('Este equipo no tiene una categoría de Tecnología Verde asignada automáticamente.',
              style: tema.textTheme.bodySmall),
          ] else if (cat != null) ...[
            const SizedBox(height: 16),
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Global.primary.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle_outline, size: 16, color: Global.primary),
                    const SizedBox(width: 7),
                    Text('${cat['nombre']}', style: TextStyle(
                      fontWeight: FontWeight.w600, color: Global.primary)),
                  ]),
                ),
                Text('Categoría asignada automáticamente',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurface.withOpacity(0.7))),
              ]),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: LayoutBuilder(builder: (context, limites) {
                final disponible = limites.maxWidth.isFinite ? limites.maxWidth : 420.0;
                final dobleColumna = disponible >= 620;
                final ancho = dobleColumna
                    ? (disponible - 16) / 2 : disponible;
                return Wrap(spacing: 16, runSpacing: 16, children: [
                  for (final raw in campos)
                    SizedBox(
                      width: ancho,
                      child: CampoTecnicoVerde(
                        campo: Map<String, dynamic>.from(raw as Map),
                        controller: _control[(raw as Map)['codigo'].toString()]!,
                        onChanged: (_) {
                          // Al editar el campo, la persona asume el valor declarado.
                          _referenciasPendientes.remove((raw as Map)['codigo'].toString());
                          _cambio();
                        },
                      ),
                    ),
                ]);
              }),
            ),
            if (_referenciasPendientes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: tema.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tema.colorScheme.outline.withOpacity(0.45)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.info_outline_rounded, size: 20, color: tema.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Referencias de IA pendientes de verificar',
                      style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 8),
                  Text('Se mostraron en los campos como borrador, pero NO se guardarán como datos del equipo hasta confirmarlos. Si proceden de modelos parecidos o estimaciones, descártalos. Comprueba la placa, ficha técnica o documento del equipo real.',
                    style: tema.textTheme.bodySmall),
                  const SizedBox(height: 10),
                  for (final entry in _referenciasPendientes.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${entry.value['origen'] ?? entry.key}: ${entry.value['evidencia'] ?? entry.value['valor']}',
                        style: tema.textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton.tonalIcon(
                      onPressed: _confirmarReferencias,
                      icon: const Icon(Icons.fact_check_outlined, size: 18),
                      label: const Text('He verificado estos datos'),
                    ),
                    TextButton.icon(
                      onPressed: _descartarReferencias,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Descartar referencias'),
                    ),
                  ]),
                ]),
              ),
            ],
            const SizedBox(height: 12),
            Text('Para números decimales puedes usar coma o punto. Los datos necesarios para un reemplazo se comprobarán al iniciar su evaluación.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurface.withOpacity(0.7))),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 6, children: [
              if (sugerencias is Map && sugerencias.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: _sugerir,
                  icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: const Text('Usar datos sugeridos'),
                ),
              if (!_dirty && _referenciasPendientes.isEmpty &&
                  _ficha?['referencias_ia'] is Map &&
                  (_ficha!['referencias_ia'] as Map).isNotEmpty)
                OutlinedButton.icon(
                  onPressed: _proponerReferencias,
                  icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: const Text('Revisar referencias de IA'),
                ),
              if (!_dirty)
                TextButton.icon(onPressed: _cargar,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Actualizar información')),
            ]),
          ],
          // FVE_USO_ACTIVOS_V2: la captura de uso pertenece a la misma ficha.
          if (widget.onPerfilUsoChanged != null) ...[
            const SizedBox(height: 20),
            Divider(color: tema.dividerColor.withOpacity(0.55)),
            const SizedBox(height: 16),
            PerfilUsoActivo(
              key: ValueKey("uso-${widget.idActivo ?? 'nuevo'}-${widget.tipo}"),
              tipo: widget.tipo,
              inicial: widget.perfilUsoInicial,
              horarioEmpresa: widget.horarioEmpresa,
              onChanged: widget.onPerfilUsoChanged!,
            ),
          ],
        ]),
      ),
    );
  }
}
