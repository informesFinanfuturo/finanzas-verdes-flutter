import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Consumoscliente extends StatefulWidget {
  const Consumoscliente({super.key});

  @override
  State<Consumoscliente> createState() =>
      _ConsumosclienteState();
}

class _ConsumosclienteState
    extends State<Consumoscliente> {
  final ClientController clientController =
  Get.find<ClientController>();

  bool _loading = true;
  String _search = '';
  String _selectedType = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadConsumos();
  }

  Future<void> _loadConsumos() async {
    setState(() {
      _loading = true;
    });

    try {
      await getConsumosByUsuarioApi(
        idUsuario:
        controller.User["id_usuario"],
        clientController: clientController,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    final normalized = value
        .toString()
        .replaceAll(',', '.')
        .replaceAll(
      RegExp(r'[^0-9.\-]'),
      '',
    );

    return double.tryParse(normalized);
  }

  String _normalize(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  DateTime? _toDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  String _formatDate(dynamic value) {
    final date = _toDate(value);

    if (date == null) {
      return 'No disponible';
    }

    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String _formatPeriod(
      Map<String, dynamic> consumo,
      ) {
    final start =
    consumo["periodo_inicio"];
    final end =
    consumo["periodo_fin"];

    if (start == null && end == null) {
      final legacyPeriod =
      consumo["periodo"];

      return legacyPeriod?.toString() ??
          'Periodo no disponible';
    }

    if (start != null && end != null) {
      return '${_formatDate(start)} - '
          '${_formatDate(end)}';
    }

    return _formatDate(
      start ?? end,
    );
  }

  String _formatNumber(
      dynamic value, {
        int decimals = 1,
      }) {
    final number = _toDouble(value);

    if (number == null) {
      return 'No disponible';
    }

    final isInteger =
        number == number.roundToDouble();

    final formatted = number.toStringAsFixed(
      isInteger ? 0 : decimals,
    );

    final parts = formatted.split('.');
    final integerPart = parts.first;

    final grouped = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
    );

    if (parts.length == 1) {
      return grouped;
    }

    return '$grouped,${parts.last}';
  }

  String _formatCurrency(dynamic value) {
    final number = _toDouble(value);

    if (number == null) {
      return 'No disponible';
    }

    return '\$ ${_formatNumber(
      number,
      decimals: 0,
    )}';
  }

  String _formatConsumption(
      Map<String, dynamic> consumo,
      ) {
    final value =
    consumo["consumo"];
    final unit =
    (consumo["unidad"] ?? '')
        .toString()
        .trim();

    if (_toDouble(value) == null) {
      return 'No disponible';
    }

    return '${_formatNumber(value)}'
        '${unit.isEmpty ? '' : ' $unit'}';
  }

  IconData _iconForType(String type) {
    final normalized =
    type.toLowerCase();

    if (normalized.contains('agua')) {
      return Icons.water_drop_outlined;
    }

    if (normalized.contains('gas')) {
      return Icons.local_fire_department_outlined;
    }

    if (normalized.contains('energ') ||
        normalized.contains('luz') ||
        normalized.contains('electric')) {
      return Icons.bolt_outlined;
    }

    return Icons.receipt_long_outlined;
  }

  Color _colorForType(String type) {
    final normalized =
    type.toLowerCase();

    if (normalized.contains('agua')) {
      return const Color(0xFF1597C4);
    }

    if (normalized.contains('gas')) {
      return const Color(0xFFE88725);
    }

    if (normalized.contains('energ') ||
        normalized.contains('luz') ||
        normalized.contains('electric')) {
      return const Color(0xFFE3A008);
    }

    return Global.primary;
  }

  List<String> _getTypes(
      List<Map<String, dynamic>> consumos,
      ) {
    final types = consumos
        .map(
          (item) =>
          (item["tipo"] ??
              'Sin categoría')
              .toString()
              .trim(),
    )
        .where(
          (type) => type.isNotEmpty,
    )
        .toSet()
        .toList();

    types.sort();

    return [
      'Todos',
      ...types,
    ];
  }

  List<Map<String, dynamic>>
  _getFilteredConsumptions(
      List<Map<String, dynamic>> consumos,
      ) {
    final query =
    _search.trim().toLowerCase();

    final result = consumos.where(
          (consumo) {
        final type = _normalize(
          consumo["tipo"],
        );

        final provider = _normalize(
          consumo["proveedor"],
        );

        final period = _normalize(
          _formatPeriod(consumo),
        );

        final value = _normalize(
          consumo["valor"],
        );

        final matchesType =
            _selectedType == 'Todos' ||
                type ==
                    _selectedType
                        .toLowerCase();

        final matchesSearch =
            query.isEmpty ||
                type.contains(query) ||
                provider.contains(query) ||
                period.contains(query) ||
                value.contains(query);

        return matchesType &&
            matchesSearch;
      },
    ).toList();

    result.sort(
          (a, b) {
        final dateA = _toDate(
          a["periodo_fin"],
        ) ??
            _toDate(
              a["periodo_inicio"],
            ) ??
            DateTime(1900);

        final dateB = _toDate(
          b["periodo_fin"],
        ) ??
            _toDate(
              b["periodo_inicio"],
            ) ??
            DateTime(1900);

        return dateB.compareTo(dateA);
      },
    );

    return result;
  }

  Map<String, List<Map<String, dynamic>>>
  _groupByType(
      List<Map<String, dynamic>> consumos,
      ) {
    final groups =
    <String,
        List<Map<String, dynamic>>>{};

    for (final consumo in consumos) {
      final type =
      (consumo["tipo"] ??
          'Sin categoría')
          .toString()
          .trim();

      final key = type.isEmpty
          ? 'Sin categoría'
          : type;

      groups.putIfAbsent(
        key,
            () => [],
      );

      groups[key]!.add(consumo);
    }

    return groups;
  }

  double _sumValues(
      List<Map<String, dynamic>> consumos,
      ) {
    return consumos.fold<double>(
      0,
          (sum, item) =>
      sum +
          (_toDouble(
            item["valor"],
          ) ??
              0),
    );
  }

  Map<String, dynamic>? _latestConsumption(
      List<Map<String, dynamic>> consumos,
      ) {
    if (consumos.isEmpty) {
      return null;
    }

    final sorted =
    List<Map<String, dynamic>>.from(
      consumos,
    );

    sorted.sort(
          (a, b) {
        final dateA = _toDate(
          a["periodo_fin"],
        ) ??
            _toDate(
              a["periodo_inicio"],
            ) ??
            DateTime(1900);

        final dateB = _toDate(
          b["periodo_fin"],
        ) ??
            _toDate(
              b["periodo_inicio"],
            ) ??
            DateTime(1900);

        return dateB.compareTo(dateA);
      },
    );

    return sorted.first;
  }

  double? _percentageVariation(
      dynamic currentValue,
      dynamic previousValue,
      ) {
    final current =
    _toDouble(currentValue);
    final previous =
    _toDouble(previousValue);

    if (current == null ||
        previous == null ||
        previous == 0) {
      return null;
    }

    return ((current - previous) /
        previous) *
        100;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () {
        final _ =
            controller.isDark.value;

        final consumos =
        clientController.Consumos
            .map<Map<String, dynamic>>(
              (item) =>
          Map<String, dynamic>.from(
            item,
          ),
        )
            .toList();

        final types =
        _getTypes(consumos);

        final filtered =
        _getFilteredConsumptions(
          consumos,
        );

        final groups =
        _groupByType(filtered);

        if (_loading) {
          return Center(
            child: CircularProgressIndicator(
              color: Global.primary,
            ),
          );
        }

        return LayoutBuilder(
          builder:
              (context, constraints) {
            final isDesktop =
                constraints.maxWidth >=
                    950;

            return RefreshIndicator(
              onRefresh: _loadConsumos,
              color: Global.primary,
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
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      consumos.length,
                    ),
                    const SizedBox(height: 20),
                    if (consumos.isNotEmpty) ...[
                      _buildSummary(
                        consumos,
                        isDesktop,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildFilters(types),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                    if (consumos.isEmpty)
                      _buildEmptyState()
                    else if (filtered.isEmpty)
                      _buildSearchEmptyState()
                    else
                      ...groups.entries.map(
                            (entry) =>
                            _buildConsumptionGroup(
                              title: entry.key,
                              consumos:
                              entry.value,
                              isDesktop:
                              isDesktop,
                            ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(int total) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color:
            Global.primary.withOpacity(
              0.12,
            ),
            borderRadius:
            BorderRadius.circular(13),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: Global.primary,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Facturas y consumos',
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w600,
                  color: Global.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                total == 1
                    ? '1 factura registrada para consulta'
                    : '$total facturas registradas para consulta',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color:
                  Global.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(
      List<Map<String, dynamic>> consumos,
      bool isDesktop,
      ) {
    final types = consumos
        .map(
          (item) =>
          (item["tipo"] ?? '')
              .toString()
              .trim(),
    )
        .where(
          (value) => value.isNotEmpty,
    )
        .toSet();

    final latest =
    _latestConsumption(consumos);

    final cardWidth = isDesktop
        ? 250.0
        : double.infinity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.08,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de facturación',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight:
              FontWeight.w600,
              color: Global.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Información consolidada de las facturas registradas.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color:
              Global.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _summaryCard(
                width: cardWidth,
                icon:
                Icons.receipt_outlined,
                title:
                'Facturas registradas',
                value:
                consumos.length.toString(),
                color: Global.primary,
              ),
              _summaryCard(
                width: cardWidth,
                icon:
                Icons.category_outlined,
                title:
                'Servicios monitoreados',
                value:
                types.length.toString(),
                color:
                const Color(0xFF3976D3),
              ),
              _summaryCard(
                width: cardWidth,
                icon:
                Icons.payments_outlined,
                title:
                'Valor acumulado registrado',
                value: _formatCurrency(
                  _sumValues(consumos),
                ),
                color:
                const Color(0xFFE88725),
              ),
              _summaryCard(
                width: cardWidth,
                icon:
                Icons.calendar_today_outlined,
                title:
                'Último periodo registrado',
                value: latest == null
                    ? 'No disponible'
                    : _formatPeriod(
                  latest,
                ),
                color:
                const Color(0xFF1597C4),
                compactValue: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required double width,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool compactValue = false,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        constraints:
        const BoxConstraints(
          minHeight: 105,
        ),
        padding:
        const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(
            0.08,
          ),
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(
              0.18,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(
                  0.13,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines:
                    compactValue ? 2 : 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    GoogleFonts.poppins(
                      fontSize:
                      compactValue
                          ? 13
                          : 17,
                      fontWeight:
                      FontWeight.w600,
                      color: Global.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    GoogleFonts.poppins(
                      fontSize: 10,
                      color: Global
                          .textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(
      List<String> types,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _search = value;
            });
          },
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: Global.text,
          ),
          decoration: InputDecoration(
            hintText:
            'Buscar por servicio, proveedor, periodo o valor',
            hintStyle:
            GoogleFonts.poppins(
              fontSize: 12,
              color: Global.textSecondary,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color:
              Global.textSecondary,
            ),
            filled: true,
            fillColor: Global.container,
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                13,
              ),
              borderSide: BorderSide(
                color: Global.text
                    .withOpacity(0.09),
              ),
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                13,
              ),
              borderSide: BorderSide(
                color: Global.text
                    .withOpacity(0.09),
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                13,
              ),
              borderSide: BorderSide(
                color: Global.primary,
                width: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection:
          Axis.horizontal,
          child: Row(
            children: types.map(
                  (type) {
                final selected =
                    _selectedType ==
                        type;

                return Padding(
                  padding:
                  const EdgeInsets.only(
                    right: 8,
                  ),
                  child: ChoiceChip(
                    selected: selected,
                    label: Text(type),
                    onSelected: (_) {
                      setState(() {
                        _selectedType =
                            type;
                      });
                    },
                    showCheckmark: false,
                    avatar: Icon(
                      type == 'Todos'
                          ? Icons
                          .dashboard_outlined
                          : _iconForType(
                        type,
                      ),
                      size: 17,
                      color: selected
                          ? Global.primary
                          : Global
                          .textSecondary,
                    ),
                    labelStyle:
                    GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: selected
                          ? Global.primary
                          : Global.text,
                    ),
                    selectedColor:
                    Global.primary
                        .withOpacity(
                      0.12,
                    ),
                    backgroundColor:
                    Global.container,
                    side: BorderSide(
                      color: selected
                          ? Global.primary
                          .withOpacity(
                        0.45,
                      )
                          : Global.text
                          .withOpacity(
                        0.09,
                      ),
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildConsumptionGroup({
    required String title,
    required List<Map<String, dynamic>>
    consumos,
    required bool isDesktop,
  }) {
    final color =
    _colorForType(title);

    final latest =
    consumos.isNotEmpty
        ? consumos[0]
        : null;

    final previous =
    consumos.length > 1
        ? consumos[1]
        : null;

    final valueVariation =
    latest != null &&
        previous != null
        ? _percentageVariation(
      latest["valor"],
      previous["valor"],
    )
        : null;

    final consumptionVariation =
    latest != null &&
        previous != null &&
        _normalize(
          latest["unidad"],
        ) ==
            _normalize(
              previous["unidad"],
            )
        ? _percentageVariation(
      latest["consumo"],
      previous["consumo"],
    )
        : null;

    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 18,
      ),
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.08,
          ),
        ),
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
                decoration: BoxDecoration(
                  color:
                  color.withOpacity(
                    0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  _iconForType(title),
                  color: color,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
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
                        fontSize: 15.5,
                        fontWeight:
                        FontWeight.w600,
                        color: Global.text,
                      ),
                    ),
                    Text(
                      consumos.length == 1
                          ? '1 periodo registrado'
                          : '${consumos.length} periodos registrados',
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
          if (latest != null) ...[
            const SizedBox(height: 16),
            _buildLatestPeriodSummary(
              latest: latest,
              valueVariation:
              valueVariation,
              consumptionVariation:
              consumptionVariation,
              color: color,
              isDesktop: isDesktop,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Historial registrado',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight:
              FontWeight.w600,
              color: Global.text,
            ),
          ),
          const SizedBox(height: 10),
          ...consumos.map(
                (consumo) =>
                _buildConsumptionItem(
                  consumo,
                  color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestPeriodSummary({
    required Map<String, dynamic>
    latest,
    required double? valueVariation,
    required double?
    consumptionVariation,
    required Color color,
    required bool isDesktop,
  }) {
    final cards = [
      _comparisonCard(
        icon: Icons.payments_outlined,
        label: 'Valor último periodo',
        value: _formatCurrency(
          latest["valor"],
        ),
        variation: valueVariation,
        color: color,
      ),
      _comparisonCard(
        icon: Icons.speed_outlined,
        label: 'Consumo último periodo',
        value: _formatConsumption(
          latest,
        ),
        variation:
        consumptionVariation,
        color: color,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
        ],
      );
    }

    return Column(
      children: [
        cards[0],
        const SizedBox(height: 10),
        cards[1],
      ],
    );
  }

  Widget _comparisonCard({
    required IconData icon,
    required String label,
    required String value,
    required double? variation,
    required Color color,
  }) {
    final increased =
        variation != null &&
            variation > 0;

    final decreased =
        variation != null &&
            variation < 0;

    final variationColor = increased
        ? const Color(0xFFD45A55)
        : decreased
        ? const Color(0xFF278568)
        : Global.textSecondary;

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
        color.withOpacity(0.07),
        borderRadius:
        BorderRadius.circular(13),
        border: Border.all(
          color:
          color.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                    color: Global.text,
                  ),
                ),
                Text(
                  label,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: Global
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (variation != null)
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: variationColor
                    .withOpacity(0.10),
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    increased
                        ? Icons
                        .arrow_upward_rounded
                        : decreased
                        ? Icons
                        .arrow_downward_rounded
                        : Icons
                        .remove_rounded,
                    size: 13,
                    color: variationColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${variation.abs().toStringAsFixed(1)}%',
                    style:
                    GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      variationColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConsumptionItem(
      Map<String, dynamic> consumo,
      Color color,
      ) {
    final provider =
    (consumo["proveedor"] ?? '')
        .toString()
        .trim();

    final status =
    (consumo["estado"] ?? '')
        .toString()
        .trim();

    return InkWell(
      onTap: () =>
          _showConsumptionDetails(
            consumo,
            color,
          ),
      borderRadius:
      BorderRadius.circular(13),
      child: Container(
        width: double.infinity,
        margin:
        const EdgeInsets.only(
          bottom: 9,
        ),
        padding:
        const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color:
          Global.absolute.withOpacity(
            0.45,
          ),
          borderRadius:
          BorderRadius.circular(13),
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color:
                color.withOpacity(
                  0.10,
                ),
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
              child: Icon(
                Icons
                    .calendar_month_outlined,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatPeriod(
                      consumo,
                    ),
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight:
                      FontWeight.w600,
                      color: Global.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    provider.isEmpty
                        ? 'Proveedor no informado'
                        : provider,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    GoogleFonts.poppins(
                      fontSize: 9.5,
                      color: Global
                          .textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(
                    consumo["valor"],
                  ),
                  style:
                  GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight:
                    FontWeight.w600,
                    color: Global.text,
                  ),
                ),
                Text(
                  _formatConsumption(
                    consumo,
                  ),
                  style:
                  GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color:
              Global.textSecondary,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  void _showConsumptionDetails(
      Map<String, dynamic> consumo,
      Color color,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder:
              (context, scrollController) {
            return Container(
              padding:
              const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24,
              ),
              decoration: BoxDecoration(
                color: Global.container,
                borderRadius:
                const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: ListView(
                controller:
                scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration:
                      BoxDecoration(
                        color: Global
                            .textSecondary
                            .withOpacity(
                          0.35,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration:
                        BoxDecoration(
                          color:
                          color.withOpacity(
                            0.12,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            13,
                          ),
                        ),
                        child: Icon(
                          _iconForType(
                            (consumo[
                            "tipo"] ??
                                '')
                                .toString(),
                          ),
                          color: color,
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
                              (consumo[
                              "tipo"] ??
                                  'Factura')
                                  .toString(),
                              style:
                              GoogleFonts
                                  .poppins(
                                fontSize:
                                17,
                                fontWeight:
                                FontWeight
                                    .w600,
                                color:
                                Global.text,
                              ),
                            ),
                            Text(
                              _formatPeriod(
                                consumo,
                              ),
                              style:
                              GoogleFonts
                                  .poppins(
                                fontSize:
                                10.5,
                                color: Global
                                    .textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(
                              context,
                            ),
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _detailSection(
                    title:
                    'Información de consumo',
                    children: [
                      _detailRow(
                        'Consumo',
                        _formatConsumption(
                          consumo,
                        ),
                      ),
                      _detailRow(
                        'Valor facturado',
                        _formatCurrency(
                          consumo["valor"],
                        ),
                      ),
                      _detailRow(
                        'Proveedor',
                        consumo["proveedor"]
                            ?.toString() ??
                            'No informado',
                      ),
                      _detailRow(
                        'Estado',
                        consumo["estado"]
                            ?.toString() ??
                            'No informado',
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _detailSection(
                    title:
                    'Periodo facturado',
                    children: [
                      _detailRow(
                        'Fecha inicial',
                        _formatDate(
                          consumo[
                          "periodo_inicio"],
                        ),
                      ),
                      _detailRow(
                        'Fecha final',
                        _formatDate(
                          consumo[
                          "periodo_fin"],
                        ),
                      ),
                    ],
                  ),
                  if ((consumo[
                  "observaciones"] ??
                      '')
                      .toString()
                      .trim()
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 12,
                    ),
                    _detailSection(
                      title:
                      'Observaciones',
                      children: [
                        Text(
                          consumo[
                          "observaciones"]
                              .toString(),
                          style:
                          GoogleFonts.poppins(
                            fontSize: 11,
                            height: 1.55,
                            color: Global
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
        Global.absolute.withOpacity(
          0.45,
        ),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.07,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight:
              FontWeight.w600,
              color: Global.text,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style:
              GoogleFonts.poppins(
                fontSize: 10.5,
                color:
                Global.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign:
              TextAlign.right,
              style:
              GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight:
                FontWeight.w500,
                color: Global.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.08,
          ),
        ),
      ),
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color:
              Global.primary.withOpacity(
                0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 35,
              color: Global.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no hay facturas registradas',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight:
              FontWeight.w600,
              color: Global.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando el asesor registre tus consumos, podrás consultarlos desde aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              height: 1.5,
              color:
              Global.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.08,
          ),
        ),
      ),
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 38,
            color:
            Global.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No encontramos resultados',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight:
              FontWeight.w600,
              color: Global.text,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Prueba con otro servicio, proveedor, periodo o valor.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color:
              Global.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}