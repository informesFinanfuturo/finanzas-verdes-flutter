import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/activoApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:finanzas_verdes/views/asesor/asesor/createCalendarioAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/viewActivosAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/consumo/viewConsumosAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/diagnostico/Viewdiagnosticosasesor.dart';
import 'package:finanzas_verdes/views/asesor/client/mipyme/infoMipymeDashBoardAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/plan_trabajo/ViewPlanTrabajosAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/requerimiento/selectActivoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/visita/Viewvisitasclienteasesor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboardclientasesor extends StatefulWidget {
  const Dashboardclientasesor({super.key});

  @override
  State<Dashboardclientasesor> createState() => _DashboardclientasesorState();
}

class _DashboardclientasesorState extends State<Dashboardclientasesor> {

  final ClientController clientController =
  Get.put(ClientController());

  late final PageController pageController;
  late final ScrollController tabScrollController;

  int selectedClientPage = 0;
  bool _headerExpanded = false;

  final List<String> clientSections = [
    'Resumen',
    'Facturas',
    'Activos',
    'Diagnósticos',
    'Plan trabajo',
    'Visitas',
  ];

  late final List<GlobalKey> tabKeys;

  @override
  void initState() {
    super.initState();

    final savedIndex =
        clientController.selectedClientSection.value;

    // Evita índices inválidos si en el futuro
    // cambia la cantidad de secciones.
    if (savedIndex >= 0 &&
        savedIndex < clientSections.length) {
      selectedClientPage = savedIndex;
    } else {
      selectedClientPage = 0;
    }

    // Se crea después de recuperar el índice.
    pageController = PageController(
      initialPage: selectedClientPage,
    );

    tabScrollController = ScrollController();

    tabKeys = List.generate(
      clientSections.length,
          (_) => GlobalKey(),
    );

    // Hace visible el botón seleccionado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _ensureTabVisible(selectedClientPage);
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    tabScrollController.dispose();
    super.dispose();
  }

  void _ensureTabVisible(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final tabContext = tabKeys[index].currentContext;

      if (tabContext == null) return;

      Scrollable.ensureVisible(
        tabContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    });
  }

  void _changeClientPage(int index) {
    setState(() {
      selectedClientPage = index;
    });

    clientController.setSelectedClientSection(index);

    _ensureTabVisible(index);

    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _toggleHeader() {
    setState(() {
      _headerExpanded = !_headerExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        final isDesktop = constraints.maxWidth > 800;
        final cardWidth = isDesktop
            ? (constraints.maxWidth / 2) - 30
            : constraints.maxWidth;

        return Obx(() {
          final _ = controller.isDark;

          final List<Widget> kpiCards = [
            KpiCard(
              key: const ValueKey('activos'),
              title: 'Activos registrados',
              value: '${clientController.Client["activos"]?.length ?? 0}',
              footer: '',
              icon: Icons.inventory_2_rounded,
              iconColor: const Color(0xFF28A745),
              footerColor: const Color(0xFF198F42),
              isDesktop: isDesktop,
            ),
            KpiCard(
              key: const ValueKey('facturas'),
              title: 'Facturas registradas',
              value: '${clientController.Client["facturas"]?.length ?? 0}',
              footer: '',
              icon: Icons.receipt_long_rounded,
              iconColor: const Color(0xFF2196F3),
              footerColor: const Color(0xFF2196F3),
              isDesktop: isDesktop,
            ),
            KpiCard(
              key: const ValueKey('diagnosticos'),
              title: 'Diagnósticos',
              value: '${clientController.Client["diagnosticos"]?.length ?? 0}',
              footer: '',
              icon: Icons.analytics_rounded,
              iconColor: const Color(0xFF8E44C2),
              footerColor: const Color(0xFF8E44C2),
              isDesktop: isDesktop,
            ),
            KpiCard(
              key: const ValueKey('visitas'),
              title: 'Visitas realizadas',
              value: '${clientController.Client["visitas"]?.length ?? 0}',
              footer: '',
              icon: Icons.event_available_rounded,
              iconColor: const Color(0xFFF5A000),
              footerColor: const Color(0xFFF5A000),
              isDesktop: isDesktop,
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isDesktop) const Divider(height: 1),

              // Título de la pantalla
              _buildPageTitle(),

              const SizedBox(height: 8),

              // Escritorio siempre expandido.
              if (isDesktop)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildExpandedClientHeader(
                    isDesktop: true,
                    kpiCards: kpiCards,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildMobileClientHeader(
                    kpiCards: kpiCards,
                  ),
                ),

              const SizedBox(height: 8),

              // Navegación de las secciones del cliente
              _buildClientTabs(),

              const Divider(height: 1),

              Expanded(
                child: PageView(
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      selectedClientPage = index;
                    });
                    _ensureTabVisible(index);
                    clientController.setSelectedClientSection(index);
                  },
                  children: [
                    ClientInformationSection(
                      mipyme: clientController.Client["mipyme"] ?? {},
                      onEdit: () {
                        controller.setPage(
                          AsesorRoutes.editMipyme,
                        );
                      },
                    ),
                    Viewfacturasasesor(
                      facturas: List<Map<String, dynamic>>.from(
                        clientController.Client["facturas"] ?? [],
                      ),
                      onCreateInvoice: () {
                        clientController.setConsumo({});

                        controller.setPage(
                          AsesorRoutes.editConsumo,
                        );
                      },
                      onOpenInvoice: (factura) async {
                        final consumo = await getConsumoApi(
                          idConsumo: factura["id_consumo"],
                        );

                        clientController.setConsumo(consumo);

                        controller.setPage(
                          AsesorRoutes.editConsumo,
                        );
                      },
                    ),
                    Viewactivosasesor(
                      activos: List<Map<String, dynamic>>.from(
                        clientController.Client["activos"] ?? [],
                      ),
                      onCreateAsset: () {
                        controller.setPage(
                          AsesorRoutes.newActivo,
                        );
                      },
                      onOpenAsset: (activo) async {
                        final assetDetail = await getActivoApi(
                          idActivo: activo["id_activo"],
                        );

                        clientController.setActivo(assetDetail);

                        controller.setPage(
                          AsesorRoutes.editActivo,
                        );
                      },
                    ),
                    Viewdiagnosticosasesor(
                      diagnosticos: List<Map<String, dynamic>>.from(
                        clientController.Client["diagnosticos"] ?? [],
                      ),

                      onCreateDiagnostic: () async {
                        final preview = await getClientFullImagesApi(
                          idUsuario:
                          clientController.Client["user"]["id_usuario"],
                        );

                        clientController.setPreview(preview);

                        controller.setPage(
                          AsesorRoutes.newDiagnostico,
                        );
                      },

                      onOpenDiagnostic: (diagnostico) async {
                        clientController.setDiagnostico(
                          diagnostico,
                        );

                        controller.setPage(
                          AsesorRoutes.viewDiagnostico,
                        );
                      },
                    ),
                    Viewplanestrabajosasesor(
                      planes: List<Map<String, dynamic>>.from(
                        clientController.Client["planes_trabajo"] ?? [],
                      ),

                      onCreatePlan: () async {
                        controller.setPage(
                          AsesorRoutes.newPlanTrabajo,
                        );
                      },

                      onOpenPlan: (plan) async {
                        clientController.setPlanTrabajo(plan);

                        controller.setPage(
                          AsesorRoutes.viewPlanTrabajo,
                        );
                      },

                      onEditPlan: (plan) async {
                        clientController.setPlanTrabajo(plan);

                        controller.setPage(
                          AsesorRoutes.editPlanTrabajo,
                        );
                      },
                    ),
                    Viewvisitasclienteasesor(
                      visitas: List<Map<String, dynamic>>.from(
                        clientController.Client["visitas"] ?? [],
                      ),

                      onCreateVisit: () async {
                        await mostrarModalCrearCalendario(
                          context,
                          {
                            'nombre_usuario':
                            clientController.Client["user"]
                            ["nombre_usuario"],

                            'nombre_mipyme':
                            clientController.Client["mipyme"]
                            ["nombre_mipyme"],

                            'email':
                            clientController.Client["user"]["email"],

                            'id_usuario':
                            clientController.Client["user"]
                            ["id_usuario"],
                          },
                          'Visita de seguimiento',
                        );

                        await clientController.refreshClient();
                      },
                    ),
                  ],
                ),
              )
            ],
          );
        });
      },
    );
  }

  Widget _buildPageTitle() {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Tooltip(
            message: 'Volver a clientes',
            child: IconButton(
              onPressed: () => controller.backPage(),
              icon: const Icon(
                CupertinoIcons.back,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              splashRadius: 22,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Dashboard del cliente',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: Global.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileClientHeader({
    required List<Widget> kpiCards,
  }) {
    final mipyme = clientController.client["mipyme"] ?? {};

    final String nombre =
        mipyme["nombre_mipyme"] ?? "Empresa desconocida";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Global.text.withOpacity(0.08),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Esta barra siempre queda visible y mide 50 px.
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleHeader,
                child: SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Global.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            Icons.apartment_rounded,
                            size: 22,
                            color: Global.primary,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Global.text,
                            ),
                          ),
                        ),

                        Text(
                          _headerExpanded ? 'Contraer' : 'Ver información',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Global.text.withOpacity(0.65),
                          ),
                        ),

                        const SizedBox(width: 4),

                        AnimatedRotation(
                          duration: const Duration(milliseconds: 250),
                          turns: _headerExpanded ? 0.5 : 0,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Global.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Información que desaparece al contraer.
            if (_headerExpanded) ...[
              Divider(
                height: 1,
                color: Global.text.withOpacity(0.08),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NIT ${mipyme["nit"] ?? "No registrado"}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Global.text.withOpacity(0.8),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color: Global.text.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${mipyme["municipio"] ?? "Sin municipio"}, '
                                '${mipyme["departamento"] ?? "Sin departamento"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Global.text.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 62,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (
                            int index = 0;
                            index < kpiCards.length;
                            index++
                            ) ...[
                              kpiCards[index],
                              if (index < kpiCards.length - 1)
                                const SizedBox(width: 10),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Expanded(
    //   child: SingleChildScrollView(
    //     child: Wrap(
    //       spacing: 20,
    //       runSpacing: 20,
    //       children: [
    //
    //         // 6. OFERTAS
    //         Container(
    //           width: cardWidth,
    //           padding: const EdgeInsets.all(16),
    //           decoration: BoxDecoration(
    //             color: Global.container,
    //             borderRadius: BorderRadius.circular(15),
    //           ),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text("Ofertas de proveedores",
    //                   style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       color: Global.text)),
    //               const SizedBox(height: 10),
    //               Text("Proveedor A - \$5000",
    //                   style: TextStyle(color: Global.text)),
    //               Text("Proveedor B - \$4800",
    //                   style: TextStyle(color: Global.text)),
    //             ],
    //           ),
    //         ),
    //
    //         // ✅ 7. DISPOSICIÓN
    //         Container(
    //           width: cardWidth,
    //           padding: const EdgeInsets.all(16),
    //           margin: EdgeInsets.only(bottom: 10),
    //           decoration: BoxDecoration(
    //             color: Global.container,
    //             borderRadius: BorderRadius.circular(15),
    //           ),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text("Disposición de activos",
    //                   style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       color: Global.text)),
    //               const SizedBox(height: 10),
    //               Text("Reciclado",
    //                   style: TextStyle(color: Global.text)),
    //               Text("En proceso",
    //                   style: TextStyle(color: Global.text)),
    //               Text("Pendiente",
    //                   style: TextStyle(color: Global.text)),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // ),
  }

  Widget _buildExpandedClientHeader({
    required bool isDesktop,
    required List<Widget> kpiCards,
  }) {
    final mipyme = clientController.client["mipyme"] ?? {};

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Global.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.apartment_rounded,
                size: 60,
                color: Global.primary,
              ),
            ),

            const SizedBox(width: 14),

            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 180,
                maxWidth: 350,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mipyme["nombre_mipyme"] ??
                        "Nombre de empresa desconocido",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Global.text,
                    ),
                  ),
                  Text(
                    'NIT ${mipyme["nit"] ?? "No registrado"}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Global.text.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '${mipyme["municipio"] ?? "Sin municipio"}, '
                        '${mipyme["departamento"] ?? "Sin departamento"}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Global.text.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: kpiCards,
        ),
      ],
    );
  }

  Widget _buildClientTabs() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        controller: tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        itemCount: clientSections.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final bool isSelected =
              selectedClientPage == index;

          return InkWell(
            key: tabKeys[index],
            onTap: () => _changeClientPage(index),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Global.primary
                    : Global.container,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Global.primary
                      : Global.text.withOpacity(0.12),
                ),
              ),
              child: Center(
                child: Text(
                  clientSections[index],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : Global.text,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}

class KpiCard extends StatefulWidget {
  final String title;
  final String value;
  final String footer;
  final IconData icon;
  final Color iconColor;
  final Color footerColor;
  final bool isDesktop;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.footer,
    required this.icon,
    required this.iconColor,
    required this.footerColor,
    required this.isDesktop,
  });

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  bool isExpanded = false;

  void toggleCard() {
    // En escritorio no se contrae.
    if (widget.isDesktop) return;

    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // En escritorio siempre muestra toda la información.
    final bool showInformation =
        widget.isDesktop || isExpanded;

    final double cardWidth = widget.isDesktop
        ? 240
        : showInformation
        ? 210
        : 62;

    final double cardHeight = widget.isDesktop ? 100 : 60;

    return Tooltip(
      message: showInformation
          ? ''
          : '${widget.title}: ${widget.value}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isDesktop ? null : toggleCard,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: cardWidth,
            height: cardHeight,
            padding: EdgeInsets.all(
              showInformation ? 8 : 6,
            ),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Global.container,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: showInformation
                    ? widget.iconColor.withOpacity(0.35)
                    : Colors.white.withOpacity(0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 30,
                    color: widget.iconColor,
                  ),
                ),

                if (showInformation) ...[
                  const SizedBox(width: 10),

                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        key: const ValueKey('kpi-information'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Global.text.withOpacity(0.7),
                            ),
                          ),

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.value,
                              style: GoogleFonts.poppins(
                                fontSize:
                                widget.isDesktop ? 21 : 17,
                                fontWeight: FontWeight.w700,
                                color: Global.text,
                              ),
                            ),
                          ),

                          if (widget.footer.isNotEmpty)
                            Text(
                              widget.footer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: widget.footerColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _row(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Global.text,
          ),
        ),
        Expanded(
          child: Text(
            value != null && value.toString().isNotEmpty
                ? value.toString()
                : "No registrado",
            style: TextStyle(
              color: Global.text.withOpacity(0.7),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _rowArea(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Global.text,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value != null &&
              value.toString().trim().isNotEmpty
              ? value.toString()
              : "No registrado",
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Global.text.withOpacity(0.7),
          ),
        ),
      ],
    ),
  );
}

Widget _rowMoney(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Global.text,
          ),
        ),
        Expanded(
          child: Text(
            value != null && value.toString().isNotEmpty
                ? "\$${Utils.formatMiles(value.toString())}"
                : "No registrado",
            style: TextStyle(
              color: Global.text.withOpacity(0.7),
            ),
          ),
        ),
      ],
    ),
  );
}