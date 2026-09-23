import 'dart:ui';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Bottommenuasesor extends StatefulWidget {
  const Bottommenuasesor({
    super.key,
  });

  @override
  State<Bottommenuasesor> createState() =>
      _BottommenuasesorState();
}

class _BottommenuasesorState
    extends State<Bottommenuasesor> {
  final List<_BottomMenuItem> modules = [
    _BottomMenuItem(
      name: 'Inicio',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      route: AsesorRoutes.home,
      inPages: [
        AsesorRoutes.home,
      ],
    ),
    _BottomMenuItem(
      name: 'Clientes',
      icon: Icons.group_outlined,
      selectedIcon: Icons.group_rounded,
      route: AsesorRoutes.clients,
      inPages: [
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
        AsesorRoutes.editConsumo,
        AsesorRoutes.newDiagnostico,
        AsesorRoutes.viewDiagnostico,
        AsesorRoutes.newPlanTrabajo,
        AsesorRoutes.editPlanTrabajo,
        AsesorRoutes.viewPlanTrabajo,
        AsesorRoutes.newRequerimiento,
      ],
    ),
    _BottomMenuItem(
      name: 'Más',
      icon: Icons.menu_rounded,
      selectedIcon: Icons.menu_rounded,
      route: AsesorRoutes.more,
      inPages: [
        AsesorRoutes.more,
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        MediaQuery.sizeOf(context).width >= 800;

    if (isDesktop) {
      return const SizedBox.shrink();
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return _buildMenuSurface(
        isDark: isDark,
        child: _buildMenuOptions(isDark),
      );
    });
  }

  Widget _buildMenuOptions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modules.map((module) {
          final bool isSelected =
          module.inPages.contains(controller.Page);

          return SizedBox(
            width: 58,
            height: 58,
            child: Center(
              child: Tooltip(
                message: module.name,
                triggerMode:
                TooltipTriggerMode.longPress,
                waitDuration:
                const Duration(milliseconds: 400),
                child: Semantics(
                  button: true,
                  label: module.name,
                  selected: isSelected,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (!isSelected) {
                          controller.setPage(
                            module.route,
                          );
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          // Selección más visible en claro.
                          color: isSelected
                              ? isDark ? Global.text.withOpacity(0.22) : Global.primary.withOpacity(0.22)
                              : Colors.transparent,

                          border: isSelected && !isDark
                              ? Border.all(
                            color: Global.primary
                                .withOpacity(0.28),
                          )
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              isSelected
                                  ? module.selectedIcon
                                  : module.icon,
                              size: isSelected ? 27 : 25,
                              color: isSelected ?
                                  isDark ?
                                  Global.text :
                                  Global.primary
                                  : isDark
                                  ? Global.textSecondary
                                  : const Color(0xFF4B555A),
                            ),

                            if (isSelected)
                              Positioned(
                                bottom: 3,
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isDark ? Global.text : Global.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuSurface({
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.14),
            offset: const Offset(0, 8),
            blurRadius: 22,
            spreadRadius: -4,
          ),

          if (!isDark)
            BoxShadow(
              color: Global.primary.withOpacity(0.14),
              offset: const Offset(0, 4),
              blurRadius: 18,
              spreadRadius: -6,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isDark ? 18 : 14,
            sigmaY: isDark ? 18 : 14,
          ),
          child: Stack(
            children: [
              // Superficie principal
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(22),
                    gradient: isDark
                        ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.11),
                        Global.container
                            .withOpacity(0.68),
                      ],
                    )
                        : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF9FFFB)
                            .withOpacity(0.86),
                        const Color(0xFFE5F4EA)
                            .withOpacity(0.78),
                        const Color(0xFFF3FAF5)
                            .withOpacity(0.72),
                      ],
                    ),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.16)
                          : Global.primary.withOpacity(0.22),
                      width: 1,
                    ),
                  ),
                ),
              ),

              // Reflejo superior del acrílico
              if (!isDark)
                Positioned(
                  top: 1,
                  left: 18,
                  right: 18,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),

              // Mancha de luz muy sutil
              if (!isDark)
                Positioned(
                  top: -25,
                  left: 25,
                  child: Container(
                    width: 95,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.42),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),

              // Opciones del menú
              child,
            ],
          ),
        ),
      ),
    );
  }
}
class _BottomMenuItem {
  final String name;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final List<String> inPages;

  const _BottomMenuItem({
    required this.name,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    required this.inPages,
  });
}