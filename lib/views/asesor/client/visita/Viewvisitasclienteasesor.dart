import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Viewvisitasclienteasesor extends StatefulWidget {
  final List<Map<String, dynamic>> visitas;
  final Future<void> Function() onCreateVisit;

  const Viewvisitasclienteasesor({
    super.key,
    required this.visitas,
    required this.onCreateVisit,
  });

  @override
  State<Viewvisitasclienteasesor> createState() =>
      _ViewvisitasclienteasesorState();
}

class _ViewvisitasclienteasesorState
    extends State<Viewvisitasclienteasesor>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController =
  ScrollController();

  final TextEditingController _searchController =
  TextEditingController();

  String _searchText = '';
  bool _isCreating = false;

  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> get filteredVisits {
    final visits = List<Map<String, dynamic>>.from(
      widget.visitas,
    );

    final query = _searchText.trim().toLowerCase();

    final filtered = visits.where((visit) {
      if (query.isEmpty) return true;

      final title = (visit['titulo'] ?? '')
          .toString()
          .toLowerCase();

      final description = (visit['descripcion'] ?? '')
          .toString()
          .toLowerCase();

      final date = (visit['fecha_hora'] ?? '')
          .toString()
          .toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          date.contains(query);
    }).toList();

    // Muestra primero las visitas más recientes.
    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(
        (a['fecha_hora'] ?? '').toString(),
      );

      final dateB = DateTime.tryParse(
        (b['fecha_hora'] ?? '').toString(),
      );

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  Future<void> _createVisit() async {
    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      await widget.onCreateVisit();
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final visits = filteredVisits;

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

                if (widget.visitas.isNotEmpty) ...[
                  _buildSearchField(),
                  const SizedBox(height: 18),
                ],

                if (visits.isEmpty)
                  _buildEmptyState()
                else
                  _buildVisitsGrid(
                    visits: visits,
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
            color: const Color(0xFF0097A7)
                .withOpacity(0.14),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.event_available_rounded,
            color: Color(0xFF0097A7),
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
                'Visitas',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Global.text,
                ),
              ),
              Text(
                '${widget.visitas.length} '
                    '${widget.visitas.length == 1 ? "visita registrada" : "visitas registradas"}',
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
            _isCreating ? null : _createVisit,
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
            label: Text(
              _isCreating
                  ? 'Preparando...'
                  : 'Nueva visita',
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
            _isCreating ? null : _createVisit,
            tooltip: 'Nueva visita',
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
        hintText: 'Buscar por título, descripción o fecha',
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

  Widget _buildVisitsGrid({
    required List<Map<String, dynamic>> visits,
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
            visits.map((visit) {
            return SizedBox(
              width: cardWidth,
              child: VisitCard(
                visit: visit,
              ),
            );
          }).toList(),
          SafeArea(child: SizedBox())
          ]
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
              color: const Color(0xFF0097A7)
                  .withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searching
                  ? Icons.search_off_rounded
                  : Icons.event_busy_outlined,
              size: 36,
              color: const Color(0xFF0097A7),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            searching
                ? 'No encontramos visitas'
                : 'No hay visitas registradas',
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
                ? 'Intenta buscar con otros datos.'
                : 'Programa la primera visita para este cliente.',
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
              _isCreating ? null : _createVisit,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Programar visita'),
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

class VisitCard extends StatelessWidget {
  final Map<String, dynamic> visit;

  const VisitCard({
    super.key,
    required this.visit,
  });

  String get title {
    final value = visit['titulo'];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return 'Visita sin título';
    }

    return value.toString().trim();
  }

  String get description {
    return (visit['descripcion'] ?? '')
        .toString()
        .trim();
  }

  DateTime? get visitDate {
    return DateTime.tryParse(
      (visit['fecha_hora'] ?? '').toString(),
    );
  }

  String get formattedDate {
    final date = visitDate;

    if (date == null) {
      return 'Fecha no registrada';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String get formattedTime {
    final date = visitDate;

    if (date == null) return '';

    final hour =
    date.hour.toString().padLeft(2, '0');
    final minute =
    date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    const visitColor = Color(0xFF0097A7);

    return Container(
      constraints: const BoxConstraints(
        minHeight: 130,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: visitColor.withOpacity(0.20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: visitColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 25,
              color: visitColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 12,
                  runSpacing: 5,
                  children: [
                    _VisitInformation(
                      icon: Icons.calendar_today_outlined,
                      text: formattedDate,
                    ),

                    if (formattedTime.isNotEmpty)
                      _VisitInformation(
                        icon: Icons.schedule_rounded,
                        text: formattedTime,
                      ),
                  ],
                ),

                if (description.isNotEmpty) ...[
                  const SizedBox(height: 10),

                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      height: 1.4,
                      color: Global.text.withOpacity(0.65),
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
}

class _VisitInformation extends StatelessWidget {
  final IconData icon;
  final String text;

  const _VisitInformation({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 15,
          color: Color(0xFF0097A7),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Global.text.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}