import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/config/Images.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Leftmenuasesor extends StatefulWidget {
  const Leftmenuasesor({super.key});

  @override
  State<Leftmenuasesor> createState() => _LeftmenuasesorState();
}

class _LeftmenuasesorState extends State<Leftmenuasesor> {
  final modules = [
    {
      "nombre": "Inicio",
      "logo": Icons.home_filled,
      "route": AsesorRoutes.home,
      "inPage": [AsesorRoutes.home],
    },
    {
      "nombre": "Clientes",
      "logo": Icons.groups_rounded,
      "route": AsesorRoutes.clients,
      "inPage": [
        AsesorRoutes.clients,
        AsesorRoutes.newClient,
        AsesorRoutes.editClient,
        AsesorRoutes.dashBoardClient,
        AsesorRoutes.newMipyme,
        AsesorRoutes.newClientMipyme,
        AsesorRoutes.editMipyme,
        AsesorRoutes.newActivo,
        AsesorRoutes.editActivo,
        AsesorRoutes.newConsumo,
        AsesorRoutes.viewDiagnostico,
        AsesorRoutes.editConsumo,
        AsesorRoutes.newDiagnostico,
        AsesorRoutes.newPlanTrabajo,
        AsesorRoutes.editPlanTrabajo,
        AsesorRoutes.viewPlanTrabajo,
        AsesorRoutes.newRequerimiento,
      ],
    },
  ];

  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 800) {
      return const SizedBox.shrink();
    }

    return Obx(
          () => AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: isCollapsed ? 72 : 250,
        height: double.infinity,
        decoration: BoxDecoration(
          // Mismo fondo del contenido principal.
          color: Global.bg,

          // Línea sutil de separación.
          border: Border(
            right: BorderSide(
              color: Global.text.withOpacity(
                controller.isDark.value ? 0.10 : 0.08,
              ),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),

            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  ...modules.map((module) {
                    final nombre = module["nombre"] as String;
                    final icon = module["logo"] as IconData;
                    final route = module["route"] as String;

                    final isSelected = (module["inPage"] as List)
                        .contains(controller.Page);

                    return _menuItem(
                      title: nombre,
                      icon: icon,
                      selected: isSelected,
                      onTap: () => controller.setPage(route),
                    );
                  }),

                  if (!isCollapsed) ...[
                    const SizedBox(height: 22),
                    _sectionTitle("MÁS"),
                    const SizedBox(height: 6),
                  ] else
                    const SizedBox(height: 16),

                  _menuItem(
                    title: "Cambiar tema",
                    subtitle: controller.isDark.value
                        ? "Cambiar a modo claro"
                        : "Cambiar a modo oscuro",
                    icon: controller.isDark.value
                        ? CupertinoIcons.sun_max_fill
                        : CupertinoIcons.moon_fill,
                    onTap: controller.toggleTheme,
                  ),

                  _menuItem(
                    title: "Acerca de",
                    icon: CupertinoIcons.info_circle,
                    onTap: () {
                      // Agrega aquí la navegación.
                    },
                  ),

                  _menuItem(
                    title: "Términos",
                    icon: CupertinoIcons.doc_text,
                    onTap: () {
                      // Agrega aquí la navegación.
                    },
                  ),

                  _menuItem(
                    title: "Configuración",
                    icon: CupertinoIcons.gear,
                    onTap: () {
                      // Agrega aquí la navegación.
                    },
                  ),
                ],
              ),
            ),

            _buildUserFooter(),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: isCollapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            if (!isCollapsed)
              Image.asset(
                Images.logo,
                width: 34,
                height: 34,
                fit: BoxFit.contain,
              ),

            Tooltip(
              message: isCollapsed
                  ? "Expandir menú"
                  : "Contraer menú",
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isCollapsed = !isCollapsed;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    child: AnimatedRotation(
                      turns: isCollapsed ? 0.5 : 0,
                      duration: const Duration(milliseconds: 240),
                      child: Icon(
                        Icons.menu_open_rounded,
                        color: Global.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    String? subtitle,
    bool selected = false,
  }) {
    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: BoxConstraints(
            minHeight: subtitle == null ? 46 : 58,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Global.primary.withOpacity(
              controller.isDark.value ? 0.18 : 0.10,
            )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 21,
                color: selected
                    ? Global.primary
                    : Global.textSecondary,
              ),

              if (!isCollapsed) ...[
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? Global.primary
                              : Global.text,
                        ),
                      ),

                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Global.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Tooltip(
        message: isCollapsed ? title : "",
        waitDuration: const Duration(milliseconds: 450),
        child: content,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          color: Global.textSecondary,
        ),
      ),
    );
  }

  Widget _buildUserFooter() {
    final nombre = controller.User["nombre_usuario"]?.toString();

    if (nombre == null || nombre.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 0 : 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Global.text.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Tooltip(
            message: isCollapsed ? nombre : "",
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Global.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                size: 19,
                color: Global.primary,
              ),
            ),
          ),

          if (!isCollapsed) ...[
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Global.text,
                    ),
                  ),
                  Text(
                    "Asesor",
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Global.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Tooltip(
              message: "Cerrar sesión",
              child: IconButton(
                onPressed: controller.logOut,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: Global.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}