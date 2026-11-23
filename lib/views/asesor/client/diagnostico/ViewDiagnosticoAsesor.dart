import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/diagnosticoApi.dart';
import 'package:finanzas_verdes/models/api/fveApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:finanzas_verdes/services/diagnostico_pdf_service.dart';
import 'package:finanzas_verdes/views/asesor/client/diagnostico/seleccionarAlternativaDiagnostico.dart';

class Viewdiagnosticoasesor extends StatefulWidget {
  const Viewdiagnosticoasesor({super.key});

  @override
  State<Viewdiagnosticoasesor> createState() =>
      _ViewdiagnosticoasesorState();
}

class _ViewdiagnosticoasesorState
    extends State<Viewdiagnosticoasesor> {
  bool loading = false;
  bool _startingFve = false;
  bool _generandoPdf = false;

  final ClientController clientController =
  Get.find<ClientController>();

  final RxSet<int> activosSeleccionados = <int>{}.obs;
  final RxMap<int, Map<String, dynamic>> alternativasSeleccionadas = <int, Map<String, dynamic>>{}.obs;

  @override
  void initState() {
    super.initState();

    final diagnostico =
        clientController.Diagnostico;

    final metricas =
        diagnostico["metricas"] ??
            {};

    final activos =
    List<dynamic>.from(
      metricas["activos"] ?? [],
    );

    final activosGuardados =
    metricas[
    "activos_seleccionados"
    ];

    final alternativasGuardadas =
    metricas[
    "alternativas_seleccionadas"
    ];

    /*
   * 1. Recuperamos primero las
   * selecciones ya confirmadas.
   *
   * Estas siempre tienen prioridad
   * sobre la recomendación original.
   */
    if (
    alternativasGuardadas is List
    ) {

      for (
      final item
      in alternativasGuardadas
      ) {

        if (item is! Map) {
          continue;
        }

        final alternativa =
        Map<String, dynamic>.from(
          item,
        );

        final idActivo =
        _toInt(
          alternativa["id_activo"],
        );

        final idItem =
        _toInt(
          alternativa["id_item"],
        );

        if (
        idActivo == null ||
            idItem == null
        ) {
          continue;
        }

        alternativasSeleccionadas[
        idActivo
        ] = alternativa;
      }
    }

    // Las recomendaciones IA se muestran como sugerencias, no quedan seleccionadas.

    /*
   * 3. Si ya existía una propuesta
   * guardada, respetamos los activos
   * confirmados.
   */
    if (
    activosGuardados is List &&
        activosGuardados.isNotEmpty
    ) {

      for (
      final id
      in activosGuardados
      ) {

        final parsedId =
        _toInt(id);

        if (parsedId != null) {
          activosSeleccionados.add(
            parsedId,
          );
        }
      }

      return;
    }

    // FVE_AUTO_SIMULAR_DIAGNOSTICO_V1
    // Solo preseleccion para el simulador, nunca confirmacion comercial FVE.
    for (final activo in activos) {
      if (activo is! Map) continue;
      final id = _toInt(activo['id_activo']);
      if (id != null) activosSeleccionados.add(id);
    }

  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '');
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _toNullableDouble(
      dynamic value,
      ) {
    if (
    value == null ||
        value.toString().trim().isEmpty
    ) {
      return null;
    }

    if (value is num) {
      final result =
      value.toDouble();

      return result.isFinite
          ? result
          : null;
    }

    final result =
    double.tryParse(
      value
          .toString()
          .replaceAll(',', '.'),
    );

    return result != null &&
        result.isFinite
        ? result
        : null;
  }

  double _parsePrice(dynamic value,) {

    if (value is num) {
      return value.toDouble();
    }

    var text =
        value
            ?.toString()
            .trim() ??
            '';

    if (text.isEmpty) {
      return 0;
    }

    text = text.replaceAll(
      RegExp(r'[^\d,.-]'),
      '',
    );

    if (
    text.contains('.') &&
        text.contains(',')
    ) {

      text = text
          .replaceAll('.', '')
          .replaceAll(',', '.');

    } else if (
    RegExp(
      r'^\d{1,3}(\.\d{3})+$',
    ).hasMatch(text)
    ) {

      text =
          text.replaceAll('.', '');

    } else {

      text =
          text.replaceAll(',', '.');
    }

    return double.tryParse(text) ?? 0;
  }

  List<dynamic> _getActivos(Map diagnostico) {
    return List<dynamic>.from(
      diagnostico["metricas"]?["activos"] ?? [],
    );
  }

  Map<String, dynamic> getMetricasSeleccionadas() {
    final diagnostico =
        clientController.Diagnostico;

    final activos =
    _getActivos(
      diagnostico,
    );

    final metricasIncluidas =
    <Map<String, dynamic>>[];

    for (final activo in activos) {
      final idActivo =
      _toInt(
        activo["id_activo"],
      );

      if (
      idActivo == null ||
          !activosSeleccionados
              .contains(idActivo)
      ) {
        continue;
      }

      metricasIncluidas.add(
        _getMetricasVisualesActivo(
          activo,
        ),
      );
    }

    double? sumarMetricaCompleta(
        String campo,
        ) {
      if (metricasIncluidas.isEmpty) {
        return null;
      }

      final valores =
      metricasIncluidas
          .map(
            (metricas) =>
            _toNullableDouble(
              metricas[campo],
            ),
      )
          .toList();

      /*
     * No mostramos un total parcial como
     * si fuera el resultado completo.
     */
      if (
      valores.any(
            (value) => value == null,
      )
      ) {
        return null;
      }

      return valores
          .whereType<double>()
          .fold<double>(
        0,
            (
            sum,
            value,
            ) =>
        sum + value,
      );
    }

    final ahorro =
    sumarMetricaCompleta(
      "ahorro_economico_mensual",
    );

    final inversion =
    sumarMetricaCompleta(
      "inversion_total_requerida",
    );

    final energia =
    sumarMetricaCompleta(
      "reduccion_energia",
    );

    final agua =
    sumarMetricaCompleta(
      "reduccion_agua",
    );

    final carbono =
    sumarMetricaCompleta(
      "reduccion_carbono",
    );

    final double? roi =
    inversion != null &&
        inversion > 0 &&
        ahorro != null
        ? (
        (
            ahorro * 60 -
                inversion
        ) /
            inversion
    ) *
        100
        : null;

    final double? payback =
    inversion != null &&
        inversion > 0 &&
        ahorro != null &&
        ahorro > 0
        ? inversion / ahorro
        : null;

    final activosConAhorro =
        metricasIncluidas
            .where(
              (metricas) =>
          _toNullableDouble(
            metricas[
            "ahorro_economico_mensual"
            ],
          ) !=
              null,
        )
            .length;

    return {
      "cantidad":
      metricasIncluidas.length,

      "ahorro":
      ahorro,

      "inversion":
      inversion,

      "energia":
      energia,

      "agua":
      agua,

      "carbono":
      carbono,

      "roi":
      roi,

      "payback":
      payback,

      "cobertura_completa":
      metricasIncluidas.isNotEmpty &&
          activosConAhorro ==
              metricasIncluidas.length,

      "activos_con_metricas":
      activosConAhorro,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = controller.isDark.value;
      final diagnostico = clientController.Diagnostico;

      return LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 700;

          return Column(
            children: [
              _buildTopBar(isMobile),
              Expanded(
                child: diagnostico.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16 : 28,
                    16,
                    isMobile ? 16 : 28,
                    isMobile ? 110 : 36,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1320,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          _buildHero(diagnostico, isMobile),
                          const SizedBox(height: 18),
                          _buildFveStart(diagnostico, isMobile),
                          const SizedBox(height: 18),
                          _buildExecutiveSummary(diagnostico),
                          const SizedBox(height: 18),
                          _buildSimulator(diagnostico, isMobile),
                          const SizedBox(height: 18),
                          _buildAssetsSection(
                            diagnostico,
                            isMobile,
                          ),
                          const SizedBox(height: 18),
                          _buildAnalysisSection(
                            diagnostico,
                            isMobile,
                          ),
                          const SizedBox(height: 18),
                          _buildDecisionCard(isMobile),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildTopBar(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Global.container,
        border: Border(
          bottom: BorderSide(
            color: Global.text.withOpacity(.08),
          ),
        ),
      ),
      child: Row(
        children: [
          _iconButton(
            icon: CupertinoIcons.back,
            tooltip: "Volver",
            onTap: controller.backPage,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Diagnóstico de sostenibilidad",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),
                if (!isMobile)
                  Text(
                    "Revisa el análisis y define los activos que harán parte de la propuesta.",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: Global.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (clientController.Diagnostico.isNotEmpty) ...[
            const SizedBox(width: 6),
            if (isMobile)
              IconButton(
                tooltip: 'Generar PDF',
                onPressed: _generandoPdf ? null : _generarPdf,
                icon: _generandoPdf
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.picture_as_pdf_outlined,
                        color: Global.primary),
              )
            else
              OutlinedButton.icon(
                onPressed: _generandoPdf ? null : _generarPdf,
                icon: _generandoPdf
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: Text(_generandoPdf ? 'Generando...' : 'Generar PDF'),
              ),
          ],
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Global.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Global.primary.withOpacity(.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: Global.primary,
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 6),
                  Text(
                    "Análisis inteligente",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Global.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Muestra errores visibles incluso cuando un snackbar no llega a aparecer.
  Future<void> _generarPdf() async {
    if (_generandoPdf) return;

    final diagnostico = clientController.Diagnostico;
    if (diagnostico.isEmpty) return;

    setState(() => _generandoPdf = true);
    try {
      final datosActivos = <Map<String, dynamic>>[];

      for (final raw in _getActivosOrdenados(diagnostico)) {
        if (raw is! Map) continue;
        final activo = Map<String, dynamic>.from(raw);
        final idActivo = _toInt(activo['id_activo']);
        final alternativa = idActivo == null
            ? null
            : alternativasSeleccionadas[idActivo];

        datosActivos.add({
          'id_activo': idActivo,
          'nombre_activo': activo['nombre_activo'],
          'prioridad': activo['prioridad'],
          'incluido': idActivo != null && activosSeleccionados.contains(idActivo),
          'metricas': _getMetricasVisualesActivo(activo),
          'confianza': activo['confianza'],
          'alternativa': alternativa == null
              ? null
              : Map<String, dynamic>.from(alternativa),
        });
      }

      await DiagnosticoPdfService.exportar(
        diagnostico: Map<String, dynamic>.from(diagnostico),
        resumenSeleccion: Map<String, dynamic>.from(getMetricasSeleccionadas()),
        activos: datosActivos,
      );
    } catch (e) {
      debugPrint('Error al exportar diagnóstico PDF: $e');
      Get.snackbar(
        'No fue posible generar el PDF',
        'Verifica los datos del diagnóstico y vuelve a intentarlo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  Future<void> _mensajeFve(String titulo, String detalle) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(titulo),
        content: SelectableText(detalle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _iniciarFve(int idDiagnostico) async {
    if (_startingFve) return;
    debugPrint('[FVE-00] Clic: diagnostico=$idDiagnostico');
    setState(() => _startingFve = true);
    try {
      final data = await iniciarProcesoFveApi(idDiagnostico: idDiagnostico)
          .timeout(const Duration(seconds: 25));
      debugPrint('[FVE-00] API respondio: creado=${data['creado']}');

      final proceso = data['proceso'];
      if (proceso is! Map) {
        throw FveApiException('La API no devolvio el objeto proceso.');
      }

      clientController.setProcesoFve(Map<String, dynamic>.from(proceso));
      if (!mounted) return;

      // La navegacion puede fallar por permisos, confirmacion o bloqueo interno.
      // Antes se ignoraba el resultado y no aparecia ningun aviso.
      final navego = await controller.setPage(AsesorRoutes.procesoFve);
      if (!navego && mounted) {
        await _mensajeFve(
          'Proceso FVE guardado, pero no se pudo abrir',
          'La API devolvio el proceso #${proceso['id_proceso']}, '
          'pero la navegacion fue bloqueada. '
          'Verifica que el usuario tenga el rol Asesor y que '
          'GeneralContoller.dart incluya AsesorRoutes.procesoFve '
          'en el mapa pages y en las rutas permitidas del asesor.',
        );
      }
    } catch (e) {
      debugPrint('[FVE-00] ERROR: $e');
      if (mounted) {
        await _mensajeFve('No fue posible iniciar / continuar FVE',
            e.toString());
      }
    } finally {
      if (mounted) setState(() => _startingFve = false);
    }
  }

  Widget _buildFveStart(Map diagnostico, bool isMobile) {
    final id = _toInt(diagnostico['id_diagnostico']);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Global.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Global.primary.withOpacity(0.24)),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          SizedBox(
            width: isMobile ? 240 : 530,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Negociaci\u00f3n FVE',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Global.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Inicia o retoma el proceso FVE desde este diagn\u00f3stico. '
                  'No se crea otra negociaci\u00f3n al pulsar dos veces.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: Global.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _startingFve
                ? null
                : () async {
                    if (id == null) {
                      await _mensajeFve(
                        'Diagnostico sin identificador',
                        'No se encontro id_diagnostico en los datos de la '
                        'pantalla. No se envio ninguna solicitud al servidor. '
                        'Revisa la carga del diagnostico antes de iniciar FVE.',
                      );
                      return;
                    }
                    await _iniciarFve(id);
                  },
            icon: _startingFve
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.arrow_forward_rounded),
            label: Text(_startingFve
                ? 'Iniciando...'
                : 'Iniciar / continuar FVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Global.primary.withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 30,
                color: Global.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No hay diagnóstico disponible",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Global.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Cuando se genere el diagnóstico podrás consultarlo desde aquí.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Global.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(Map diagnostico, bool isMobile) {
    final title = diagnostico["titulo"]?.toString().trim();
    final assetsCount = _getActivos(diagnostico).length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Global.primary,
            Color.lerp(
              Global.primary,
              Global.secondary,
              .72,
            ) ??
                Global.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Global.primary.withOpacity(.20),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isMobile
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heroIcon(),
          const SizedBox(height: 16),
          _heroText(title),
          const SizedBox(height: 18),
          _heroBadge(assetsCount),
        ],
      )
          : Row(
        children: [
          _heroIcon(),
          const SizedBox(width: 18),
          Expanded(child: _heroText(title)),
          const SizedBox(width: 18),
          _heroBadge(assetsCount),
        ],
      ),
    );
  }

  Widget _heroIcon() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(.20),
        ),
      ),
      child: const Icon(
        Icons.eco_outlined,
        size: 28,
        color: Colors.white,
      ),
    );
  }

  Widget _heroText(String? title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "RESULTADO DEL DIAGNÓSTICO",
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.white.withOpacity(.76),
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(
          title?.isNotEmpty == true ? title! : "Diagnóstico",
          style: GoogleFonts.poppins(
            fontSize: 21,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _heroBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "$count ${count == 1 ? 'activo analizado' : 'activos analizados'}",
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveSummary(Map diagnostico) {
    final text = diagnostico["problema"]?["resumen"]
        ?.toString()
        .trim() ??
        "";

    return _surfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.analytics_outlined,
            title: "Resumen ejecutivo",
            subtitle:
            "Principales conclusiones obtenidas del análisis.",
            color: Global.primary,
          ),
          const SizedBox(height: 16),
          SelectableText(
            text.isEmpty ? "Sin información disponible." : text,
            textAlign: TextAlign.left,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.65,
              color: Global.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulator(Map diagnostico, bool isMobile) {
    final activos = _getActivos(diagnostico);

    return _surfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _sectionHeader(
              icon: Icons.tune_rounded,
              title: "Simulador de propuesta",
              subtitle:
              alternativasSeleccionadas.isEmpty
                  ? "Selecciona los activos y observa cómo cambian los resultados."
                  : "La inversión usa los productos elegidos. Los ahorros técnicos permanecen como estimación del diagnóstico.",
              color: Global.primary,
            ),
            const SizedBox(height: 14),
            _selectionActions(activos),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _sectionHeader(
                    icon: Icons.tune_rounded,
                    title: "Simulador de propuesta",
                    subtitle:
                    "Selecciona los activos y observa cómo cambian los resultados.",
                    color: Global.primary,
                  ),
                ),
                const SizedBox(width: 16),
                _selectionActions(activos),
              ],
            ),
          const SizedBox(height: 20),
          Obx(() {
            final metricas = getMetricasSeleccionadas();

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 1050
                    ? 4
                    : width >= 650
                    ? 2
                    : 1;

                final spacing = 12.0;
                final cardWidth =
                    (width - (spacing * (columns - 1))) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    _metricCard(
                      width: cardWidth,
                      title: "Ahorro mensual",
                      value: formatCurrency(metricas["ahorro"]),
                      icon: Icons.savings_outlined,
                      color: const Color(0xFF16835D),
                    ),
                    _metricCard(
                      width: cardWidth,
                      title: "Inversión requerida",
                      value: formatCurrency(metricas["inversion"]),
                      icon: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFFE58A1F),
                    ),
                    _metricCard(
                      width: cardWidth,
                      title: "ROI a 5 años",
                      value: metricas["roi"] == null
                          ? "No disponible"
                          : "${metricas["roi"].toStringAsFixed(1)}%",
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFF7756C9),
                    ),
                    _metricCard(
                      width: cardWidth,
                      title: "Retorno de inversión",
                      value: metricas["payback"] == null
                          ? "No disponible"
                          : "${metricas["payback"].toStringAsFixed(1)} meses",
                      icon: Icons.schedule_rounded,
                      color: const Color(0xFF3276C3),
                    ),
                    _metricCard(
                      width: cardWidth,
                      title: "Energía reducida",
                      value:
                      metricas["energia"] == null
                          ? "No disponible"
                          : "${metricas["energia"].toStringAsFixed(1)} kWh",
                      icon: Icons.bolt_rounded,
                      color: const Color(0xFFD19B13),
                    ),
                    _metricCard(
                      width: cardWidth,
                      title: "Agua reducida",
                      value:
                      metricas["agua"] == null
                          ? "No disponible"
                          : "${metricas["agua"].toStringAsFixed(1)} m³",
                      icon: Icons.water_drop_outlined,
                      color: const Color(0xFF1597C5),
                    ),
                    _metricCard(
                      width: cardWidth,
                      title: "CO₂ evitado",
                      value:
                      metricas["carbono"] == null
                          ? "No disponible"
                          : "${metricas["carbono"].toStringAsFixed(1)} kg",
                      icon: Icons.eco_outlined,
                      color: const Color(0xFF198B78),
                    ),
                    _metricCard(
                      width: cardWidth,
                      title: "Activos incluidos",
                      value:
                      "${metricas["cantidad"]} de ${activos.length}",
                      icon: Icons.inventory_2_outlined,
                      color: Global.primary,
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _selectionActions(List<dynamic> activos) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: () {
            activosSeleccionados.clear();

            for (final activo in activos) {
              final id = _toInt(activo["id_activo"]);

              if (id != null) {
                activosSeleccionados.add(id);
              }
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: Global.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.done_all_rounded, size: 18),
          label: const Text("Seleccionar todos"),
        ),
        OutlinedButton.icon(
          onPressed: activosSeleccionados.clear,
          style: OutlinedButton.styleFrom(
            foregroundColor: Global.text,
            side: BorderSide(
              color: Global.text.withOpacity(.16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.remove_done_rounded, size: 18),
          label: const Text("Limpiar"),
        ),
      ],
    );
  }

  // FVE_GUARDAR_SELECCION: confirmacion explicita, independiente de la decision comercial.
  bool _guardandoSeleccionFve = false;
  Future<void> _guardarSeleccionParaFve() async {
    if (_guardandoSeleccionFve) return;
    final idDiag = _toInt(clientController.Diagnostico['id_diagnostico']);
    if (idDiag == null) return;
    final ids = activosSeleccionados.toList();
    if (ids.isEmpty) {
      Get.snackbar('Seleccion vacia', 'Selecciona por lo menos un activo.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // Las recomendaciones IA no equivalen a una eleccion del asesor.
    final pendientes = ids.where((id) => _toInt(alternativasSeleccionadas[id]?['id_item']) == null ||
        alternativasSeleccionadas[id]?['fuente'] != 'usuario').toList();
    if (pendientes.isNotEmpty) {
      Get.snackbar('Productos sin confirmar',
        'Abre Ver alternativas y elige un producto para cada activo incluido. Si no lo vas a reemplazar, desmarcalo.',
        snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 6));
      return;
    }
    setState(() => _guardandoSeleccionFve = true);
    try {
      final metricas = getMetricasSeleccionadas();
      final respuesta = await guardarSeleccionActivosDiagnosticoApi(
        idDiagnostico: idDiag,
        activosSeleccionados: ids,
        alternativasSeleccionadas: ids.map((id) => <String, dynamic>{
          'id_activo': id, 'id_item': alternativasSeleccionadas[id]!['id_item'], 'fuente': 'usuario',
        }).toList(),
        resumenSeleccionado: <String, dynamic>{
          'ahorro_economico_mensual': _toNullableDouble(metricas['ahorro']),
          'inversion_total_requerida': _toNullableDouble(metricas['inversion']),
          'reduccion_energia': _toNullableDouble(metricas['energia']),
          'reduccion_agua': _toNullableDouble(metricas['agua']),
          'reduccion_carbono': _toNullableDouble(metricas['carbono']),
          'roi': _toNullableDouble(metricas['roi']),
          'payback': _toNullableDouble(metricas['payback']),
        },
      );
      if (!mounted) return;
      if (respuesta['diagnostico'] is Map) {
        clientController.setDiagnostico(Map<String, dynamic>.from(respuesta['diagnostico']));
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Seleccion guardada. Ya puedes volver a FVE y actualizar la negociacion.'),
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No se pudo guardar la seleccion: $e'),
      ));
    } finally {
      if (mounted) setState(() => _guardandoSeleccionFve = false);
    }
  }

  Widget _buildAssetsSection(Map diagnostico, bool isMobile) {
    final activos = _getActivosOrdenados(diagnostico);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _sectionHeader(
            icon: Icons.inventory_2_outlined,
            title: "Activos recomendados",
            subtitle:
            "Oportunidades detectadas automáticamente, ordenadas por ahorro disponible.",
            color: Global.primary,
          ),
        ),
        // FVE_AUTO_SIMULADOR_AVISO_V1
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: Text(
            'Los activos detectados se incluyen inicialmente en la simulación. ' 
            'La selección y el producto deben confirmarse antes de guardar para FVE. ' 
            'Confianza baja no equivale a elegibilidad verde.',
            style: GoogleFonts.poppins(fontSize: 11, color: Global.textSecondary),
          ),
        ),
        if (diagnostico['metricas']?['contiene_estimaciones_ia'] == true)
          Padding(padding: const EdgeInsets.only(top: 10),
            child: Container(width: double.infinity,padding:const EdgeInsets.all(12),
              decoration:BoxDecoration(color:Colors.orange.withOpacity(.10),borderRadius:BorderRadius.circular(10)),
              child:Text('AVISO: Este diagnostico incluye escenarios aproximados de IA basados en referencias externas. No son consumos medidos ni beneficios certificados.',
                style:TextStyle(color:Global.text,fontWeight:FontWeight.w600,fontSize:12)))),
        // FVE_GUARDAR_BOTON
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _guardandoSeleccionFve ? null : _guardarSeleccionParaFve,
            icon: const Icon(Icons.save_outlined, size: 17),
            label: const Text('Guardar selección para FVE'),
          ),
        ),
        const SizedBox(height: 9),
        const SizedBox(height: 14),
        if (activos.isEmpty)
          _surfaceCard(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text("No hay activos para mostrar."),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1080
                  ? 3
                  : width >= 680
                  ? 2
                  : 1;

              const spacing = 14.0;
              final cardWidth =
                  (width - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: activos.map((activo) {
                  return SizedBox(
                    width: cardWidth,
                    child: _assetCard(activo),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Map<String, dynamic> _getMetricasVisualesActivo(dynamic activo,) {
    final originales =
    Map<String, dynamic>.from(
      activo["metricas"] ?? {},
    );

    final idActivo =
    _toInt(
      activo["id_activo"],
    );

    if (idActivo == null) {
      return originales;
    }

    final alternativa =
    alternativasSeleccionadas[
    idActivo
    ];

    if (alternativa == null) {
      return originales;
    }

    /*
   * Las alternativas consultadas o ya
   * guardadas contienen las métricas
   * oficiales calculadas por el backend.
   */
    final metricasAlternativaRaw =
    alternativa["metricas"];

    if (
    metricasAlternativaRaw is Map
    ) {
      final metricasAlternativa =
      Map<String, dynamic>.from(
        metricasAlternativaRaw,
      );

      return {
        ...originales,
        ...metricasAlternativa,

        "escenario_alternativa":
        true,

        "fuente_alternativa":
        alternativa["fuente"],

        "id_item_alternativa":
        alternativa["id_item"],
      };
    }

    /*
   * Compatibilidad con diagnósticos
   * generados antes de implementar el
   * cálculo completo.
   *
   * En este caso solo podemos actualizar
   * inversión, ROI y payback, porque no
   * existen métricas técnicas específicas
   * de la alternativa.
   */
    final precioUnitario =
    _parsePrice(
      alternativa["precio_base"],
    );

    final cantidadActivo =
        _toInt(
          alternativa[
          "cantidad_activo"
          ],
        ) ??
            1;

    final inversion = alternativa['precio_base'] == null
        ? null : precioUnitario * cantidadActivo;

    // FVE_METRICAS_ALTERNATIVA_V1: datos atribuidos a una referencia del catalogo; sin linea base no hay ahorro.
    // FVE_ALTERNATIVA_TRAZABLE_V1: no trasladar proyecciones de la referencia IA a otro producto.
    final proyeccion = alternativa['proyeccion_ia'];
    final proyeccionMap = proyeccion is Map ? proyeccion : null;
    return {
      ...originales,
      'consumo_energia_proyectado_mes': proyeccionMap?['consumo_energia_proyectado_mes'],
      'consumo_agua_proyectado_mes': proyeccionMap?['consumo_agua_proyectado_mes'],
      'ahorro_economico_mensual': null,
      'reduccion_energia': null,
      'reduccion_agua': null,
      'reduccion_carbono': null,
      'costo_proyectado_mes': null,
      'inversion_total_requerida': inversion,
      'roi_5_anios': null,
      'payback': null,
      'escenario_alternativa': true,
      'metricas_alternativa_disponibles': false,
    };
  }

  // FVE_REFERENCIA_CONSUMO_IA_V1: una referencia citada no se suma a las metricas de ahorro.
  Widget _assetCard(dynamic activo) {
    final idActivo = _toInt(activo["id_activo"],);

    return Obx(() {
      final referencia = idActivo == null ? null :
          alternativasSeleccionadas[idActivo]?['consumo_referencia_ia'];
      final consumoReferencia = referencia is Map
          ? _toNullableDouble(referencia['valor']) : null;
      final metricas = _getMetricasVisualesActivo(activo,);
      final selected = idActivo != null && activosSeleccionados.contains(idActivo);

      return Semantics(
        selected: selected,
        button: true,
        label:
        "${activo["nombre_activo"] ?? "Activo"}. ${selected ? "Incluido" : "No incluido"}",
        child: InkWell(
          onTap: idActivo == null
              ? null
              : () => _toggleAsset(idActivo),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: selected
                  ? Global.container
                  : Global.container.withOpacity(.58),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? Global.primary.withOpacity(.55)
                    : Global.text.withOpacity(.09),
                width: selected ? 1.4 : 1,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color: Global.primary.withOpacity(.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Global.primary.withOpacity(.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        _assetIcon(
                          activo["nombre_activo"]?.toString(),
                        ),
                        color: Global.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activo["nombre_activo"]?.toString() ??
                                "Activo",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Global.text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Prioridad ${activo["prioridad"] ?? "-"}",
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: Global.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: selected
                            ? Global.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? Global.primary
                              : Global.text.withOpacity(.25),
                        ),
                      ),
                      child: selected
                          ? const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16835D).withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.savings_outlined,
                        size: 18,
                        color: Color(0xFF16835D),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ahorro mensual estimado",
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                color: Global.textSecondary,
                              ),
                            ),
                            Text(
                              formatCurrency(
                                metricas[
                                "ahorro_economico_mensual"],
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16835D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                _miniMetric(
                  "Inversión",
                  formatCurrency(
                    metricas["inversion_total_requerida"],
                  ),
                ),
                _miniMetric(
                  'Consumo proyectado citado por diagnóstico IA (sin verificar)',
                  _formatMeasurement(
                    metricas['consumo_energia_proyectado_mes'], 'kWh/mes',
                  ),
                ),
                if (consumoReferencia != null)
                  _miniMetric(
                    'Consumo de referencia citado por IA (sin verificar)',
                    _formatMeasurement(consumoReferencia, 'kWh/mes'),
                  ),
                if (metricas['fve_referencias_tecnicas_ia'] is Map &&
                    metricas['fve_escenario_estimado'] is! Map) ...[
                  Container(width: double.infinity,padding:const EdgeInsets.all(12),
                    decoration:BoxDecoration(color:Colors.orange.withOpacity(.10),borderRadius:BorderRadius.circular(10)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[
                      Text('REFERENCIAS TECNICAS APROXIMADAS (IA)',
                        style:TextStyle(color:Global.text,fontWeight:FontWeight.bold,fontSize:11)),
                      for (final x in (metricas['fve_referencias_tecnicas_ia'] as Map).entries)
                        if (x.value is Map)
                          Text('${x.key}: ${x.value['valor']} ${x.value['unidad']} (sin medir)',
                            style:TextStyle(color:Global.text,fontSize:11)),
                      Text('No representan mediciones ni ahorros garantizados.',
                        style:TextStyle(color:Global.textSecondary,fontSize:11)),
                    ])),
                  const SizedBox(height: 8),
                ],
                if (metricas['fve_escenario_estimado'] is Map) ...[
                  const SizedBox(height: 9),
                  Container(width: double.infinity, padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(.10),borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(.3))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('ESCENARIO APROXIMADO CON IA', style: TextStyle(color: Global.text,fontSize: 11,fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text('Consumo actual estimado (sin medicion): ${metricas['fve_escenario_estimado']['consumo_actual_estimado_kwh_mes']} kWh/mes',
                        style: TextStyle(color: Global.text, fontSize: 11)),
                      if (idActivo != null && !alternativasSeleccionadas.containsKey(idActivo) &&
                          metricas['fve_escenario_estimado']['ahorro_estimado_kwh_mes'] != null)
                        Text('Diferencia hipotetica: ${metricas['fve_escenario_estimado']['ahorro_estimado_kwh_mes']} kWh/mes',
                          style: TextStyle(color: Global.text,fontSize: 11)),
                      if (idActivo != null && !alternativasSeleccionadas.containsKey(idActivo) &&
                          metricas['fve_escenario_estimado']['ahorro_estimado_cop_mes'] != null)
                        Text('Ahorro orientativo: ${formatCurrency(metricas['fve_escenario_estimado']['ahorro_estimado_cop_mes'])}/mes',
                          style: TextStyle(color: Global.text,fontSize: 11)),
                      if (idActivo != null && !alternativasSeleccionadas.containsKey(idActivo) &&
                          metricas['fve_escenario_estimado']['roi_estimado_cinco_anios_pct'] != null)
                        Text('ROI hipotetico a cinco años: ${_formatPercentage(metricas['fve_escenario_estimado']['roi_estimado_cinco_anios_pct'])}',
                          style: TextStyle(color: Global.text,fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('Estimacion externa citada por IA. No es ahorro comprobado ni otorga elegibilidad verde.',
                        style: TextStyle(color: Global.textSecondary,fontSize: 11)),
                      for (final f in (metricas['fve_escenario_estimado']['fuentes'] is List
                         ? metricas['fve_escenario_estimado']['fuentes'] as List : <dynamic>[]))
                        if (f is Map && f['url'] != null) SelectableText('${f['url']}',
                          style: TextStyle(color: Global.primary,fontSize: 10)),
                    ])),
                  const SizedBox(height: 8),
                ],
                _miniMetric(
                  "ROI a 5 años",
                  _formatPercentage(
                    metricas["roi_5_anios"],
                    hideWhenZeroSaving:
                    _toDouble(metricas["ahorro_economico_mensual"]) ==
                        0,
                  ),
                ),
                _miniMetric(
                  "Energía reducida",
                  _formatMeasurement(
                    metricas["reduccion_energia"],
                    "kWh",
                  ),
                ),
                _miniMetric(
                  "Agua reducida",
                  _formatMeasurement(
                    metricas["reduccion_agua"],
                    "m³",
                  ),
                ),
                _miniMetric(
                  "CO₂ evitado",
                  _formatMeasurement(
                    metricas["reduccion_carbono"],
                    "kg",
                  ),
                ),
                const SizedBox(height: 13),
                _confidenceBlock(activo["confianza"],),
                const SizedBox(height: 12),
                _buildAlternativeSelection(activo,),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _confidenceBlock(dynamic confidence) {
    final level = confidence?["nivel"]?.toString().trim() ?? "";
    final reason = confidence?["motivo"]?.toString().trim() ?? "";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Global.text.withOpacity(.035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Global.text.withOpacity(.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 15,
                color: Global.primary,
              ),
              const SizedBox(width: 6),
              Text(
                "Confianza del análisis",
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Global.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                level.isEmpty ? "Sin clasificar" : level,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Global.primary,
                ),
              ),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              reason,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                height: 1.45,
                color: Global.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlternativeSelection(
      dynamic activo,
      ) {

    final idActivo =
    _toInt(
      activo["id_activo"],
    );

    if (idActivo == null) {
      return const SizedBox.shrink();
    }

    final alternativa =
    alternativasSeleccionadas[
    idActivo
    ];

    if (alternativa == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            _abrirSelectorAlternativa(
              activo,
            );
          },

          style:
          OutlinedButton.styleFrom(
            foregroundColor:
            Global.primary,

            padding:
            const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),

            side: BorderSide(
              color:
              Global.primary
                  .withOpacity(.35),
            ),

            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
          ),

          icon: const Icon(
            Icons.compare_arrows_rounded,
            size: 18,
          ),

          label: const Text(
            "Comparar productos",
          ),
        ),
      );
    }

    final proveedor =
    alternativa["proveedor"];

    final nombreProveedor =
    proveedor is Map
        ? proveedor["nombre"]
        ?.toString()
        .trim() ??
        ""
        : "";

    final nombreProducto =
        alternativa["nombre"]
            ?.toString()
            .trim() ??
            "Producto seleccionado";

    final fuente =
        alternativa["fuente"]
            ?.toString()
            .toLowerCase() ??
            "usuario";

    final recomendadaPorIA =
        fuente == "ia";

    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color:
        Global.primary
            .withOpacity(.065),

        borderRadius:
        BorderRadius.circular(13),

        border: Border.all(
          color:
          Global.primary
              .withOpacity(.20),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                recomendadaPorIA
                    ? Icons.auto_awesome_rounded
                    : Icons.check_circle_rounded,
                size: 17,
                color:
                Global.primary,
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  recomendadaPorIA
                      ? "Recomendación de la IA"
                      : "Alternativa elegida por el usuario",
                  style:
                  GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    Global.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            nombreProducto,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style:
            GoogleFonts.poppins(
              fontSize: 12,
              fontWeight:
              FontWeight.w600,
              color: Global.text,
            ),
          ),

          if (
          nombreProveedor.isNotEmpty
          ) ...[
            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  Icons
                      .storefront_outlined,
                  size: 14,
                  color:
                  Global
                      .textSecondary,
                ),

                const SizedBox(width: 5),

                Expanded(
                  child: Text(
                    nombreProveedor,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    GoogleFonts
                        .poppins(
                      fontSize: 10,
                      color:
                      Global
                          .textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 7),

          Row(
            children: [
              Expanded(
                child: Text(
                  formatCurrency(
                    alternativa[
                    "precio_base"
                    ],
                  ),
                  style:
                  GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    Global.text,
                  ),
                ),
              ),

              TextButton.icon(
                onPressed: () {
                  _abrirSelectorAlternativa(
                    activo,
                  );
                },

                style:
                TextButton.styleFrom(
                  foregroundColor:
                  Global.primary,

                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),

                  minimumSize:
                  Size.zero,

                  tapTargetSize:
                  MaterialTapTargetSize
                      .shrinkWrap,
                ),

                icon: const Icon(
                  Icons.edit_outlined,
                  size: 15,
                ),

                label: Text(
                  recomendadaPorIA
                      ? "Ver alternativas"
                      : "Cambiar",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(Map diagnostico, bool isMobile) {
    final problem = diagnostico["problema"]?["detalle"]?.toString();
    final benefit =
    diagnostico["beneficios"]?["detalle"]?.toString();

    if (isMobile) {
      return Column(
        children: [
          _detailCard(
            title: "Problema identificado",
            subtitle: "Situación actual que requiere atención.",
            text: problem,
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFD74C4C),
          ),
          const SizedBox(height: 14),
          _detailCard(
            title: "Beneficio y oportunidad",
            subtitle: "Impacto esperado al implementar la propuesta.",
            text: benefit,
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF16835D),
          ),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _detailCard(
              title: "Problema identificado",
              subtitle: "Situación actual que requiere atención.",
              text: problem,
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFD74C4C),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _detailCard(
              title: "Beneficio y oportunidad",
              subtitle:
              "Impacto esperado al implementar la propuesta.",
              text: benefit,
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF16835D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({
    required String title,
    required String subtitle,
    required String? text,
    required IconData icon,
    required Color color,
  }) {
    final value = text?.trim() ?? "";

    return _surfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: icon,
            title: title,
            subtitle: subtitle,
            color: color,
          ),
          const SizedBox(height: 15),
          SelectableText(
            value.isEmpty ? "Sin información disponible." : value,
            textAlign: TextAlign.left,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.65,
              color: Global.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: Global.primary.withOpacity(.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Global.primary.withOpacity(.20),
        ),
      ),
      child: isMobile
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _decisionContent(),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: _decisionButton(),
          ),
        ],
      )
          : Row(
        children: [
          Expanded(child: _decisionContent()),
          const SizedBox(width: 24),
          _decisionButton(),
        ],
      ),
    );
  }

  Widget _decisionContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Global.primary.withOpacity(.13),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.handshake_outlined,
            color: Global.primary,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Decisión del cliente",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Global.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Después de socializar el diagnóstico, registra si el cliente continuará con la propuesta.",
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  height: 1.5,
                  color: Global.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _decisionButton() {
    return FilledButton.icon(
      onPressed: loading
          ? null
          : () => mostrarModalDecisionCliente(
        context,
        clientController.Client,
        clientController,
      ),
      style: FilledButton.styleFrom(
        backgroundColor: Global.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Global.primary.withOpacity(.35),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
      icon: loading
          ? const SizedBox(
        width: 17,
        height: 17,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : const Icon(Icons.fact_check_outlined, size: 19),
      label: Text(
        loading ? "Guardando..." : "Registrar decisión",
      ),
    );
  }

  Widget _surfaceCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Global.text.withOpacity(.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              controller.isDark.value ? .12 : .035,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 21, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Global.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  height: 1.35,
                  color: Global.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: Global.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                color: Global.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Global.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Global.text.withOpacity(.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Global.text.withOpacity(.07),
            ),
          ),
          child: Icon(icon, size: 20, color: Global.text),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getActivosSinAlternativa() {

    final diagnostico = clientController.Diagnostico;

    final activos =
    _getActivos(
      diagnostico,
    );

    final sinAlternativa =
    <Map<String, dynamic>>[];

    for (final activo in activos) {

      if (activo is! Map) {
        continue;
      }

      final activoMap =
      Map<String, dynamic>.from(
        activo,
      );

      final idActivo =
      _toInt(
        activoMap["id_activo"],
      );

      if (
      idActivo == null ||
          !activosSeleccionados
              .contains(idActivo)
      ) {
        continue;
      }

      final alternativa =
      alternativasSeleccionadas[
      idActivo
      ];

      final idItem =
      _toInt(
        alternativa?["id_item"],
      );

      if (idItem == null) {
        sinAlternativa.add(
          activoMap,
        );
      }
    }

    return sinAlternativa;
  }

  Future<void> _mostrarActivosSinAlternativa(List<Map<String, dynamic>>activos,) async {

    await showDialog<void>(
      context: context,
      builder: (
          dialogContext,
          ) {

        return AlertDialog(
          backgroundColor:
          Global.container,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              18,
            ),
          ),

          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFF5A000,
                  ).withOpacity(.12),

                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .storefront_outlined,
                  color:
                  Color(
                    0xFFF5A000,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  "Faltan alternativas",
                  style:
                  GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w600,
                    color: Global.text,
                  ),
                ),
              ),
            ],
          ),

          content:
          ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 460,
            ),

            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Para continuar debes elegir "
                      "un producto y proveedor para "
                      "cada activo incluido.",
                  style:
                  GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.5,
                    color:
                    Global
                        .textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Container(
                  width:
                  double.infinity,

                  padding:
                  const EdgeInsets.all(
                    12,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    Global.text
                        .withOpacity(
                      .035,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      13,
                    ),

                    border:
                    Border.all(
                      color:
                      Global.text
                          .withOpacity(
                        .08,
                      ),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children:
                    activos.map(
                          (activo) {

                        return Padding(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            vertical: 4,
                          ),

                          child: Row(
                            children: [
                              Icon(
                                Icons
                                    .circle,
                                size: 6,
                                color:
                                Global
                                    .primary,
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Expanded(
                                child: Text(
                                  activo[
                                  "nombre_activo"
                                  ]
                                      ?.toString() ??
                                      "Activo sin nombre",

                                  style:
                                  GoogleFonts
                                      .poppins(
                                    fontSize:
                                    11.5,
                                    color:
                                    Global
                                        .text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  "Puedes elegir una alternativa "
                      "o retirar el activo de la propuesta.",
                  style:
                  GoogleFonts.poppins(
                    fontSize: 10.5,
                    height: 1.45,
                    color:
                    Global
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },

              style:
              FilledButton.styleFrom(
                backgroundColor:
                Global.primary,

                foregroundColor:
                Colors.white,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    11,
                  ),
                ),
              ),

              child:
              const Text(
                "Revisar activos",
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _abrirSelectorAlternativa(dynamic activo,) async {

    final idDiagnostico =
    _toInt(
      clientController
          .Diagnostico[
      "id_diagnostico"
      ],
    );

    final idActivo =
    _toInt(
      activo["id_activo"],
    );

    if (
    idDiagnostico == null ||
        idActivo == null
    ) {

      Get.snackbar(
        "Información incompleta",
        "No fue posible identificar "
            "el diagnóstico o el activo.",
        snackPosition:
        SnackPosition.BOTTOM,
        margin:
        const EdgeInsets.all(16),
      );

      return;
    }

    final alternativa =
    await mostrarSelectorAlternativaDiagnostico(
      context: context,

      idDiagnostico:
      idDiagnostico,

      idActivo:
      idActivo,

      seleccionActual:
      alternativasSeleccionadas[
      idActivo
      ],
    );

    if (
    alternativa == null ||
        !mounted
    ) {
      return;
    }

    final seleccion =
    Map<String, dynamic>.from(alternativa);
    final soloVinculo = seleccion.remove('solo_vinculo') == true;
    final idResuelto = _toInt(seleccion.remove('id_activo_resuelto')) ?? idActivo;
    final diagnosticoCorregido = seleccion.remove('diagnostico_actualizado');
    if (diagnosticoCorregido is Map) {
      // La correccion fue escrita por el backend en el diagnostico actual.
      clientController.setDiagnostico(Map<String,dynamic>.from(diagnosticoCorregido));
      if (idResuelto != idActivo) {
        if (activosSeleccionados.remove(idActivo)) activosSeleccionados.add(idResuelto);
        final previa = alternativasSeleccionadas.remove(idActivo);
        if (previa != null) {
          alternativasSeleccionadas[idResuelto] = {...previa, 'id_activo': idResuelto};
        }
      }
      setState(() {});
    }
    if (soloVinculo) return;

    /*
   * Guardamos también el activo al que
   * corresponde la alternativa.
   */
    seleccion["id_activo"] = idResuelto;
    seleccion["fuente"] = "usuario";
    seleccion["seleccionado_at"] = DateTime.now().toIso8601String();

    alternativasSeleccionadas[
    idResuelto
    ] = seleccion;

    /*
   * Si eligió una alternativa, incluimos
   * automáticamente el activo dentro de
   * la propuesta.
   */
    activosSeleccionados.add(
      idResuelto,
    );
  }

  void _toggleAsset(int idActivo) {
    if (activosSeleccionados.contains(idActivo)) {
      activosSeleccionados.remove(idActivo);
    } else {
      activosSeleccionados.add(idActivo);
    }
  }

  IconData _assetIcon(String? name) {
    final value = name?.toLowerCase() ?? "";

    if (value.contains("climat") || value.contains("aire")) {
      return Icons.ac_unit_rounded;
    }

    if (value.contains("nevera") ||
        value.contains("refrig") ||
        value.contains("congel")) {
      return Icons.kitchen_rounded;
    }

    if (value.contains("ilumin") || value.contains("lámpara")) {
      return Icons.lightbulb_outline_rounded;
    }

    if (value.contains("horno")) {
      return Icons.microwave_rounded;
    }

    if (value.contains("lavadora")) {
      return Icons.local_laundry_service_outlined;
    }

    if (value.contains("comput")) {
      return Icons.computer_rounded;
    }

    if (value.contains("motor")) {
      return Icons.settings_outlined;
    }

    if (value.contains("grifo") || value.contains("agua")) {
      return Icons.water_drop_outlined;
    }

    return Icons.inventory_2_outlined;
  }

  String _formatPercentage(
      dynamic value, {
        bool hideWhenZeroSaving = false,
      }) {
    if (value == null || hideWhenZeroSaving) {
      return "No disponible";
    }

    return "${_toDouble(value).toStringAsFixed(1)}%";
  }

  String _formatMeasurement(dynamic value, String unit) {
    if (value == null) {
      return "No disponible";
    }

    return "${_toDouble(value).toStringAsFixed(1)} $unit";
  }

  String formatCurrency(dynamic value,) {
    final amount =
    _toNullableDouble(
      value,
    );

    if (amount == null) {
      return "No disponible";
    }

    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$ ',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> mostrarModalDecisionCliente(
      BuildContext context,
      Map usuario,
      ClientController clientController,
      ) async {
    String? decision;

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Global.absolute.withOpacity(0.9),
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              titlePadding: const EdgeInsets.fromLTRB(
                22,
                22,
                14,
                0,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                22,
                14,
                22,
                8,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                22,
                8,
                22,
                20,
              ),
              title: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Global.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.fact_check_outlined,
                      color: Global.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Decisión del cliente",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Global.text,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext, false),
                    tooltip: "Cerrar",
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Luego de socializar el diagnóstico con el cliente, selecciona la decisión acordada.",
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          height: 1.5,
                          color: Global.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _opcionDecision(
                        titulo: "Confirmar proceso",
                        descripcion:
                        "El cliente acepta continuar con la propuesta.",
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF16835D),
                        seleccionado: decision == "activo",
                        onTap: () {
                          setModalState(() {
                            decision = "activo";
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _opcionDecision(
                        titulo: "Posponer proceso",
                        descripcion:
                        "La decisión queda pendiente para otro momento.",
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFFE58A1F),
                        seleccionado: decision == "nuevo",
                        onTap: () {
                          setModalState(() {
                            decision = "nuevo";
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _opcionDecision(
                        titulo: "No continuar",
                        descripcion:
                        "El cliente decide no avanzar con la propuesta.",
                        icon: Icons.cancel_outlined,
                        color: const Color(0xFFD74C4C),
                        seleccionado: decision == "desinteresado",
                        onTap: () {
                          setModalState(() {
                            decision = "desinteresado";
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text("Cancelar"),
                ),
                FilledButton.icon(
                  onPressed: decision == null
                      ? null
                      : () => Navigator.pop(dialogContext, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Global.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text("Guardar decisión"),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true || decision == null || !mounted) {
      return;
    }

    if (decision == "activo" && activosSeleccionados.isEmpty) {
      Get.snackbar(
        "Selecciona al menos un activo",
        "Para confirmar el proceso debes incluir un activo en la propuesta.",
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );

      return;
    }

    if (decision == "activo") {

      final activosSinAlternativa = _getActivosSinAlternativa();

      if (activosSinAlternativa.isNotEmpty) {

        await _mostrarActivosSinAlternativa(
          activosSinAlternativa,
        );

        return;
      }
    }

    setState(() {
      loading = true;
    });

    try {
      if (decision == "activo") {
        final metricas = getMetricasSeleccionadas();

        final response = await guardarSeleccionActivosDiagnosticoApi(
          idDiagnostico:
          clientController.Diagnostico["id_diagnostico"],
          activosSeleccionados: activosSeleccionados.toList(),
          resumenSeleccionado: {
            "ahorro_economico_mensual": metricas["ahorro"],
            "inversion_total_requerida": metricas["inversion"],
            "reduccion_energia": metricas["energia"],
            "reduccion_agua": metricas["agua"],
            "reduccion_carbono": metricas["carbono"],
            "roi": metricas["roi"],
            "payback": metricas["payback"],
          },
          alternativasSeleccionadas:
          alternativasSeleccionadas
              .entries
              .where(
                (entry) => activosSeleccionados.contains(entry.key,),).map(
                (entry) => {
                  "id_activo": entry.key,
                  "id_item": entry.value["id_item"],
                  "fuente": entry.value["fuente"] ?? "usuario",},).toList(),
        );

        final diagnosticoActualizado = response["diagnostico"];

        if (diagnosticoActualizado is Map) {
          clientController.setDiagnostico(Map<String, dynamic>.from(diagnosticoActualizado,),);
        }

      }

      await editClientApi(
        idUsuario: usuario["user"]["id_usuario"],
        updatedBy: controller.User["id_usuario"],
        clientController: Get.find<ClientController>(),
        estado: decision,
      );

      if (!mounted) {
        return;
      }

      if (decision != "activo") {
        await getClientApi(
          clientController: clientController,
        );

        controller.backPage();
        controller.backPage();
        controller.setPage(AsesorRoutes.home);
      } else {
        clientController.refreshClient();
        controller.backPage();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      Get.snackbar(
        "No fue posible guardar la decisión",
        "Verifica tu conexión e inténtalo nuevamente.",
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFFD74C4C),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget _opcionDecision({
    required String titulo,
    required String descripcion,
    required IconData icon,
    required Color color,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withOpacity(.10)
              : Global.text.withOpacity(.025),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: seleccionado
                ? color
                : Global.text.withOpacity(.10),
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(.11),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Global.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descripcion,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      height: 1.4,
                      color: Global.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                color: seleccionado ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: seleccionado
                      ? color
                      : Global.text.withOpacity(.24),
                ),
              ),
              child: seleccionado
                  ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 15,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _getActivosOrdenados(Map diagnostico) {
    final activos = _getActivos(diagnostico);

    double getSaving(dynamic activo) {
      return _toDouble(
        activo["metricas"]?["ahorro_economico_mensual"],
      );
    }

    activos.sort((a, b) {
      final comparison = getSaving(b).compareTo(getSaving(a));

      if (comparison != 0) {
        return comparison;
      }

      final nameA =
          a["nombre_activo"]?.toString().toLowerCase() ?? '';

      final nameB =
          b["nombre_activo"]?.toString().toLowerCase() ?? '';

      return nameA.compareTo(nameB);
    });

    return activos;
  }
}