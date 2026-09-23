import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Viewplanestrabajosasesor extends StatefulWidget {
  final List<Map<String, dynamic>> planes;

  final Future<void> Function() onCreatePlan;

  final Future<void> Function(
      Map<String, dynamic> plan,
      ) onOpenPlan;

  final Future<void> Function(
      Map<String, dynamic> plan,
      ) onEditPlan;

  const Viewplanestrabajosasesor({
    super.key,
    required this.planes,
    required this.onCreatePlan,
    required this.onOpenPlan,
    required this.onEditPlan,
  });

  @override
  State<Viewplanestrabajosasesor> createState() =>
      _ViewplanestrabajosasesorState();
}

class _ViewplanestrabajosasesorState
    extends State<Viewplanestrabajosasesor>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController =
  ScrollController();

  final TextEditingController _searchController =
  TextEditingController();

  String _searchText = '';
  bool _isCreating = false;

  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> get _filteredPlans {
    final plans = List<Map<String, dynamic>>.from(
      widget.planes,
    );

    final query = _searchText.trim().toLowerCase();

    final filtered = plans.where((plan) {
      if (query.isEmpty) return true;

      final name = (plan['nombre_plan_trabajo'] ?? '')
          .toString()
          .toLowerCase();

      final description = (plan['descripcion'] ?? '')
          .toString()
          .toLowerCase();

      return name.contains(query) ||
          description.contains(query);
    }).toList();

    // Los planes incompletos aparecen primero.
    filtered.sort((a, b) {
      final progressA = _parseProgress(
        a['porcentaje_completado'],
      );

      final progressB = _parseProgress(
        b['porcentaje_completado'],
      );

      return progressA.compareTo(progressB);
    });

    return filtered;
  }

  static double _parseProgress(dynamic value) {
    final progress = double.tryParse(
      (value ?? '0').toString(),
    ) ??
        0;

    return progress.clamp(0, 100).toDouble();
  }

  Future<void> _createPlan() async {
    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      await widget.onCreatePlan();
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

    final plans = _filteredPlans;

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

                if (widget.planes.isNotEmpty) ...[
                  _buildSummary(),
                  const SizedBox(height: 14),
                  _buildSearchField(),
                  const SizedBox(height: 18),
                ],

                if (plans.isEmpty)
                  _buildEmptyState()
                else
                  _buildPlansGrid(
                    plans: plans,
                    isDesktop: isDesktop,
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
            color: const Color(0xFFF5A000)
                .withOpacity(0.14),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.assignment_rounded,
            color: Color(0xFFF5A000),
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
                'Planes de trabajo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Global.text,
                ),
              ),
              Text(
                '${widget.planes.length} '
                    '${widget.planes.length == 1 ? "plan registrado" : "planes registrados"}',
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
            _isCreating ? null : _createPlan,
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
                  : 'Nuevo plan',
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
            _isCreating ? null : _createPlan,
            tooltip: 'Nuevo plan de trabajo',
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

  Widget _buildSummary() {
    final completedPlans = widget.planes.where((plan) {
      return _parseProgress(
        plan['porcentaje_completado'],
      ) >=
          100;
    }).length;

    final plansInProgress =
        widget.planes.length - completedPlans;

    return Row(
      children: [
        Expanded(
          child: _SummaryIndicator(
            label: 'En progreso',
            value: plansInProgress.toString(),
            icon: Icons.pending_actions_rounded,
            color: const Color(0xFFF5A000),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryIndicator(
            label: 'Completados',
            value: completedPlans.toString(),
            icon: Icons.task_alt_rounded,
            color: const Color(0xFF28A745),
          ),
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
        hintText: 'Buscar plan de trabajo',
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

  Widget _buildPlansGrid({
    required List<Map<String, dynamic>> plans,
    required bool isDesktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Los planes contienen más información,
        // por eso se recomiendan dos columnas.
        final int columns = isDesktop ? 2 : 1;
        const double spacing = 14;

        final cardWidth =
            (constraints.maxWidth -
                spacing * (columns - 1)) /
                columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: plans.map((plan) {
            return SizedBox(
              width: cardWidth,
              child: WorkPlanCard(
                plan: plan,
                onOpen: () {
                  return widget.onOpenPlan(plan);
                },
                onEdit: () {
                  return widget.onEditPlan(plan);
                },
              ),
            );
          }).toList(),
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
              color: const Color(0xFFF5A000)
                  .withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searching
                  ? Icons.search_off_rounded
                  : Icons.assignment_outlined,
              size: 36,
              color: const Color(0xFFF5A000),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            searching
                ? 'No encontramos planes'
                : 'No hay planes de trabajo',
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
                ? 'Intenta buscar con otro nombre.'
                : 'Crea el primer plan de trabajo del cliente.',
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
              _isCreating ? null : _createPlan,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear plan'),
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

class _SummaryIndicator extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryIndicator({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 21,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Global.text,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Global.text.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkPlanCard extends StatefulWidget {
  final Map<String, dynamic> plan;
  final Future<void> Function() onOpen;
  final Future<void> Function() onEdit;

  const WorkPlanCard({
    super.key,
    required this.plan,
    required this.onOpen,
    required this.onEdit,
  });

  @override
  State<WorkPlanCard> createState() =>
      _WorkPlanCardState();
}

class _WorkPlanCardState extends State<WorkPlanCard> {
  bool _isOpening = false;
  bool _isEditing = false;

  double get progress {
    final value = double.tryParse(
      (widget.plan['porcentaje_completado'] ?? '0')
          .toString(),
    ) ??
        0;

    return value.clamp(0, 100).toDouble();
  }

  int get totalTasks {
    return int.tryParse(
      (widget.plan['total_tareas'] ?? '0')
          .toString(),
    ) ??
        0;
  }

  int get completedTasks {
    return int.tryParse(
      (widget.plan['tareas_completadas'] ?? '0')
          .toString(),
    ) ??
        0;
  }

  String get name {
    final value = widget.plan['nombre_plan_trabajo'];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return 'Plan de trabajo sin nombre';
    }

    return value.toString().trim();
  }

  String get description {
    return (widget.plan['descripcion'] ?? '')
        .toString()
        .trim();
  }

  String get endDate {
    final value =
    (widget.plan['fecha_fin'] ?? '')
        .toString()
        .trim();

    if (value.isEmpty) {
      return '';
    }

    try {
      return Utils.formatFechaCorta(value);
    } catch (_) {
      return value;
    }
  }

  bool get isCompleted => progress >= 100;

  bool get hasStarted =>
      progress > 0 || completedTasks > 0;

  String get status {
    if (isCompleted) return 'Completado';
    if (!hasStarted) return 'Sin iniciar';
    return 'En progreso';
  }

  Color get statusColor {
    if (isCompleted) {
      return const Color(0xFF28A745);
    }

    if (!hasStarted) {
      return const Color(0xFF78909C);
    }

    return const Color(0xFFF5A000);
  }

  Future<void> _openPlan() async {
    if (_isOpening || _isEditing) return;

    setState(() {
      _isOpening = true;
    });

    try {
      await widget.onOpen();
    } finally {
      if (mounted) {
        setState(() {
          _isOpening = false;
        });
      }
    }
  }

  Future<void> _editPlan() async {
    if (_isOpening || _isEditing) return;

    setState(() {
      _isEditing = true;
    });

    try {
      await widget.onEdit();
    } finally {
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool loading = _isOpening || _isEditing;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : _openPlan,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Global.container,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: statusColor.withOpacity(0.20),
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
                      color: statusColor.withOpacity(0.12),
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.task_alt_rounded
                          : Icons.assignment_rounded,
                      size: 23,
                      color: statusColor,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Global.text,
                      ),
                    ),
                  ),

                  if (_isEditing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  else
                    IconButton(
                      onPressed:
                      loading ? null : _editPlan,
                      tooltip: 'Editar plan',
                      visualDensity:
                      VisualDensity.compact,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Global.text.withOpacity(0.65),
                      ),
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

              if (endDate.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 17,
                      color: Color(0xFFF5A000),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Finaliza: $endDate',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Global.text.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$completedTasks de $totalTasks tareas',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Global.text.withOpacity(0.65),
                      ),
                    ),
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  backgroundColor:
                  Global.text.withOpacity(0.08),
                  valueColor:
                  AlwaysStoppedAnimation<Color>(
                    statusColor,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),

                  const Spacer(),

                  if (_isOpening)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Global.primary,
                      ),
                    )
                  else ...[
                    Text(
                      'Ver plan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Global.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Global.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}