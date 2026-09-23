import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Viewdiagnosticosasesor extends StatefulWidget {
  final List<Map<String, dynamic>> diagnosticos;

  final Future<void> Function() onCreateDiagnostic;

  final Future<void> Function(
      Map<String, dynamic> diagnostico,
      ) onOpenDiagnostic;

  const Viewdiagnosticosasesor({
    super.key,
    required this.diagnosticos,
    required this.onCreateDiagnostic,
    required this.onOpenDiagnostic,
  });

  @override
  State<Viewdiagnosticosasesor> createState() =>
      _ViewdiagnosticosasesorState();
}

class _ViewdiagnosticosasesorState
    extends State<Viewdiagnosticosasesor>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController =
  TextEditingController();

  String _searchText = '';
  bool _isCreating = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredDiagnostics {
    final diagnosticos =
    List<Map<String, dynamic>>.from(
      widget.diagnosticos,
    );

    final query = _searchText
        .trim()
        .toLowerCase();

    if (query.isEmpty) {
      return diagnosticos;
    }

    return diagnosticos.where((diagnostico) {
      final titulo = (diagnostico['titulo'] ?? '')
          .toString()
          .toLowerCase();

      final resumen = _getSummary(diagnostico)
          .toLowerCase();

      return titulo.contains(query) ||
          resumen.contains(query);
    }).toList();
  }

  static String _getSummary(
      Map<String, dynamic> diagnostico,
      ) {
    final problema = diagnostico['problema'];

    if (problema is Map) {
      final resumen = problema['resumen'];

      if (resumen != null &&
          resumen.toString().trim().isNotEmpty) {
        return resumen.toString().trim();
      }
    }

    return '';
  }

  Future<void> _createDiagnostic() async {
    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      await widget.onCreateDiagnostic();
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final diagnostics = _filteredDiagnostics;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop =
            constraints.maxWidth > 800;

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: isDesktop,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeader(isDesktop),

                const SizedBox(height: 18),

                if (widget.diagnosticos.isNotEmpty) ...[
                  _buildSearchField(),
                  const SizedBox(height: 18),
                ],

                if (diagnostics.isEmpty)
                  _buildEmptyState()
                else
                  _buildDiagnosticCards(
                    diagnostics: diagnostics,
                    isDesktop: isDesktop,
                  ),
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
            color: const Color(0xFF8E44C2)
                .withOpacity(0.14),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.analytics_rounded,
            color: Color(0xFF8E44C2),
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
                'Diagnósticos',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Global.text,
                ),
              ),
              Text(
                '${widget.diagnosticos.length} '
                    '${widget.diagnosticos.length == 1 ? "diagnóstico realizado" : "diagnósticos realizados"}',
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
            onPressed:
            _isCreating ? null : _createDiagnostic,
            icon: _isCreating
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.add_rounded,
              size: 20,
            ),
            label: Text(
              _isCreating
                  ? 'Preparando...'
                  : 'Nuevo diagnóstico',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Global.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
              Global.primary.withOpacity(0.6),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
            ),
          )
        else
          IconButton.filled(
            onPressed:
            _isCreating ? null : _createDiagnostic,
            tooltip: 'Nuevo diagnóstico',
            style: IconButton.styleFrom(
              backgroundColor: Global.primary,
              foregroundColor: Colors.white,
            ),
            icon: _isCreating
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.add_rounded),
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
        hintText: 'Buscar diagnóstico',
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

  Widget _buildDiagnosticCards({
    required List<Map<String, dynamic>> diagnostics,
    required bool isDesktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = isDesktop ? 2 : 1;
        const double spacing = 14;

        final double cardWidth =
            (constraints.maxWidth -
                spacing * (columns - 1)) /
                columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            ...
            diagnostics.map((diagnostico) {
              return SizedBox(
                width: cardWidth,
                child: DiagnosticCard(
                  diagnostico: diagnostico,
                  onTap: () {
                    return widget.onOpenDiagnostic(
                      diagnostico,
                    );
                  },
                ),
              );
            }).toList(),
            SafeArea(child: SizedBox())
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final bool searching =
        _searchText.trim().isNotEmpty;

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
              color: const Color(0xFF8E44C2)
                  .withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searching
                  ? Icons.search_off_rounded
                  : Icons.analytics_outlined,
              size: 36,
              color: const Color(0xFF8E44C2),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            searching
                ? 'No encontramos diagnósticos'
                : 'No hay diagnósticos realizados',
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
                ? 'Intenta buscar con otro título o palabra.'
                : 'Crea el primer diagnóstico del cliente.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Global.text.withOpacity(0.6),
            ),
          ),

          if (!searching) ...[
            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed:
              _isCreating ? null : _createDiagnostic,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Crear diagnóstico',
              ),
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

class DiagnosticCard extends StatefulWidget {
  final Map<String, dynamic> diagnostico;
  final Future<void> Function() onTap;

  const DiagnosticCard({
    super.key,
    required this.diagnostico,
    required this.onTap,
  });

  @override
  State<DiagnosticCard> createState() =>
      _DiagnosticCardState();
}

class _DiagnosticCardState
    extends State<DiagnosticCard> {
  bool _isLoading = false;

  Future<void> _openDiagnostic() async {
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

  String get _title {
    final title = widget.diagnostico['titulo'];

    if (title == null ||
        title.toString().trim().isEmpty) {
      return 'Diagnóstico sin título';
    }

    return title.toString().trim();
  }

  String get _summary {
    final problema =
    widget.diagnostico['problema'];

    if (problema is Map) {
      final resumen = problema['resumen'];

      if (resumen != null &&
          resumen.toString().trim().isNotEmpty) {
        return resumen.toString().trim();
      }
    }

    return 'Este diagnóstico no tiene un resumen registrado.';
  }

  @override
  Widget build(BuildContext context) {
    const diagnosticColor = Color(0xFF8E44C2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
        _isLoading ? null : _openDiagnostic,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 150,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Global.container,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: diagnosticColor.withOpacity(0.20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: diagnosticColor
                          .withOpacity(0.12),
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      size: 23,
                      color: diagnosticColor,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      _title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Global.text,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: diagnosticColor,
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Global.text.withOpacity(0.45),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                _summary,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.45,
                  color: Global.text.withOpacity(0.68),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    size: 17,
                    color: diagnosticColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Ver diagnóstico',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: diagnosticColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

