import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Diagnosticoscliente
    extends StatefulWidget {
  const Diagnosticoscliente({
    super.key,
  });

  @override
  State<Diagnosticoscliente> createState() =>
      _DiagnosticosclienteState();
}

class _DiagnosticosclienteState extends State<Diagnosticoscliente> {
  final ClientController clientController = Get.find<ClientController>();

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    _loadProposal();
  }

  Future<void> _loadProposal() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      await getDiagnosticosByUsuario(
        clientController:
        clientController,
      );
    } catch (exception) {
      if (mounted) {
        setState(() {
          error = exception
              .toString()
              .replaceFirst(
            'Exception: ',
            '',
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Map<String, dynamic> _map(
      dynamic value,
      ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return {};
  }

  List<Map<String, dynamic>> _maps(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) =>
      Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }

  int? _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  double? _toDouble(
      dynamic value,
      ) {
    if (
    value == null ||
        value.toString().trim().isEmpty
    ) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value
          .toString()
          .replaceAll(',', '.'),
    );
  }

  String _text(
      dynamic value, {
        String fallback =
        'No disponible',
      }) {
    final result =
        value?.toString().trim() ?? '';

    return result.isEmpty
        ? fallback
        : result;
  }

  String _currency(
      dynamic value,
      ) {
    final amount =
    _toDouble(value);

    if (amount == null) {
      return 'No disponible';
    }

    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$ ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _percentage(
      dynamic value,
      ) {
    final amount =
    _toDouble(value);

    if (amount == null) {
      return 'No disponible';
    }

    return '${amount.toStringAsFixed(1)}%';
  }

  String _measurement(
      dynamic value,
      String unit,
      ) {
    final amount =
    _toDouble(value);

    if (amount == null) {
      return 'No disponible';
    }

    return '${amount.toStringAsFixed(1)} $unit';
  }

  String _date(
      dynamic value,
      ) {
    if (value == null) {
      return 'Sin fecha';
    }

    final parsed =
    DateTime.tryParse(
      value.toString(),
    );

    if (parsed == null) {
      return 'Sin fecha';
    }

    return DateFormat(
      'dd/MM/yyyy',
    ).format(
      parsed.toLocal(),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Obx(() {
      final _ = controller.isDark.value;

      if (loading) {
        return _loadingState();
      }

      if (error != null) {
        return _errorState();
      }

      final diagnostico =
      Map<String, dynamic>.from(
        clientController.Diagnostico,
      );

      if (diagnostico.isEmpty) {
        return _emptyState();
      }

      return RefreshIndicator(
        onRefresh:
        _loadProposal,

        color:
        Global.primary,

        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.fromLTRB(
            15,
            15,
            15,
            110,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 1400,
              ),

              child: _proposalContent(
                diagnostico,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _proposalContent(
      Map<String, dynamic>
      diagnostico,
      ) {
    final metricas =
    _map(
      diagnostico["metricas"],
    );

    final problema =
    _map(
      diagnostico["problema"],
    );

    final beneficios =
    _map(
      diagnostico["beneficios"],
    );

    final activos =
    _maps(
      metricas["activos"],
    );

    final alternativas =
    _maps(
      metricas[
      "alternativas_seleccionadas"
      ],
    );

    final resumenGuardado =
    _map(
      metricas[
      "resumen_seleccionado"
      ],
    );

    /*
     * Si existe una selección guardada,
     * utilizamos su resumen oficial.
     * Si no, mostramos el diagnóstico
     * inicial.
     */
    final resumen =
    resumenGuardado.isNotEmpty
        ? resumenGuardado
        : metricas;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _header(
          diagnostico,
          alternativas,
        ),

        const SizedBox(
          height: 18,
        ),

        _statusBanner(
          diagnostico,
          resumen,
        ),

        const SizedBox(
          height: 18,
        ),

        _metricsSection(
          resumen,
          activos.length,
        ),

        const SizedBox(
          height: 22,
        ),

        _analysisSection(
          problema:
          problema,

          beneficios:
          beneficios,
        ),

        const SizedBox(
          height: 22,
        ),

        _assetsSection(
          activos:
          activos,

          alternativas:
          alternativas,
        ),
      ],
    );
  }

  Widget _header(
      Map<String, dynamic>
      diagnostico,

      List<Map<String, dynamic>>
      alternativas,
      ) {
    final hasSelection =
        alternativas.isNotEmpty;

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final mobile =
            constraints.maxWidth <
                650;

        final title = Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                  BoxDecoration(
                    color:
                    Global.primary
                        .withOpacity(
                      .10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: Icon(
                    Icons
                        .assessment_rounded,
                    color:
                    Global.primary,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        'Mi propuesta',
                        style:
                        GoogleFonts.poppins(
                          fontSize:
                          mobile
                              ? 20
                              : 24,
                          fontWeight:
                          FontWeight
                              .w600,
                          color:
                          Global.text,
                        ),
                      ),
                      Text(
                        'Revisa las recomendaciones y beneficios estimados.',
                        style:
                        GoogleFonts.poppins(
                          fontSize: 11.5,
                          color:
                          Global
                              .textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );

        final status =
        _statusChip(
          hasSelection
              ? 'Selección guardada'
              : 'Recomendación generada',

          hasSelection
              ? Icons.check_circle_outline
              : Icons.auto_awesome_outlined,

          hasSelection
              ? const Color(
            0xFF16835D,
          )
              : const Color(
            0xFF3276C3,
          ),
        );

        return mobile
            ? Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,
          children: [
            title,
            const SizedBox(
              height: 12,
            ),
            status,
          ],
        )
            : Row(
          children: [
            Expanded(
              child: title,
            ),
            const SizedBox(
              width: 16,
            ),
            status,
          ],
        );
      },
    );
  }

  Widget _statusBanner(
      Map<String, dynamic>
      diagnostico,

      Map<String, dynamic>
      resumen,
      ) {
    final cobertura =
    _map(
      resumen[
      "cobertura_calculo"
      ],
    );

    final completa =
        cobertura["completa"] ==
            true;

    final fecha =
        diagnostico[
        "updated_at"
        ] ??
            diagnostico[
            "created_at"
            ];

    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        18,
      ),

      decoration:
      BoxDecoration(
        color:
        Global.container,

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border:
        Border.all(
          color:
          Global.text
              .withOpacity(
            .07,
          ),
        ),
      ),

      child: Wrap(
        spacing: 22,
        runSpacing: 14,
        alignment:
        WrapAlignment
            .spaceBetween,
        crossAxisAlignment:
        WrapCrossAlignment
            .center,
        children: [
          _statusInformation(
            icon:
            Icons
                .description_outlined,
            title:
            _text(
              diagnostico[
              "titulo"
              ],
              fallback:
              'Propuesta de optimización',
            ),
            subtitle:
            'Actualizada ${_date(fecha)}',
          ),

          _statusInformation(
            icon:
            completa
                ? Icons
                .verified_outlined
                : Icons
                .info_outline_rounded,
            title:
            completa
                ? 'Cálculo completo'
                : 'Cálculo con información disponible',
            subtitle:
            completa
                ? 'Todos los activos cuentan con métricas.'
                : 'Algunos indicadores pueden no estar disponibles.',
          ),
        ],
      ),
    );
  }

  Widget _metricsSection(
      Map<String, dynamic>
      resumen,

      int totalActivos,
      ) {
    final cantidad =
        _toInt(
          resumen["cantidad"],
        ) ??
            _toInt(
              resumen[
              "cantidad_activos"
              ],
            ) ??
            totalActivos;

    final metrics = [
      _MetricData(
        title:
        'Ahorro mensual',
        value:
        _currency(
          resumen[
          "ahorro_economico_mensual"
          ],
        ),
        icon:
        Icons.savings_outlined,
        color:
        const Color(
          0xFF16835D,
        ),
      ),
      _MetricData(
        title:
        'Inversión requerida',
        value:
        _currency(
          resumen[
          "inversion_total_requerida"
          ],
        ),
        icon:
        Icons
            .account_balance_wallet_outlined,
        color:
        const Color(
          0xFFE58A1F,
        ),
      ),
      _MetricData(
        title:
        'ROI a 5 años',
        value:
        _percentage(
          resumen["roi"],
        ),
        icon:
        Icons
            .trending_up_rounded,
        color:
        const Color(
          0xFF7756C9,
        ),
      ),
      _MetricData(
        title:
        'Retorno de inversión',
        value:
        _toDouble(
          resumen[
          "payback"
          ],
        ) ==
            null
            ? 'No disponible'
            : '${_toDouble(resumen["payback"])!.toStringAsFixed(1)} meses',
        icon:
        Icons.schedule_rounded,
        color:
        const Color(
          0xFF3276C3,
        ),
      ),
      _MetricData(
        title:
        'Energía reducida',
        value:
        _measurement(
          resumen[
          "reduccion_energia"
          ],
          'kWh',
        ),
        icon:
        Icons.bolt_rounded,
        color:
        const Color(
          0xFFD19B13,
        ),
      ),
      _MetricData(
        title:
        'Agua reducida',
        value:
        _measurement(
          resumen[
          "reduccion_agua"
          ],
          'm³',
        ),
        icon:
        Icons
            .water_drop_outlined,
        color:
        const Color(
          0xFF1597C5,
        ),
      ),
      _MetricData(
        title:
        'CO₂ evitado',
        value:
        _measurement(
          resumen[
          "reduccion_carbono"
          ],
          'kg',
        ),
        icon:
        Icons.eco_outlined,
        color:
        const Color(
          0xFF198B78,
        ),
      ),
      _MetricData(
        title:
        'Activos incluidos',
        value:
        '$cantidad',
        icon:
        Icons
            .inventory_2_outlined,
        color:
        Global.primary,
      ),
    ];

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon:
          Icons
              .analytics_outlined,
          title:
          'Beneficios estimados',
          subtitle:
          'Resultados calculados con la información técnica disponible.',
        ),

        const SizedBox(
          height: 14,
        ),

        LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final columns =
            constraints.maxWidth >=
                1050
                ? 4
                : constraints.maxWidth >=
                620
                ? 2
                : 1;

            const spacing =
            12.0;

            final cardWidth =
                (
                    constraints
                        .maxWidth -
                        spacing *
                            (
                                columns -
                                    1
                            )
                ) /
                    columns;

            return Wrap(
              spacing:
              spacing,
              runSpacing:
              spacing,
              children:
              metrics
                  .map(
                    (
                    metric,
                    ) =>
                    _metricCard(
                      width:
                      cardWidth,
                      data:
                      metric,
                    ),
              )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _analysisSection({
    required Map<String, dynamic>
    problema,

    required Map<String, dynamic>
    beneficios,
  }) {
    final problemaText =
        problema["resumen"] ??
            problema["descripcion"] ??
            problema["detalle"];

    final beneficioText =
        beneficios["resumen"] ??
            beneficios["descripcion"] ??
            beneficios["detalle"];

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon:
          Icons
              .auto_awesome_outlined,
          title:
          'Resumen del análisis',
          subtitle:
          'Principales hallazgos y oportunidades identificadas.',
        ),

        const SizedBox(
          height: 14,
        ),

        LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final desktop =
                constraints.maxWidth >=
                    760;

            final problem =
            _analysisCard(
              title:
              'Situación identificada',
              description:
              _text(
                problemaText,
                fallback:
                'No hay un resumen disponible.',
              ),
              icon:
              Icons
                  .search_rounded,
              color:
              const Color(
                0xFFE58A1F,
              ),
            );

            final benefits =
            _analysisCard(
              title:
              'Oportunidad de mejora',
              description:
              _text(
                beneficioText,
                fallback:
                'No hay beneficios descritos.',
              ),
              icon:
              Icons
                  .eco_outlined,
              color:
              const Color(
                0xFF16835D,
              ),
            );

            if (!desktop) {
              return Column(
                children: [
                  problem,
                  const SizedBox(
                    height: 12,
                  ),
                  benefits,
                ],
              );
            }

            return Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Expanded(
                  child:
                  problem,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child:
                  benefits,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _assetsSection({
    required List<
        Map<String, dynamic>>
    activos,

    required List<
        Map<String, dynamic>>
    alternativas,
  }) {
    if (activos.isEmpty) {
      return _surface(
        child: Padding(
          padding:
          const EdgeInsets
              .symmetric(
            vertical: 30,
          ),
          child: Center(
            child: Text(
              'No hay activos recomendados.',
              style:
              GoogleFonts.poppins(
                color:
                Global
                    .textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon:
          Icons
              .inventory_2_outlined,
          title:
          'Activos recomendados',
          subtitle:
          'Productos y proveedores asociados a la propuesta.',
        ),

        const SizedBox(
          height: 14,
        ),

        LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final columns =
            constraints.maxWidth >=
                1050
                ? 3
                : constraints.maxWidth >=
                680
                ? 2
                : 1;

            const spacing =
            14.0;

            final cardWidth =
                (
                    constraints
                        .maxWidth -
                        spacing *
                            (
                                columns -
                                    1
                            )
                ) /
                    columns;

            return Wrap(
              spacing:
              spacing,
              runSpacing:
              spacing,
              children:
              activos.map(
                    (
                    activo,
                    ) {
                  final idActivo =
                  _toInt(
                    activo[
                    "id_activo"
                    ],
                  );

                  Map<String, dynamic>
                  seleccionada =
                  {};

                  for (
                  final alternativa
                  in alternativas
                  ) {
                    if (
                    _toInt(
                      alternativa[
                      "id_activo"
                      ],
                    ) ==
                        idActivo
                    ) {
                      seleccionada =
                          alternativa;
                      break;
                    }
                  }

                  final recomendada =
                  _map(
                    activo[
                    "producto_recomendado"
                    ],
                  );

                  final producto =
                  seleccionada
                      .isNotEmpty
                      ? seleccionada
                      : recomendada;

                  return SizedBox(
                    width:
                    cardWidth,
                    child:
                    _assetCard(
                      activo:
                      activo,
                      producto:
                      producto,
                      selectedByUser:
                      seleccionada
                          .isNotEmpty,
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _assetCard({
    required Map<String, dynamic>
    activo,

    required Map<String, dynamic>
    producto,

    required bool
    selectedByUser,
  }) {
    final metricasProducto =
    _map(
      producto["metricas"],
    );

    final metricas =
    metricasProducto.isNotEmpty
        ? metricasProducto
        : _map(
      activo["metricas"],
    );

    final proveedor =
    _map(
      producto["proveedor"],
    );

    final fuente =
    producto["fuente"]
        ?.toString();

    final isAi =
        !selectedByUser ||
            fuente == 'ia';

    return _surface(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color:
                  Global.primary
                      .withOpacity(
                    .10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  Icons
                      .inventory_2_outlined,
                  color:
                  Global.primary,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      _text(
                        activo[
                        "nombre_activo"
                        ],
                        fallback:
                        'Activo',
                      ),
                      maxLines: 2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts
                          .poppins(
                        fontSize: 14,
                        fontWeight:
                        FontWeight
                            .w600,
                        color:
                        Global.text,
                      ),
                    ),
                    Text(
                      'Prioridad ${_text(activo["prioridad"], fallback: "No definida")}',
                      style:
                      GoogleFonts
                          .poppins(
                        fontSize: 10.5,
                        color:
                        Global
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          Container(
            width:
            double.infinity,
            padding:
            const EdgeInsets.all(
              13,
            ),
            decoration:
            BoxDecoration(
              color:
              Global.primary
                  .withOpacity(
                .06,
              ),
              borderRadius:
              BorderRadius.circular(
                13,
              ),
              border:
              Border.all(
                color:
                Global.primary
                    .withOpacity(
                  .15,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  isAi
                      ? 'Recomendación de la IA'
                      : 'Alternativa seleccionada',
                  style:
                  GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight:
                    FontWeight
                        .w600,
                    color:
                    Global.primary,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  _text(
                    producto[
                    "nombre"
                    ],
                    fallback:
                    'Producto no definido',
                  ),
                  maxLines: 2,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight:
                    FontWeight
                        .w600,
                    color:
                    Global.text,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  _text(
                    proveedor[
                    "nombre"
                    ] ??
                        producto[
                        "nombre_proveedor"
                        ],
                    fallback:
                    'Proveedor no informado',
                  ),
                  style:
                  GoogleFonts.poppins(
                    fontSize: 10.5,
                    color:
                    Global
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _assetMetric(
            'Inversión',
            _currency(
              metricas[
              "inversion_total_requerida"
              ] ??
                  producto[
                  "precio_base"
                  ],
            ),
          ),

          _assetMetric(
            'Ahorro mensual',
            _currency(
              metricas[
              "ahorro_economico_mensual"
              ],
            ),
          ),

          _assetMetric(
            'ROI a 5 años',
            _percentage(
              metricas[
              "roi_5_anios"
              ],
            ),
          ),

          _assetMetric(
            'Energía reducida',
            _measurement(
              metricas[
              "reduccion_energia"
              ],
              'kWh',
            ),
          ),

          _assetMetric(
            'CO₂ evitado',
            _measurement(
              metricas[
              "reduccion_carbono"
              ],
              'kg',
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          _calculationStatus(
            metricas,
          ),
        ],
      ),
    );
  }

  Widget _calculationStatus(
      Map<String, dynamic>
      metricas,
      ) {
    final calculable =
    _map(
      metricas["calculable"],
    );

    final complete =
        calculable["ahorro"] ==
            true;

    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        11,
      ),
      decoration:
      BoxDecoration(
        color:
        (
            complete
                ? const Color(
              0xFF16835D,
            )
                : const Color(
              0xFFE58A1F,
            )
        ).withOpacity(
          .08,
        ),
        borderRadius:
        BorderRadius.circular(
          11,
        ),
      ),
      child: Row(
        children: [
          Icon(
            complete
                ? Icons
                .verified_outlined
                : Icons
                .info_outline_rounded,
            size: 17,
            color:
            complete
                ? const Color(
              0xFF16835D,
            )
                : const Color(
              0xFFE58A1F,
            ),
          ),

          const SizedBox(
            width: 7,
          ),

          Expanded(
            child: Text(
              complete
                  ? 'Métricas calculadas con información disponible.'
                  : 'Algunas métricas no pudieron calcularse.',
              style:
              GoogleFonts.poppins(
                fontSize: 9.5,
                color:
                Global
                    .textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetMetric(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
              GoogleFonts.poppins(
                fontSize: 10.5,
                color:
                Global
                    .textSecondary,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            value,
            textAlign:
            TextAlign.right,
            style:
            GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight:
              FontWeight.w600,
              color:
              Global.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required double width,
    required _MetricData data,
  }) {
    return Container(
      width:
      width,
      constraints:
      const BoxConstraints(
        minHeight: 112,
      ),
      padding:
      const EdgeInsets.all(
        16,
      ),
      decoration:
      BoxDecoration(
        color:
        data.color
            .withOpacity(
          .065,
        ),
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        border:
        Border.all(
          color:
          data.color
              .withOpacity(
            .20,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
            BoxDecoration(
              color:
              data.color
                  .withOpacity(
                .13,
              ),
              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              data.icon,
              color:
              data.color,
              size: 22,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment
                  .center,
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  data.value,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight:
                    FontWeight
                        .w600,
                    color:
                    Global.text,
                  ),
                ),
                Text(
                  data.title,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 10,
                    color:
                    Global
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return _surface(
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
            BoxDecoration(
              color:
              color.withOpacity(
                .10,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color:
              color,
              size: 21,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  title,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight:
                    FontWeight
                        .w600,
                    color:
                    Global.text,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  description,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 10.5,
                    height: 1.5,
                    color:
                    Global
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration:
          BoxDecoration(
            color:
            Global.primary
                .withOpacity(
              .09,
            ),
            borderRadius:
            BorderRadius.circular(
              11,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
            Global.primary,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Text(
                title,
                style:
                GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Global.text,
                ),
              ),
              Text(
                subtitle,
                style:
                GoogleFonts.poppins(
                  fontSize: 10.5,
                  color:
                  Global
                      .textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusInformation({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color:
          Global.primary,
        ),
        const SizedBox(
          width: 8,
        ),
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
              GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight:
                FontWeight.w600,
                color:
                Global.text,
              ),
            ),
            Text(
              subtitle,
              style:
              GoogleFonts.poppins(
                fontSize: 9.5,
                color:
                Global
                    .textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(
      String text,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration:
      BoxDecoration(
        color:
        color.withOpacity(
          .09,
        ),
        borderRadius:
        BorderRadius.circular(
          30,
        ),
        border:
        Border.all(
          color:
          color.withOpacity(
            .22,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color:
            color,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            text,
            style:
            GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight:
              FontWeight.w600,
              color:
              color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _surface({
    required Widget child,
  }) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        17,
      ),
      decoration:
      BoxDecoration(
        color:
        Global.container,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        border:
        Border.all(
          color:
          Global.text
              .withOpacity(
            .07,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withOpacity(
              .035,
            ),
            blurRadius: 18,
            offset:
            const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child:
      child,
    );
  }

  Widget _loadingState() {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color:
            Global.primary,
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            'Consultando tu propuesta...',
            style:
            GoogleFonts.poppins(
              color:
              Global
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: ConstrainedBox(
        constraints:
        const BoxConstraints(
          maxWidth: 460,
        ),
        child: _surface(
          child: Padding(
            padding:
            const EdgeInsets
                .symmetric(
              vertical: 34,
            ),
            child: Column(
              children: [
                Icon(
                  Icons
                      .assessment_outlined,
                  size: 54,
                  color:
                  Global.primary
                      .withOpacity(
                    .65,
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Text(
                  'Tu propuesta aún no está disponible',
                  textAlign:
                  TextAlign.center,
                  style:
                  GoogleFonts
                      .poppins(
                    fontSize: 17,
                    fontWeight:
                    FontWeight
                        .w600,
                    color:
                    Global.text,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Cuando finalice el análisis de tus activos y consumos podrás consultarla aquí.',
                  textAlign:
                  TextAlign.center,
                  style:
                  GoogleFonts
                      .poppins(
                    fontSize: 11,
                    color:
                    Global
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: ConstrainedBox(
        constraints:
        const BoxConstraints(
          maxWidth: 460,
        ),
        child: _surface(
          child: Column(
            children: [
              const Icon(
                Icons
                    .error_outline_rounded,
                size: 48,
                color:
                Colors.redAccent,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                error ??
                    'No fue posible consultar la propuesta.',
                textAlign:
                TextAlign.center,
                style:
                GoogleFonts.poppins(
                  color:
                  Global.text,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              FilledButton.icon(
                onPressed:
                _loadProposal,
                icon:
                const Icon(
                  Icons
                      .refresh_rounded,
                ),
                label:
                const Text(
                  'Reintentar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}