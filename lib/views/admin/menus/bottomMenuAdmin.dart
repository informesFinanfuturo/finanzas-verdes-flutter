import 'dart:ui';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Bottommenuadmin extends StatelessWidget {
  const Bottommenuadmin({super.key});

  static const List<_AdminBottomItem> _modules = [
    _AdminBottomItem(
      name: 'Inicio',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      route: Adminroutes.home,
      inPages: [
        Adminroutes.home,
      ],
    ),
    _AdminBottomItem(
      name: 'Usuarios',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
      route: Adminroutes.users,
      inPages: [
        Adminroutes.users,
        Adminroutes.newUser,
        Adminroutes.editUser,
      ],
    ),
    _AdminBottomItem(
      name: 'Roles y permisos',
      icon:
      Icons.shield_outlined,
      selectedIcon:
      Icons.shield_rounded,
      route:
      Adminroutes.rols,
      inPages: [
        Adminroutes.rols,
      ],
    ),
    _AdminBottomItem(
      name: 'Catálogo',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
      route: Adminroutes.homeProveedores,
      inPages: [
        Adminroutes.homeProveedores,
      ],
    ),
    _AdminBottomItem(
      name: 'Más',
      icon: Icons.menu_rounded,
      selectedIcon: Icons.menu_rounded,
      route: Adminroutes.more,
      inPages: [
        Adminroutes.more,
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.sizeOf(context).width;

    if (screenWidth >= 800) {
      return const SizedBox.shrink();
    }

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final menuWidth = (screenWidth - 24)
        .clamp(290.0, 390.0)
        .toDouble();

    return Obx(
          () => Container(
        width: menuWidth,
        height: 64,
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(23),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.38)
                  : Colors.black.withOpacity(0.14),
              offset: const Offset(0, 8),
              blurRadius: 22,
              spreadRadius: -4,
            ),
            if (!isDark)
              BoxShadow(
                color:
                Global.primary.withOpacity(0.13),
                offset: const Offset(0, 4),
                blurRadius: 18,
                spreadRadius: -6,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(23),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isDark ? 18 : 14,
              sigmaY: isDark ? 18 : 14,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(23),
                      gradient: isDark
                          ? LinearGradient(
                        begin:
                        Alignment.topLeft,
                        end: Alignment
                            .bottomRight,
                        colors: [
                          Colors.white
                              .withOpacity(0.11),
                          Global.container
                              .withOpacity(0.72),
                        ],
                      )
                          : LinearGradient(
                        begin:
                        Alignment.topLeft,
                        end: Alignment
                            .bottomRight,
                        colors: [
                          const Color(
                            0xFFF9FFFB,
                          ).withOpacity(0.94),
                          const Color(
                            0xFFE5F4EA,
                          ).withOpacity(0.88),
                          const Color(
                            0xFFF3FAF5,
                          ).withOpacity(0.84),
                        ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white
                            .withOpacity(0.16)
                            : Global.primary
                            .withOpacity(0.22),
                      ),
                    ),
                  ),
                ),
                if (!isDark)
                  Positioned(
                    top: 1,
                    left: 22,
                    right: 22,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white
                                .withOpacity(0),
                            Colors.white
                                .withOpacity(0.95),
                            Colors.white
                                .withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    child: Row(
                      children: _modules.map(
                            (module) {
                          final selected =
                          module.inPages.contains(
                            controller.Page,
                          );

                          return Expanded(
                            child: _menuOption(
                              module: module,
                              selected: selected,
                              isDark: isDark,
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuOption({
    required _AdminBottomItem module,
    required bool selected,
    required bool isDark,
  }) {
    return Tooltip(
      message: module.name,
      triggerMode:
      TooltipTriggerMode.longPress,
      child: Semantics(
        button: true,
        label: module.name,
        selected: selected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!selected) {
                controller.setPage(
                  module.route,
                );
              }
            },
            customBorder:
            const CircleBorder(),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 190,
                ),
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? isDark
                      ? Global.text
                      .withOpacity(0.20)
                      : Global.primary
                      .withOpacity(0.18)
                      : Colors.transparent,
                  border: selected && !isDark
                      ? Border.all(
                    color: Global.primary
                        .withOpacity(0.24),
                  )
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      selected
                          ? module.selectedIcon
                          : module.icon,
                      size: selected ? 24 : 22,
                      color: selected
                          ? isDark
                          ? Global.text
                          : Global.primary
                          : isDark
                          ? Global.textSecondary
                          : const Color(
                        0xFF4B555A,
                      ),
                    ),
                    if (selected)
                      Positioned(
                        bottom: 3,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Global.text
                                : Global.primary,
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
    );
  }
}

class _AdminBottomItem {
  final String name;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final List<String> inPages;

  const _AdminBottomItem({
    required this.name,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    required this.inPages,
  });
}