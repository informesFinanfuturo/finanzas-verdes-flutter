import 'package:animate_do/animate_do.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/views/admin/menus/appBarAdmin.dart';
import 'package:finanzas_verdes/views/admin/menus/bottomMenuAdmin.dart';
import 'package:finanzas_verdes/views/admin/menus/leftMenuAdmin.dart';
import 'package:finanzas_verdes/views/asesor/menus/appBarAsesor.dart';
import 'package:finanzas_verdes/views/asesor/menus/bottomMenuAsesor.dart';
import 'package:finanzas_verdes/views/asesor/menus/leftMenuAsesor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Dashboardasesor extends StatefulWidget {
  const Dashboardasesor({super.key});

  @override
  State<Dashboardasesor> createState() =>
      _DashboardasesorState();
}

class _DashboardasesorState
    extends State<Dashboardasesor> {
  @override
  void initState() {
    super.initState();

    controller.setPage(
      AsesorRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool isDesktop = width >= 800;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.backPage();
        }
      },
      child: Obx(
            () => Scaffold(
          backgroundColor: Global.bg,

          appBar: isDesktop
              ? null
              : AppBarAsesor(),

          // Permite que el contenido pase visualmente
          // por detrás del menú flotante.
          extendBody: true,

          body: Row(
            children: [
              if (isDesktop)
                Leftmenuasesor(),

              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Global.bg,
                  child: FadeInDown(
                    key: ValueKey(controller.Page),
                    duration: Duration(milliseconds: 250),
                    from: 20,
                    child: controller.Pages[controller.Page],
                  ),
                ),
              ),
            ],
          ),

          // Menú flotante solamente en móvil.
          bottomNavigationBar: isDesktop
              ? null
              : _buildFloatingBottomMenu(),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomMenu() {
    return SafeArea(
      minimum: const EdgeInsets.only(
        bottom: 15,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: const Material(
          color: Colors.transparent,
          elevation: 0,
          child: Bottommenuasesor(),
        ),
      ),
    );
  }
}