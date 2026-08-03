import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/config/Images.dart';
import 'package:finanzas_verdes/main.dart';

class AppBarCliente extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCliente({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Obx(() => AppBar(
        backgroundColor: Global.bg,
        elevation: 0,
        leading: const SizedBox(),
        leadingWidth: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cliente",
              style: TextStyle(
                color: Global.text.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            Text(
              controller.User["nombre_usuario"] ?? '',
              style: TextStyle(
                color: Global.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Image.asset(Images.logo, height: 36),
          const SizedBox(width: 12),
        ],
      )),
    );
  }
}
