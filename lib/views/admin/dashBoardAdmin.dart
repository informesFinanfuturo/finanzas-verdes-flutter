import 'package:animate_do/animate_do.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/views/admin/menus/appBarAdmin.dart';
import 'package:finanzas_verdes/views/admin/menus/bottomMenuAdmin.dart';
import 'package:finanzas_verdes/views/admin/menus/leftMenuAdmin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dashboardadmin extends StatefulWidget {
  const Dashboardadmin({super.key});

  @override
  State<Dashboardadmin> createState() => _DashboardadminState();
}

class _DashboardadminState extends State<Dashboardadmin> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.setPage(Adminroutes.home);
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Obx(() => Scaffold(
      backgroundColor: Global.bg,
      appBar: width >= 800 ? null : AppBarAdmin(),
      body: Column(
        children: [
          Expanded(
              child: Row(
                children: [
                  Leftmenuadmin(),
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
          Bottommenuadmin()
        ],
      ),
    ));
  }
}
