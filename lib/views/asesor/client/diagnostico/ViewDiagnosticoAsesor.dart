import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/diagnosticoApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Viewdiagnosticoasesor extends StatefulWidget {
  const Viewdiagnosticoasesor({super.key});

  @override
  State<Viewdiagnosticoasesor> createState() =>
      _ViewdiagnosticoasesorState();
}

class _ViewdiagnosticoasesorState
    extends State<Viewdiagnosticoasesor> {
  bool loading = false;

  final ClientController clientController =
  Get.find<ClientController>();

  final RxSet<int> activosSeleccionados = <int>{}.obs;

  @override
  void initState() {
    super.initState();

    final diagnostico = clientController.Diagnostico;
    final metricas = diagnostico["metricas"] ?? {};
    final activos = metricas["activos"] ?? [];
    final activosGuardados = metricas["activos_seleccionados"];

    if (activosGuardados is List && activosGuardados.isNotEmpty) {
      for (final id in activosGuardados) {
        final parsedId = _toInt(id);

        if (parsedId != null) {
          activosSeleccionados.add(parsedId);
        }
      }

      return;
    }

    if (activos is List) {
      for (final activo in activos) {
        final id = _toInt(activo["id_activo"]);

        if (id != null) {
          activosSeleccionados.add(id);
        }
      }
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

  List<dynamic> _getActivos(Map diagnostico) {
    return List<dynamic>.from(
      diagnostico["metricas"]?["activos"] ?? [],
    );
  }

  Map<String, dynamic> getMetricasSeleccionadas() {
    final diagnostico = clientController.Diagnostico;
    final activos = _getActivos(diagnostico);

    double ahorro = 0;
    double inversion = 0;
    double energia = 0;
    double agua = 0;
    double carbono = 0;
    int cantidad = 0;

    for (final activo in activos) {
      final id = _toInt(activo["id_activo"]);

      if (id == null || !activosSeleccionados.contains(id)) {
        continue;
      }

      cantidad++;

      final metricas = activo["metricas"] ?? {};

      ahorro += _toDouble(
        metricas["ahorro_economico_mensual"],
      );

      inversion += _toDouble(
        metricas["inversion_total_requerida"],
      );

      energia += _toDouble(
        metricas["reduccion_energia"],
      );

      agua += _toDouble(
        metricas["reduccion_agua"],
      );

      carbono += _toDouble(
        metricas["reduccion_carbono"],
      );
    }

    final double? roi = inversion > 0
        ? (((ahorro * 60) - inversion) / inversion) * 100
        : null;

    final double? payback =
    ahorro > 0 ? inversion / ahorro : null;

    return {
      "cantidad": cantidad,
      "ahorro": ahorro,
      "inversion": inversion,
      "energia": energia,
      "agua": agua,
      "carbono": carbono,
      "roi": roi,
      "payback": payback,
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
              "Selecciona los activos y observa cómo cambian los resultados.",
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
                      "${metricas["energia"].toStringAsFixed(1)} kWh",
                      icon: Icons.bolt_rounded,
                      color: const Color(0xFFD19B13),
                    ),
                    _metricCard(
                      width: cardWidth,
                      title: "Agua reducida",
                      value:
                      "${metricas["agua"].toStringAsFixed(1)} m³",
                      icon: Icons.water_drop_outlined,
                      color: const Color(0xFF1597C5),
                    ),
                    _metricCard(
                      width: cardWidth,
                      title: "CO₂ evitado",
                      value:
                      "${metricas["carbono"].toStringAsFixed(1)} kg",
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
            "Ordenados de mayor a menor ahorro económico mensual.",
            color: Global.primary,
          ),
        ),
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

  Widget _assetCard(dynamic activo) {
    final metricas = activo["metricas"] ?? {};
    final idActivo = _toInt(activo["id_activo"]);

    return Obx(() {
      final selected = idActivo != null &&
          activosSeleccionados.contains(idActivo);

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
                _confidenceBlock(activo["confianza"]),
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

  String formatCurrency(dynamic value) {
    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$ ',
      decimalDigits: 0,
    ).format(_toDouble(value));
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

    setState(() {
      loading = true;
    });

    try {
      if (decision == "activo") {
        final metricas = getMetricasSeleccionadas();

        await guardarSeleccionActivosDiagnosticoApi(
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
        );
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