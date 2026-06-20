// lib/app/routes/app_pages.dart
import 'package:finanzas_verdes/app/routes/routeNames.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/views/admin/dashBoardAdmin.dart';
import 'package:finanzas_verdes/views/asesor/dashBoardAsesor.dart';
import 'package:finanzas_verdes/views/login/Login.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => const Login(),
    ),
    GetPage(
      name: Routes.splash,
      page: () => const Splash(),
    ),
    GetPage(
      name: Routes.dashboardAdmin,
      page: () => const Dashboardadmin(),
    ),
    GetPage(
      name: Routes.dashboardAsesor,
      page: () => const Dashboardasesor(),
    ),
  ];
}