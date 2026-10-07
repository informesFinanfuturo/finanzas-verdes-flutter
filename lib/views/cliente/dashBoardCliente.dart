import 'package:animate_do/animate_do.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/clienteRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/views/cliente/menus/appBarCliente.dart';
import 'package:finanzas_verdes/views/cliente/menus/bottomMenuCliente.dart';
import 'package:finanzas_verdes/views/cliente/menus/leftMenuCliente.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dashboardcliente
    extends StatefulWidget {
  const Dashboardcliente({
    super.key,
  });

  @override
  State<Dashboardcliente> createState() =>
      _DashboardclienteState();
}

class _DashboardclienteState
    extends State<Dashboardcliente> {

  @override
  void initState() {
    super.initState();

    controller.setPage(
      ClienteRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context).width;

    final bool isDesktop =
        width >= 800;

    return PopScope(
      canPop: false,

      onPopInvokedWithResult:
          (
          didPop,
          result,
          ) {
        if (!didPop) {
          controller.backPage();
        }
      },

      child: Obx(
            () => Scaffold(
          backgroundColor:
          Global.bg,

          appBar:
          isDesktop
              ? null
              : const AppBarCliente(),

          /*
           * Permite que el contenido se
           * extienda por detrás del menú
           * inferior flotante.
           */
          extendBody: true,

          body: Row(
            children: [
              if (isDesktop)
                const Leftmenucliente(),

              Expanded(
                child: Container(
                  width:
                  double.infinity,

                  height:
                  double.infinity,

                  color:
                  Global.bg,

                  child:
                  controller.User[
                  "id_usuario"
                  ] ==
                      null
                      ? Center(
                    child:
                    CircularProgressIndicator(
                      color:
                      Global.primary,
                    ),
                  )
                      : FadeInDown(
                    key:
                    ValueKey(
                      controller
                          .Page,
                    ),

                    duration:
                    const Duration(
                      milliseconds:
                      250,
                    ),

                    from: 20,

                    child:
                    controller
                        .Pages[
                    controller
                        .Page
                    ],
                  ),
                ),
              ),
            ],
          ),

          bottomNavigationBar:
          isDesktop
              ? null
              : _buildFloatingBottomMenu(),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomMenu() {
    return SafeArea(
      minimum:
      const EdgeInsets.only(
        bottom: 15,
      ),

      child: Align(
        alignment:
        Alignment.bottomCenter,

        heightFactor: 1,

        child: const Material(
          color:
          Colors.transparent,

          elevation: 0,

          child:
          Bottommenucliente(),
        ),
      ),
    );
  }
}