// lib/app/middlewares/auth_middleware.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:finanzas_verdes/app/routes/routeNames.dart';
import 'package:finanzas_verdes/main.dart';

// class AuthMiddleware extends GetMiddleware {
//   @override
//   int? get priority => 1; // se ejecuta temprano
//
//   @override
//   RouteSettings? redirect(String? route) {
//     //final isLoggedIn = generalController.isLoggedIn.value;
//     //final isAdmin = generalController.isAdmin.value;
//
//     // 🚫 No logueado → login
//     if (!isLoggedIn) {
//       return const RouteSettings(name: Routes.login);
//     }
//
//     // 🚫 No admin → fuera del dashboard admin
//     if (route == Routes.dashboardAdmin && !isAdmin) {
//       return const RouteSettings(name: Routes.login);
//     }
//
//     return null; // ✅ deja pasar
//   }
// }