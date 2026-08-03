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
  State<Dashboardasesor> createState() => _DashboardasesorState();
}

class _DashboardasesorState extends State<Dashboardasesor> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.setPage(AsesorRoutes.home);
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        controller.backPage();
      },
      child: Obx(() {
        print("REBUILD PAGE => ${controller.Page}");
        return Scaffold(
          backgroundColor: Global.bg,
          appBar: width >= 800 ? null : AppBarAsesor(),
          body: Column(
            children: [
              Expanded(
                  child: Row(
                    children: [
                      Leftmenuasesor(),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          color: Global.bg,
                          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                          child: FadeInDown(
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
              SafeArea(child: Bottommenuasesor())
            ],
          ),
        );
      }),
    );
  }
}
