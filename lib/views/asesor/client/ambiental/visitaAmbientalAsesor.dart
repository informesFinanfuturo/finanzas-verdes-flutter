import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/ambientalApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Se conserva el nombre de la clase para no modificar el dashboard.
class VisitaAmbientalAsesor extends StatefulWidget {
  const VisitaAmbientalAsesor({super.key});

  @override
  State<VisitaAmbientalAsesor> createState() =>
      _VisitaAmbientalAsesorState();
}

class _PasoAmbiental {
  final int bloque;
  final String tipo; // pregunta, inventario, puntaje o resumen
  final Map<String, dynamic>? pregunta;

  const _PasoAmbiental(this.bloque, this.tipo, [this.pregunta]);
}

class _VisitaAmbientalAsesorState extends State<VisitaAmbientalAsesor> {
  final cliente = Get.find<ClientController>();
  final comentarioGeneral = TextEditingController();
  final desplazamiento = ScrollController();
  final Map<String, TextEditingController> comentarios = {};

  static const nombresBloques = <int, String>{
    1: 'Agua y energía',
    2: 'Inventario de activos',
    3: 'Economía circular y residuos',
    4: 'Huella de carbono',
    5: 'Contexto normativo',
    6: 'Estrategia ambiental',
  };

  static const descripcionesPuntaje = <String>[
    'Sin información / no aplica',
    'No implementado',
    'Básico o informal',
    'En implementación',
    'Gestionado y medido',
    'Optimizado / mejora continua',
  ];

  Map<String, dynamic>? formulario;
  Map<String, dynamic>? evaluacion;
  final Map<String, dynamic> respuestas = {};
  final Map<String, int> puntajes = {};
  List<Map<String, dynamic>> historial = [];
  List<Map<String, dynamic>> activos = [];

  int? idEvaluacion;
  int pasoActual = 0;
  bool cargando = true;
  bool guardando = false;
  bool cambios = false;
  bool finalizada = false;
  bool viendoHistorial = false;

  int? get idMipyme => int.tryParse(
        '${cliente.Client['mipyme']?['id_mipyme'] ?? ''}',
      );

  List<Map<String, dynamic>> get preguntas {
    final lista = (formulario?['preguntas'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    lista.sort((a, b) => (a['numero'] as num).compareTo(b['numero'] as num));
    return lista;
  }

  List<_PasoAmbiental> get pasos {
    final resultado = <_PasoAmbiental>[];
    for (var bloque = 1; bloque <= 6; bloque++) {
      if (bloque == 2) {
        resultado.add(const _PasoAmbiental(2, 'inventario'));
      }
      for (final p in preguntas.where((p) => p['bloque'] == bloque)) {
        resultado.add(_PasoAmbiental(bloque, 'pregunta', p));
      }
      if ([1, 3, 4, 5].contains(bloque)) {
        resultado.add(_PasoAmbiental(bloque, 'puntaje'));
      }
    }
    resultado.add(const _PasoAmbiental(0, 'resumen'));
    return resultado;
  }

  int get totalObligatorias => preguntas
      .where((p) => p['opcional'] != true && p['tipo'] != 'informativa')
      .length;

  int get respondidasObligatorias => preguntas.where((p) {
        if (p['opcional'] == true || p['tipo'] == 'informativa') {
          return false;
        }
        return respuestaCompleta(p);
      }).length;

  double? get ad07 => [1, 3, 4, 5].every(
        (b) => puntajes.containsKey('$b'),
      )
          ? [1, 3, 4, 5].fold<int>(0, (n, b) => n + puntajes['$b']!) /
              4
          : null;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  void dispose() {
    for (final c in comentarios.values) {
      c.dispose();
    }
    comentarioGeneral.dispose();
    desplazamiento.dispose();
    if (cambios) controller.hasUnsavedChanges.value = false;
    super.dispose();
  }

  void avisar(Object mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$mensaje'.replaceFirst('Exception: ', ''))),
    );
  }

  void marcarCambio() {
    if (finalizada) return;
    setState(() => cambios = true);
    controller.hasUnsavedChanges.value = true;
  }

  void prepararControladores(Map<String, dynamic> f) {
    for (final item in (f['preguntas'] as List<dynamic>? ?? [])) {
      final k = '${(item as Map)['numero']}';
      comentarios.putIfAbsent(k, () => TextEditingController());
    }
  }

  void irAPaso(int indice) {
    if (indice < 0 || indice >= pasos.length) return;
    setState(() {
      viendoHistorial = false;
      pasoActual = indice;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && desplazamiento.hasClients) desplazamiento.jumpTo(0);
    });
  }

  void irABloque(int bloque) {
    final indice = pasos.indexWhere((p) => p.bloque == bloque);
    if (indice >= 0) irAPaso(indice);
  }

  Future<void> cargar() async {
    final empresa = idMipyme;
    if (empresa == null) {
      if (mounted) setState(() => cargando = false);
      return;
    }
    setState(() => cargando = true);
    try {
      final f = await AmbientalApi.formulario();
      final h = await AmbientalApi.listar(empresa);
      if (!mounted) return;
      final form = Map<String, dynamic>.from(f['formulario'] as Map);
      prepararControladores(form);
      setState(() {
        formulario = form;
        historial = (h['evaluaciones'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        activos = (h['activos'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        cargando = false;
      });
    } catch (e) {
      if (mounted) setState(() => cargando = false);
      avisar(e);
    }
  }

  Future<bool> puedeDescartar() async {
    if (!cambios) return true;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cambios sin guardar'),
            content: const Text(
              'Tienes respuestas pendientes de guardar. '
              '¿Quieres descartarlas?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Descartar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> nuevaEvaluacion() async {
    if (!await puedeDescartar() || !mounted) return;
    try {
      final f = await AmbientalApi.formulario();
      if (!mounted) return;
      final form = Map<String, dynamic>.from(f['formulario'] as Map);
      prepararControladores(form);
      setState(() {
        formulario = form;
        evaluacion = null;
        idEvaluacion = null;
        pasoActual = 0;
        viendoHistorial = false;
        finalizada = false;
        respuestas.clear();
        puntajes.clear();
        comentarioGeneral.clear();
        for (final c in comentarios.values) {
          c.clear();
        }
        cambios = false;
        controller.hasUnsavedChanges.value = false;
      });
    } catch (e) {
      avisar(e);
    }
  }

  Future<void> abrirEvaluacion(int id) async {
    if (!await puedeDescartar() || !mounted) return;
    setState(() => cargando = true);
    try {
      final r = await AmbientalApi.obtener(id);
      final e = Map<String, dynamic>.from(r['evaluacion'] as Map);
      final codigo = '${e['version_formulario']}';
      Map<String, dynamic> form = formulario!;
      if (form['codigo'] != codigo) {
        final anterior = await AmbientalApi.formulario(codigo: codigo);
        form = Map<String, dynamic>.from(anterior['formulario'] as Map);
      }
      if (!mounted) return;
      prepararControladores(form);
      setState(() {
        formulario = form;
        evaluacion = e;
        idEvaluacion = id;
        finalizada = e['estado'] == 'finalizada';
        viendoHistorial = false;
        pasoActual = 0;
        respuestas.clear();
        for (final c in comentarios.values) {
          c.clear();
        }
        final guardadas = Map<String, dynamic>.from(e['respuestas'] ?? {});
        for (final p in preguntas) {
          final k = '${p['numero']}';
          final original = guardadas[k];
          if (original is Map) {
            respuestas[k] = Map<String, dynamic>.from(original);
            comentarios[k]!.text = '${original['observacion'] ?? ''}';
          } else if (original is String) {
            // Lectura de registros creados antes del formulario estructurado.
            respuestas[k] = {'valor': null, 'observacion': original};
            comentarios[k]!.text = original;
          }
        }
        puntajes.clear();
        final guardados = Map<String, dynamic>.from(e['puntajes'] ?? {});
        for (final k in ['1', '3', '4', '5']) {
          if (guardados[k] is num) puntajes[k] = (guardados[k] as num).toInt();
        }
        comentarioGeneral.text = '${e['observacion_general'] ?? ''}';
        cambios = false;
        controller.hasUnsavedChanges.value = false;
        cargando = false;
      });
    } catch (e) {
      if (mounted) setState(() => cargando = false);
      avisar(e);
    }
  }

  dynamic valorDe(String k) =>
      respuestas[k] is Map ? respuestas[k]['valor'] : null;

  void cambiarValor(String k, dynamic valor) {
    if (finalizada) return;
    setState(() {
      final anterior = Map<String, dynamic>.from(respuestas[k] ?? {});
      anterior['valor'] = valor;
      respuestas[k] = anterior;
    });
    marcarCambio();
  }

  bool respuestaCompleta(Map<String, dynamic> p) {
    final valor = valorDe('${p['numero']}');
    if (p['tipo'] == 'informativa') return true;
    if (p['tipo'] == 'multiple') return valor is List && valor.isNotEmpty;
    return valor is String && valor.trim().isNotEmpty;
  }

  Map<String, dynamic> respuestasParaGuardar() {
    final resultado = <String, dynamic>{};
    for (final p in preguntas) {
      final k = '${p['numero']}';
      final valor = valorDe(k);
      final nota = comentarios[k]?.text.trim() ?? '';
      if (valor != null || nota.isNotEmpty) {
        resultado[k] = {'valor': valor, 'observacion': nota};
      }
    }
    return resultado;
  }

  int? get primerPendiente {
    final lista = pasos;
    for (var i = 0; i < lista.length; i++) {
      final paso = lista[i];
      if (paso.tipo == 'pregunta') {
        final p = paso.pregunta!;
        if (p['opcional'] != true &&
            p['tipo'] != 'informativa' &&
            !respuestaCompleta(p)) {
          return i;
        }
      }
      if (paso.tipo == 'puntaje' && !puntajes.containsKey('${paso.bloque}')) {
        return i;
      }
    }
    return null;
  }

  Future<void> guardar(bool finalizar) async {
    if (guardando || finalizada || idMipyme == null) return;
    if (finalizar) {
      final pendiente = primerPendiente;
      if (pendiente != null) {
        final paso = pasos[pendiente];
        avisar(paso.tipo == 'puntaje'
            ? 'Falta la calificación del bloque ${paso.bloque}.'
            : 'Falta responder la pregunta ${paso.pregunta!['numero']}.');
        irAPaso(pendiente);
        return;
      }
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Finalizar evaluación'),
          content: const Text(
            'La evaluación quedará en el historial en modo de solo lectura. '
            'No será posible modificarla después.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Revisar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Finalizar'),
            ),
          ],
        ),
      );
      if (confirmado != true) return;
    }
    if (!mounted) return;
    setState(() => guardando = true);
    try {
      final r = await AmbientalApi.guardar(
        idMipyme: idMipyme!,
        idEvaluacion: idEvaluacion,
        respuestas: respuestasParaGuardar(),
        puntajes: Map<String, int>.from(puntajes),
        observacion: comentarioGeneral.text.trim(),
        finalizar: finalizar,
      );
      if (!mounted) return;
      setState(() {
        evaluacion = Map<String, dynamic>.from(r['evaluacion'] as Map);
        idEvaluacion = int.tryParse('${evaluacion!['id_evaluacion']}');
        finalizada = evaluacion!['estado'] == 'finalizada';
        cambios = false;
        controller.hasUnsavedChanges.value = false;
      });
      // El guardado ya se completó; si falla esta segunda consulta
      // no se debe mostrar un falso error de guardado.
      try {
        final h = await AmbientalApi.listar(idMipyme!);
        if (mounted) {
          setState(() {
            historial = (h['evaluaciones'] as List<dynamic>? ?? [])
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
            activos = (h['activos'] as List<dynamic>? ?? [])
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          });
        }
        avisar(finalizar ? 'Evaluación finalizada correctamente' : 'Borrador guardado');
      } catch (_) {
        avisar('Se guardó correctamente; actualiza el historial para verlo.');
      }
    } catch (e) {
      avisar(e);
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  String fechaCorta(dynamic valor) {
    final s = '$valor';
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  BoxDecoration tarjeta({bool seleccionada = false}) => BoxDecoration(
        color: seleccionada
            ? Global.primary.withOpacity(0.10)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: seleccionada
              ? Global.primary
              : Global.text.withOpacity(0.13),
          width: seleccionada ? 2 : 1,
        ),
      );

  Widget opcion({
    required String letra,
    required String texto,
    required bool seleccionada,
    required bool multiple,
    required VoidCallback? alPulsar,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        selected: seleccionada,
        label: 'Opción $letra: $texto',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: alPulsar,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              constraints: const BoxConstraints(minHeight: 62),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: tarjeta(seleccionada: seleccionada),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: seleccionada
                        ? Global.primary
                        : Global.primary.withOpacity(0.09),
                    child: Text(
                      letra,
                      style: TextStyle(
                        color: seleccionada ? Colors.white : Global.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      texto,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: seleccionada ? FontWeight.w600 : FontWeight.w400,
                        color: Global.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    multiple
                        ? (seleccionada ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded)
                        : (seleccionada ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                    color: seleccionada ? Global.primary : Global.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget cajaInfo(String texto, {IconData icono = Icons.info_outline}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Global.primary.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Global.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: TextStyle(color: Global.text))),
        ],
      ),
    );
  }

  Widget preguntaActual(Map<String, dynamic> p) {
    final numero = '${p['numero']}';
    final tipo = '${p['tipo']}';
    final opciones = List<String>.from(p['opciones'] as List<dynamic>? ?? []);
    final valor = valorDe(numero);
    final multiple = tipo == 'multiple';
    final informativa = tipo == 'informativa';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREGUNTA $numero DE ${preguntas.length}',
          style: TextStyle(color: Global.primary, fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Text(
          '${p['texto']}',
          style: TextStyle(color: Global.text, fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
        ),
        const SizedBox(height: 12),
        Text(
          informativa
              ? 'Información de verificación'
              : multiple
                  ? 'Puedes marcar varias respuestas.'
                  : 'Selecciona una respuesta.',
          style: TextStyle(color: Global.textSecondary),
        ),
        const SizedBox(height: 22),
        if (informativa)
          cajaInfo(
            'La verificación DNSH se realizará por cada activo realmente financiado. '
            'Este cuestionario no certifica el cumplimiento.',
          )
        else
          for (var i = 0; i < opciones.length; i++)
            opcion(
              letra: String.fromCharCode(65 + i),
              texto: opciones[i],
              seleccionada: multiple
                  ? (valor is List && valor.contains(opciones[i]))
                  : valor == opciones[i],
              multiple: multiple,
              alPulsar: finalizada
                  ? null
                  : () {
                      if (!multiple) {
                        cambiarValor(numero, opciones[i]);
                        return;
                      }
                      final seleccionadas = valor is List
                          ? List<String>.from(valor)
                          : <String>[];
                      final elegida = opciones[i];
                      if (elegida == 'No identifica') {
                        cambiarValor(numero, seleccionadas.contains(elegida)
                            ? <String>[]
                            : <String>[elegida]);
                        return;
                      }
                      seleccionadas.remove('No identifica');
                      if (seleccionadas.contains(elegida)) {
                        seleccionadas.remove(elegida);
                      } else {
                        seleccionadas.add(elegida);
                      }
                      cambiarValor(numero, seleccionadas);
                    },
            ),
        const SizedBox(height: 18),
        TextField(
          key: ValueKey('observacion_${formulario?['codigo']}_$numero'),
          controller: comentarios[numero],
          readOnly: finalizada,
          maxLines: 2,
          maxLength: 2000,
          onChanged: (_) => marcarCambio(),
          decoration: InputDecoration(
            labelText: 'Observación (opcional)',
            hintText: 'Agrega contexto o evidencia cuando haga falta',
            prefixIcon: const Icon(Icons.notes_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget calificacionActual(int bloque) {
    final elegida = puntajes['$bloque'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CALIFICACIÓN DEL BLOQUE $bloque',
            style: TextStyle(color: Global.primary, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 12),
        Text('¿Qué nivel describe mejor al establecimiento?',
            style: TextStyle(color: Global.text, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text('Selecciona la calificación global de ${nombresBloques[bloque]}. '
            'Esta nota no se calcula automáticamente a partir de las respuestas.',
            style: TextStyle(color: Global.textSecondary)),
        const SizedBox(height: 22),
        for (var i = 0; i <= 5; i++)
          opcion(
            letra: '$i',
            texto: descripcionesPuntaje[i],
            seleccionada: elegida == i,
            multiple: false,
            alPulsar: finalizada
                ? null
                : () {
                    setState(() => puntajes['$bloque'] = i);
                    marcarCambio();
                  },
          ),
      ],
    );
  }

  Widget inventarioActual() {
    final inventario = finalizada
        ? (evaluacion?['inventario_snapshot'] as List<dynamic>? ?? [])
        : activos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BLOQUE 2 · INVENTARIO',
            style: TextStyle(color: Global.primary, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 12),
        Text('Activos registrados del negocio',
            style: TextStyle(color: Global.text, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        cajaInfo('Este bloque no puntúa en AD-07. Aquí se muestran los activos registrados en el cliente. '
            'La caracterización de las 18 categorías de HORECA se desarrollará en la siguiente entrega.',
            icono: Icons.inventory_2_outlined),
        const SizedBox(height: 20),
        if (inventario.isEmpty)
          const ListTile(title: Text('No hay activos registrados'))
        else
          for (final item in inventario)
            Card(
              child: ListTile(
                leading: const Icon(Icons.kitchen_outlined),
                title: Text('${(item as Map)['nombre'] ?? 'Activo'}'),
                subtitle: Text('Cantidad: ${item['cantidad'] ?? 1} · ${item['tipo'] ?? ''}'),
              ),
            ),
      ],
    );
  }

  Widget revisionFinal() {
    final pendiente = primerPendiente;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REVISIÓN FINAL',
            style: TextStyle(color: Global.primary, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 10),
        Text('Revisa antes de finalizar',
            style: TextStyle(color: Global.text, fontSize: 23, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        cajaInfo(
          pendiente == null
              ? 'Las preguntas obligatorias y las cuatro calificaciones están completas.'
              : 'Hay elementos pendientes. Puedes guardar un borrador o tocar cada elemento para completarlo.',
          icono: pendiente == null ? Icons.check_circle_outline : Icons.fact_check_outlined,
        ),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: Icon(Icons.insights_outlined, color: Global.primary),
            title: Text('AD-07: ${ad07?.toStringAsFixed(2) ?? 'Pendiente'} / 5'),
            subtitle: const Text('Promedio de bloques 1, 3, 4 y 5. No determina la aprobación del crédito.'),
          ),
        ),
        const SizedBox(height: 14),
        for (final p in preguntas) ...[
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Icon(
              p['tipo'] == 'informativa'
                  ? Icons.info_outline
                  : respuestaCompleta(p)
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
              color: respuestaCompleta(p) ? Global.primary : Global.textSecondary,
            ),
            title: Text('Pregunta ${p['numero']} · ${p['texto']}', maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(p['opcional'] == true ? 'Opcional' : p['tipo'] == 'informativa' ? 'Verificación posterior' : respuestaCompleta(p) ? 'Respondida' : 'Pendiente'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => irAPaso(pasos.indexWhere((x) => x.tipo == 'pregunta' && x.pregunta?['numero'] == p['numero'])),
          ),
          const Divider(height: 1),
        ],
        for (final bloque in [1, 3, 4, 5])
          ListTile(
            dense: true,
            leading: Icon(puntajes.containsKey('$bloque') ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                color: puntajes.containsKey('$bloque') ? Global.primary : Global.textSecondary),
            title: Text('Calificación del bloque $bloque'),
            subtitle: Text(puntajes.containsKey('$bloque') ? '${puntajes['$bloque']} de 5' : 'Pendiente'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => irAPaso(pasos.indexWhere((x) => x.tipo == 'puntaje' && x.bloque == bloque)),
          ),
        const SizedBox(height: 18),
        TextField(
          controller: comentarioGeneral,
          readOnly: finalizada,
          maxLines: 3,
          maxLength: 5000,
          onChanged: (_) => marcarCambio(),
          decoration: InputDecoration(
            labelText: 'Observaciones generales (opcional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (finalizada)
          cajaInfo('Esta evaluación está finalizada y protegida contra modificaciones.',
              icono: Icons.lock_outline),
      ],
    );
  }

  Widget barraBloques(int bloqueActual) {
    return SizedBox(
      height: 43,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var b = 1; b <= 6; b++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                backgroundColor: bloqueActual == b
                    ? Global.primary.withOpacity(0.15)
                    : Theme.of(context).colorScheme.surface,
                avatar: CircleAvatar(
                  radius: 12,
                  backgroundColor: bloqueActual == b ? Global.primary : Global.text.withOpacity(0.08),
                  child: Text('$b', style: TextStyle(fontSize: 11,
                      color: bloqueActual == b ? Colors.white : Global.text)),
                ),
                label: Text(nombresBloques[b]!,
                    style: TextStyle(color: Global.text, fontSize: 12)),
                onPressed: () => irABloque(b),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> refrescarHistorial() async {
    if (idMipyme == null) return;
    try {
      final h = await AmbientalApi.listar(idMipyme!);
      if (!mounted) return;
      setState(() {
        historial = (h['evaluaciones'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      });
    } catch (e) {
      avisar(e);
    }
  }

  Widget historialVista() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historial de evaluaciones',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Global.text)),
                const SizedBox(height: 7),
                Text('Cada evaluación finalizada conserva sus respuestas y resultados originales.',
                    style: TextStyle(color: Global.textSecondary)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: refrescarHistorial,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualizar historial'),
                ),
                const SizedBox(height: 16),
                if (historial.isEmpty)
                  cajaInfo('Todavía no hay evaluaciones guardadas para este cliente.')
                else
                  for (final e in historial)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Global.primary.withOpacity(0.12),
                            child: Icon(e['estado'] == 'finalizada' ? Icons.lock_outline : Icons.edit_note,
                                color: Global.primary),
                          ),
                          title: Text('Evaluación #${e['id_evaluacion']}'),
                          subtitle: Text(
                            '${fechaCorta(e['fecha_evaluacion'])} · '
                            '${e['estado'] == 'finalizada' ? 'Finalizada' : 'Borrador'} · '
                            'AD-07: ${e['indice_ad07'] ?? 'Pendiente'}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            final id = int.tryParse('${e['id_evaluacion']}');
                            if (id != null) abrirEvaluacion(id);
                          },
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget pieNavegacion(bool esUltimo) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Global.text.withOpacity(0.12))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final atras = OutlinedButton.icon(
            onPressed: pasoActual == 0 ? null : () => irAPaso(pasoActual - 1),
            icon: const Icon(Icons.chevron_left),
            label: const Text('Anterior'),
          );
          final adelante = FilledButton.icon(
            onPressed: esUltimo
                ? (finalizada
                    ? () => setState(() => viendoHistorial = true)
                    : guardando ? null : () => guardar(true))
                : () => irAPaso(pasoActual + 1),
            icon: Icon(esUltimo
                ? (finalizada ? Icons.history : Icons.check_circle_outline)
                : Icons.chevron_right),
            label: Text(esUltimo
                ? (finalizada ? 'Ver historial' : 'Finalizar evaluación')
                : 'Siguiente'),
          );
          final borrador = OutlinedButton.icon(
            onPressed: finalizada || guardando ? null : () => guardar(false),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar borrador'),
          );
          if (constraints.maxWidth < 600) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!esUltimo)
                  Row(children: [
                    Expanded(child: atras),
                    const SizedBox(width: 10),
                    Expanded(child: adelante),
                  ]),
                if (esUltimo) ...[
                  SizedBox(width: double.infinity, child: adelante),
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, child: atras),
                ],
                if (!finalizada) ...[
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, child: borrador),
                ],
              ],
            );
          }
          return Row(
            children: [
              atras,
              const SizedBox(width: 12),
              if (!finalizada) borrador,
              const Spacer(),
              adelante,
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (formulario == null) {
      return Center(
        child: TextButton.icon(
          onPressed: cargar,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar carga del cuestionario'),
        ),
      );
    }

    final lista = pasos;
    final indice = pasoActual >= lista.length ? lista.length - 1 : pasoActual;
    final actual = lista[indice];
    final ultimo = indice == lista.length - 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 9),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Text('Evaluación ambiental HORECA',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Global.text)),
                      if (finalizada)
                        Chip(label: const Text('Finalizada'),
                            avatar: Icon(Icons.lock, size: 16, color: Global.primary)),
                      if (cambios)
                        const Chip(label: Text('Sin guardar'), avatar: Icon(Icons.circle, size: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    Text('${formulario?['codigo']} · $respondidasObligatorias/$totalObligatorias obligatorias respondidas',
                        style: TextStyle(color: Global.textSecondary, fontSize: 12)),
                    TextButton.icon(
                      onPressed: () => setState(() => viendoHistorial = !viendoHistorial),
                      icon: Icon(viendoHistorial ? Icons.edit_note : Icons.history),
                      label: Text(viendoHistorial ? 'Volver al formulario' : 'Ver historial'),
                    ),
                    TextButton.icon(
                      onPressed: guardando ? null : nuevaEvaluacion,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Nueva evaluación'),
                    ),
                  ]),
                  if (!viendoHistorial) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text(actual.tipo == 'resumen'
                            ? 'Revisión y cierre'
                            : 'Bloque ${actual.bloque}: ${nombresBloques[actual.bloque]}',
                            style: TextStyle(color: Global.text, fontWeight: FontWeight.w600))),
                        Text('Paso ${indice + 1} de ${lista.length}', style: TextStyle(color: Global.textSecondary, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (indice + 1) / lista.length,
                        minHeight: 6,
                        backgroundColor: Global.primary.withOpacity(0.13),
                        color: Global.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    barraBloques(actual.bloque),
                  ],
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: viendoHistorial
              ? historialVista()
              : SingleChildScrollView(
                  controller: desplazamiento,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: tarjeta(),
                        child: actual.tipo == 'pregunta'
                            ? preguntaActual(actual.pregunta!)
                            : actual.tipo == 'puntaje'
                                ? calificacionActual(actual.bloque)
                                : actual.tipo == 'inventario'
                                    ? inventarioActual()
                                    : revisionFinal(),
                      ),
                    ),
                  ),
                ),
        ),
        if (!viendoHistorial) pieNavegacion(ultimo),
      ],
    );
  }
}
