import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Viewfacturasasesor extends StatefulWidget {
  final List<Map<String, dynamic>> facturas;

  final VoidCallback onCreateInvoice;

  final Future<void> Function(
      Map<String, dynamic> factura,
      ) onOpenInvoice;

  const Viewfacturasasesor({
    super.key,
    required this.facturas,
    required this.onCreateInvoice,
    required this.onOpenInvoice,
  });

  @override
  State<Viewfacturasasesor> createState() =>
      _ViewfacturasasesorState();
}

class _ViewfacturasasesorState
    extends State<Viewfacturasasesor>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  String _searchText = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> _groupInvoices() {
    // Se crea una copia para no modificar la lista original.
    final facturas = List<Map<String, dynamic>>.from(
      widget.facturas,
    );

    // Filtrado por búsqueda.
    final filteredInvoices = facturas.where((factura) {
      if (_searchText.trim().isEmpty) return true;

      final query = _searchText.toLowerCase().trim();

      final tipo = (factura['tipo'] ?? '')
          .toString()
          .toLowerCase();

      final periodo = (factura['periodo_inicio'] ?? '')
          .toString()
          .toLowerCase();

      final valor = (factura['valor'] ?? '')
          .toString()
          .toLowerCase();

      return tipo.contains(query) ||
          periodo.contains(query) ||
          valor.contains(query);
    }).toList();

    // Ordena primero por tipo.
    filteredInvoices.sort(
          (a, b) => (a['tipo'] ?? 'Sin categoría')
          .toString()
          .compareTo(
        (b['tipo'] ?? 'Sin categoría').toString(),
      ),
    );

    final Map<String, List<Map<String, dynamic>>>
    invoicesByType = {};

    for (final factura in filteredInvoices) {
      final tipo = (factura['tipo'] ?? 'Sin categoría')
          .toString()
          .trim();

      final category = tipo.isEmpty
          ? 'Sin categoría'
          : tipo;

      invoicesByType.putIfAbsent(
        category,
            () => [],
      );

      invoicesByType[category]!.add(factura);
    }

    // Ordena cada grupo por fecha, mostrando primero lo más reciente.
    for (final invoices in invoicesByType.values) {
      invoices.sort(
            (a, b) => (b['periodo_inicio'] ?? '')
            .toString()
            .compareTo(
          (a['periodo_inicio'] ?? '').toString(),
        ),
      );
    }

    return invoicesByType;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final groupedInvoices = _groupInvoices();

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

                if (groupedInvoices.isEmpty)
                  _buildEmptyState()
                else
                  ...groupedInvoices.entries.map(
                        (entry) => _InvoiceGroup(
                      title: entry.key,
                      facturas: entry.value,
                      isDesktop: isDesktop,
                      onOpenInvoice: widget.onOpenInvoice,
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
            color: const Color(0xFF2196F3).withOpacity(0.14),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Color(0xFF2196F3),
            size: 25,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Facturas y consumos',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Global.text,
                ),
              ),
              Text(
                '${widget.facturas.length} facturas registradas',
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
            onPressed: widget.onCreateInvoice,
            icon: const Icon(
              Icons.add_rounded,
              size: 20,
            ),
            label: const Text('Nueva factura'),
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
            onPressed: widget.onCreateInvoice,
            tooltip: 'Nueva factura',
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
        hintText: 'Buscar por tipo, fecha o valor',
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Global.text.withOpacity(0.45),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Global.text.withOpacity(0.55),
        ),
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
                  : Icons.receipt_long_outlined,
              size: 36,
              color: Global.primary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            searching
                ? 'No encontramos facturas'
                : 'No hay facturas registradas',
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
                ? 'Intenta realizar la búsqueda con otros datos.'
                : 'Registra la primera factura de consumo del cliente.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Global.text.withOpacity(0.6),
            ),
          ),

          if (!searching) ...[
            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: widget.onCreateInvoice,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar factura'),
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

class _InvoiceGroup extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> facturas;
  final bool isDesktop;

  final Future<void> Function(
      Map<String, dynamic> factura,
      ) onOpenInvoice;

  const _InvoiceGroup({
    required this.title,
    required this.facturas,
    required this.isDesktop,
    required this.onOpenInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final int columns;

    if (!isDesktop) {
      columns = 1;
    } else {
      columns = 3;
    }

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
                  _getInvoiceTypeIcon(title),
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
                  '${facturas.length}',
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
              const double spacing = 12;

              final double cardWidth =
                  (constraints.maxWidth -
                      (spacing * (columns - 1))) /
                      columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: facturas.map((factura) {
                  return SizedBox(
                    width: cardWidth,
                    child: _InvoiceCard(
                      factura: factura,
                      onTap: () => onOpenInvoice(factura),
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

  static IconData _getInvoiceTypeIcon(String type) {
    final normalizedType = type.toLowerCase();

    if (normalizedType.contains('agua')) {
      return Icons.water_drop_rounded;
    }

    if (normalizedType.contains('energ')) {
      return Icons.bolt_rounded;
    }

    if (normalizedType.contains('gas')) {
      return Icons.local_fire_department_rounded;
    }

    return Icons.receipt_long_rounded;
  }
}

class _InvoiceCard extends StatefulWidget {
  final Map<String, dynamic> factura;
  final Future<void> Function() onTap;

  const _InvoiceCard({
    required this.factura,
    required this.onTap,
  });

  @override
  State<_InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
  bool _isLoading = false;

  Future<void> _openInvoice() async {
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

  String getValue(String key, {String fallback = 'No registrado'}) {
    final value = widget.factura[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final String tipo = getValue(
      'tipo',
      fallback: 'Sin categoría',
    );

    final String periodo = getValue(
      'periodo_inicio',
      fallback: 'Sin fecha',
    );

    final dynamic valor = widget.factura['valor'];

    final String formattedValue = valor == null
        ? 'Valor no registrado'
        : '\$${Utils.formatMiles(valor)}';

    final Color typeColor = _getTypeColor(tipo);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _openInvoice,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 118,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Global.container,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: typeColor.withOpacity(0.22),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  _getTypeIcon(tipo),
                  color: typeColor,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periodo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Global.text,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      tipo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: typeColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      formattedValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Global.text.withOpacity(0.75),
                      ),
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

  Color _getTypeColor(String type) {
    final normalizedType = type.toLowerCase();

    if (normalizedType.contains('agua')) {
      return const Color(0xFF2196F3);
    }

    if (normalizedType.contains('energ')) {
      return const Color(0xFFF5A000);
    }

    if (normalizedType.contains('gas')) {
      return const Color(0xFFE85D4A);
    }

    return Global.primary;
  }

  IconData _getTypeIcon(String type) {
    final normalizedType = type.toLowerCase();

    if (normalizedType.contains('agua')) {
      return Icons.water_drop_rounded;
    }

    if (normalizedType.contains('energ')) {
      return Icons.bolt_rounded;
    }

    if (normalizedType.contains('gas')) {
      return Icons.local_fire_department_rounded;
    }

    return Icons.receipt_long_rounded;
  }
}