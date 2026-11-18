import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/fveApi.dart';
import 'package:finanzas_verdes/models/api/fveNegociacionApi.dart';
import 'package:finanzas_verdes/views/asesor/client/fve/negociacionIntegralPanel.dart';
import 'package:finanzas_verdes/views/asesor/client/diagnostico/seleccionarAlternativaDiagnostico.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Procesofveasesor extends StatefulWidget {
  const Procesofveasesor({super.key});
  @override
  State<Procesofveasesor> createState() => _ProcesofveasesorState();
}

class _ProcesofveasesorState extends State<Procesofveasesor> {
  final ClientController cliente = Get.find<ClientController>();
  bool cargando = false;
  bool guardando = false;
  String? error;
  List<Map<String, dynamic>> lineas = [];
  List<Map<String, dynamic>> disponibles = [];

  static const List<String> pasos = [
    'Inicio', 'Confirmar activos', 'Propuesta', 'PDF', 'Decisión',
    'Financiación', 'Viabilidad', 'Cierre',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) cargar();
    });
  }

  static int? entero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num && valor.isFinite && valor == valor.roundToDouble()) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '');
  }
  static String texto(dynamic dato, [String falta = '']) {
    final s = dato?.toString().trim() ?? '';
    return s.isEmpty || s.toLowerCase() == 'null' ? falta : s;
  }
  static Map<String, dynamic> mapa(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  int pasoVisible(Map<String, dynamic> proceso) {
    final original = entero(proceso['paso_actual']) ?? 2;
    if (entero(proceso['version_flujo']) == 8) return original.clamp(1, 8).toInt();
    if (original <= 1) return 1;
    if (original <= 3) return 2;
    return (original - 1).clamp(1, 8).toInt();
  }

  Future<void> cargar() async {
    final id = entero(cliente.ProcesoFve['id_proceso']);
    if (id == null || cargando) return;
    setState(() { cargando = true; error = null; });
    try {
      final p = await obtenerProcesoFveApi(idProceso: id);
      final respuesta = await obtenerSeleccionFveApi(idProceso: id);
      if (!mounted) return;
      cliente.setProcesoFve(p);
      setState(() {
        lineas = (respuesta['lineas'] as List<dynamic>? ?? [])
            .whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        disponibles = (respuesta['activos_disponibles'] as List<dynamic>? ?? [])
            .whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      if (mounted) setState(() => error = texto(e));
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> cambiarProducto(int indice) async {
    final proceso = mapa(cliente.ProcesoFve);
    final idDiagnostico = entero(proceso['id_diagnostico']);
    final idActivo = entero(lineas[indice]['id_activo']);
    if (idDiagnostico == null || idActivo == null) return;
    final actual = lineas[indice];
    final alternativa = await mostrarSelectorAlternativaDiagnostico(
      context: context,
      idDiagnostico: idDiagnostico,
      idActivo: idActivo,
      seleccionActual: actual['id_item'] == null ? null : {'id_item': actual['id_item']},
    );
    if (alternativa == null || !mounted) return;
    final idItem = entero(alternativa['id_item']);
    if (idItem == null) return;
    final proveedor = mapa(alternativa['proveedor']);
    setState(() {
      lineas[indice] = {...actual,
        'id_item': idItem,
        'nombre_producto': alternativa['nombre'],
        'nombre_proveedor': proveedor['nombre'] ?? alternativa['nombre_proveedor'],
        'precio_base': alternativa['precio_base'],
        'disponible': alternativa['disponible'] == true,
        'origen': 'asesor_fve',
      };
    });
  }

  void cambiarCantidad(int indice, int cambio) {
    final actual = entero(lineas[indice]['cantidad']) ?? 1;
    final nuevo = (actual + cambio).clamp(1, 10000);
    if (actual == nuevo) return;
    setState(() => lineas[indice] = {...lineas[indice], 'cantidad': nuevo});
  }

  Future<void> agregarActivo() async {
    final usados = lineas.map((x) => entero(x['id_activo'])).toSet();
    final opciones = disponibles.where((x) => !usados.contains(entero(x['id_activo']))).toList();
    if (opciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No quedan activos disponibles de este diagnóstico.'),
      ));
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(child: ListView(
        shrinkWrap: true,
        children: [
          const ListTile(title: Text('Agregar activo del diagnóstico')),
          for (final a in opciones)
            ListTile(
              title: Text(texto(a['nombre'], 'Activo')),
              subtitle: Text(texto(a['tipo'])),
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () {
                setState(() => lineas.add({
                  'id_activo': a['id_activo'],
                  'activo_nombre': a['nombre'],
                  'id_item': null,
                  'nombre_producto': null,
                  'cantidad': 1,
                  'origen': 'asesor_fve',
                  'disponible': false,
                }));
                Navigator.pop(ctx);
              },
            ),
        ],
      )),
    );
  }

  List<Map<String, dynamic>> payload() => lineas.map((l) => {
    'id_activo': entero(l['id_activo']),
    'id_item': entero(l['id_item']),
    'cantidad': entero(l['cantidad']) ?? 1,
  }).toList();

  Future<void> guardar({required bool confirmar}) async {
    if (guardando) return;
    final id = entero(cliente.ProcesoFve['id_proceso']);
    if (id == null) return;
    if (lineas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Debes incluir al menos un activo en la negociación.'),
      ));
      return;
    }
    if (confirmar && lineas.any((l) => entero(l['id_item']) == null || l['disponible'] != true)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona productos disponibles para todos los activos.'),
      ));
      return;
    }
    setState(() => guardando = true);
    try {
      if (confirmar) {
        await confirmarSeleccionFveApi(idProceso: id, lineas: payload());
      } else {
        await guardarSeleccionFveApi(idProceso: id, lineas: payload());
      }
      await cargar();
      if (mounted && error == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
          confirmar ? 'Selección confirmada. Paso 3: propuesta comercial.' : 'Cambios guardados.',
        )));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texto(e))),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  // FVE_ORIGEN_NAVEGACION: siempre consultar el diagnostico original.
  Future<void> verDiagnostico(Map<String, dynamic> p) async {
    final id = entero(p['id_proceso']);
    if(id == null) return;
    try {
      final r = await FveNegociacionApi.solicitud(id, 'GET', '/diagnostico');
      final original = mapa(r['diagnostico']);
      if(original.isEmpty) throw Exception('El diagnostico de origen no se encontro.');
      cliente.setDiagnostico(original);
      await controller.setPage(AsesorRoutes.viewDiagnostico);
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));
    }
  }

  Widget barraPasos(int paso) => LayoutBuilder(builder: (context, limites) {
    final ancho = limites.maxWidth;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: ancho >= 830 ? ancho : 830,
        child: Row(children: List.generate(pasos.length, (i) {
          final n = i + 1;
          final completado = n < paso;
          final actual = n == paso;
          final color = n <= paso ? Global.primary : Global.textSecondary;
          return Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: Divider(thickness: 1,
                color: i == 0 ? Colors.transparent : n <= paso ? Global.primary : Global.textSecondary.withOpacity(.22))),
              Container(
                width: 25, height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completado ? Global.primary : actual ? Global.primary.withOpacity(.10) : Colors.transparent,
                  border: Border.all(color: color, width: actual ? 2 : 1),
                ),
                child: completado ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text('$n', style: TextStyle(fontSize: 12, color: color)),
              ),
              Expanded(child: Divider(thickness: 1,
                color: i == pasos.length - 1 ? Colors.transparent : n < paso ? Global.primary : Global.textSecondary.withOpacity(.22))),
            ]),
            const SizedBox(height: 4),
            Text(pasos[i], maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: color,
                fontWeight: actual ? FontWeight.bold : FontWeight.normal)),
          ]));
        })),
      ),
    );
  });

  String precio(dynamic valor) {
    final n = valor is num ? valor : num.tryParse(texto(valor));
    if (n == null) return 'Precio pendiente';
    return NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0).format(n);
  }

  Widget fila(int indice, bool editable) {
    final l = lineas[indice];
    final existe = entero(l['id_item']) != null;
    final disponible = l['disponible'] == true;
    final origen = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(texto(l['activo_nombre'], 'Activo'),
        style: TextStyle(color: Global.text, fontWeight: FontWeight.w600)),
      Text('Equipo actual', style: TextStyle(color: Global.textSecondary, fontSize: 11)),
    ]);
    final destino = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(existe ? texto(l['nombre_producto'], 'Producto #${l['id_item']}') : 'Seleccionar tecnología',
        style: TextStyle(color: Global.text, fontWeight: FontWeight.w600)),
      Text(existe
          ? '${texto(l['nombre_proveedor'], 'Proveedor sin identificar')} · ${precio(l['precio_base'])}${disponible ? '' : ' · No disponible'}'
          : 'Producto no registrado en el diagnóstico',
        maxLines: 2, overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Global.textSecondary, fontSize: 11)),
    ]);
    final acciones = <Widget>[
      IconButton(onPressed: (entero(l['cantidad']) ?? 1) > 1 ? () => cambiarCantidad(indice, -1) : null,
        tooltip: 'Disminuir cantidad', visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.remove_circle_outline, size: 18)),
      Text('${l['cantidad'] ?? 1}', style: TextStyle(color: Global.text)),
      IconButton(onPressed: () => cambiarCantidad(indice, 1),
        tooltip: 'Aumentar cantidad', visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.add_circle_outline, size: 18)),
      TextButton(onPressed: guardando ? null : () => cambiarProducto(indice),
        child: Text(existe ? 'Cambiar' : 'Elegir')),
      if (lineas.length > 1)
        IconButton(onPressed: guardando ? null : () => setState(() => lineas.removeAt(indice)),
          tooltip: 'Retirar de la negociación', icon: const Icon(Icons.close, size: 17)),
    ];
    return LayoutBuilder(builder: (context, limites) {
      final compacto = limites.maxWidth < 900;
      final comparacion = Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(Icons.inventory_2_outlined, color: Global.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(flex: 4, child: origen),
        Icon(Icons.arrow_forward, size: 15, color: Global.textSecondary),
        const SizedBox(width: 10),
        Expanded(flex: 5, child: destino),
        if (!editable) ...[
          const SizedBox(width: 12),
          Text('Cant. ${l['cantidad'] ?? 1}',
            style: TextStyle(color: Global.textSecondary, fontSize: 12)),
        ],
      ]);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: compacto
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              comparacion,
              if (editable) Align(alignment: Alignment.centerRight,
                child: Wrap(crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 1, children: acciones)),
            ])
          : Row(children: [
              Expanded(child: comparacion),
              if (editable) ...acciones,
            ]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = mapa(cliente.ProcesoFve);
    final paso = pasoVisible(p);
    final empresa = texto(p['nombre_mipyme'], texto(mapa(cliente.Client['mipyme'])['nombre_mipyme'], 'Cliente'));
    final esConfirmacion = paso == 2;
    if(paso >= 3) {
      return NegociacionIntegralPanel(
        proceso:p,
        onRefresh:cargar,
        onBack:() async {await controller.backPage();},
        onDiagnostico:() => verDiagnostico(p),
      );
    }
    return Column(children: [
      Container(
        color: Global.container,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(children: [
          IconButton(onPressed: controller.backPage, tooltip: 'Volver', icon: const Icon(Icons.arrow_back)),
          const SizedBox(width: 4),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Negociación verde', style: TextStyle(color: Global.text, fontSize: 17, fontWeight: FontWeight.bold)),
            Text(empresa, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Global.textSecondary, fontSize: 12)),
          ])),
          if (cargando || guardando)
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          else IconButton(onPressed: cargar, tooltip: 'Actualizar', icon: const Icon(Icons.refresh)),
        ]),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
        barraPasos(paso),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Global.container, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Global.textSecondary.withOpacity(.18)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Paso $paso de 8 · ${pasos[paso-1]}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Global.text)),
                Text('Diagnóstico: ${texto(p['titulo_diagnostico'], 'Registrado')}',
                  style: TextStyle(fontSize: 12, color: Global.textSecondary),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ])),
              TextButton.icon(onPressed: () => verDiagnostico(p),
                icon: const Icon(Icons.open_in_new, size: 15), label: const Text('Ver diagnóstico')),
            ]),
            const SizedBox(height: 9),
            Divider(color: Global.textSecondary.withOpacity(.16), height: 1),
            const SizedBox(height: 10),
            if (error != null)
              Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(error!,
                style: const TextStyle(color: Colors.red))),
            if (cargando && lineas.isEmpty) const LinearProgressIndicator(),
            if (error == null) ...[
              Text(esConfirmacion ? 'Confirmar selección del diagnóstico' : 'Selección confirmada',
                style: TextStyle(color: Global.text, fontWeight: FontWeight.w600)),
              if (lineas.isEmpty)
                Padding(padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Este diagnóstico aún no tiene una selección guardada para FVE. Vuelve al diagnóstico, elige los productos y pulsa "Guardar selección para FVE".',
                    style: TextStyle(color: Global.textSecondary))),
              for (int i = 0; i < lineas.length; i++) ...[
                fila(i, esConfirmacion),
                if (i < lineas.length - 1) Divider(color: Global.textSecondary.withOpacity(.13)),
              ],
              if (esConfirmacion) ...[
                const SizedBox(height: 10),
                Wrap(spacing: 10, runSpacing: 8, children: [
                  OutlinedButton.icon(onPressed: guardando ? null : agregarActivo,
                    icon: const Icon(Icons.add, size: 17), label: const Text('Añadir activo')),
                  OutlinedButton(onPressed: guardando ? null : () => guardar(confirmar: false),
                    child: const Text('Guardar cambios')),
                  FilledButton.icon(onPressed: guardando ? null : () => guardar(confirmar: true),
                    icon: const Icon(Icons.check, size: 17), label: const Text('Confirmar y continuar')),
                ]),
              ] else if (paso == 3) ...[
                const SizedBox(height: 10),
                Text('Los activos y productos quedaron confirmados. El siguiente trabajo es generar la propuesta comercial.',
                  style: TextStyle(color: Global.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: guardando ? null : () => guardar(confirmar: false),
                  child: const Text('Editar selección antes de la propuesta')),
              ],
            ],
          ]),
        ),
      ])),
    ]);
  }
}
