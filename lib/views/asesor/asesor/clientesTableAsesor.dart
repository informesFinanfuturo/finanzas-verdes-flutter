import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/views/asesor/asesor/createCalendarioAsesor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientesTable extends StatefulWidget {
  const ClientesTable({super.key});

  @override
  State<ClientesTable> createState() => _ClientesTableState();
}

class _ClientesTableState extends State<ClientesTable> {
  final ClientController clientController = Get.find();
  final TextEditingController searchController =
  TextEditingController();

  String search = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isDark = controller.isDark.value;

      final query = search.trim().toLowerCase();

      final clientes = clientController.clients.where((cliente) {
        final nombre = _value(
          cliente["nombre_usuario"],
        ).toLowerCase();

        final empresa = _value(
          cliente["nombre_mipyme"],
        ).toLowerCase();

        final documento = _value(
          cliente["documento"],
        ).toLowerCase();

        return query.isEmpty ||
            nombre.contains(query) ||
            empresa.contains(query) ||
            documento.contains(query);
      }).toList();

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Global.container,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Global.text.withOpacity(
              isDark ? 0.10 : 0.07,
            ),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToolbar(clientes.length),

            Divider(
              height: 1,
              color: Global.text.withOpacity(0.07),
            ),

            if (clientes.isEmpty)
              _buildEmptyState()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 760) {
                    return _buildMobileList(clientes);
                  }

                  return _buildDesktopTable(clientes);
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildToolbar(int resultCount) {
    final bool hasSearch = search.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 650;

          final searchField = TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                search = value;
              });
            },
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Global.text,
            ),
            decoration: InputDecoration(
              hintText: "Buscar por cliente, empresa o documento",
              hintStyle: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Global.textSecondary,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 21,
                color: Global.textSecondary,
              ),
              suffixIcon: hasSearch
                  ? IconButton(
                onPressed: () {
                  searchController.clear();

                  setState(() {
                    search = '';
                  });
                },
                tooltip: "Limpiar búsqueda",
                icon: Icon(
                  Icons.close_rounded,
                  size: 19,
                  color: Global.textSecondary,
                ),
              )
                  : null,
              filled: true,
              fillColor: Global.bg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(
                  color: Global.text.withOpacity(0.10),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(
                  color: Global.primary,
                  width: 1.4,
                ),
              ),
            ),
          );

          final counter = Container(
            height: 44,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: Global.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.groups_rounded,
                  size: 18,
                  color: Global.primary,
                ),
                const SizedBox(width: 7),
                Text(
                  "$resultCount ${resultCount == 1 ? 'cliente' : 'clientes'}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Global.primary,
                  ),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                searchField,
                const SizedBox(height: 10),
                counter,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 12),
              counter,
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopTable(
      List<dynamic> clientes,
      ) {
    return Column(
      children: [
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          color: Global.bg.withOpacity(0.65),
          child: Row(
            children: [
              _tableHeader(
                "Cliente",
                flex: 3,
              ),
              _tableHeader(
                "Empresa",
                flex: 3,
              ),
              _tableHeader(
                "Documento",
                flex: 2,
              ),
              _tableHeader(
                "Acción",
                flex: 2,
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ),

        ...List.generate(
          clientes.length,
              (index) {
            final cliente = clientes[index];

            return _desktopRow(
              cliente: cliente,
              showDivider: index < clientes.length - 1,
            );
          },
        ),
      ],
    );
  }

  Widget _tableHeader(
      String title, {
        required int flex,
        Alignment alignment = Alignment.centerLeft,
      }) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.65,
            color: Global.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _desktopRow({
    required Map<String, dynamic> cliente,
    required bool showDivider,
  }) {
    final nombre = _value(
      cliente["nombre_usuario"],
      fallback: "Cliente sin nombre",
    );

    final empresa = _value(
      cliente["nombre_mipyme"],
      fallback: "Sin empresa registrada",
    );

    final documento = _value(
      cliente["documento"],
      fallback: "Sin documento",
    );

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _schedule(cliente),
            hoverColor: Global.primary.withOpacity(0.035),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Global.primary.withOpacity(0.09),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _initials(nombre),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Global.primary,
                            ),
                          ),
                        ),

                        const SizedBox(width: 11),

                        Expanded(
                          child: Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Global.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        empresa,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: Global.text,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 16,
                          color: Global.textSecondary,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            documento,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Global.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _scheduleButton(cliente),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (showDivider)
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Global.text.withOpacity(0.065),
          ),
      ],
    );
  }

  Widget _buildMobileList(
      List<dynamic> clientes,
      ) {
    return ListView.separated(
      itemCount: clientes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, __) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final Map<String, dynamic> cliente =
        Map<String, dynamic>.from(clientes[index]);

        return _mobileCard(cliente);
      },
    );
  }

  Widget _mobileCard(
      Map<String, dynamic> cliente,
      ) {
    final nombre = _value(
      cliente["nombre_usuario"],
      fallback: "Cliente sin nombre",
    );

    final empresa = _value(
      cliente["nombre_mipyme"],
      fallback: "Sin empresa registrada",
    );

    final documento = _value(
      cliente["documento"],
      fallback: "Sin documento",
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Global.bg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Global.text.withOpacity(0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Global.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  _initials(nombre),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Global.primary,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Global.text,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      empresa,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Global.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Global.container,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 17,
                  color: Global.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    documento,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Global.text,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: _scheduleButton(cliente),
          ),
        ],
      ),
    );
  }

  Widget _scheduleButton(
      Map<String, dynamic> cliente,
      ) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: () => _schedule(cliente),
        icon: const Icon(
          Icons.calendar_month_rounded,
          size: 17,
        ),
        label: const Text("Programar visita"),
        style: OutlinedButton.styleFrom(
          foregroundColor: Global.primary,
          backgroundColor: Global.primary.withOpacity(0.04),
          side: BorderSide(
            color: Global.primary.withOpacity(0.30),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 48,
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Global.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                color: Global.primary,
                size: 26,
              ),
            ),

            const SizedBox(height: 13),

            Text(
              "No encontramos clientes",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Global.text,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Verifica el nombre, la empresa o el documento.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: Global.textSecondary,
              ),
            ),

            if (search.trim().isNotEmpty) ...[
              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  searchController.clear();

                  setState(() {
                    search = '';
                  });
                },
                child: const Text("Limpiar búsqueda"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _schedule(
      Map<String, dynamic> cliente,
      ) {
    mostrarModalCrearCalendario(
      context,
      cliente,
      "Visita inicial",
    );
  }

  String _value(
      dynamic value, {
        String fallback = "",
      }) {
    final text = value?.toString().trim() ?? "";

    return text.isEmpty ? fallback : text;
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r"\s+"))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return "?";
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }
}