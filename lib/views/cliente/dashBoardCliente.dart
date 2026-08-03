import 'package:animate_do/animate_do.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/clienteRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/views/admin/menus/appBarAdmin.dart';
import 'package:finanzas_verdes/views/admin/menus/bottomMenuAdmin.dart';
import 'package:finanzas_verdes/views/admin/menus/leftMenuAdmin.dart';
import 'package:finanzas_verdes/views/asesor/menus/appBarAsesor.dart';
import 'package:finanzas_verdes/views/asesor/menus/bottomMenuAsesor.dart';
import 'package:finanzas_verdes/views/asesor/menus/leftMenuAsesor.dart';
import 'package:finanzas_verdes/views/cliente/menus/appBarCliente.dart';
import 'package:finanzas_verdes/views/cliente/menus/bottomMenuCliente.dart';
import 'package:finanzas_verdes/views/cliente/menus/leftMenuCliente.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dashboardcliente extends StatefulWidget {
  const Dashboardcliente({super.key});

  @override
  State<Dashboardcliente> createState() => _DashboardclienteState();
}

class _DashboardclienteState extends State<Dashboardcliente> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.setPage(ClienteRoutes.home);
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        controller.backPage();
      },
      child: Obx(() => Scaffold(
        backgroundColor: Global.bg,
        appBar: width >= 800 ? null : AppBarCliente(),
        body: Column(
          children: [
            Expanded(
                child: Row(
                  children: [
                    Leftmenucliente(),
                    Expanded(
                      child: Container(
                        height: double.infinity,
                        color: Global.bg,
                        padding: EdgeInsets.all(20),
                        child:
                        controller.User["id_usuario"] == null ?
                        Center(
                          child: CircularProgressIndicator(color: Global.primary,),
                        )  :
                        FadeInDown(
                          key: ValueKey(controller.Page),
                          duration: const Duration(milliseconds: 250),
                          from: 20,
                          child: controller.Pages[controller.Page],
                        ),
                      ),
                    )
                  ],
                )
            ),
            SafeArea(child: Bottommenucliente())
          ],
        ),
      )),
    );
  }
}
