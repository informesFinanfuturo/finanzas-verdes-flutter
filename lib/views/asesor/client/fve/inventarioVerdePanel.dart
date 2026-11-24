import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/models/api/fveInventarioApi.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/campoTecnicoVerde.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Consulta del inventario. Los datos tecnicos se editan una sola vez en Activos.
class InventarioVerdePanel extends StatefulWidget {
  final int idMipyme;
  const InventarioVerdePanel({super.key, required this.idMipyme});
  @override
  State<InventarioVerdePanel> createState() => _InventarioVerdePanelState();
}

class _InventarioVerdePanelState extends State<InventarioVerdePanel> {
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _activos = [];

  @override
  void initState() { super.initState(); _cargar(); }
  @override
  void didUpdateWidget(covariant InventarioVerdePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idMipyme != widget.idMipyme) _cargar();
  }

  Future<void> _cargar() async {
    final empresa = widget.idMipyme;
    if (empresa <= 0) { setState(() { _cargando = false; _error = 'Empresa inválida'; }); return; }
    setState(() { _cargando = true; _error = null; });
    try {
      final datos = await cargarInventarioFveApi(empresa);
      if (mounted && widget.idMipyme == empresa) setState(() => _activos = datos);
    } catch (e) {
      if (mounted && widget.idMipyme == empresa) setState(() => _error = e.toString());
    } finally {
      if (mounted && widget.idMipyme == empresa) setState(() => _cargando = false);
    }
  }

  Future<void> _validar(Map<String, dynamic> activo) async {
    final id = (activo['id_activo'] as num).toInt();
    try {
      final r = await validarReemplazoFveApi(id);
      if (!mounted) return;
      final faltantes = (r['campos_pendientes'] as List<dynamic>? ?? [])
          .map((x) => Map<String, dynamic>.from(x as Map)).toList();
      if (faltantes.isEmpty) {
        await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
          title: Text('Reemplazo · ${activo['nombre'] ?? 'Activo'}'),
          content: const Text('La ficha del equipo actual tiene los datos necesarios. '
              'La elegibilidad ambiental se comprobará al seleccionar una Tecnología Verde.'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido'))],
        ));
        return;
      }
      // Se solicitan exclusivamente los campos faltantes. Se guardan en la
      // misma ficha del equipo existente, no en un formulario duplicado.
      final controles = <String, TextEditingController>{};
      for (final campo in faltantes) {
        controles[campo['codigo'].toString()] = TextEditingController();
      }
      bool guardando = false;
      final formKey = GlobalKey<FormState>();
      try {
        await showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(
          builder: (ctx, actualizar) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(children: [
              Icon(Icons.fact_check_outlined, color: Global.primary),
              const SizedBox(width: 10),
              const Expanded(child: Text('Datos para evaluar el reemplazo')),
            ]),
            content: SizedBox(
              width: 540,
              child: SingleChildScrollView(child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Equipo actual: ${activo['nombre'] ?? 'Activo'}',
                      style: Theme.of(ctx).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    const Text('Completa únicamente los datos que faltan. '
                      'Quedarán guardados en la ficha original del activo.'),
                    const SizedBox(height: 20),
                    LayoutBuilder(builder: (ctx, limites) {
                      final dobleColumna = limites.maxWidth >= 500;
                      final ancho = dobleColumna
                        ? (limites.maxWidth - 12) / 2 : limites.maxWidth;
                      return Wrap(spacing: 12, runSpacing: 14, children: [
                        for (final campo in faltantes)
                          SizedBox(
                            width: ancho,
                            child: CampoTecnicoVerde(
                              campo: campo,
                              controller: controles[campo['codigo'].toString()]!,
                              obligatorio: true,
                            ),
                          ),
                      ]);
                    }),
                    const SizedBox(height: 10),
                    Text('Los valores se validan antes de guardar.',
                      style: Theme.of(ctx).textTheme.bodySmall),
                  ],
                ),
              )),
            ),
            actions: [
              TextButton(
                onPressed: guardando ? null : () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: guardando ? null : () async {
                  if (formKey.currentState?.validate() != true) return;
                  final nuevos = <String, dynamic>{};
                  for (final campo in faltantes) {
                    final codigo = campo['codigo'].toString();
                    final raw = controles[codigo]!.text.trim();
                    nuevos[codigo] = CampoTecnicoVerde.valorParaGuardar(campo, raw);
                  }
                  // Conservar las caracteristicas existentes del equipo actual.
                  final caracterizacion = activo['caracterizacion'];
                  final anteriores = caracterizacion is Map &&
                          caracterizacion['datos_tecnicos'] is Map
                      ? Map<String, dynamic>.from(caracterizacion['datos_tecnicos'] as Map)
                      : <String, dynamic>{};
                  final camposValidos = (activo['campos_existentes'] as List<dynamic>? ?? [])
                      .map((x) => (x as Map)['codigo'].toString()).toSet();
                  final datos = <String, dynamic>{};
                  for (final entry in anteriores.entries) {
                    if (camposValidos.contains(entry.key)) datos[entry.key] = entry.value;
                  }
                  datos.addAll(nuevos);
                  actualizar(() => guardando = true);
                  try {
                    await guardarInventarioFveApi(idActivo: id, datosTecnicos: datos);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    await _cargar();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Datos guardados en la ficha del activo.')));
                  } catch (e) {
                    if (ctx.mounted) {
                      actualizar(() => guardando = false);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text(guardando ? 'Guardando...' : 'Guardar datos'),
              ),
            ],
          ),
        ));
      } finally {
        for (final c in controles.values) { c.dispose(); }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() => _buildInventario(context));

  Widget _buildInventario(BuildContext context) {
    final completas = _activos.where((a) => a['caracterizacion'] != null &&
        (a['campos_pendientes'] as List<dynamic>? ?? []).isEmpty).length;
    final tema = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Global.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tema.dividerColor.withOpacity(0.6)),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(Icons.eco_outlined, color: Global.primary),
        title: const Text('Inventario verde HORECA',
          style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(_cargando
          ? 'Consultando equipos...'
          : _error != null ? 'No fue posible cargar el inventario'
          : '$completas de ${_activos.length} equipos con datos técnicos completos'),
        childrenPadding: const EdgeInsets.fromLTRB(18, 2, 18, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Las categorías se asignan automáticamente. '
              'Los datos del equipo actual se actualizan desde Activos.',
              style: tema.textTheme.bodySmall),
          ),
          const SizedBox(height: 12),
          if (_cargando) const LinearProgressIndicator(),
          if (_error != null) ...[
            Text(_error!, style: TextStyle(color: tema.colorScheme.error)),
            TextButton.icon(onPressed: _cargar,
              icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
          ],
          if (!_cargando && _error == null && _activos.isEmpty)
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('No hay equipos con una categoría disponible'),
              subtitle: Text('Los demás activos permanecen en el inventario general.'),
            ),
          if (_error == null && !_cargando)
            for (final activo in _activos) ...[
              LayoutBuilder(builder: (ctx, limites) {
                final compacto = limites.maxWidth < 620;
                final completo = activo['caracterizacion'] != null &&
                    (activo['campos_pendientes'] as List<dynamic>? ?? []).isEmpty;
                final nombre = '${activo['nombre'] ?? 'Equipo'}';
                final categoria =
                    '${(activo['taxonomia'] as Map?)?['nombre'] ?? 'Sin categoría'}';
                final resumen = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: tema.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(categoria, style: tema.textTheme.bodySmall),
                    const SizedBox(height: 5),
                    Text(completo ? 'Información técnica completa'
                        : 'Información técnica pendiente para reemplazo',
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: tema.colorScheme.onSurface.withOpacity(0.7))),
                  ],
                );
                final boton = OutlinedButton.icon(
                  onPressed: () => _validar(activo),
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: const Text('Revisar reemplazo'),
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: compacto
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [resumen, const SizedBox(height: 10), boton])
                    : Row(children: [
                        Expanded(child: resumen),
                        const SizedBox(width: 16),
                        boton,
                      ]),
                );
              }),
              const Divider(height: 1),
            ],
        ],
      ),
    );
  }
}
