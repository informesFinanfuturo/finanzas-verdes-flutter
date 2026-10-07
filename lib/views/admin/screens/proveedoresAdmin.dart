import 'dart:async';
import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/catalogoApi.dart';
import 'package:finanzas_verdes/models/api/proveedorApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Proveedoresadmin extends StatefulWidget {
  const Proveedoresadmin({super.key});

  @override
  State<Proveedoresadmin> createState() => _ProveedoresadminState();
}

class _ProveedoresadminState extends State<Proveedoresadmin> with SingleTickerProviderStateMixin {
  final ProveedorController proveedorController =
  Get.isRegistered<ProveedorController>()
      ? Get.find<ProveedorController>()
      : Get.put(ProveedorController());

  final TextEditingController searchController = TextEditingController();

  Timer? syncTimer;

  final ScrollController catalogScrollController = ScrollController();
  final ScrollController syncScrollController = ScrollController();

  late final TabController moduleTabController;

  final TextEditingController providerSearchController = TextEditingController();

  final ScrollController providerScrollController = ScrollController();

  bool _isProviderDetailOpen = false;

  String syncLogLevel = 'TODOS';
  String syncLogProvider = 'TODOS';

  @override
  void initState() {
    super.initState();
    moduleTabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    syncTimer?.cancel();
    moduleTabController.dispose();
    searchController.dispose();
    providerSearchController.dispose();
    catalogScrollController.dispose();
    providerScrollController.dispose();
    syncScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadProviders(),
      _loadCatalog(),
      _loadHistory(),
    ]);

    final sync = proveedorController.sincronizacionActual;
    final id = _toInt(sync['id_sincronizacion']);

    if (id != null && proveedorController.haySincronizacionActiva) {
      _startSyncMonitoring(id);
    }
  }

  Future<void> _loadProviders() async {
    try {
      await Future.wait([
        cargarProveedoresAdminApi(
          proveedorController: proveedorController,
        ),
        getTipoProveedoresApi(
          proveedorController: proveedorController,
        ),
      ]);
    } catch (_) {}
  }

  Future<void> _loadCatalog() async {
    try {
      await cargarCatalogoAdminApi(proveedorController: proveedorController);
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    try {
      await getHistorialSincronizacionesApi(
        proveedorController: proveedorController,
        limite: 20,
      );
    } catch (_) {}
  }

  Future<void> _applyFilters() async {
    proveedorController.busquedaCatalogo.value = searchController.text.trim();
    proveedorController.paginaCatalogo.value = 1;

    await _scrollCatalogTop();
    await _loadCatalog();
  }

  Future<void> _clearFilters() async {
    searchController.clear();
    proveedorController.limpiarFiltrosCatalogo();

    await _scrollCatalogTop();
    await _loadCatalog();
  }

  Future<void> _changePage(int page) async {
    if (page <= 0) return;

    proveedorController.setPaginaCatalogo(page);

    await _scrollCatalogTop();
    await _loadCatalog();
  }

  Future<void> _confirmSync() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Global.container,
        title: Text(
          'Sincronizar fuentes externas',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Global.text,
          ),
        ),
        content: Text(
          'Este proceso ejecutará los crawlers y actualizará el catálogo '
              'almacenado. Puede tardar varios minutos.',
          style: GoogleFonts.poppins(fontSize: 12, color: Global.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.sync_rounded, size: 18),
            label: const Text('Iniciar'),
            style: FilledButton.styleFrom(
              backgroundColor: Global.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _startSync();
    }
  }

  Future<void> _startSync() async {
    try {
      final id = await iniciarSincronizacionCatalogoApi(
        proveedorController: proveedorController,
      );

      _startSyncMonitoring(id);

      if (mounted) {
        Get.snackbar(
          'Sincronización iniciada',
          'El proceso continuará en segundo plano.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF278568),
          colorText: Colors.white,
        );
      }
    } catch (error) {
      if (!mounted) return;

      Get.snackbar(
        'No fue posible iniciar',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC84C4C),
        colorText: Colors.white,
      );

      final currentId = _toInt(
        proveedorController.sincronizacionActual['id_sincronizacion'],
      );

      if (currentId != null && proveedorController.haySincronizacionActiva) {
        _startSyncMonitoring(currentId);
      }
    }
  }

  void _startSyncMonitoring(int idSincronizacion) {
    syncTimer?.cancel();
    _checkSync(idSincronizacion);

    syncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkSync(idSincronizacion);
    });
  }

  Future<void> _checkSync(int idSincronizacion) async {
    try {
      final sync = await getSincronizacionCatalogoApi(
        idSincronizacion: idSincronizacion,
        proveedorController: proveedorController,
      );

      final status = sync['estado']?.toString().toLowerCase();

      if (status == 'completada' ||
          status == 'completada_con_errores' ||
          status == 'fallida') {
        syncTimer?.cancel();
        await Future.wait([_loadHistory(), _loadCatalog()]);
      }
    } catch (_) {
      // El monitoreo continuará en el siguiente intervalo.
    }
  }

  int? _toInt(dynamic value) => int.tryParse(value?.toString() ?? '');

  int _number(dynamic value) => _toInt(value) ?? 0;

  String _money(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '') ?? 0;

    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    ).format(amount);
  }

  String _date(dynamic value) {
    if (value == null) return 'Sin fecha';

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();

    return DateFormat('dd/MM/yyyy · HH:mm').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 10),
        _summaryCards(),
        const SizedBox(height: 10),
        _tabs(),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: moduleTabController,
            children: [
              _providersSection(),
              _catalogSection(),
              _syncSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proveedores y catálogo',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: compact ? 18 : 22,
                fontWeight: FontWeight.w700,
                color: Global.text,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 3),
              Text(
                'Consulta los productos almacenados y controla las fuentes externas.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Global.textSecondary,
                ),
              ),
            ],
          ],
        );

        final syncButton = Obx(() {
          final disabled =
              proveedorController.iniciandoSincronizacion.value ||
                  proveedorController.haySincronizacionActiva;

          return FilledButton.icon(
            onPressed: disabled ? null : _confirmSync,
            icon: proveedorController.iniciandoSincronizacion.value
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.sync_rounded, size: 18),
            label: Text(
              proveedorController.haySincronizacionActiva
                  ? 'Sincronizando'
                  : compact
                  ? 'Sincronizar'
                  : 'Sincronizar fuentes',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Global.primary,
              foregroundColor: Colors.white,
            ),
          );
        });

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(child: syncButton),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: _loadInitialData,
                    tooltip: 'Actualizar información',
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            IconButton(
              onPressed: _loadInitialData,
              tooltip: 'Actualizar información',
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: 6),
            syncButton,
          ],
        );
      },
    );
  }

  Widget _summaryCards() {
    return Obx(() {
      final summary = proveedorController.resumenCatalogoAdmin;

      final cards = [
        _SummaryData(
          title: 'Productos',
          value: _number(summary['total_productos']).toString(),
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF3976D3),
        ),
        _SummaryData(
          title: 'Disponibles',
          value: _number(summary['disponibles']).toString(),
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF278568),
        ),
        _SummaryData(
          title: 'No disponibles',
          value: _number(summary['no_disponibles']).toString(),
          icon: Icons.remove_circle_outline_rounded,
          color: const Color(0xFFE88725),
        ),
        _SummaryData(
          title: 'Proveedores',
          value: _number(summary['total_proveedores']).toString(),
          icon: Icons.storefront_outlined,
          color: const Color(0xFF7455C6),
        ),
      ];

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 560) {
            return SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: cards.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 175,
                    child: _summaryCard(cards[index]),
                  );
                },
              ),
            );
          }

          final width = constraints.maxWidth >= 1000
              ? (constraints.maxWidth - 36) / 4
              : (constraints.maxWidth - 12) / 2;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map((card) => SizedBox(width: width, child: _summaryCard(card)))
                .toList(),
          );
        },
      );
    });
  }

  Widget _summaryCard(_SummaryData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(data.icon, color: data.color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Global.text,
                  ),
                ),
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
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

  Widget _tabs() {
    return Container(
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(13),
      ),
      child: TabBar(
        controller: moduleTabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: Global.primary,
        unselectedLabelColor: Global.textSecondary,
        indicatorColor: Global.primary,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.poppins(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.storefront_outlined, size: 19),
            text: 'Proveedores',
          ),
          Tab(
            icon: Icon(Icons.inventory_2_outlined, size: 19),
            text: 'Catálogo',
          ),
          Tab(
            icon: Icon(Icons.sync_rounded, size: 19),
            text: 'Sincronizaciones',
          ),
        ],
      ),
    );
  }

  Future<void> _applyProviderFilters() async {
    proveedorController.busquedaProveedor.value =
        providerSearchController.text.trim();

    proveedorController.paginaProveedores.value = 1;

    if (providerScrollController.hasClients) {
      await providerScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    await _loadProviders();
  }

  Future<void> _clearProviderFilters() async {
    providerSearchController.clear();
    proveedorController.limpiarFiltrosProveedores();

    if (providerScrollController.hasClients) {
      providerScrollController.jumpTo(0);
    }

    await _loadProviders();
  }

  Future<void> _changeProviderPage(int page) async {
    if (page <= 0) return;

    proveedorController.setPaginaProveedores(page);

    if (providerScrollController.hasClients) {
      await providerScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    await _loadProviders();
  }

  Future<void> _openProviderCatalog(Map<String, dynamic> provider) async {
    final id = _toInt(provider['id_proveedor']);
    if (id == null) return;

    proveedorController.proveedorSeleccionadoId.value = id;
    proveedorController.paginaCatalogo.value = 1;

    moduleTabController.animateTo(1);
    await _loadCatalog();
  }

  Widget _providersSection() {
    return Obx(() {
      final loading = proveedorController.loadingProveedoresAdmin.value;
      final providers = proveedorController.proveedoresAdmin;
      final error = proveedorController.errorProveedoresAdmin.value;

      if (loading && providers.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: Global.primary),
        );
      }

      final width = MediaQuery.sizeOf(context).width;
      final safeBottom = MediaQuery.paddingOf(context).bottom;
      final bottomSpace = width < 800 ? 100.0 + safeBottom : 24.0;

      return RefreshIndicator(
        onRefresh: _loadProviders,
        color: Global.primary,
        child: CustomScrollView(
          controller: providerScrollController,
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _providerSummary()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _providerFilters()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            if (error.isNotEmpty) ...[
              SliverToBoxAdapter(child: _errorBox(error, _loadProviders)),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
            ],

            if (providers.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: _emptyState(
                    icon: Icons.storefront_outlined,
                    title: 'No hay proveedores para mostrar',
                    description: 'Prueba cambiando los filtros.',
                  ),
                ),
              )
            else if (width < 800)
              _providerMobileList()
            else
              SliverToBoxAdapter(child: _providerTable()),

            if (providers.isNotEmpty)
              SliverToBoxAdapter(child: _providerPagination()),

            if (loading && providers.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(
                    color: Global.primary,
                    backgroundColor: Global.primary.withOpacity(0.10),
                  ),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: bottomSpace)),
          ],
        ),
      );
    });
  }

  Widget _providerSummary() {
    return Obx(() {
      final summary = proveedorController.resumenProveedoresAdmin;

      final values = [
        _SummaryData(
          title: 'Total',
          value: _number(summary['total_proveedores']).toString(),
          icon: Icons.storefront_outlined,
          color: const Color(0xFF3976D3),
        ),
        _SummaryData(
          title: 'Activos',
          value: _number(summary['proveedores_activos']).toString(),
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF278568),
        ),
        _SummaryData(
          title: 'Sin usuario',
          value: _number(summary['sin_usuario']).toString(),
          icon: Icons.person_off_outlined,
          color: const Color(0xFFE88725),
        ),
        _SummaryData(
          title: 'Sin productos',
          value: _number(summary['sin_productos']).toString(),
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF7455C6),
        ),
      ];

      return SizedBox(
        height: 74,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          itemCount: values.length,
          separatorBuilder: (_, _) => const SizedBox(width: 9),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 165,
              child: _summaryCard(values[index]),
            );
          },
        ),
      );
    });
  }

  Widget _providerFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 850;

          final search = TextField(
            controller: providerSearchController,
            onSubmitted: (_) => _applyProviderFilters(),
            style: GoogleFonts.poppins(fontSize: 11, color: Global.text),
            decoration: InputDecoration(
              hintText: 'Buscar razón social, NIT, usuario o correo',
              hintStyle: GoogleFonts.poppins(
                fontSize: 9.5,
                color: Global.textSecondary,
              ),
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Global.bg,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
            ),
          );

          final state = Obx(
                () => DropdownButtonFormField<String>(
              isExpanded: true,
              value: proveedorController.estadoProveedorFiltro.value.isEmpty
                  ? 'todos'
                  : proveedorController.estadoProveedorFiltro.value,
              decoration: _filterDecoration('Estado'),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'activo', child: Text('Activos')),
                DropdownMenuItem(value: 'inactivo', child: Text('Inactivos')),
              ],
              onChanged: (value) {
                proveedorController.estadoProveedorFiltro.value =
                value == 'todos' ? '' : value ?? '';
                _applyProviderFilters();
              },
            ),
          );

          final origin = Obx(
                () => DropdownButtonFormField<String>(
                  isExpanded: true,
              value: proveedorController.origenProveedorFiltro.value.isEmpty
                  ? 'todos'
                  : proveedorController.origenProveedorFiltro.value,
              decoration: _filterDecoration('Origen'),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'crawler', child: Text('Crawler')),
                DropdownMenuItem(value: 'manual', child: Text('Manual')),
                DropdownMenuItem(value: 'mixto', child: Text('Mixto')),
                DropdownMenuItem(
                  value: 'sin_catalogo',
                  child: Text('Sin catálogo'),
                ),
              ],
              onChanged: (value) {
                proveedorController.origenProveedorFiltro.value =
                value == 'todos' ? '' : value ?? '';
                _applyProviderFilters();
              },
            ),
          );

          final type = Obx(
                () => DropdownButtonFormField<int?>(
              isExpanded: true,
              value: proveedorController.tipoProveedorFiltroId.value,
              decoration: _filterDecoration('Tipo'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...proveedorController.TiposProveedores.map((item) {
                  return DropdownMenuItem<int?>(
                    value: _toInt(item['id_tipo_proveedor']),
                    child: Text(
                      item['nombre_tipo']?.toString() ?? 'Sin nombre',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                proveedorController.tipoProveedorFiltroId.value = value;
                _applyProviderFilters();
              },
            ),
          );

          final buttons = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: _applyProviderFilters,
                icon: const Icon(Icons.filter_alt_outlined, size: 17),
                label: const Text('Aplicar'),
                style: FilledButton.styleFrom(
                  backgroundColor: Global.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                onPressed: _clearProviderFilters,
                tooltip: 'Limpiar filtros',
                icon: const Icon(Icons.filter_alt_off_outlined),
              ),
            ],
          );

          if (compact) {
            return Column(
              children: [
                search,
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(child: state),
                    const SizedBox(width: 8),
                    Expanded(child: origin),
                  ],
                ),
                const SizedBox(height: 9),
                type,
                const SizedBox(height: 9),
                Align(alignment: Alignment.centerRight, child: buttons),
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 2, child: search),
              const SizedBox(width: 8),
              SizedBox(width: 145, child: state),
              const SizedBox(width: 8),
              SizedBox(width: 155, child: origin),
              const SizedBox(width: 8),
              SizedBox(width: 195, child: type),
              const SizedBox(width: 8),
              buttons,
            ],
          );
        },
      ),
    );
  }

  InputDecoration _filterDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Global.bg,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _providerMobileList() {
    return SliverList.separated(
      itemCount: proveedorController.proveedoresAdmin.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _providerCard(proveedorController.proveedoresAdmin[index]);
      },
    );
  }

  Widget _providerCard(Map<String, dynamic> provider) {
    final active = provider['estado_proveedor']
        ?.toString()
        .toLowerCase() ==
        'activo';

    final types = provider['tipos_proveedor'] is List
        ? provider['tipos_proveedor'] as List
        : <dynamic>[];

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => _showProviderDetail(provider),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Global.container,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Global.text.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Global.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.storefront_outlined, color: Global.primary),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider['razon_social']?.toString() ?? 'Sin razón social',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Global.text,
                        ),
                      ),
                      Text(
                        'NIT: ${provider['nit'] ?? 'No informado'}',
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          color: Global.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusChip(
                  active ? 'Activo' : 'Inactivo',
                  active ? const Color(0xFF278568) : const Color(0xFF8A8F98),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _smallChip(
                  _originLabel(provider['origen_catalogo']),
                  const Color(0xFF7455C6),
                ),
                _smallChip(
                  '${_number(provider['total_productos'])} productos',
                  const Color(0xFF3976D3),
                ),
                _smallChip(
                  provider['id_usuario'] == null
                      ? 'Sin acceso'
                      : 'Usuario asociado',
                  provider['id_usuario'] == null
                      ? const Color(0xFFE88725)
                      : const Color(0xFF278568),
                ),
              ],
            ),
            if (types.isNotEmpty) ...[
              const SizedBox(height: 9),
              Text(
                types
                    .map((type) => type['nombre_tipo']?.toString() ?? '')
                    .where((name) => name.isNotEmpty)
                    .join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  color: Global.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _openProviderCatalog(provider),
                icon: const Icon(Icons.inventory_2_outlined, size: 17),
                label: const Text('Ver catálogo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerTable() {
    return Container(
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Global.text.withOpacity(0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(
              Global.primary.withOpacity(0.06),
            ),
            columns: const [
              DataColumn(label: Text('Proveedor')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Origen')),
              DataColumn(label: Text('Productos')),
              DataColumn(label: Text('Disponibles')),
              DataColumn(label: Text('Acceso')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: proveedorController.proveedoresAdmin.map((provider) {
              final active = provider['estado_proveedor']
                  ?.toString()
                  .toLowerCase() ==
                  'activo';

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 190,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider['razon_social']?.toString() ??
                                'Sin razón social',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'NIT: ${provider['nit'] ?? 'No informado'}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Global.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    _statusChip(
                      active ? 'Activo' : 'Inactivo',
                      active
                          ? const Color(0xFF278568)
                          : const Color(0xFF8A8F98),
                    ),
                  ),
                  DataCell(Text(_originLabel(provider['origen_catalogo']))),
                  DataCell(Text('${_number(provider['total_productos'])}')),
                  DataCell(Text('${_number(provider['productos_disponibles'])}')),
                  DataCell(
                    Text(
                      provider['id_usuario'] == null
                          ? 'Sin usuario'
                          : 'Con usuario',
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showProviderDetail(provider),
                          tooltip: 'Ver detalle',
                          icon: const Icon(Icons.visibility_outlined),
                        ),
                        IconButton(
                          onPressed: () => _openProviderCatalog(provider),
                          tooltip: 'Ver catálogo',
                          icon: const Icon(Icons.inventory_2_outlined),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showProviderDetail(Map<String, dynamic> provider) {
    if (_isProviderDetailOpen || !mounted) return;

    _isProviderDetailOpen = true;
    proveedorController.setProveedorDetalle(provider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final types = provider['tipos_proveedor'] is List
            ? provider['tipos_proveedor'] as List
            : <dynamic>[];

        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.82,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Global.container,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storefront_outlined, color: Global.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider['razon_social']?.toString() ??
                              'Proveedor',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Global.text,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _detailRow('NIT', provider['nit']),
                  _detailRow('Dirección', provider['direccion']),
                  _detailRow('Estado', provider['estado_proveedor']),
                  _detailRow(
                    'Origen del catálogo',
                    _originLabel(provider['origen_catalogo']),
                  ),
                  _detailRow(
                    'Productos',
                    provider['total_productos'],
                  ),
                  _detailRow(
                    'Productos disponibles',
                    provider['productos_disponibles'],
                  ),
                  _detailRow(
                    'Última actualización',
                    _date(provider['ultima_actualizacion_catalogo']),
                  ),
                  _detailRow(
                    'Usuario asociado',
                    provider['nombre_usuario'] ?? 'Sin usuario asociado',
                  ),
                  _detailRow('Correo', provider['email'] ?? 'No aplica'),
                  _detailRow(
                    'Tipos',
                    types.isEmpty
                        ? 'Sin tipos asignados'
                        : types
                        .map(
                          (type) =>
                      type['nombre_tipo']?.toString() ?? '',
                    )
                        .where((name) => name.isNotEmpty)
                        .join(', '),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _openProviderCatalog(provider);
                      },
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Ver catálogo'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Global.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Global.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'No informado',
              style: GoogleFonts.poppins(fontSize: 10, color: Global.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _providerPagination() {
    return Obx(() {
      final pagination = proveedorController.paginacionProveedoresAdmin;
      final current = _number(pagination['pagina']);
      final total = _number(pagination['total_paginas']);
      final records = _number(pagination['total_registros']);

      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: current > 1
                  ? () => _changeProviderPage(current - 1)
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Text(
              total > 0
                  ? 'Página $current de $total · $records proveedores'
                  : '$records proveedores',
              style: GoogleFonts.poppins(fontSize: 9.5, color: Global.text),
            ),
            IconButton(
              onPressed: current < total
                  ? () => _changeProviderPage(current + 1)
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      );
    });
  }

  String _originLabel(dynamic value) {
    switch (value?.toString()) {
      case 'crawler':
        return 'Crawler';
      case 'manual':
        return 'Manual';
      case 'mixto':
        return 'Mixto';
      default:
        return 'Sin catálogo';
    }
  }

  Widget _catalogSection() {
    return Obx(() {
      final loading = proveedorController.loadingCatalogoAdmin.value;
      final products = proveedorController.productosAdmin;
      final error = proveedorController.errorCatalogoAdmin.value;

      if (loading && products.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: Global.primary),
        );
      }

      final screenWidth = MediaQuery.sizeOf(context).width;
      final safeBottom = MediaQuery.paddingOf(context).bottom;

      /*
     * En móvil se reservan:
     * 64 px del menú + separación + SafeArea.
     */
      final bottomSpace = screenWidth < 800 ? 100.0 + safeBottom : 24.0;

      return RefreshIndicator(
        onRefresh: _loadCatalog,
        color: Global.primary,
        child: CustomScrollView(
          controller: catalogScrollController,
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _catalogFilters()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            if (error.isNotEmpty) ...[
              SliverToBoxAdapter(child: _errorBox(error, _loadCatalog)),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
            ],

            if (products.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: _emptyCatalog(),
                ),
              )
            else
              _productGridSliver(),

            if (products.isNotEmpty)
              SliverToBoxAdapter(child: _pagination()),

            if (loading && products.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(
                    color: Global.primary,
                    backgroundColor: Global.primary.withOpacity(0.10),
                  ),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: bottomSpace)),
          ],
        ),
      );
    });
  }

  Widget _catalogFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;

          final search = TextField(
            controller: searchController,
            onSubmitted: (_) => _applyFilters(),
            style: GoogleFonts.poppins(fontSize: 11, color: Global.text),
            decoration: InputDecoration(
              hintText: 'Buscar producto, proveedor o NIT',
              hintStyle: GoogleFonts.poppins(
                fontSize: 10,
                color: Global.textSecondary,
              ),
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Global.bg,
              isDense: true,
            ),
          );

          final availability = Obx(
                () => DropdownButtonFormField<String>(
              value: proveedorController.disponibilidadSeleccionada.value == null
                  ? 'todos'
                  : proveedorController.disponibilidadSeleccionada.value!
                  ? 'disponibles'
                  : 'no_disponibles',
              decoration: InputDecoration(
                labelText: 'Disponibilidad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Global.bg,
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(
                  value: 'disponibles',
                  child: Text('Disponibles'),
                ),
                DropdownMenuItem(
                  value: 'no_disponibles',
                  child: Text('No disponibles'),
                ),
              ],
              onChanged: (value) {
                proveedorController.disponibilidadSeleccionada.value =
                value == 'todos' ? null : value == 'disponibles';
                _applyFilters();
              },
            ),
          );

          final buttons = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.filter_alt_outlined, size: 17),
                label: const Text('Aplicar'),
                style: FilledButton.styleFrom(
                  backgroundColor: Global.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 7),
              IconButton(
                onPressed: _clearFilters,
                tooltip: 'Limpiar filtros',
                icon: const Icon(Icons.filter_alt_off_outlined),
              ),
            ],
          );

          if (compact) {
            return Column(
              children: [
                search,
                const SizedBox(height: 10),
                availability,
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: buttons),
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 2, child: search),
              const SizedBox(width: 10),
              SizedBox(width: 190, child: availability),
              const SizedBox(width: 10),
              buttons,
            ],
          );
        },
      ),
    );
  }

  Widget _productGridSliver() {
    final width = MediaQuery.sizeOf(context).width;

    final columns = width >= 1350
        ? 4
        : width >= 950
        ? 3
        : width >= 600
        ? 2
        : 1;

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return _productCard(
            proveedorController.productosAdmin[index],
          );
        },
        childCount: proveedorController.productosAdmin.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 220,
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> product) {
    final available = product['disponible'] == true;
    final provider = product['nombre_proveedor']?.toString().trim();
    final type = product['tipo_item']?.toString().trim();

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Global.text.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: Global.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Global.primary,
                  size: 21,
                ),
              ),
              const Spacer(),
              _statusChip(
                available ? 'Disponible' : 'No disponible',
                available
                    ? const Color(0xFF278568)
                    : const Color(0xFFE88725),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product['nombre']?.toString() ?? 'Producto sin nombre',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Global.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            provider?.isNotEmpty == true ? provider! : 'Proveedor no informado',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 8.5,
              color: Global.textSecondary,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              if (type?.isNotEmpty == true)
                _smallChip(type!, const Color(0xFF3976D3)),
              if (product['url_origen'] != null)
                _smallChip('Crawler', const Color(0xFF7455C6)),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Text(
                  _money(product['precio_base']),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Global.primary,
                  ),
                ),
              ),
              Tooltip(
                message:
                'Última actualización: ${_date(product['updated_at'])}',
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: Global.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pagination() {
    return Obx(() {
      final pagination = proveedorController.paginacionCatalogoAdmin;
      final current = _number(pagination['pagina']);
      final total = _number(pagination['total_paginas']);
      final records = _number(pagination['total_registros']);

      if (total <= 1) {
        return Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Center(
            child: Text(
              '$records productos',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: Global.textSecondary,
              ),
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Global.container,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Global.text.withOpacity(0.06)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: current > 1 ? () => _changePage(current - 1) : null,
              tooltip: 'Página anterior',
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Página $current de $total',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),
                Text(
                  '$records productos',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    color: Global.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: current < total ? () => _changePage(current + 1) : null,
              tooltip: 'Página siguiente',
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      );
    });
  }

  Widget _syncSection() {
    return Obx(() {
      if (proveedorController.cargandoHistorial.value &&
          proveedorController.historialSincronizaciones.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: Global.primary),
        );
      }

      return Column(
        children: [
          if (proveedorController.sincronizacionActual.isNotEmpty)
            _currentSyncCard(),
          if (proveedorController.sincronizacionActual.isNotEmpty)
            const SizedBox(height: 12),
          if (proveedorController.errorSincronizacion.isNotEmpty)
            _errorBox(
              proveedorController.errorSincronizacion.value,
              _loadHistory,
            ),
          if (proveedorController.errorSincronizacion.isNotEmpty)
            const SizedBox(height: 12),
          Expanded(
            child: proveedorController.historialSincronizaciones.isEmpty
                ? _emptyHistory()
                : ListView.separated(
              controller: syncScrollController,
              primary: false,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.sizeOf(context).width < 800
                    ? 100 + MediaQuery.paddingOf(context).bottom
                    : 24,
              ),
              itemCount: proveedorController.historialSincronizaciones.length,
              separatorBuilder: (_, _) => const SizedBox(height: 9),
              itemBuilder: (context, index) => _historyCard(
                proveedorController.historialSincronizaciones[index],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _currentSyncCard() {
    final sync = proveedorController.sincronizacionActual;
    final status = sync['estado']?.toString() ?? 'pendiente';
    final active = status == 'pendiente' || status == 'procesando';
    final color = _syncColor(status);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          active
              ? SizedBox(
            width: 35,
            height: 35,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: color,
            ),
          )
              : Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_syncIcon(status), color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active ? 'Sincronización en curso' : _syncLabel(status),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),
                Text(
                  'Iniciada: ${_date(sync['inicio'] ?? sync['created_at'])}',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Global.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _statusChip(_syncLabel(status), color),
        ],
      ),
    );
  }

  Widget _providerSyncResult(Map<String, dynamic> item) {
    final status = item['estado']?.toString() ?? 'completada';
    final color = status == 'fallida'
        ? const Color(0xFFC84C4C)
        : status == 'parcial'
        ? const Color(0xFFE88725)
        : const Color(0xFF278568);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Global.bg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withOpacity(.14)),
      ),
      child: Row(
        children: [
          Icon(
            status == 'fallida'
                ? Icons.error_outline_rounded
                : status == 'parcial'
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['proveedor']?.toString() ?? 'Proveedor',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),
                Text(
                  'Encontrados ${_number(item['encontrados'])} · '
                      'Creados ${_number(item['creados'])} · '
                      'Actualizados ${_number(item['actualizados'])} · '
                      'Desactivados ${_number(item['desactivados'])}',
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
                    color: Global.textSecondary,
                  ),
                ),
                if (item['error'] != null && item['error'].toString().trim().isNotEmpty)
                  Text(
                    item['error'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 8.5,
                      color: const Color(0xFFC84C4C),
                    ),
                  ),
              ],
            ),
          ),
          _statusChip(
            status == 'parcial'
                ? 'Parcial'
                : status == 'fallida'
                ? 'Fallida'
                : 'Completa',
            color,
          ),
        ],
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> sync) {
    final status = sync['estado']?.toString() ?? 'pendiente';
    final report = sync['reporte'] is Map
        ? Map<String, dynamic>.from(sync['reporte'])
        : <String, dynamic>{};
    final summary = report['resumen'] is Map
        ? Map<String, dynamic>.from(report['resumen'])
        : <String, dynamic>{};
    final providers = report['proveedores'] is List
        ? (report['proveedores'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];
    final color = _syncColor(status);
    final id = _toInt(sync['id_sincronizacion']);

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      backgroundColor: Global.container,
      collapsedBackgroundColor: Global.container,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Container(
        width: 39, height: 39,
        decoration: BoxDecoration(
          color: color.withOpacity(.11),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(_syncIcon(status), color: color, size: 21),
      ),
      title: Text(
        _syncLabel(status),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Global.text,
        ),
      ),
      subtitle: Text(
        '${sync['origen'] == 'automatico' ? 'Automática' : 'Manual'} · '
            '${_date(sync['inicio'] ?? sync['created_at'])}',
        style: GoogleFonts.poppins(fontSize: 8.5, color: Global.textSecondary),
      ),
      trailing: _statusChip(_syncLabel(status), color),
      children: [
        if (summary.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _reportValue('Encontrados', summary['encontrados']),
              _reportValue('Creados', summary['creados']),
              _reportValue('Actualizados', summary['actualizados']),
              _reportValue('Sin cambios', summary['sin_cambios']),
              _reportValue('Desactivados', summary['desactivados']),
            ],
          ),
          const SizedBox(height: 12),
        ],

        if (providers.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Resultado por fuente',
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Global.text,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...providers.map(_providerSyncResult),
          const SizedBox(height: 10),
        ],

        if (sync['error'] != null && sync['error'].toString().trim().isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFC84C4C).withOpacity(.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              sync['error'].toString(),
              style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFFC84C4C)),
            ),
          ),
          const SizedBox(height: 10),
        ],

        if (id != null)
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _showSyncLogs(sync),
              icon: const Icon(Icons.terminal_rounded, size: 17),
              label: const Text('Ver registro técnico'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Global.primary,
                side: BorderSide(color: Global.primary.withOpacity(.25)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _reportValue(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Global.bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        '$label: ${_number(value)}',
        style: GoogleFonts.poppins(fontSize: 9, color: Global.text),
      ),
    );
  }

  Widget _emptyCatalog() {
    return _emptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No hay productos para mostrar',
      description: 'Prueba cambiando los filtros o actualiza el catálogo.',
    );
  }

  Widget _emptyHistory() {
    return _emptyState(
      icon: Icons.history_rounded,
      title: 'No hay sincronizaciones registradas',
      description: 'El historial aparecerá después de ejecutar el crawler.',
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Global.primary.withOpacity(0.65)),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Global.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              color: Global.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String message, Future<void> Function() retry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFC84C4C).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC84C4C).withOpacity(0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFC84C4C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(fontSize: 9.5, color: Global.text),
            ),
          ),
          TextButton(onPressed: retry, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _smallChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 7.5, color: color),
      ),
    );
  }

  Color _syncColor(String status) {
    switch (status) {
      case 'completada':
        return const Color(0xFF278568);
      case 'completada_con_errores':
        return const Color(0xFFE88725);
      case 'fallida':
        return const Color(0xFFC84C4C);
      default:
        return const Color(0xFF3976D3);
    }
  }

  IconData _syncIcon(String status) {
    switch (status) {
      case 'completada':
        return Icons.check_circle_outline_rounded;
      case 'completada_con_errores':
        return Icons.warning_amber_rounded;
      case 'fallida':
        return Icons.error_outline_rounded;
      default:
        return Icons.sync_rounded;
    }
  }

  String _syncLabel(String status) {
    switch (status) {
      case 'procesando':
        return 'Procesando';
      case 'completada':
        return 'Completada';
      case 'completada_con_errores':
        return 'Con novedades';
      case 'fallida':
        return 'Fallida';
      default:
        return 'Pendiente';
    }
  }

  Future<void> _scrollCatalogTop() async {
    if (!catalogScrollController.hasClients) return;

    await catalogScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _showSyncLogs(Map<String, dynamic> sync) async {
    final id = _toInt(sync['id_sincronizacion']);
    if (id == null) return;

    proveedorController.limpiarLogsSincronizacion();
    syncLogLevel = 'TODOS';
    syncLogProvider = 'TODOS';

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Obx(() => _syncLogsDialog(
              dialogContext,
              sync,
              setModalState,
            ));
          },
        );
      },
    );

    try {
      await getLogsSincronizacionCatalogoApi(
        idSincronizacion: id,
        proveedorController: proveedorController,
      );
    } catch (_) {}
  }

  Widget _syncLogsDialog(
      BuildContext dialogContext,
      Map<String, dynamic> sync,
      StateSetter setModalState,
      ) {
    final size = MediaQuery.sizeOf(dialogContext);
    final mobile = size.width < 700;
    final loading = proveedorController.cargandoLogsSincronizacion.value;
    final error = proveedorController.errorLogsSincronizacion.value;
    final allLogs = proveedorController.logsSincronizacion;

    final providers = allLogs
        .map((e) => e['proveedor']?.toString().trim())
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final logs = allLogs.where((log) {
      final level = log['nivel']?.toString().toUpperCase() ?? '';
      final provider = log['proveedor']?.toString() ?? '';
      return (syncLogLevel == 'TODOS' || level == syncLogLevel) &&
          (syncLogProvider == 'TODOS' || provider == syncLogProvider);
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: mobile ? 10 : 35,
        vertical: mobile ? 15 : 35,
      ),
      child: Container(
        width: mobile ? size.width : 1050,
        height: size.height * .86,
        decoration: BoxDecoration(
          color: Global.container,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Global.text.withOpacity(.08)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 10, 13),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Global.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(Icons.terminal_rounded, color: Global.primary),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registro técnico',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Global.text,
                          ),
                        ),
                        Text(
                          'Sincronización #${sync['id_sincronizacion']} · ${_date(sync['inicio'] ?? sync['created_at'])}',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Global.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Global.text.withOpacity(.08)),

            if (!loading && error.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final level = DropdownButtonFormField<String>(
                      value: syncLogLevel,
                      isExpanded: true,
                      decoration: _filterDecoration('Nivel'),
                      items: const [
                        DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
                        DropdownMenuItem(value: 'INFO', child: Text('Información')),
                        DropdownMenuItem(value: 'WARN', child: Text('Advertencias')),
                        DropdownMenuItem(value: 'ERROR', child: Text('Errores')),
                      ],
                      onChanged: (value) =>
                          setModalState(() => syncLogLevel = value ?? 'TODOS'),
                    );

                    final provider = DropdownButtonFormField<String>(
                      value: providers.contains(syncLogProvider)
                          ? syncLogProvider
                          : 'TODOS',
                      isExpanded: true,
                      decoration: _filterDecoration('Proveedor'),
                      items: [
                        const DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
                        ...providers.map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                        ),
                      ],
                      onChanged: (value) =>
                          setModalState(() => syncLogProvider = value ?? 'TODOS'),
                    );

                    final copy = OutlinedButton.icon(
                      onPressed: logs.isEmpty ? null : () => _copyLogs(logs),
                      icon: const Icon(Icons.copy_all_rounded, size: 17),
                      label: const Text('Copiar'),
                    );

                    if (constraints.maxWidth < 650) {
                      return Column(
                        children: [
                          level,
                          const SizedBox(height: 8),
                          provider,
                          const SizedBox(height: 8),
                          SizedBox(width: double.infinity, child: copy),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: level),
                        const SizedBox(width: 8),
                        Expanded(child: provider),
                        const SizedBox(width: 8),
                        copy,
                      ],
                    );
                  },
                ),
              ),

            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator(color: Global.primary))
                  : error.isNotEmpty
                  ? _syncLogError(sync, setModalState)
                  : logs.isEmpty
                  ? _emptyState(
                icon: Icons.terminal_rounded,
                title: 'No hay registros para mostrar',
                description: 'No existen eventos con los filtros seleccionados.',
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                itemCount: logs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (_, index) => _syncLogItem(logs[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _syncLogItem(Map<String, dynamic> log) {
    final level = log['nivel']?.toString().toUpperCase() ?? 'INFO';
    final color = level == 'ERROR'
        ? const Color(0xFFC84C4C)
        : level == 'WARN'
        ? const Color(0xFFE88725)
        : const Color(0xFF3976D3);

    final detail = log['detalle'];
    final hasDetail = detail is Map && detail.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Global.bg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withOpacity(.12)),
      ),
      child: ExpansionTile(
        enabled: hasDetail,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          width: 8,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        title: Row(
          children: [
            _statusChip(level, color),
            const SizedBox(width: 7),
            if (log['proveedor'] != null) ...[
              Flexible(
                child: Text(
                  log['proveedor'].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              log['etapa']?.toString() ?? 'GENERAL',
              style: GoogleFonts.poppins(
                fontSize: 8,
                color: Global.textSecondary,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              log['mensaje']?.toString() ?? '',
              style: GoogleFonts.poppins(
                fontSize: 9,
                height: 1.4,
                color: Global.text,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _date(log['created_at']),
              style: GoogleFonts.poppins(
                fontSize: 7.5,
                color: Global.textSecondary,
              ),
            ),
          ],
        ),
        children: [
          if (hasDetail)
            SelectableText(
              _prettyValue(detail),
              style: GoogleFonts.robotoMono(
                fontSize: 9,
                height: 1.45,
                color: Global.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  String _prettyValue(dynamic value) {
    try {
      if (value is Map || value is List) {
        return const JsonEncoder.withIndent('  ').convert(value);
      }
      return value?.toString() ?? '';
    } catch (_) {
      return value?.toString() ?? '';
    }
  }

  Future<void> _copyLogs(List<Map<String, dynamic>> logs) async {
    final text = logs.map((log) {
      final date = _date(log['created_at']);
      final level = log['nivel'] ?? 'INFO';
      final provider = log['proveedor'] ?? 'Sistema';
      final stage = log['etapa'] ?? 'GENERAL';
      final message = log['mensaje'] ?? '';
      return '$date | $level | $provider | $stage | $message';
    }).join('\n');

    await Clipboard.setData(ClipboardData(text: text));

    if (mounted) {
      Get.snackbar(
        'Registro copiado',
        '${logs.length} eventos fueron copiados al portapapeles.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF278568),
        colorText: Colors.white,
      );
    }
  }

  Widget _syncLogError(
      Map<String, dynamic> sync,
      StateSetter setModalState,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Color(0xFFC84C4C),
            ),
            const SizedBox(height: 10),
            Text(
              proveedorController.errorLogsSincronizacion.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 10, color: Global.text),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final id = _toInt(sync['id_sincronizacion']);
                if (id == null) return;

                try {
                  await getLogsSincronizacionCatalogoApi(
                    idSincronizacion: id,
                    proveedorController: proveedorController,
                  );
                } catch (_) {}
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
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