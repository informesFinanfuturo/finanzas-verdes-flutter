import 'package:animate_do/animate_do.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/views/admin/menus/appBarAdmin.dart';
import 'package:finanzas_verdes/views/admin/menus/bottomMenuAdmin.dart';
import 'package:finanzas_verdes/views/admin/menus/leftMenuAdmin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dashboardadmin extends StatefulWidget {
  const Dashboardadmin({super.key});

  @override
  State<Dashboardadmin> createState() =>
      _DashboardadminState();
}

class _DashboardadminState
    extends State<Dashboardadmin> {
  @override
  void initState() {
    super.initState();

    controller.setPage(
      Adminroutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context).width;

    final isDesktop = width >= 800;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult:
          (didPop, result) {
        if (!didPop) {
          controller.backPage();
        }
      },
      child: Obx(
            () => Scaffold(
          backgroundColor: Global.bg,
          extendBody: true,
          appBar: isDesktop
              ? null
              : const AppBarAdmin(),
          body: Row(
            children: [
              if (isDesktop)
                const Leftmenuadmin(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Global.bg,
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 24 : 14,
                    isDesktop ? 22 : 12,
                    isDesktop ? 24 : 14,
                    isDesktop ? 22 : 0,
                  ),
                  child: controller.User[
                  "id_usuario"] ==
                      null
                      ? Center(
                    child:
                    CircularProgressIndicator(
                      color:
                      Global.primary,
                    ),
                  )
                      : FadeInDown(
                    key: ValueKey(
                      controller.Page,
                    ),
                    duration:
                    const Duration(
                      milliseconds: 230,
                    ),
                    from: 16,
                    child: controller
                        .Pages[
                    controller.Page
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar:
          isDesktop
              ? null
              : _buildFloatingMenu(),
        ),
      ),
    );
  }

  Widget _buildFloatingMenu() {
    return SafeArea(
      minimum:
      const EdgeInsets.only(
        bottom: 14,
      ),
      child: Align(
        alignment:
        Alignment.bottomCenter,
        heightFactor: 1,
        child: const Material(
          color: Colors.transparent,
          elevation: 0,
          child: Bottommenuadmin(),
        ),
      ),
    );
  }
}