import 'package:animate_do/animate_do.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/views/admin/menus/appBarAdmin.dart';
import 'package:finanzas_verdes/views/admin/menus/bottomMenuAdmin.dart';
import 'package:finanzas_verdes/views/admin/menus/leftMenuAdmin.dart';
import 'package:finanzas_verdes/views/superadmin/menus/bottomMenuSuperAdmin.dart';
import 'package:finanzas_verdes/views/superadmin/menus/leftMenuSuperAdmin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dashboardsuperadmin extends StatefulWidget {
  const Dashboardsuperadmin({super.key});

  @override
  State<Dashboardsuperadmin> createState() => _DashboardsuperadminState();
}

class _DashboardsuperadminState extends State<Dashboardsuperadmin> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.setPage(Adminroutes.home);
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
        appBar: width >= 800 ? null : AppBarAdmin(),
        body: Column(
          children: [
            Expanded(
                child: Row(
                  children: [
                    Leftmenusuperadmin(),
                    Expanded(
                      child: Container(
                        height: double.infinity,
                        color: Global.bg,
                        padding: EdgeInsets.all(20),
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
            SafeArea(child: Bottommenusuperadmin())
          ],
        ),
      )),
    );
  }
}
