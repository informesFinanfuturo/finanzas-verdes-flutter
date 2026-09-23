import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Viewactivosasesor extends StatefulWidget {
  final List<Map<String, dynamic>> activos;
  final VoidCallback onCreateAsset;

  final Future<void> Function(
      Map<String, dynamic> activo,
      ) onOpenAsset;

  const Viewactivosasesor({
    super.key,
    required this.activos,
    required this.onCreateAsset,
    required this.onOpenAsset,
  });

  @override
  State<Viewactivosasesor> createState() =>
      _ViewactivosasesorState();
}

class _ViewactivosasesorState
    extends State<Viewactivosasesor>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController =
  TextEditingController();

  String _searchText = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> _groupAssets() {
    // Copia la lista para no alterar la información del controlador.
    final activos = List<Map<String, dynamic>>.from(
      widget.activos,
    );

    final filteredAssets = activos.where((activo) {
      if (_searchText.trim().isEmpty) {
        return true;
      }

      final query = _searchText.toLowerCase().trim();

      final nombre = (activo['nombre'] ?? '')
          .toString()
          .toLowerCase();

      final tipo = (activo['tipo'] ?? '')
          .toString()
          .toLowerCase();

      final cantidad = (activo['cantidad'] ?? '')
          .toString()
          .toLowerCase();

      return nombre.contains(query) ||
          tipo.contains(query) ||
          cantidad.contains(query);
    }).toList();

    // Ordena inicialmente por tipo.
    filteredAssets.sort(
          (a, b) => (a['tipo'] ?? 'Sin categoría')
          .toString()
          .compareTo(
        (b['tipo'] ?? 'Sin categoría').toString(),
      ),
    );

    final Map<String, List<Map<String, dynamic>>>
    assetsByType = {};

    for (final activo in filteredAssets) {
      final rawType =
      (activo['tipo'] ?? 'Sin categoría')
          .toString()
          .trim();

      final type = rawType.isEmpty
          ? 'Sin categoría'
          : rawType;

      assetsByType.putIfAbsent(
        type,
            () => [],
      );

      assetsByType[type]!.add(activo);
    }

    // Ordena alfabéticamente los activos de cada grupo.
    for (final assets in assetsByType.values) {
      assets.sort(
            (a, b) => (a['nombre'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo(
          (b['nombre'] ?? '')
              .toString()
              .toLowerCase(),
        ),
      );
    }

    return assetsByType;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final groupedAssets = _groupAssets();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: isDesktop,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDesktop),

                const SizedBox(height: 18),

                _buildSearchField(),

                const SizedBox(height: 18),

                if (groupedAssets.isEmpty)
                  _buildEmptyState()
                else
                  ...groupedAssets.entries.map(
                        (entry) => AssetGroup(
                      title: entry.key,
                      activos: entry.value,
                      isDesktop: isDesktop,
                      onOpenAsset: widget.onOpenAsset,
                    ),
                  ),
                
                SafeArea(child: SizedBox())
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF28A745).withOpacity(0.14),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: Color(0xFF28A745),
            size: 25,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activos',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Global.text,
                ),
              ),
              Text(
                '${widget.activos.length} activos registrados',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Global.text.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        if (isDesktop)
          ElevatedButton.icon(
            onPressed: widget.onCreateAsset,
            icon: const Icon(
              Icons.add_rounded,
              size: 20,
            ),
            label: Text(
              'Nuevo activo',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Global.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        else
          IconButton.filled(
            onPressed: widget.onCreateAsset,
            tooltip: 'Nuevo activo',
            style: IconButton.styleFrom(
              backgroundColor: Global.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add_rounded),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Global.text,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o tipo',
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Global.text.withOpacity(0.45),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Global.text.withOpacity(0.55),
        ),
        suffixIcon: _searchText.isNotEmpty
            ? IconButton(
          onPressed: () {
            _searchController.clear();

            setState(() {
              _searchText = '';
            });
          },
          tooltip: 'Limpiar búsqueda',
          icon: Icon(
            Icons.close_rounded,
            color: Global.text.withOpacity(0.55),
          ),
        )
            : null,
        filled: true,
        fillColor: Global.container,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Global.text.withOpacity(0.10),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Global.text.withOpacity(0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Global.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool searching = _searchText.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Global.text.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Global.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searching
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              size: 36,
              color: Global.primary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            searching
                ? 'No encontramos activos'
                : 'No hay activos registrados',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Global.text,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            searching
                ? 'Prueba la búsqueda con otro nombre o categoría.'
                : 'Registra el primer activo del cliente.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Global.text.withOpacity(0.6),
            ),
          ),

          if (!searching) ...[
            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: widget.onCreateAsset,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar activo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Global.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AssetGroup extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> activos;
  final bool isDesktop;

  final Future<void> Function(
      Map<String, dynamic> activo,
      ) onOpenAsset;

  const AssetGroup({
    super.key,
    required this.title,
    required this.activos,
    required this.isDesktop,
    required this.onOpenAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Global.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  getAssetTypeIcon(title),
                  size: 19,
                  color: Global.primary,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Global.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${activos.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Global.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final int columns =
              isDesktop ? 3 : 1;

              const double spacing = 12;

              final double cardWidth =
                  (constraints.maxWidth -
                      spacing * (columns - 1)) /
                      columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: activos.map((activo) {
                  return SizedBox(
                    width: cardWidth,
                    child: AssetCard(
                      activo: activo,
                      onTap: () => onOpenAsset(activo),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  static IconData getAssetTypeIcon(String type) {
    final normalizedType = type
        .trim()
        .toLowerCase();

    switch (normalizedType) {
      case 'neveras':
        return Icons.kitchen_rounded;

      case 'televisores':
        return Icons.tv_rounded;

      case 'hornos':
        return Icons.microwave_rounded;

      case 'climatización':
      case 'climatizacion':
        return Icons.ac_unit_rounded;

      case 'vitrinas':
        return Icons.storefront_rounded;

      case 'refrigeración':
      case 'refrigeracion':
        return Icons.severe_cold_rounded;

      case 'secadoras':
        return Icons.dry_cleaning_rounded;

      case 'iluminación':
      case 'iluminacion':
        return Icons.lightbulb_rounded;

      case 'lavadoras':
        return Icons.local_laundry_service_rounded;

      case 'lava vajillas':
      case 'lavavajillas':
        return Icons.local_dining_rounded;

      case 'sanitarios':
        return Icons.wc_rounded;

      case 'grifos':
        return Icons.water_drop_rounded;

      case 'otro':
      default:
        return Icons.inventory_2_rounded;
    }
  }
}

class AssetCard extends StatefulWidget {
  final Map<String, dynamic> activo;
  final Future<void> Function() onTap;

  const AssetCard({
    super.key,
    required this.activo,
    required this.onTap,
  });

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  bool _isLoading = false;

  Future<void> _openAsset() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onTap();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String getValue(
      String key, {
        String fallback = 'No registrado',
      }) {
    final value = widget.activo[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = getValue(
      'nombre',
      fallback: 'Activo sin nombre',
    );

    final String tipo = getValue(
      'tipo',
      fallback: 'Sin categoría',
    );

    final String cantidad = getValue(
      'cantidad',
      fallback: '1',
    );

    final IconData typeIcon =
    AssetGroup.getAssetTypeIcon(tipo);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _openAsset,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 112,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Global.container,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Global.primary.withOpacity(0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Global.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  typeIcon,
                  size: 25,
                  color: Global.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Global.text,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      tipo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Global.primary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.numbers_rounded,
                          size: 15,
                          color: Global.text.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Cantidad: $cantidad',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Global.text.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              if (_isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Global.primary,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: Global.text.withOpacity(0.45),
                ),
            ],
          ),
        ),
      ),
    );
  }
}