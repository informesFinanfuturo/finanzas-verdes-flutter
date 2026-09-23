import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/models/api/diagnosticoApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Newdiagnosticoasesor extends StatefulWidget {
  const Newdiagnosticoasesor({super.key});

  @override
  State<Newdiagnosticoasesor> createState() => _NewdiagnosticoasesorState();
}

class _NewdiagnosticoasesorState
    extends State<Newdiagnosticoasesor> {

  bool loading = false;

  final ClientController clientController =
  Get.find<ClientController>();

  Map<String, dynamic> get _mipyme {
    final preview =
    clientController.Preview["mipyme"];

    if (preview is Map) {
      return Map<String, dynamic>.from(
        preview,
      );
    }

    final client =
    clientController.Client["mipyme"];

    if (client is Map) {
      return Map<String, dynamic>.from(
        client,
      );
    }

    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activos =
          clientController
              .activosVisible
              .value;

      final facturas =
          clientController
              .facturasVisible
              .value;

      return LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile =
              constraints.maxWidth < 720;

          final bool isDesktop =
              constraints.maxWidth >= 1050;

          return Padding(
            padding: EdgeInsets.all(
              isMobile ? 12 : 20,
            ),
            child: Column(
              children: [
                _buildHeader(
                  isMobile: isMobile,
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .onDrag,
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                        const BoxConstraints(
                          maxWidth: 1400,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            _buildIntroduction(),

                            const SizedBox(height: 16),

                            _buildSummary(
                              activosCount:
                              activos.length,
                              facturasCount:
                              facturas.length,
                              isMobile:
                              isMobile,
                            ),

                            const SizedBox(height: 18),

                            if (isDesktop)
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child:
                                    _buildCompanySection(),
                                  ),

                                  const SizedBox(
                                    width: 18,
                                  ),

                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      children: [
                                        _buildAssetsSection(
                                          activos,
                                        ),

                                        const SizedBox(
                                          height: 18,
                                        ),

                                        _buildInvoicesSection(
                                          facturas,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _buildCompanySection(),

                              const SizedBox(
                                height: 16,
                              ),

                              _buildAssetsSection(
                                activos,
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              _buildInvoicesSection(
                                facturas,
                              ),
                            ],

                            SizedBox(
                              height:
                              isMobile ? 100 : 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildHeader({
    required bool isMobile,
  }) {
    final title = Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Preparar diagnóstico',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 19 : 23,
            fontWeight: FontWeight.w600,
            color: Global.text,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          'Revisa la información que será analizada por la IA.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Global.textSecondary,
          ),
        ),
      ],
    );

    final backButton = Material(
      color: Global.container,
      borderRadius:
      BorderRadius.circular(12),
      child: InkWell(
        onTap:
        loading
            ? null
            : controller.backPage,
        borderRadius:
        BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_rounded,
            color: Global.text,
          ),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              backButton,

              const SizedBox(width: 12),

              Expanded(
                child: title,
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child:
            _buildGenerateButton(),
          ),
        ],
      );
    }

    return Row(
      children: [
        backButton,

        const SizedBox(width: 14),

        Expanded(
          child: title,
        ),

        const SizedBox(width: 16),

        _buildGenerateButton(),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed:
      loading
          ? null
          : _generateDiagnostic,
      icon:
      loading
          ? const SizedBox(
        width: 18,
        height: 18,
        child:
        CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : const Icon(
        Icons.auto_awesome_rounded,
        size: 19,
      ),
      label: Text(
        loading
            ? 'Analizando información...'
            : 'Generar diagnóstico',
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
        Global.primary,
        foregroundColor:
        Colors.white,
        disabledBackgroundColor:
        Global.primary.withOpacity(0.55),
        disabledForegroundColor:
        Colors.white,
        elevation: 0,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        Global.primary.withOpacity(
          controller.isDark.value
              ? 0.12
              : 0.06,
        ),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color:
          Global.primary.withOpacity(
            0.16,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
              Global.primary.withOpacity(
                0.14,
              ),
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.tips_and_updates_outlined,
              color: Global.primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Información que analizará la IA',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight:
                    FontWeight.w600,
                    color: Global.text,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Verifica los datos antes de continuar. Puedes excluir activos o facturas que no deban formar parte del diagnóstico.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    height: 1.5,
                    color:
                    Global.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary({
    required int activosCount,
    required int facturasCount,
    required bool isMobile,
  }) {
    final cards = [
      _SummaryData(
        title: 'Empresa',
        value:
        _displayValue(
          _mipyme["nombre_mipyme"],
        ),
        icon:
        Icons.business_outlined,
        color:
        Global.primary,
      ),
      _SummaryData(
        title: 'Activos incluidos',
        value:
        '$activosCount',
        icon:
        Icons.inventory_2_outlined,
        color:
        Colors.orange,
      ),
      _SummaryData(
        title: 'Facturas incluidas',
        value:
        '$facturasCount',
        icon:
        Icons.receipt_long_outlined,
        color:
        Colors.blue,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;

        final columns =
        isMobile ? 1 : 3;

        final itemWidth =
            (
                constraints.maxWidth -
                    (spacing * (columns - 1))
            ) /
                columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (item) => SizedBox(
              width: itemWidth,
              child:
              _buildSummaryCard(
                item,
              ),
            ),
          )
              .toList(),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      _SummaryData item,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.07,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
              item.color.withOpacity(
                0.11,
              ),
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: item.color,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color:
                    Global.textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  item.value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w600,
                    color: Global.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySection() {
    final fields = [
      _InfoData(
        'Nombre',
        _mipyme["nombre_mipyme"],
        Icons.business_outlined,
      ),
      _InfoData(
        'NIT',
        _mipyme["nit"],
        Icons.badge_outlined,
      ),
      _InfoData(
        'Tipo de persona',
        _mipyme["tipo_persona"],
        Icons.person_outline_rounded,
      ),
      _InfoData(
        'Sector económico',
        _mipyme["sector_economico"],
        Icons.category_outlined,
      ),
      _InfoData(
        'Código CIIU',
        _mipyme["codigo_ciiu"],
        Icons.account_tree_outlined,
      ),
      _InfoData(
        'Cantidad de empleados',
        _mipyme["cantidad_empleados"],
        Icons.groups_outlined,
      ),
      _InfoData(
        'Departamento',
        _mipyme["departamento"],
        Icons.map_outlined,
      ),
      _InfoData(
        'Municipio',
        _mipyme["municipio"],
        Icons.location_city_outlined,
      ),
      _InfoData(
        'Barrio',
        _mipyme["barrio"],
        Icons.place_outlined,
      ),
      _InfoData(
        'Dirección',
        _mipyme["direccion"],
        Icons.signpost_outlined,
      ),
      _InfoData(
        'Estrato',
        _mipyme["estrato"],
        Icons.layers_outlined,
      ),
    ];

    return _SectionCard(
      title:
      'Información de la empresa',
      subtitle:
      'Datos generales incluidos en el análisis.',
      icon:
      Icons.apartment_rounded,
      iconColor:
      Global.primary,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final columns =
              constraints.maxWidth >=
                  650
                  ? 2
                  : 1;

              const spacing = 10.0;

              final width =
                  (
                      constraints.maxWidth -
                          spacing *
                              (columns - 1)
                  ) /
                      columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: fields
                    .map(
                      (field) =>
                      SizedBox(
                        width: width,
                        child:
                        _buildInfoItem(
                          field,
                        ),
                      ),
                )
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 10),

          _buildDescriptionItem(
            label:
            'Descripción de la empresa',
            value:
            _mipyme[
            "descripcion_empresa"],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      _InfoData item,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
        Global.absolute.withOpacity(
          controller.isDark.value
              ? 0.38
              : 0.65,
        ),
        borderRadius:
        BorderRadius.circular(11),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.055,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 17,
            color: Global.primary,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight:
                    FontWeight.w500,
                    color:
                    Global.textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _displayValue(
                    item.value,
                  ),
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight:
                    FontWeight.w500,
                    color: Global.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem({
    required String label,
    dynamic value,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color:
        Global.absolute.withOpacity(
          controller.isDark.value
              ? 0.38
              : 0.65,
        ),
        borderRadius:
        BorderRadius.circular(11),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.055,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight:
              FontWeight.w500,
              color:
              Global.textSecondary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _displayValue(value),
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              height: 1.5,
              color: Global.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsSection(
      List activos,
      ) {
    return _SectionCard(
      title: 'Activos',
      subtitle:
      '${activos.length} elementos incluidos en el diagnóstico.',
      icon:
      Icons.inventory_2_outlined,
      iconColor:
      Colors.orange,
      child:
      activos.isEmpty
          ? _buildEmptyState(
        icon:
        Icons.inventory_2_outlined,
        title:
        'No hay activos incluidos',
        description:
        'El diagnóstico se realizará sin información de activos.',
      )
          : _buildResponsiveCards(
        activos.asMap().entries
            .map(
              (entry) =>
              _buildAssetCard(
                index:
                entry.key,
                activo:
                entry.value,
              ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildAssetCard({
    required int index,
    required dynamic activo,
  }) {
    final nombre =
    _displayValue(
      activo["nombre"],
      fallback: 'Activo sin nombre',
    );

    final tipo =
    _displayValue(
      activo["tipo"],
    );

    final observaciones =
    _displayValue(
      activo["observaciones"],
      fallback: '',
    );

    return _SelectionCard(
      icon:
      _assetIcon(tipo),
      accentColor:
      Colors.orange,
      title:
      nombre,
      badge:
      tipo,
      description:
      observaciones,
      onRemove: () {
        clientController
            .removeActivo(index);
      },
    );
  }

  Widget _buildInvoicesSection(
      List facturas,
      ) {
    return _SectionCard(
      title: 'Facturas y consumos',
      subtitle:
      '${facturas.length} registros incluidos en el diagnóstico.',
      icon:
      Icons.receipt_long_outlined,
      iconColor:
      Colors.blue,
      child:
      facturas.isEmpty
          ? _buildEmptyState(
        icon:
        Icons.receipt_long_outlined,
        title:
        'No hay facturas incluidas',
        description:
        'El diagnóstico se realizará sin información de consumo histórico.',
      )
          : _buildResponsiveCards(
        facturas.asMap().entries
            .map(
              (entry) =>
              _buildInvoiceCard(
                index:
                entry.key,
                factura:
                entry.value,
              ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildInvoiceCard({
    required int index,
    required dynamic factura,
  }) {
    final tipo =
    _displayValue(
      factura["tipo"] ??
          factura["tipo_servicio"],
      fallback: 'Servicio',
    );

    final consumo =
    _displayValue(
      factura["consumo"],
    );

    final unidad =
    _displayValue(
      factura["unidad_medida"],
      fallback: '',
    );

    final periodo =
    _formatPeriod(factura);

    final details = <String>[
      if (consumo != 'No registrado')
        'Consumo: $consumo${unidad.isEmpty ? '' : ' $unidad'}',
      if (periodo.isNotEmpty)
        'Periodo: $periodo',
    ].join('  •  ');

    return _SelectionCard(
      icon:
      _serviceIcon(tipo),
      accentColor:
      Colors.blue,
      title:
      tipo,
      badge:
      'Factura',
      description:
      details,
      onRemove: () {
        clientController
            .removeFactura(index);
      },
    );
  }

  Widget _buildResponsiveCards(
      List<Widget> cards,
      ) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        const spacing = 10.0;

        final columns =
        constraints.maxWidth >= 720
            ? 2
            : 1;

        final width =
            (
                constraints.maxWidth -
                    spacing * (columns - 1)
            ) /
                columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
              width: width,
              child: card,
            ),
          )
              .toList(),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color:
        Global.absolute.withOpacity(
          controller.isDark.value
              ? 0.30
              : 0.55,
        ),
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.06,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
            color:
            Global.textSecondary,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign:
            TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight:
              FontWeight.w600,
              color: Global.text,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            description,
            textAlign:
            TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              height: 1.45,
              color:
              Global.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void>
  _generateDiagnostic() async {
    if (loading) return;

    final idMipyme =
    _mipyme["id_mipyme"];

    if (idMipyme == null) {
      Get.snackbar(
        'No fue posible continuar',
        'No se encontró la empresa asociada al diagnóstico.',
        snackPosition:
        SnackPosition.BOTTOM,
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response =
      await generarYSyncDiagnosticosApi(
        idMipyme: idMipyme,
        empresa: _mipyme,
        activos:
        clientController
            .activosVisible
            .value,
        facturas:
        clientController
            .facturasVisible
            .value,
        diagnosticos:
        clientController
            .Preview[
        "diagnosticos"] ??
            [],
      );

      final user =
      clientController.Client["user"];

      final idUsuario =
      user is Map
          ? user["id_usuario"]
          : null;

      if (idUsuario != null) {
        clientController.setClient(
          await getClientDetailApi(
            idUsuario:
            idUsuario,
          ),
        );
      }

      if (
      response["diagnostico"] !=
          null &&
          mounted
      ) {
        controller.backPage();
      }
    } catch (error) {
      Get.snackbar(
        'No se pudo generar el diagnóstico',
        'Verifica la conexión e inténtalo nuevamente.',
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  String _displayValue(
      dynamic value, {
        String fallback =
        'No registrado',
      }) {
    final text =
        value?.toString().trim() ??
            '';

    if (
    text.isEmpty ||
        text.toLowerCase() ==
            'null'
    ) {
      return fallback;
    }

    return text;
  }

  String _formatPeriod(
      dynamic factura,
      ) {
    final inicio =
    _displayValue(
      factura["periodo_inicio"],
      fallback: '',
    );

    final fin =
    _displayValue(
      factura["periodo_fin"],
      fallback: '',
    );

    if (
    inicio.isEmpty &&
        fin.isEmpty
    ) {
      return '';
    }

    if (inicio.isEmpty) {
      return fin;
    }

    if (fin.isEmpty) {
      return inicio;
    }

    return '$inicio – $fin';
  }

  IconData _assetIcon(
      String type,
      ) {
    final value =
    type.toLowerCase();

    if (
    value.contains('nevera') ||
        value.contains('refrig')
    ) {
      return Icons.kitchen_outlined;
    }

    if (
    value.contains('horno')
    ) {
      return Icons.microwave_outlined;
    }

    if (
    value.contains('clima') ||
        value.contains('aire')
    ) {
      return Icons.ac_unit_rounded;
    }

    if (
    value.contains('ilum') ||
        value.contains('bombillo')
    ) {
      return Icons.lightbulb_outline;
    }

    if (
    value.contains('comput')
    ) {
      return Icons.computer_outlined;
    }

    if (
    value.contains('motor')
    ) {
      return Icons.settings_outlined;
    }

    return Icons.inventory_2_outlined;
  }

  IconData _serviceIcon(
      String type,
      ) {
    final value =
    type.toLowerCase();

    if (
    value.contains('agua')
    ) {
      return Icons.water_drop_outlined;
    }

    if (
    value.contains('energ') ||
        value.contains('luz')
    ) {
      return Icons.bolt_outlined;
    }

    if (
    value.contains('gas')
    ) {
      return Icons.local_fire_department_outlined;
    }

    return Icons.receipt_long_outlined;
  }
}

class _SummaryData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _InfoData {
  final String label;
  final dynamic value;
  final IconData icon;

  const _InfoData(
      this.label,
      this.value,
      this.icon,
      );
}

class _SectionCard
    extends StatelessWidget {

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.07,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              controller.isDark.value
                  ? 0.12
                  : 0.035,
            ),
            blurRadius: 22,
            offset:
            const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                BoxDecoration(
                  color:
                  iconColor.withOpacity(
                    0.11,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

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
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,
                        color: Global.text,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: Global
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Divider(
            height: 1,
            color:
            Global.text.withOpacity(
              0.07,
            ),
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }
}

class _SelectionCard
    extends StatelessWidget {

  final IconData icon;
  final Color accentColor;
  final String title;
  final String badge;
  final String description;
  final VoidCallback onRemove;

  const _SelectionCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.badge,
    required this.description,
    required this.onRemove,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color:
        Global.absolute.withOpacity(
          controller.isDark.value
              ? 0.36
              : 0.64,
        ),
        borderRadius:
        BorderRadius.circular(13),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.06,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                BoxDecoration(
                  color:
                  accentColor.withOpacity(
                    0.11,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: accentColor,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w600,
                        color: Global.text,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        accentColor
                            .withOpacity(
                          0.09,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),
                      child: Text(
                        badge,
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight:
                          FontWeight.w500,
                          color:
                          accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              Tooltip(
                message:
                'Excluir del diagnóstico',
                child: IconButton(
                  onPressed:
                  onRemove,
                  visualDensity:
                  VisualDensity.compact,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                  ),
                  color:
                  Colors.redAccent,
                  style:
                  IconButton.styleFrom(
                    backgroundColor:
                    Colors.redAccent
                        .withOpacity(
                      0.08,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (
          description.trim().isNotEmpty
          ) ...[
            const SizedBox(height: 10),

            Text(
              description,
              maxLines: 3,
              overflow:
              TextOverflow.ellipsis,
              style:
              GoogleFonts.poppins(
                fontSize: 10.5,
                height: 1.45,
                color:
                Global.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}