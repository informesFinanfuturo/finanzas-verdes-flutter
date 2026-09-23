import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/views/asesor/client/viewDetailsInactiveClient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Clientsasesor extends StatefulWidget {
  const Clientsasesor({
    super.key,
  });

  @override
  State<Clientsasesor> createState() =>
      _ClientsasesorState();
}

class _ClientsasesorState extends State<Clientsasesor> {
  final ClientController clientController =
  Get.put(ClientController());

  final TextEditingController searchController =
  TextEditingController();

  String searchText = '';
  String selectedFilter = 'activos';

  bool isFiltering = false;
  bool isSearchingExact = false;

  @override
  void initState() {
    super.initState();
    _loadClients('activos');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients(String filter) async {
    if (isFiltering) return;

    setState(() {
      selectedFilter = filter;
      isFiltering = true;
    });

    try {
      switch (filter) {
        case 'inactivos':
          await getClientsByEstadoApi(
            clientController: clientController,
            estado: 'inactivo',
          );
          break;

        case 'pospuestos':
          await getClientsByEstadoApi(
            clientController: clientController,
            estado: 'pospuesto',
          );
          break;

        case 'activos':
        default:
          await getClientApi(
            clientController: clientController,
          );
      }
    } catch (error) {
      Get.snackbar(
        'No fue posible cargar los clientes',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          isFiltering = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get filteredClients {
    final clients = List<Map<String, dynamic>>.from(
      clientController.clients,
    );

    final query = searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return clients;
    }

    return clients.where((client) {
      final userName = (client['nombre_usuario'] ?? '')
          .toString()
          .toLowerCase();

      final companyName = (client['nombre_mipyme'] ?? '')
          .toString()
          .toLowerCase();

      final document = (client['documento'] ?? '')
          .toString()
          .toLowerCase();

      final phone = (client['telefono'] ?? '')
          .toString()
          .toLowerCase();

      final municipality = (client['municipio'] ?? '')
          .toString()
          .toLowerCase();

      return userName.contains(query) ||
          companyName.contains(query) ||
          document.contains(query) ||
          phone.contains(query) ||
          municipality.contains(query);
    }).toList();
  }

  Future<void> _searchExactClient() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      Get.snackbar(
        'Búsqueda incompleta',
        'Ingrese un NIT o número de documento.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isSearchingExact) return;

    setState(() {
      isSearchingExact = true;
    });

    try {
      final client = await searchClient(
        query: query,
      );

      final detail = await getClientDetailApi(
        idUsuario: client['id_usuario'],
      );

      clientController.setClient(detail);

      controller.setPage(
        AsesorRoutes.dashBoardClient,
      );
    } catch (error) {
      Get.snackbar(
        'Cliente no encontrado',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSearchingExact = false;
        });
      }
    }
  }

  Future<void> _openClient(
      Map<String, dynamic> client,
      ) async {
    try {
      final detail = await getClientDetailApi(
        idUsuario: client['id_usuario'],
      );

      clientController.setClient(detail);

      final status = (client['estado'] ?? '')
          .toString()
          .toLowerCase();

      if (status == 'inactivo' ||
          status == 'pospuesto') {
        if (!mounted) return;

        viewDetailsInactiveClient(
          nombreCliente:
          client['nombre_usuario'] ?? 'Sin nombre',
          email: client['email'] ?? '',
          estado: status,
          observacionesEstado:
          client['estado_observaciones'] ?? '',
          nombreEmpresa:
          client['nombre_mipyme'] ?? '',
          telefono: client['telefono'] ?? '',
          context: context,
          idUsuario: client['id_usuario'],
        );

        return;
      }

      controller.setPage(
        AsesorRoutes.dashBoardClient,
      );
    } catch (error) {
      Get.snackbar(
        'No fue posible abrir el cliente',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _editClient(
      Map<String, dynamic> client,
      ) {
    clientController.setClient(client);

    controller.setPage(
      AsesorRoutes.editClient,
    );
  }

  void _createClient() {
    controller.setPage(
      AsesorRoutes.newClientMipyme,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop =
            constraints.maxWidth >= 900;

        final double horizontalPadding =
        isDesktop ? 28 : 12;

        return Obx(() {
          final clients = filteredClients;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isDesktop ? 24 : 12,
                  horizontalPadding,
                  0,
                ),
                child: _buildHeader(
                  isDesktop: isDesktop,
                  visibleClients: clients.length,
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: _buildSearchAndFilters(
                  isDesktop,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: AnimatedSwitcher(
                  duration:
                  const Duration(milliseconds: 220),
                  child: isFiltering
                      ? _buildLoading()
                      : clients.isEmpty
                      ? _buildEmptyState()
                      : _buildClientList(
                    clients: clients,
                    isDesktop: isDesktop,
                    horizontalPadding:
                    horizontalPadding,
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildHeader({
    required bool isDesktop,
    required int visibleClients,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: isDesktop ? 52 : 44,
          height: isDesktop ? 52 : 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Global.primary,
                Global.primary.withOpacity(0.70),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Global.primary.withOpacity(0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.groups_rounded,
            color: Colors.white,
            size: isDesktop ? 28 : 24,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clientes',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 26 : 21,
                  fontWeight: FontWeight.w700,
                  color: Global.text,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$visibleClients clientes encontrados',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Global.text.withOpacity(0.60),
                ),
              ),
            ],
          ),
        ),

        if (isDesktop)
          ElevatedButton.icon(
            onPressed: _createClient,
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 19,
            ),
            label: Text(
              'Nuevo cliente',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Global.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          )
        else
          IconButton.filled(
            onPressed: _createClient,
            tooltip: 'Nuevo cliente',
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Global.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(44, 44),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchAndFilters(bool isDesktop) {
    final searchField = TextField(
      controller: searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _searchExactClient(),
      onChanged: (value) {
        setState(() {
          searchText = value.trim().toLowerCase();
        });
      },
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Global.text,
      ),
      decoration: InputDecoration(
        hintText:
        'Buscar cliente, empresa o documento',
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Global.text.withOpacity(0.45),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Global.text.withOpacity(0.55),
        ),
        suffixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
          onPressed: () {
            searchController.clear();

            setState(() {
              searchText = '';
            });
          },
          tooltip: 'Limpiar búsqueda',
          icon: const Icon(Icons.close_rounded),
        ),
        filled: true,
        fillColor: Global.container,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Global.text.withOpacity(0.10),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Global.text.withOpacity(0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Global.primary,
            width: 1.5,
          ),
        ),
      ),
    );

    final exactSearchButton = SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isSearchingExact
            ? null
            : _searchExactClient,
        style: ElevatedButton.styleFrom(
          backgroundColor: Global.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          Global.primary.withOpacity(0.55),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isSearchingExact
            ? const SizedBox(
          width: 19,
          height: 19,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.manage_search_rounded,
              size: 20,
            ),
            if (isDesktop) ...[
              const SizedBox(width: 8),
              Text(
                'Buscar exacto',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 10),
            exactSearchButton,
          ],
        ),

        const SizedBox(height: 14),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _ClientFilterChip(
                label: 'Activos',
                icon: Icons.check_circle_outline_rounded,
                selected: selectedFilter == 'activos',
                color: const Color(0xFF238A57),
                onTap: () => _loadClients('activos'),
              ),
              const SizedBox(width: 8),
              _ClientFilterChip(
                label: 'Inactivos',
                icon: Icons.block_rounded,
                selected: selectedFilter == 'inactivos',
                color: const Color(0xFFD84A4A),
                onTap: () => _loadClients('inactivos'),
              ),
              const SizedBox(width: 8),
              _ClientFilterChip(
                label: 'Pospuestos',
                icon: Icons.schedule_rounded,
                selected: selectedFilter == 'pospuestos',
                color: const Color(0xFFE29022),
                onTap: () => _loadClients('pospuestos'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientList({
    required List<Map<String, dynamic>> clients,
    required bool isDesktop,
    required double horizontalPadding,
  }) {
    final bottomPadding =
        MediaQuery.paddingOf(context).bottom +
            (isDesktop ? 30 : 90);

    if (!isDesktop) {
      return ListView.separated(
        key: ValueKey(
          'mobile-$selectedFilter-$searchText',
        ),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          bottomPadding,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: clients.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final client = clients[index];

          return ClientPremiumCard(
            key: ValueKey(client['id_usuario']),
            client: client,
            compact: true,
            onTap: () => _openClient(client),
            onEdit: () => _editClient(client),
          );
        },
      );
    }

    final double cardHeight =
    MediaQuery.sizeOf(context).width >= 1200
        ? 265
        : 285;

    return GridView.builder(
      key: ValueKey(
        'desktop-$selectedFilter-$searchText',
      ),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        bottomPadding,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: clients.length,
      gridDelegate:
      SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 370,
        mainAxisExtent: cardHeight,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final client = clients[index];

        return ClientPremiumCard(
          key: ValueKey(client['id_usuario']),
          client: client,
          compact: false,
          onTap: () => _openClient(client),
          onEdit: () => _editClient(client),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      key: ValueKey('loading'),
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    final bool searching = searchText.isNotEmpty;

    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Global.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                searching
                    ? Icons.search_off_rounded
                    : Icons.groups_outlined,
                size: 38,
                color: Global.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              searching
                  ? 'No encontramos clientes'
                  : 'No hay clientes en esta categoría',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Global.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              searching
                  ? 'Prueba la búsqueda con otro nombre, empresa o documento.'
                  : 'Selecciona otro filtro o registra un nuevo cliente.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Global.text.withOpacity(0.60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ClientFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: selected ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withOpacity(0.14)
                : Global.container,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? color.withOpacity(0.40)
                  : Global.text.withOpacity(0.10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? color
                    : Global.text.withOpacity(0.55),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: selected
                      ? color
                      : Global.text.withOpacity(0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientPremiumCard extends StatelessWidget {
  final Map<String, dynamic> client;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const ClientPremiumCard({
    super.key,
    required this.client,
    required this.compact,
    required this.onTap,
    required this.onEdit,
  });

  String value(
      String key, {
        String fallback = 'No registrado',
      }) {
    final currentValue = client[key];

    if (currentValue == null ||
        currentValue.toString().trim().isEmpty) {
      return fallback;
    }

    return currentValue.toString().trim();
  }

  String get status =>
      value('estado', fallback: 'activo').toLowerCase();

  String get companyName {
    final company = client['nombre_mipyme'];

    if (company != null &&
        company.toString().trim().isNotEmpty) {
      return company.toString().trim();
    }

    return value(
      'nombre_usuario',
      fallback: 'Cliente sin nombre',
    );
  }

  Color get statusColor {
    switch (status) {
      case 'inactivo':
        return const Color(0xFFD84A4A);
      case 'pospuesto':
        return const Color(0xFFE29022);
      default:
        return const Color(0xFF238A57);
    }
  }

  String get statusLabel {
    switch (status) {
      case 'inactivo':
        return 'Inactivo';
      case 'pospuesto':
        return 'Pospuesto';
      default:
        return 'Activo';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'inactivo':
        return Icons.block_rounded;
      case 'pospuesto':
        return Icons.schedule_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasObservation =
        status != 'activo' &&
            value(
              'estado_observaciones',
              fallback: '',
            ).isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 14 : 18),
          decoration: BoxDecoration(
            color: Global.container,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: statusColor.withOpacity(0.17),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.055),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 48 : 52,
                    height: compact ? 48 : 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Global.primary.withOpacity(0.17),
                          Global.primary.withOpacity(0.07),
                        ],
                      ),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      size: compact ? 25 : 28,
                      color: Global.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: compact ? 15 : 16,
                            fontWeight: FontWeight.w600,
                            color: Global.text,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          value(
                            'nombre_usuario',
                            fallback:
                            'Responsable no registrado',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                            Global.text.withOpacity(0.60),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  _StatusBadge(
                    label: statusLabel,
                    icon: statusIcon,
                    color: statusColor,
                  ),

                  const SizedBox(width: 2),

                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Editar cliente',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 19,
                      color: Global.text.withOpacity(0.60),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ClientInformationChip(
                    icon: Icons.location_on_outlined,
                    text: value(
                      'municipio',
                      fallback: 'Sin municipio',
                    ),
                  ),
                  _ClientInformationChip(
                    icon: Icons.phone_outlined,
                    text: value(
                      'telefono',
                      fallback: 'Sin teléfono',
                    ),
                  ),
                  _ClientInformationChip(
                    icon: Icons.business_outlined,
                    text: value(
                      'tipo_empresa',
                      fallback: 'Sin clasificación',
                    ),
                  ),
                ],
              ),

              if (hasObservation) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    value('estado_observaciones'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      height: 1.35,
                      color: Global.text.withOpacity(0.70),
                    ),
                  ),
                ),
              ],

              if (!compact) const Spacer(),

              const SizedBox(height: 12),

              Row(
                children: [
                  Text(
                    status == 'activo'
                        ? 'Ver dashboard'
                        : 'Ver información',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Global.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: Global.primary,
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

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientInformationChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ClientInformationChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Global.bg.withOpacity(0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Global.text.withOpacity(0.07),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Global.primary,
          ),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 150,
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Global.text.withOpacity(0.72),
              ),
            ),
          ),
        ],
      ),
    );
  }
}