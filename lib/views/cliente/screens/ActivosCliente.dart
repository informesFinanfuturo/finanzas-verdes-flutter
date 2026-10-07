import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Activoscliente extends StatefulWidget {
  const Activoscliente({
    super.key,
  });

  @override
  State<Activoscliente> createState() =>
      _ActivosclienteState();
}

class _ActivosclienteState
    extends State<Activoscliente> {
  final ClientController clientController =
  Get.find<ClientController>();

  final TextEditingController searchController =
  TextEditingController();

  bool loading = true;
  String? error;
  String selectedFilter = 'Todos';

  final filters = const [
    'Todos',
    'Con recomendación',
    'Sin recomendación',
    'Prioridad alta',
  ];

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      await Future.wait<void>([
        getActivosByUsuarioApi(
          idUsuario:
          controller.User[
          "id_usuario"
          ],
          clientController:
          clientController,
        ),

        getDiagnosticosByUsuario(
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

  Map<String, dynamic> _findDiagnosticAsset(
      Map<String, dynamic> asset,
      ) {
    final diagnosis =
    Map<String, dynamic>.from(
      clientController.Diagnostico,
    );

    final metrics =
    _map(
      diagnosis["metricas"],
    );

    final diagnosticAssets =
    _maps(
      metrics["activos"],
    );

    final assetId =
    _toInt(
      asset["id_activo"],
    );

    for (
    final diagnosticAsset
    in diagnosticAssets
    ) {
      if (
      _toInt(
        diagnosticAsset[
        "id_activo"
        ],
      ) ==
          assetId
      ) {
        return diagnosticAsset;
      }
    }

    return {};
  }

  Map<String, dynamic> _findSelectedAlternative(
      Map<String, dynamic> asset,
      ) {
    final diagnosis =
    Map<String, dynamic>.from(
      clientController.Diagnostico,
    );

    final metrics =
    _map(
      diagnosis["metricas"],
    );

    final alternatives =
    _maps(
      metrics[
      "alternativas_seleccionadas"
      ],
    );

    final assetId =
    _toInt(
      asset["id_activo"],
    );

    for (
    final alternative
    in alternatives
    ) {
      if (
      _toInt(
        alternative[
        "id_activo"
        ],
      ) ==
          assetId
      ) {
        return alternative;
      }
    }

    return {};
  }

  Map<String, dynamic> _getProduct(
      Map<String, dynamic> asset,
      ) {
    final selected =
    _findSelectedAlternative(
      asset,
    );

    if (selected.isNotEmpty) {
      return selected;
    }

    final diagnosticAsset =
    _findDiagnosticAsset(
      asset,
    );

    return _map(
      diagnosticAsset[
      "producto_recomendado"
      ],
    );
  }

  bool _isIncluded(
      Map<String, dynamic> asset,
      ) {
    final diagnosis =
    Map<String, dynamic>.from(
      clientController.Diagnostico,
    );

    final metrics =
    _map(
      diagnosis["metricas"],
    );

    final selectedIds =
    List<dynamic>.from(
      metrics[
      "activos_seleccionados"
      ] ??
          [],
    );

    final assetId =
    _toInt(
      asset["id_activo"],
    );

    return selectedIds.any(
          (id) =>
      _toInt(id) ==
          assetId,
    );
  }

  List<Map<String, dynamic>>
  _filteredAssets(
      List<Map<String, dynamic>> assets,
      ) {
    final query =
    searchController.text
        .trim()
        .toLowerCase();

    return assets.where(
          (asset) {
        final diagnosticAsset =
        _findDiagnosticAsset(
          asset,
        );

        final product =
        _getProduct(
          asset,
        );

        final priority =
        _text(
          diagnosticAsset[
          "prioridad"
          ],
          fallback: '',
        ).toLowerCase();

        final searchableText = [
          asset["nombre"],
          asset["tipo"],
          asset["marca"],
          asset["modelo"],
          asset["descripcion"],
          product["nombre"],
        ]
            .where(
              (value) =>
          value != null,
        )
            .map(
              (value) =>
              value
                  .toString()
                  .toLowerCase(),
        )
            .join(' ');

        final matchesSearch =
            query.isEmpty ||
                searchableText.contains(
                  query,
                );

        bool matchesFilter = true;

        switch (selectedFilter) {
          case 'Con recomendación':
            matchesFilter =
                product.isNotEmpty;
            break;

          case 'Sin recomendación':
            matchesFilter =
                product.isEmpty;
            break;

          case 'Prioridad alta':
            matchesFilter =
                priority == 'alta';
            break;
        }

        return matchesSearch &&
            matchesFilter;
      },
    ).toList();
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

      final assets =
      _maps(
        clientController.Activos,
      );

      final filtered =
      _filteredAssets(
        assets,
      );

      return RefreshIndicator(
        color:
        Global.primary,

        onRefresh:
        _loadData,

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

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _header(),

                  const SizedBox(
                    height: 18,
                  ),

                  _summary(
                    assets,
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  _filters(),

                  const SizedBox(
                    height: 18,
                  ),

                  if (assets.isEmpty)
                    _emptyState()
                  else if (filtered.isEmpty)
                    _noResultsState()
                  else
                    _assetsGrid(
                      filtered,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _header() {
    return Row(
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
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Mis activos',
                style:
                GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Global.text,
                ),
              ),

              Text(
                'Consulta los equipos registrados y su relación con la propuesta.',
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

  Widget _summary(
      List<Map<String, dynamic>> assets,
      ) {
    int analyzed = 0;
    int recommended = 0;
    int included = 0;

    for (final asset in assets) {
      if (
      _findDiagnosticAsset(
        asset,
      ).isNotEmpty
      ) {
        analyzed++;
      }

      if (
      _getProduct(
        asset,
      ).isNotEmpty
      ) {
        recommended++;
      }

      if (_isIncluded(asset)) {
        included++;
      }
    }

    final summary = [
      _SummaryData(
        label:
        'Registrados',
        value:
        assets.length.toString(),
        icon:
        Icons
            .inventory_2_outlined,
        color:
        const Color(
          0xFF3276C3,
        ),
      ),
      _SummaryData(
        label:
        'Analizados',
        value:
        analyzed.toString(),
        icon:
        Icons
            .analytics_outlined,
        color:
        const Color(
          0xFF7756C9,
        ),
      ),
      _SummaryData(
        label:
        'Con recomendación',
        value:
        recommended.toString(),
        icon:
        Icons
            .auto_awesome_outlined,
        color:
        const Color(
          0xFFE58A1F,
        ),
      ),
      _SummaryData(
        label:
        'Incluidos',
        value:
        included.toString(),
        icon:
        Icons
            .check_circle_outline,
        color:
        const Color(
          0xFF16835D,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final columns =
        constraints.maxWidth >=
            850
            ? 4
            : constraints.maxWidth >=
            520
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
          summary
              .map(
                (
                item,
                ) =>
                SizedBox(
                  width:
                  width,
                  child:
                  _summaryCard(
                    item,
                  ),
                ),
          )
              .toList(),
        );
      },
    );
  }

  Widget _summaryCard(
      _SummaryData data,
      ) {
    return Container(
      constraints:
      const BoxConstraints(
        minHeight: 94,
      ),

      padding:
      const EdgeInsets.all(
        15,
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
          16,
        ),

        border:
        Border.all(
          color:
          data.color
              .withOpacity(
            .18,
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
            BoxDecoration(
              color:
              data.color
                  .withOpacity(
                .14,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              data.icon,
              color:
              data.color,
              size: 21,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    Global.text,
                  ),
                ),

                Text(
                  data.label,
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

  Widget _filters() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        14,
      ),

      decoration:
      _surfaceDecoration(),

      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final mobile =
              constraints.maxWidth <
                  650;

          final search =
          TextField(
            controller:
            searchController,

            onChanged: (_) {
              setState(() {});
            },

            style:
            GoogleFonts.poppins(
              fontSize: 11.5,
              color:
              Global.text,
            ),

            decoration:
            InputDecoration(
              hintText:
              'Buscar activo, tipo, marca o modelo',

              hintStyle:
              GoogleFonts.poppins(
                fontSize: 10.5,
                color:
                Global
                    .textSecondary,
              ),

              prefixIcon:
              Icon(
                Icons.search_rounded,
                color:
                Global
                    .textSecondary,
              ),

              suffixIcon:
              searchController
                  .text
                  .isEmpty
                  ? null
                  : IconButton(
                onPressed: () {
                  searchController
                      .clear();

                  setState(
                        () {},
                  );
                },
                icon:
                const Icon(
                  Icons
                      .close_rounded,
                ),
              ),

              filled:
              true,

              fillColor:
              Global.text
                  .withOpacity(
                .035,
              ),

              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  13,
                ),
                borderSide:
                BorderSide.none,
              ),

              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  13,
                ),
                borderSide:
                BorderSide(
                  color:
                  Global.text
                      .withOpacity(
                    .08,
                  ),
                ),
              ),

              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  13,
                ),
                borderSide:
                BorderSide(
                  color:
                  Global.primary,
                ),
              ),
            ),
          );

          final filter =
          DropdownButtonFormField<String>(
            value:
            selectedFilter,

            isExpanded:
            true,

            items:
            filters
                .map(
                  (
                  item,
                  ) =>
                  DropdownMenuItem(
                    value:
                    item,
                    child:
                    Text(
                      item,
                      style:
                      GoogleFonts
                          .poppins(
                        fontSize:
                        11,
                      ),
                    ),
                  ),
            )
                .toList(),

            onChanged:
                (value) {
              if (value == null) {
                return;
              }

              setState(() {
                selectedFilter =
                    value;
              });
            },

            decoration:
            InputDecoration(
              labelText:
              'Estado',

              prefixIcon:
              Icon(
                Icons
                    .filter_alt_outlined,
                color:
                Global
                    .textSecondary,
              ),

              filled:
              true,

              fillColor:
              Global.text
                  .withOpacity(
                .035,
              ),

              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  13,
                ),
                borderSide:
                BorderSide.none,
              ),

              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  13,
                ),
                borderSide:
                BorderSide(
                  color:
                  Global.text
                      .withOpacity(
                    .08,
                  ),
                ),
              ),
            ),
          );

          if (mobile) {
            return Column(
              children: [
                search,

                const SizedBox(
                  height: 10,
                ),

                filter,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 3,
                child:
                search,
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                flex: 2,
                child:
                filter,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _assetsGrid(
      List<Map<String, dynamic>> assets,
      ) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final columns =
        constraints.maxWidth >=
            1100
            ? 3
            : constraints.maxWidth >=
            700
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
          spacing,
          children:
          assets
              .map(
                (
                asset,
                ) =>
                SizedBox(
                  width:
                  width,
                  child:
                  _assetCard(
                    asset,
                  ),
                ),
          )
              .toList(),
        );
      },
    );
  }

  Widget _assetCard(
      Map<String, dynamic> asset,
      ) {
    final diagnosticAsset =
    _findDiagnosticAsset(
      asset,
    );

    final selectedAlternative =
    _findSelectedAlternative(
      asset,
    );

    final product =
    selectedAlternative.isNotEmpty
        ? selectedAlternative
        : _map(
      diagnosticAsset[
      "producto_recomendado"
      ],
    );

    final provider =
    _map(
      product["proveedor"],
    );

    final metrics =
    _map(
      product["metricas"],
    ).isNotEmpty
        ? _map(
      product["metricas"],
    )
        : _map(
      diagnosticAsset[
      "metricas"
      ],
    );

    final included =
    _isIncluded(
      asset,
    );

    final analyzed =
        diagnosticAsset.isNotEmpty;

    final recommended =
        product.isNotEmpty;

    final status = included
        ? 'Incluido en propuesta'
        : recommended
        ? 'Reemplazo recomendado'
        : analyzed
        ? 'Analizado'
        : 'Registrado';

    final statusColor = included
        ? const Color(
      0xFF16835D,
    )
        : recommended
        ? const Color(
      0xFFE58A1F,
    )
        : analyzed
        ? const Color(
      0xFF7756C9,
    )
        : const Color(
      0xFF3276C3,
    );

    return Container(
      padding:
      const EdgeInsets.all(
        17,
      ),

      decoration:
      _surfaceDecoration(),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
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
                  _assetIcon(
                    asset["tipo"],
                  ),
                  color:
                  Global.primary,
                  size: 22,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(
                        asset["nombre"],
                        fallback:
                        'Activo',
                      ),
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        Global.text,
                      ),
                    ),

                    Text(
                      _text(
                        asset["tipo"],
                        fallback:
                        'Tipo no definido',
                      ),
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

              const SizedBox(
                width: 8,
              ),

              _statusChip(
                status,
                statusColor,
              ),
            ],
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
                    .branding_watermark_outlined,
                text:
                _text(
                  asset["marca"],
                  fallback:
                  'Marca no identificada',
                ),
              ),

              _informationChip(
                icon:
                Icons
                    .memory_outlined,
                text:
                _text(
                  asset["modelo"],
                  fallback:
                  'Modelo no identificado',
                ),
              ),

              _informationChip(
                icon:
                Icons
                    .tag_outlined,
                text:
                'Cantidad: ${_text(asset["cantidad"], fallback: "1")}',
              ),
            ],
          ),

          if (
          diagnosticAsset.isNotEmpty
          ) ...[
            const SizedBox(
              height: 13,
            ),

            Row(
              children: [
                Expanded(
                  child:
                  _smallInformation(
                    label:
                    'Prioridad',
                    value:
                    _text(
                      diagnosticAsset[
                      "prioridad"
                      ],
                      fallback:
                      'No definida',
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                  _smallInformation(
                    label:
                    'Confianza',
                    value:
                    _text(
                      _map(
                        diagnosticAsset[
                        "confianza"
                        ],
                      )["nivel"],
                      fallback:
                      'No definida',
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (product.isNotEmpty) ...[
            const SizedBox(
              height: 15,
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
                  .055,
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
                    .14,
                  ),
                ),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAlternative
                        .isNotEmpty
                        ? 'Alternativa seleccionada'
                        : 'Recomendación de la IA',
                    style:
                    GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      Global.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    _text(
                      product["nombre"],
                      fallback:
                      'Producto no definido',
                    ),
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      Global.text,
                    ),
                  ),

                  Text(
                    _text(
                      provider["nombre"],
                      fallback:
                      'Proveedor no informado',
                    ),
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    GoogleFonts.poppins(
                      fontSize: 9.5,
                      color:
                      Global
                          .textSecondary,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _proposalMetric(
                    'Inversión',
                    _currency(
                      metrics[
                      "inversion_total_requerida"
                      ] ??
                          product[
                          "precio_base"
                          ],
                    ),
                  ),

                  _proposalMetric(
                    'Ahorro mensual',
                    _currency(
                      metrics[
                      "ahorro_economico_mensual"
                      ],
                    ),
                  ),

                  _proposalMetric(
                    'Energía reducida',
                    _measurement(
                      metrics[
                      "reduccion_energia"
                      ],
                      'kWh',
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(
            height: 14,
          ),

          SizedBox(
            width:
            double.infinity,

            child:
            OutlinedButton.icon(
              onPressed: () {
                _showAssetDetail(
                  asset:
                  asset,

                  diagnosticAsset:
                  diagnosticAsset,

                  product:
                  product,

                  metrics:
                  metrics,
                );
              },

              icon:
              const Icon(
                Icons
                    .visibility_outlined,
                size: 18,
              ),

              label:
              const Text(
                'Ver detalle',
              ),

              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                Global.primary,

                side:
                BorderSide(
                  color:
                  Global.primary
                      .withOpacity(
                    .25,
                  ),
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssetDetail({
    required Map<String, dynamic>
    asset,

    required Map<String, dynamic>
    diagnosticAsset,

    required Map<String, dynamic>
    product,

    required Map<String, dynamic>
    metrics,
  }) {
    final technicalData =
    _map(
      asset["datos"],
    );

    final observation =
        asset[
        "observacion_ia"
        ] ??
            diagnosticAsset[
            "observacion"
            ] ??
            diagnosticAsset[
            "descripcion"
            ];

    showDialog<void>(
      context:
      context,

      builder:
          (dialogContext) {
        final size =
        MediaQuery.sizeOf(
          dialogContext,
        );

        final mobile =
            size.width <
                650;

        return Dialog(
          insetPadding:
          EdgeInsets.symmetric(
            horizontal:
            mobile ? 12 : 40,
            vertical:
            mobile ? 18 : 36,
          ),

          backgroundColor:
          Colors.transparent,

          child: Container(
            width:
            mobile
                ? size.width
                : 720,

            constraints:
            BoxConstraints(
              maxHeight:
              size.height *
                  .88,
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
                  .08,
                ),
              ),
            ),

            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration:
                        BoxDecoration(
                          color:
                          Global.primary
                              .withOpacity(
                            .10,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Icon(
                          _assetIcon(
                            asset["tipo"],
                          ),
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
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              _text(
                                asset["nombre"],
                                fallback:
                                'Activo',
                              ),
                              style:
                              GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w600,
                                color:
                                Global.text,
                              ),
                            ),

                            Text(
                              'Detalle consultivo del activo',
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

                      IconButton(
                        onPressed: () {
                          Navigator.of(
                            dialogContext,
                          ).pop();
                        },
                        icon:
                        const Icon(
                          Icons
                              .close_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color:
                  Global.text
                      .withOpacity(
                    .08,
                  ),
                ),

                Flexible(
                  child:
                  SingleChildScrollView(
                    padding:
                    const EdgeInsets.all(
                      18,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _detailTitle(
                          'Información registrada',
                        ),

                        _detailRow(
                          'Tipo',
                          _text(
                            asset["tipo"],
                          ),
                        ),

                        _detailRow(
                          'Marca',
                          _text(
                            asset["marca"],
                          ),
                        ),

                        _detailRow(
                          'Modelo',
                          _text(
                            asset["modelo"],
                          ),
                        ),

                        _detailRow(
                          'Cantidad',
                          _text(
                            asset["cantidad"],
                            fallback: '1',
                          ),
                        ),

                        if (
                        technicalData
                            .isNotEmpty
                        ) ...[
                          const SizedBox(
                            height: 16,
                          ),

                          _detailTitle(
                            'Datos técnicos',
                          ),

                          ...technicalData
                              .entries
                              .map(
                                (
                                entry,
                                ) =>
                                _detailRow(
                                  _formatKey(
                                    entry.key,
                                  ),
                                  _text(
                                    entry.value,
                                  ),
                                ),
                          ),
                        ],

                        if (
                        observation !=
                            null
                        ) ...[
                          const SizedBox(
                            height: 16,
                          ),

                          _detailTitle(
                            'Observación del análisis',
                          ),

                          Text(
                            observation
                                .toString(),
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

                        if (
                        product.isNotEmpty
                        ) ...[
                          const SizedBox(
                            height: 16,
                          ),

                          _detailTitle(
                            'Alternativa propuesta',
                          ),

                          _detailRow(
                            'Producto',
                            _text(
                              product["nombre"],
                            ),
                          ),

                          _detailRow(
                            'Inversión',
                            _currency(
                              metrics[
                              "inversion_total_requerida"
                              ] ??
                                  product[
                                  "precio_base"
                                  ],
                            ),
                          ),

                          _detailRow(
                            'Consumo proyectado',
                            _measurement(
                              metrics[
                              "consumo_energia_proyectado_mes"
                              ],
                              'kWh/mes',
                            ),
                          ),

                          _detailRow(
                            'Ahorro mensual',
                            _currency(
                              metrics[
                              "ahorro_economico_mensual"
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _proposalMetric(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 5,
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
              GoogleFonts.poppins(
                fontSize: 9.5,
                color:
                Global
                    .textSecondary,
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            value,
            textAlign:
            TextAlign.right,
            style:
            GoogleFonts.poppins(
              fontSize: 9.5,
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

  Widget _smallInformation({
    required String label,
    required String value,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(
        10,
      ),

      decoration:
      BoxDecoration(
        color:
        Global.text
            .withOpacity(
          .03,
        ),

        borderRadius:
        BorderRadius.circular(
          11,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
            GoogleFonts.poppins(
              fontSize: 8.5,
              color:
              Global
                  .textSecondary,
            ),
          ),

          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            GoogleFonts.poppins(
              fontSize: 10,
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

  Widget _informationChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
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
          30,
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

      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color:
            Global
                .textSecondary,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,
            style:
            GoogleFonts.poppins(
              fontSize: 8.8,
              color:
              Global
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
      String status,
      Color color,
      ) {
    return Container(
      constraints:
      const BoxConstraints(
        maxWidth: 120,
      ),

      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
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
      ),

      child: Text(
        status,
        maxLines: 2,
        textAlign:
        TextAlign.center,
        overflow:
        TextOverflow.ellipsis,
        style:
        GoogleFonts.poppins(
          fontSize: 8,
          fontWeight:
          FontWeight.w600,
          color:
          color,
        ),
      ),
    );
  }

  Widget _detailTitle(
      String title,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 8,
      ),

      child: Text(
        title,
        style:
        GoogleFonts.poppins(
          fontSize: 12,
          fontWeight:
          FontWeight.w600,
          color:
          Global.text,
        ),
      ),
    );
  }

  Widget _detailRow(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 5,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style:
              GoogleFonts.poppins(
                fontSize: 10,
                color:
                Global
                    .textSecondary,
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              value,
              style:
              GoogleFonts.poppins(
                fontSize: 10,
                fontWeight:
                FontWeight.w500,
                color:
                Global.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(
      String key,
      ) {
    if (key.isEmpty) {
      return key;
    }

    final formatted =
    key
        .replaceAll('_', ' ')
        .trim();

    if (formatted.isEmpty) {
      return formatted;
    }

    return formatted[0]
        .toUpperCase() +
        formatted.substring(1);
  }

  IconData _assetIcon(
      dynamic type,
      ) {
    final value =
        type
            ?.toString()
            .toLowerCase() ??
            '';

    if (
    value.contains('nevera') ||
        value.contains('refrig')
    ) {
      return Icons.kitchen_outlined;
    }

    if (
    value.contains('climat') ||
        value.contains('aire')
    ) {
      return Icons.ac_unit_rounded;
    }

    if (
    value.contains('ilumin')
    ) {
      return Icons.lightbulb_outline;
    }

    if (
    value.contains('horno')
    ) {
      return Icons.microwave_outlined;
    }

    if (
    value.contains('televisor')
    ) {
      return Icons.tv_outlined;
    }

    if (
    value.contains('lavadora')
    ) {
      return Icons.local_laundry_service_outlined;
    }

    if (
    value.contains('sanitario') ||
        value.contains('grifo')
    ) {
      return Icons.water_drop_outlined;
    }

    return Icons.inventory_2_outlined;
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
            'Consultando activos...',
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
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          const Icon(
            Icons
                .error_outline_rounded,
            color:
            Colors.redAccent,
            size: 48,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            error ??
                'No fue posible consultar los activos.',
            textAlign:
            TextAlign.center,
          ),

          const SizedBox(
            height: 12,
          ),

          FilledButton.icon(
            onPressed:
            _loadData,
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
    );
  }

  Widget _emptyState() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 20,
      ),

      decoration:
      _surfaceDecoration(),

      child: Column(
        children: [
          Icon(
            Icons
                .inventory_2_outlined,
            size: 54,
            color:
            Global.primary
                .withOpacity(
              .6,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          Text(
            'No hay activos registrados',
            style:
            GoogleFonts.poppins(
              fontSize: 16,
              fontWeight:
              FontWeight.w600,
              color:
              Global.text,
            ),
          ),

          Text(
            'Cuando el asesor registre los activos podrás consultarlos aquí.',
            textAlign:
            TextAlign.center,
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
    );
  }

  Widget _noResultsState() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.symmetric(
        vertical: 40,
      ),

      decoration:
      _surfaceDecoration(),

      child: Center(
        child: Text(
          'No hay activos que coincidan con los filtros.',
          style:
          GoogleFonts.poppins(
            color:
            Global
                .textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SummaryData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}