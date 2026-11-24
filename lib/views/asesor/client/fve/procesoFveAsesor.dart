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
    'Diagnóstico', 'Reemplazos', 'Propuesta', 'PDF', 'Decisión',
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
    if (confirmar && lineas.any((l) => entero(l['cantidad']) != 1)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Hay cantidades heredadas distintas de 1. Corrígelas explícitamente antes de confirmar.'),
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
          confirmar ? 'Reemplazos confirmados. Paso 3: propuesta comercial.' : 'Cambios guardados.',
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
    final idItem = entero(l['id_item']);
    final existe = idItem != null;
    final disponible = existe && l['disponible'] == true;
    final unidades = entero(l['cantidad']) ?? 0;
    final oscuro = controller.isDark.value;
    final verde = oscuro ? const Color(0xFF8DDDB1) : const Color(0xFF166341);
    final fondoNuevo = oscuro ? const Color(0xFF173A30) : const Color(0xFFEDF8F0);
    final bordeNuevo = oscuro ? const Color(0xFF3F9672) : const Color(0xFF9BD2AF);
    final fondoActual = oscuro ? const Color(0xFF2A333A) : const Color(0xFFF4F6F8);
    final fondoAviso = oscuro ? const Color(0xFF4A3620) : const Color(0xFFFFF5E4);
    final colorAviso = oscuro ? const Color(0xFFFFDA9C) : const Color(0xFF8B5519);

    Widget panel({required String titulo, required String nombre,
      required bool destino, required Widget detalle}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: destino ? fondoNuevo : fondoActual,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: destino ? bordeNuevo : Global.textSecondary.withOpacity(.17),
            width: destino ? 1.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: TextStyle(
            color: destino ? verde : Global.textSecondary,
            fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .7)),
          const SizedBox(height: 12),
          Text(nombre, style: TextStyle(color: destino ? (oscuro ? Colors.white : const Color(0xFF143B29)) : Global.text,
            fontSize: 16, fontWeight: FontWeight.w700, height: 1.25)),
          const SizedBox(height: 10),
          detalle,
        ]),
      );
    }

    final origen = panel(
      titulo: 'EQUIPO ACTUAL DEL DIAGNÓSTICO',
      nombre: texto(l['activo_nombre'], 'Activo sin nombre'),
      destino: false,
      detalle: const SizedBox.shrink(),
    );
    final destino = panel(
      titulo: 'TECNOLOGÍA VERDE',
      nombre: existe ? texto(l['nombre_producto'], 'Producto #$idItem') : 'Aún no se eligió un producto',
      destino: true,
      detalle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (existe) ...[
          Text('Proveedor: ${texto(l['nombre_proveedor'], 'No identificado')}',
            style: TextStyle(fontSize: 12, color: Global.text)),
          const SizedBox(height: 3),
          Text('Precio del catálogo: ${precio(l['precio_base'])}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: verde)),
          if (!disponible) ...[
            const SizedBox(height: 10),
            Text('No disponible: elige otra alternativa.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorAviso)),
          ],
        ] else Text('Selecciona una alternativa del catálogo para este reemplazo.',
          style: TextStyle(fontSize: 12, color: Global.textSecondary)),
      ]),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Global.container,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Global.textSecondary.withOpacity(.22)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text('REEMPLAZO PROPUESTO ${indice + 1} DE ${lineas.length}',
              style: TextStyle(color: Global.text, fontSize: 13,
                fontWeight: FontWeight.w800, letterSpacing: .3)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: disponible ? fondoNuevo : fondoAviso, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: disponible ? bordeNuevo : colorAviso.withOpacity(.4))),
              child: Text(!existe ? 'Tecnología sin elegir' :
                (disponible ? 'Lista para la propuesta' : 'Producto no disponible'),
                style: TextStyle(color: disponible ? verde : colorAviso,
                  fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, limites) {
            if (limites.maxWidth < 650) {
              return Column(children: [
                origen,
                Padding(padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Icon(Icons.arrow_downward_rounded, size: 23, color: verde)),
                destino,
              ]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(child: origen),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward_rounded, size: 27, color: verde)),
              Expanded(child: destino),
            ]);
          }),
          if (unidades != 1) ...[
            const SizedBox(height: 12),
            Container(width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: fondoAviso,
                border: Border.all(color: colorAviso.withOpacity(.5)),
                borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Revisar cantidad heredada: $unidades',
                  style: TextStyle(fontWeight: FontWeight.w800, color: colorAviso)),
                const SizedBox(height: 5),
                Text('El ahorro se evalúa por activo, pero esta selección tiene varias unidades. Para evitar métricas inconsistentes, confirma un único reemplazo por activo. No se modificará el dato hasta guardar.',
                  style: TextStyle(fontSize: 12, color: colorAviso)),
                if (editable)
                  TextButton.icon(
                    onPressed: guardando ? null : () => setState(() {
                      lineas[indice] = {...lineas[indice], 'cantidad': 1};
                    }),
                    icon: const Icon(Icons.rule, size: 17),
                    label: const Text('Corregir a 1 reemplazo'),
                  ),
              ]),
            ),
          ],
          if (editable) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 4, children: [
              FilledButton.tonalIcon(
                onPressed: guardando ? null : () => cambiarProducto(indice),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: Text(existe ? 'Cambiar tecnología' : 'Seleccionar tecnología'),
              ),
              if (lineas.length > 1)
                TextButton.icon(
                  onPressed: guardando ? null : () => setState(() => lineas.removeAt(indice)),
                  icon: const Icon(Icons.remove_circle_outline, size: 17),
                  label: const Text('Quitar de la negociación'),
                ),
            ]),
          ],
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Obx(() => ColoredBox(
    color: Global.bg,
    child: _buildVista(context),
  ));

  Widget _buildVista(BuildContext context) {
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
              if (paso == 1)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Este paso corresponde al diagnóstico que dio origen a la negociación. Puedes consultarlo en Ver diagnóstico.'),
                ),
              Text(paso == 1 ? 'Diagnóstico de origen' : esConfirmacion ? 'Confirma los reemplazos propuestos' : 'Selección confirmada',
                style: TextStyle(color: Global.text, fontWeight: FontWeight.w800, fontSize: 17)),
              if (esConfirmacion) ...[
                const SizedBox(height: 7),
                Text('Cada equipo del diagnóstico se vincula con una tecnología propuesta. Revisa ambos lados del cambio antes de generar la propuesta comercial.',
                  style: TextStyle(color: Global.textSecondary, fontSize: 13, height: 1.3)),
                const SizedBox(height: 12),
                Container(width: double.infinity, padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Global.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Global.primary.withOpacity(.28))),
                  child: Wrap(spacing: 14, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('${lineas.length} activo(s) a revisar',
                        style: TextStyle(color: Global.text, fontWeight: FontWeight.w700)),
                      Text('${lineas.where((l) => entero(l['id_item']) != null && l['disponible'] == true).length} alternativa(s) disponibles',
                        style: TextStyle(color: Global.textSecondary)),
                    ])),
                const SizedBox(height: 9),
                Text('Un reemplazo por activo. La cantidad no se elige aquí: una cantidad libre puede distorsionar la inversión frente al ahorro estimado.',
                  style: TextStyle(color: Global.textSecondary, fontSize: 12)),
              ],
              if (lineas.isEmpty)
                Padding(padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Este diagnóstico aún no tiene una selección guardada para FVE. Vuelve al diagnóstico, elige los productos y pulsa "Guardar selección para FVE".',
                    style: TextStyle(color: Global.textSecondary))),
              for (int i = 0; i < lineas.length; i++) fila(i, esConfirmacion),
              if (esConfirmacion) ...[
                const SizedBox(height: 14),
                Wrap(spacing: 10, runSpacing: 8, children: [
                  OutlinedButton.icon(onPressed: guardando ? null : agregarActivo,
                    icon: const Icon(Icons.add, size: 17), label: const Text('Añadir otro activo del diagnóstico')),
                  OutlinedButton(onPressed: guardando ? null : () => guardar(confirmar: false),
                    child: const Text('Guardar cambios')),
                  FilledButton.icon(
                    onPressed: guardando || lineas.isEmpty || lineas.any((l) =>
                      entero(l['id_item']) == null || l['disponible'] != true || entero(l['cantidad']) != 1)
                      ? null : () => guardar(confirmar: true),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Confirmar reemplazos y continuar')),
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
