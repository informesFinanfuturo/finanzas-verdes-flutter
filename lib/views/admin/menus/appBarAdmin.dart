import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/config/Images.dart';
import 'package:finanzas_verdes/app/routes/routeNames.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarAdmin extends StatelessWidget
    implements PreferredSizeWidget {
  const AppBarAdmin({super.key});

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Global.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Administrador',
              style: TextStyle(
                color: Global.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              controller.User["nombre_usuario"]
                  ?.toString() ??
                  '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Global.text,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Opciones de cuenta',
            color: Global.container,
            position: PopupMenuPosition.under,
            onSelected: (value) {
              if (value == 'change_password') {
                Get.toNamed(
                  Routes.changeRequiredPassword,
                  arguments: {
                    'required': false,
                  },
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'change_password',
                child: Row(
                  children: [
                    Icon(
                      Icons.password_rounded,
                      color: Global.primary,
                      size: 21,
                    ),
                    const SizedBox(width: 11),
                    Text(
                      'Cambiar mi contraseña',
                      style: TextStyle(
                        color: Global.text,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(
                Images.logo,
                width: 38,
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}