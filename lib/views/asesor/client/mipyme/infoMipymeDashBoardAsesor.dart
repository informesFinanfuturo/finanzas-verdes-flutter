import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientInformationSection extends StatefulWidget {
  final Map? mipyme;
  final VoidCallback? onEdit;

  const ClientInformationSection({
    super.key,
    required this.mipyme,
    this.onEdit,
  });

  @override
  State<ClientInformationSection> createState() =>
      _ClientInformationSectionState();
}

class _ClientInformationSectionState
    extends State<ClientInformationSection>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  // Mantiene el estado y la posición del scroll dentro del PageView.
  @override
  bool get wantKeepAlive => true;

  Map get mipyme => widget.mipyme ?? {};

  String getValue(String key) {
    final value = mipyme[key];

    if (value == null || value.toString().trim().isEmpty) {
      return 'No registrado';
    }

    return value.toString().trim();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;

        const double spacing = 16;

        final double cardWidth = isDesktop
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

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
                _buildTitle(),

                const SizedBox(height: 16),

                _buildCompanyHeader(),

                const SizedBox(height: 16),

                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _InfoSectionCard(
                        icon: Icons.business_center_rounded,
                        iconColor: const Color(0xFF2196F3),
                        title: 'Información general',
                        children: [
                          _InfoRow(
                            icon: Icons.badge_outlined,
                            label: 'NIT',
                            value: getValue('nit'),
                          ),
                          _InfoRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Tipo de persona',
                            value: getValue('tipo_persona'),
                          ),
                          _InfoRow(
                            icon: Icons.apartment_rounded,
                            label: 'Tipo de empresa',
                            value: getValue('tipo_empresa'),
                          ),
                          _InfoRow(
                            icon: Icons.category_outlined,
                            label: 'Sector económico',
                            value: getValue('sector_economico'),
                          ),
                          _InfoRow(
                            icon: Icons.numbers_rounded,
                            label: 'Código CIIU',
                            value: getValue('codigo_ciiu'),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: cardWidth,
                      child: _InfoSectionCard(
                        icon: Icons.location_on_rounded,
                        iconColor: const Color(0xFFF5A000),
                        title: 'Ubicación',
                        children: [
                          _InfoRow(
                            icon: Icons.signpost_outlined,
                            label: 'Dirección',
                            value: getValue('direccion'),
                          ),
                          _InfoRow(
                            icon: Icons.map_outlined,
                            label: 'Departamento',
                            value: getValue('departamento'),
                          ),
                          _InfoRow(
                            icon: Icons.location_city_outlined,
                            label: 'Municipio',
                            value: getValue('municipio'),
                          ),
                          _InfoRow(
                            icon: Icons.home_work_outlined,
                            label: 'Barrio',
                            value: getValue('barrio'),
                          ),
                          _InfoRow(
                            icon: Icons.layers_outlined,
                            label: 'Estrato',
                            value: getValue('estrato'),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: cardWidth,
                      child: _InfoSectionCard(
                        icon: Icons.groups_rounded,
                        iconColor: const Color(0xFF8E44C2),
                        title: 'Capacidad empresarial',
                        children: [
                          _InfoRow(
                            icon: Icons.people_outline_rounded,
                            label: 'Número de empleados',
                            value: getValue('cantidad_empleados'),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: cardWidth,
                      child: _InfoSectionCard(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF28A745),
                        title: 'Descripción de la empresa',
                        children: [
                          _DescriptionField(
                            value: getValue('descripcion_empresa'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (widget.onEdit != null) ...[
                  const SizedBox(height: 20),

                  Align(
                    alignment: isDesktop
                        ? Alignment.centerRight
                        : Alignment.center,
                    child: SizedBox(
                      width: isDesktop ? 220 : double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: widget.onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                        ),
                        label: Text(
                          'Editar información',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Global.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(child: SizedBox(width: double.infinity))
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Global.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.apartment_rounded,
            color: Global.primary,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información de la empresa',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Global.text,
                ),
              ),
              Text(
                'Datos generales y ubicación del cliente',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Global.text.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Global.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Global.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.business_rounded,
              size: 30,
              color: Global.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getValue('nombre_mipyme'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Global.text.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${getValue('municipio')}, '
                            '${getValue('departamento')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Global.text.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _InfoSectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Global.text.withOpacity(0.08),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...children,
        ],
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final String value;

  const _DescriptionField({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != 'No registrado';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Global.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 13,
          height: 1.5,
          fontStyle: hasValue
              ? FontStyle.normal
              : FontStyle.italic,
          color: hasValue
              ? Global.text.withOpacity(0.8)
              : Global.text.withOpacity(0.45),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  bool get hasValue => value != 'No registrado';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 19,
                color: hasValue
                    ? Global.primary
                    : Global.text.withOpacity(0.35),
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Global.text.withOpacity(0.6),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 6,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: hasValue
                        ? FontWeight.w500
                        : FontWeight.w400,
                    fontStyle: hasValue
                        ? FontStyle.normal
                        : FontStyle.italic,
                    color: hasValue
                        ? Global.text
                        : Global.text.withOpacity(0.45),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (showDivider)
          Divider(
            height: 1,
            color: Global.text.withOpacity(0.07),
          ),
      ],
    );
  }
}