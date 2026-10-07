import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/clienteRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Homecliente extends StatefulWidget {
  const Homecliente({
    super.key,
  });

  @override
  State<Homecliente> createState() =>
      _HomeclienteState();
}

class _HomeclienteState
    extends State<Homecliente> {
  final ClientController clientController = Get.put(ClientController());

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      /*
       * La información empresarial es la
       * fuente principal del dashboard.
       */
      await getClienteMipymeApi(
        idUsuario:
        controller.User[
        "id_usuario"
        ],
        clientController:
        clientController,
      );

      /*
       * Las demás consultas son independientes.
       * Si una sección todavía no tiene datos,
       * el inicio puede seguir mostrándose.
       */
      await Future.wait<void>([
        getActivosByUsuarioApi(
          idUsuario:
          controller.User[
          "id_usuario"
          ],
          clientController:
          clientController,
        ).catchError(
              (_) {},
        ),

        getConsumosByUsuarioApi(
          idUsuario:
          controller.User[
          "id_usuario"
          ],
          clientController:
          clientController,
        ).catchError(
              (_) {},
        ),

        getDiagnosticosByUsuario(
          clientController:
          clientController,
        ).catchError(
              (_) {},
        ),

        getPlanesTrabajoByUsuario(
          clientController:
          clientController,
        ).catchError(
              (_) {},
        ),
      ]);
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

  int _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  String _text(
      dynamic value, {
        String fallback =
        'No registrado',
      }) {
    final text =
        value?.toString().trim() ?? '';

    return text.isEmpty
        ? fallback
        : text;
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
    final number =
    _toDouble(value);

    if (number == null) {
      return 'No disponible';
    }

    return '${number.toStringAsFixed(1)}%';
  }

  String _measurement(
      dynamic value,
      String unit,
      ) {
    final number =
    _toDouble(value);

    if (number == null) {
      return 'No disponible';
    }

    return '${number.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Obx(() {
      final _ =
          controller.isDark.value;

      if (loading) {
        return _loadingState();
      }

      if (error != null) {
        return _errorState();
      }

      return RefreshIndicator(
        color:
        Global.primary,
        onRefresh:
        _loadDashboard,

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

              child:
              _dashboardContent(),
            ),
          ),
        ),
      );
    });
  }

  Widget _dashboardContent() {
    final empresa =
    Map<String, dynamic>.from(
      clientController.InfoCliente,
    );

    final activos =
    List<dynamic>.from(
      clientController.Activos,
    );

    final consumos =
    List<dynamic>.from(
      clientController.Consumos,
    );

    final diagnostico =
    Map<String, dynamic>.from(
      clientController.Diagnostico,
    );

    final planes =
    _maps(
      clientController
          .PlanesTrabajo,
    );

    final metricas =
    _map(
      diagnostico["metricas"],
    );

    final resumenGuardado =
    _map(
      metricas[
      "resumen_seleccionado"
      ],
    );

    final resumen =
    resumenGuardado.isNotEmpty
        ? resumenGuardado
        : metricas;

    final etapas =
    _buildProcessSteps(
      empresa:
      empresa,

      activos:
      activos,

      consumos:
      consumos,

      diagnostico:
      diagnostico,

      planes:
      planes,
    );

    final nextStep =
    _getNextStep(
      empresa:
      empresa,

      activos:
      activos,

      consumos:
      consumos,

      diagnostico:
      diagnostico,

      planes:
      planes,
    );

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _welcomeHeader(
          empresa,
        ),

        const SizedBox(
          height: 18,
        ),

        _nextStepCard(
          nextStep,
        ),

        const SizedBox(
          height: 22,
        ),

        _processSection(
          etapas,
        ),

        const SizedBox(
          height: 22,
        ),

        if (diagnostico.isNotEmpty) ...[
          _proposalSummary(
            resumen,
          ),

          const SizedBox(
            height: 22,
          ),
        ],

        _plansSection(
          planes,
        ),

        const SizedBox(
          height: 22,
        ),

        _companySection(
          empresa,
        ),
      ],
    );
  }

  Widget _welcomeHeader(
      Map<String, dynamic> empresa,
      ) {
    final userName =
    _text(
      controller.User[
      "nombre_usuario"
      ],
      fallback: 'Cliente',
    );

    final companyName =
    _text(
      empresa[
      "nombre_mipyme"
      ],
      fallback:
      'Tu empresa',
    );

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final mobile =
            constraints.maxWidth <
                700;

        return Container(
          width:
          double.infinity,

          padding:
          EdgeInsets.all(
            mobile ? 18 : 24,
          ),

          decoration:
          BoxDecoration(
            color:
            Global.container,

            borderRadius:
            BorderRadius.circular(
              22,
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
                blurRadius: 22,
                offset:
                const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),

          child:
          mobile
              ? Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children:
            _welcomeChildren(
              userName:
              userName,
              companyName:
              companyName,
              empresa:
              empresa,
            ),
          )
              : Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children:
                  _welcomeChildren(
                    userName:
                    userName,
                    companyName:
                    companyName,
                    empresa:
                    empresa,
                  ),
                ),
              ),

              const SizedBox(
                width: 20,
              ),

              Container(
                width: 74,
                height: 74,
                decoration:
                BoxDecoration(
                  color:
                  Global.primary
                      .withOpacity(
                    .10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    22,
                  ),
                ),
                child: Icon(
                  Icons
                      .business_rounded,
                  size: 35,
                  color:
                  Global.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _welcomeChildren({
    required String userName,
    required String companyName,
    required Map<String, dynamic>
    empresa,
  }) {
    final municipality =
    _text(
      empresa["municipio"],
      fallback:
      'Municipio no registrado',
    );

    final sector =
    _text(
      empresa[
      "sector_economico"
      ],
      fallback:
      'Sector no registrado',
    );

    return [
      Text(
        'Hola, $userName',
        style:
        GoogleFonts.poppins(
          fontSize: 12,
          color:
          Global.textSecondary,
        ),
      ),

      const SizedBox(
        height: 3,
      ),

      Text(
        companyName,
        maxLines: 2,
        overflow:
        TextOverflow.ellipsis,
        style:
        GoogleFonts.poppins(
          fontSize: 23,
          fontWeight:
          FontWeight.w600,
          color:
          Global.text,
        ),
      ),

      const SizedBox(
        height: 8,
      ),

      Text(
        'Este es el estado actual de tu proceso de Finanzas Verdes.',
        style:
        GoogleFonts.poppins(
          fontSize: 11.5,
          color:
          Global.textSecondary,
        ),
      ),

      const SizedBox(
        height: 14,
      ),

      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _informationChip(
            icon:
            Icons
                .location_on_outlined,
            text:
            municipality,
          ),

          _informationChip(
            icon:
            Icons
                .category_outlined,
            text:
            sector,
          ),
        ],
      ),
    ];
  }

  Widget _nextStepCard(
      _NextStep nextStep,
      ) {
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
        nextStep.color
            .withOpacity(
          .075,
        ),

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border:
        Border.all(
          color:
          nextStep.color
              .withOpacity(
            .22,
          ),
        ),
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
            BoxDecoration(
              color:
              nextStep.color
                  .withOpacity(
                .14,
              ),
              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              nextStep.icon,
              color:
              nextStep.color,
              size: 22,
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
                  nextStep.title,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    Global.text,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  nextStep.description,
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

          if (nextStep.route != null)
            IconButton(
              tooltip:
              'Consultar',
              onPressed: () {
                controller.setPage(
                  nextStep.route!,
                );
              },
              icon: Icon(
                Icons
                    .arrow_forward_rounded,
                color:
                nextStep.color,
              ),
            ),
        ],
      ),
    );
  }

  Widget _processSection(
      List<_ProcessStep> steps,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          icon:
          Icons
              .route_outlined,
          title:
          'Estado del proceso',
          subtitle:
          'Consulta el avance general de tu acompañamiento.',
        ),

        const SizedBox(
          height: 14,
        ),

        Container(
          width:
          double.infinity,

          padding:
          const EdgeInsets.all(
            17,
          ),

          decoration:
          _surfaceDecoration(),

          child:
          LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final columns =
              constraints.maxWidth >=
                  1000
                  ? 6
                  : constraints.maxWidth >=
                  650
                  ? 3
                  : 2;

              const spacing =
              10.0;

              final width =
                  (
                      constraints.maxWidth -
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
                steps
                    .map(
                      (
                      step,
                      ) =>
                      SizedBox(
                        width:
                        width,
                        child:
                        _processStepCard(
                          step,
                        ),
                      ),
                )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _processStepCard(
      _ProcessStep step,
      ) {
    final completed =
        step.completed;

    return Container(
      height: 106,
      padding:
      const EdgeInsets.all(
        12,
      ),

      decoration:
      BoxDecoration(
        color:
        completed
            ? Global.primary
            .withOpacity(
          .075,
        )
            : Global.text
            .withOpacity(
          .025,
        ),

        borderRadius:
        BorderRadius.circular(
          14,
        ),

        border:
        Border.all(
          color:
          completed
              ? Global.primary
              .withOpacity(
            .22,
          )
              : Global.text
              .withOpacity(
            .08,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                step.icon,
                size: 20,
                color:
                completed
                    ? Global.primary
                    : Global
                    .textSecondary,
              ),

              const Spacer(),

              Icon(
                completed
                    ? Icons
                    .check_circle_rounded
                    : Icons
                    .radio_button_unchecked_rounded,
                size: 18,
                color:
                completed
                    ? Global.primary
                    : Global
                    .textSecondary,
              ),
            ],
          ),

          const Spacer(),

          Text(
            step.name,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style:
            GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight:
              completed
                  ? FontWeight.w600
                  : FontWeight.w400,
              color:
              completed
                  ? Global.text
                  : Global
                  .textSecondary,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            completed
                ? 'Completado'
                : 'Pendiente',
            style:
            GoogleFonts.poppins(
              fontSize: 8.5,
              color:
              completed
                  ? Global.primary
                  : Global
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _proposalSummary(
      Map<String, dynamic> resumen,
      ) {
    final metrics = [
      _HomeMetric(
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
      _HomeMetric(
        title:
        'Inversión',
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
      _HomeMetric(
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
      _HomeMetric(
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
    ];

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionHeader(
                icon:
                Icons
                    .assessment_outlined,
                title:
                'Resumen de tu propuesta',
                subtitle:
                'Beneficios estimados con la información disponible.',
              ),
            ),

            TextButton.icon(
              onPressed: () {
                controller.setPage(
                  ClienteRoutes
                      .diagnosticos,
                );
              },
              icon:
              const Icon(
                Icons
                    .arrow_forward_rounded,
                size: 18,
              ),
              label:
              const Text(
                'Ver propuesta',
              ),
            ),
          ],
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
                900
                ? 4
                : constraints.maxWidth >=
                580
                ? 2
                : 1;

            const spacing =
            12.0;

            final width =
                (
                    constraints.maxWidth -
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
                    SizedBox(
                      width:
                      width,
                      child:
                      _homeMetricCard(
                        metric,
                      ),
                    ),
              )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _plansSection(
      List<Map<String, dynamic>>
      planes,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          icon:
          Icons
              .task_alt_rounded,
          title:
          'Plan de trabajo',
          subtitle:
          'Seguimiento consultivo de las acciones definidas.',
        ),

        const SizedBox(
          height: 14,
        ),

        if (planes.isEmpty)
          _surface(
            child: Padding(
              padding:
              const EdgeInsets
                  .symmetric(
                vertical: 28,
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons
                          .assignment_outlined,
                      size: 42,
                      color:
                      Global
                          .textSecondary,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      'Todavía no hay un plan de trabajo registrado.',
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
          )
        else
          LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final columns =
              constraints.maxWidth >=
                  900
                  ? 2
                  : 1;

              const spacing =
              12.0;

              final width =
                  (
                      constraints.maxWidth -
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
                planes
                    .take(4)
                    .map(
                      (
                      plan,
                      ) =>
                      SizedBox(
                        width:
                        width,
                        child:
                        _planCard(
                          plan,
                        ),
                      ),
                )
                    .toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _planCard(
      Map<String, dynamic> plan,
      ) {
    final percentage =
    (_toDouble(
      plan[
      "porcentaje_completado"
      ],
    ) ??
        0)
        .clamp(
      0,
      100,
    )
        .toDouble();

    final total =
    _toInt(
      plan[
      "total_tareas"
      ],
    );

    final completed =
    _toInt(
      plan[
      "tareas_completadas"
      ],
    );

    return _surface(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration:
                BoxDecoration(
                  color:
                  Global.primary
                      .withOpacity(
                    .09,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  Icons
                      .assignment_outlined,
                  color:
                  Global.primary,
                  size: 20,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Text(
                  _text(
                    plan[
                    "nombre_plan_trabajo"
                    ],
                    fallback:
                    'Plan de trabajo',
                  ),
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    Global.text,
                  ),
                ),
              ),

              Text(
                '${percentage.toStringAsFixed(0)}%',
                style:
                GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Global.primary,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              10,
            ),
            child:
            LinearProgressIndicator(
              value:
              percentage /
                  100,
              minHeight:
              7,
              backgroundColor:
              Global.text
                  .withOpacity(
                .07,
              ),
              valueColor:
              AlwaysStoppedAnimation(
                Global.primary,
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            '$completed de $total tareas completadas',
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
    );
  }

  Widget _companySection(
      Map<String, dynamic> empresa,
      ) {
    final fields = [
      _CompanyField(
        label:
        'NIT',
        value:
        _text(
          empresa["nit"],
        ),
      ),
      _CompanyField(
        label:
        'Municipio',
        value:
        _text(
          empresa["municipio"],
        ),
      ),
      _CompanyField(
        label:
        'Sector',
        value:
        _text(
          empresa[
          "sector_economico"
          ],
        ),
      ),
      _CompanyField(
        label:
        'Empleados',
        value:
        _text(
          empresa[
          "cantidad_empleados"
          ],
        ),
      ),
      _CompanyField(
        label:
        'Código CIIU',
        value:
        _text(
          empresa[
          "codigo_ciiu"
          ],
        ),
      ),
      _CompanyField(
        label:
        'Dirección',
        value:
        _text(
          empresa["direccion"],
        ),
      ),
    ];

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          icon:
          Icons
              .business_outlined,
          title:
          'Mi empresa',
          subtitle:
          'Información registrada en el proceso.',
        ),

        const SizedBox(
          height: 14,
        ),

        _surface(
          child:
          LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final columns =
              constraints.maxWidth >=
                  850
                  ? 3
                  : constraints.maxWidth >=
                  520
                  ? 2
                  : 1;

              const spacing =
              14.0;

              final width =
                  (
                      constraints.maxWidth -
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
                14,
                children:
                fields
                    .map(
                      (
                      field,
                      ) =>
                      SizedBox(
                        width:
                        width,
                        child:
                        _companyField(
                          field,
                        ),
                      ),
                )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  List<_ProcessStep> _buildProcessSteps({
    required Map<String, dynamic>
    empresa,

    required List<dynamic>
    activos,

    required List<dynamic>
    consumos,

    required Map<String, dynamic>
    diagnostico,

    required List<Map<String, dynamic>>
    planes,
  }) {
    final metricas =
    _map(
      diagnostico["metricas"],
    );

    final hasProposal =
        diagnostico.isNotEmpty &&
            (
                _maps(
                  metricas["activos"],
                ).isNotEmpty
            );

    return [
      _ProcessStep(
        name:
        'Información',
        icon:
        Icons
            .business_outlined,
        completed:
        empresa.isNotEmpty,
      ),
      _ProcessStep(
        name:
        'Activos',
        icon:
        Icons
            .inventory_2_outlined,
        completed:
        activos.isNotEmpty,
      ),
      _ProcessStep(
        name:
        'Facturas',
        icon:
        Icons
            .receipt_long_outlined,
        completed:
        consumos.isNotEmpty,
      ),
      _ProcessStep(
        name:
        'Diagnóstico',
        icon:
        Icons
            .analytics_outlined,
        completed:
        diagnostico.isNotEmpty,
      ),
      _ProcessStep(
        name:
        'Propuesta',
        icon:
        Icons
            .assessment_outlined,
        completed:
        hasProposal,
      ),
      _ProcessStep(
        name:
        'Plan de trabajo',
        icon:
        Icons
            .task_alt_outlined,
        completed:
        planes.isNotEmpty,
      ),
    ];
  }

  _NextStep _getNextStep({
    required Map<String, dynamic>
    empresa,

    required List<dynamic>
    activos,

    required List<dynamic>
    consumos,

    required Map<String, dynamic>
    diagnostico,

    required List<Map<String, dynamic>>
    planes,
  }) {
    if (empresa.isEmpty) {
      return const _NextStep(
        title:
        'Información empresarial pendiente',
        description:
        'El asesor continúa recopilando la información necesaria para iniciar tu proceso.',
        icon:
        Icons
            .business_outlined,
        color:
        Color(
          0xFFE58A1F,
        ),
      );
    }

    if (activos.isEmpty) {
      return _NextStep(
        title:
        'Registro de activos en proceso',
        description:
        'Aún no se encuentran activos registrados para el análisis.',
        icon:
        Icons
            .inventory_2_outlined,
        color:
        const Color(
          0xFFE58A1F,
        ),
        route:
        ClienteRoutes.activos,
      );
    }

    if (consumos.isEmpty) {
      return _NextStep(
        title:
        'Facturas pendientes de análisis',
        description:
        'Todavía no se encuentran facturas disponibles para calcular consumos y costos.',
        icon:
        Icons
            .receipt_long_outlined,
        color:
        const Color(
          0xFFE58A1F,
        ),
        route:
        ClienteRoutes.consumos,
      );
    }

    if (diagnostico.isEmpty) {
      return const _NextStep(
        title:
        'Diagnóstico en preparación',
        description:
        'Tu información ya está registrada y será analizada por el asesor.',
        icon:
        Icons
            .analytics_outlined,
        color:
        Color(
          0xFF3276C3,
        ),
      );
    }

    if (planes.isEmpty) {
      return _NextStep(
        title:
        'Tu propuesta está disponible',
        description:
        'Consulta los activos recomendados y los beneficios estimados del análisis.',
        icon:
        Icons
            .assessment_outlined,
        color:
        const Color(
          0xFF16835D,
        ),
        route:
        ClienteRoutes
            .diagnosticos,
      );
    }

    return const _NextStep(
      title:
      'Acompañamiento en progreso',
      description:
      'Ya tienes un plan de trabajo registrado. Consulta su avance y las tareas definidas.',
      icon:
      Icons.task_alt_rounded,
      color:
      Color(
        0xFF16835D,
      ),
    );
  }

  Widget _homeMetricCard(
      _HomeMetric metric,
      ) {
    return Container(
      constraints:
      const BoxConstraints(
        minHeight: 108,
      ),

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(
        color:
        metric.color
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
          metric.color
              .withOpacity(
            .18,
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
              metric.color
                  .withOpacity(
                .13,
              ),
              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              metric.icon,
              color:
              metric.color,
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
                  metric.value,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
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
                  metric.title,
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
          ),
        ],
      ),
    );
  }

  Widget _companyField(
      _CompanyField field,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style:
          GoogleFonts.poppins(
            fontSize: 9.5,
            color:
            Global
                .textSecondary,
          ),
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          field.value,
          maxLines: 2,
          overflow:
          TextOverflow.ellipsis,
          style:
          GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight:
            FontWeight.w500,
            color:
            Global.text,
          ),
        ),
      ],
    );
  }

  Widget _informationChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),

      decoration:
      BoxDecoration(
        color:
        Global.text
            .withOpacity(
          .04,
        ),

        borderRadius:
        BorderRadius.circular(
          30,
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

      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color:
            Global.primary,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,
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
    );
  }

  Widget _sectionHeader({
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

  BoxDecoration _surfaceDecoration() {
    return BoxDecoration(
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
      _surfaceDecoration(),

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
            'Consultando tu proceso...',
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

  Widget _errorState() {
    return Center(
      child: ConstrainedBox(
        constraints:
        const BoxConstraints(
          maxWidth: 450,
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
                    'No fue posible consultar el proceso.',
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
                _loadDashboard,
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

class _ProcessStep {
  final String name;
  final IconData icon;
  final bool completed;

  const _ProcessStep({
    required this.name,
    required this.icon,
    required this.completed,
  });
}

class _NextStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? route;

  const _NextStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.route,
  });
}

class _HomeMetric {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HomeMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _CompanyField {
  final String label;
  final String value;

  const _CompanyField({
    required this.label,
    required this.value,
  });
}