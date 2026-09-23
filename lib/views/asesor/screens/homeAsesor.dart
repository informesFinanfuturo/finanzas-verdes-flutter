import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/calendarioApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/views/asesor/asesor/agendaCalendarAsesor.dart';
import 'package:finanzas_verdes/views/asesor/asesor/clienteAgendaCard.dart';
import 'package:finanzas_verdes/views/asesor/asesor/clientesTableAsesor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Homeasesor extends StatefulWidget {
  const Homeasesor({super.key});

  @override
  State<Homeasesor> createState() => _HomeasesorState();
}

class _HomeasesorState extends State<Homeasesor> {
  final ClientController clientController =
  Get.isRegistered<ClientController>()
      ? Get.find<ClientController>()
      : Get.put(ClientController());

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _clientesSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    getClientsAgendaApi();

    getClientsByEstadoApi(
      clientController: clientController,
      estado: "nuevo",
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToClients() {
    final currentContext = _clientesSectionKey.currentContext;

    if (currentContext == null) return;

    Scrollable.ensureVisible(
      currentContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool isDesktop = size.width >= 900;

    final double horizontalPadding = isDesktop ? 24 : 14;

    return Obx(
          () => SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          20,
          horizontalPadding,
          32,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1600,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(isDesktop),

                const SizedBox(height: 22),

                _buildTodayAgenda(isDesktop),

                const SizedBox(height: 20),

                _buildCalendarSection(
                  context: context,
                  isDesktop: isDesktop,
                ),

                const SizedBox(height: 26),

                Container(
                  key: _clientesSectionKey,
                  child: _buildClientsSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle(),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: _scheduleButton(),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildPageTitle(),
        ),

        const SizedBox(width: 20),

        _scheduleButton(),
      ],
    );
  }

  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Agenda",
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Global.text,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          "Organiza las visitas y seguimientos de tus clientes.",
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Global.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _scheduleButton() {
    return FilledButton.icon(
      onPressed: _goToClients,
      icon: const Icon(
        Icons.add_rounded,
        size: 20,
      ),
      label: Text(
        "Programar visita",
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: Global.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(170, 46),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTodayAgenda(bool isDesktop) {
    final agenda = controller.Agenda;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Global.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.today_rounded,
                size: 19,
                color: Global.primary,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Agenda de hoy",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Global.text,
                    ),
                  ),
                  Text(
                    agenda.isEmpty
                        ? "No tienes visitas programadas"
                        : "${agenda.length} ${agenda.length == 1 ? 'visita programada' : 'visitas programadas'}",
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

        if (agenda.isEmpty)
          _buildEmptyTodayAgenda(isDesktop)
        else
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: agenda.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 12);
              },
              itemBuilder: (context, index) {
                return ClienteAgendaCard(
                  cliente: agenda[index],
                );
              },
            ),
          )
      ],
    );
  }

  Widget _buildEmptyTodayAgenda(bool isDesktop) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 82,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Global.text.withOpacity(0.07),
        ),
      ),
      child: isDesktop
          ? Row(
        children: [
          _emptyAgendaIcon(),

          const SizedBox(width: 14),

          Expanded(
            child: _emptyAgendaText(),
          ),

          const SizedBox(width: 16),

          TextButton.icon(
            onPressed: _goToClients,
            icon: const Icon(
              Icons.add_rounded,
              size: 18,
            ),
            label: const Text("Agregar visita"),
            style: TextButton.styleFrom(
              foregroundColor: Global.primary,
            ),
          ),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _emptyAgendaIcon(),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _emptyAgendaText(),

                const SizedBox(height: 6),

                TextButton(
                  onPressed: _goToClients,
                  style: TextButton.styleFrom(
                    foregroundColor: Global.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Programar una visita"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyAgendaIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Global.primary.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.event_available_rounded,
        size: 22,
        color: Global.primary,
      ),
    );
  }

  Widget _emptyAgendaText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tu agenda está libre por hoy",
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Global.text,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          "Puedes aprovechar para programar una visita o seguimiento.",
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: Global.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection({
    required BuildContext context,
    required bool isDesktop,
  }) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    final double calendarHeight = isDesktop
        ? (screenHeight * 0.70).clamp(540.0, 680.0)
        : 560;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isDesktop ? 18 : 10,
      ),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Global.text.withOpacity(0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 4 : 2,
              vertical: 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Calendario de visitas",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Global.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Consulta las visitas programadas y los seguimientos.",
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: Global.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isDesktop)
                  OutlinedButton.icon(
                    onPressed: _goToClients,
                    icon: const Icon(
                      Icons.person_search_rounded,
                      size: 18,
                    ),
                    label: const Text("Buscar cliente"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Global.primary,
                      side: BorderSide(
                        color: Global.primary.withOpacity(0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Divider(
            height: 1,
            color: Global.text.withOpacity(0.07),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: calendarHeight,
            child: const AgendaCalendarWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildClientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Global.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.groups_rounded,
                size: 20,
                color: Global.primary,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Clientes",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Global.text,
                    ),
                  ),
                  Text(
                    "Selecciona un cliente para programar una visita.",
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

        const SizedBox(height: 14),

        const ClientesTable(),
      ],
    );
  }
}