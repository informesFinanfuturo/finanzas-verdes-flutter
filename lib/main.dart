import 'package:animate_do/animate_do.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/config/Images.dart';
import 'package:finanzas_verdes/app/routes/appRouter.dart';
import 'package:finanzas_verdes/app/routes/routeNames.dart';
import 'package:finanzas_verdes/controllers/GeneralContoller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

void main () async {

  await GetStorage.init();
  Get.put(Generalcontoller());
  runApp(Obx(() => GetMaterialApp(
    title: "Finanzas verdes",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Global.primary,
        brightness: Brightness.light,
      ).copyWith(
        onSurface: Colors.black,
        onPrimary: Colors.white,
      ),
      hoverColor: Global.primary.withOpacity(0.12), // ✅ clave
      textTheme: GoogleFonts.latoTextTheme(),
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Global.primary,
        brightness: Brightness.dark,
      ).copyWith(
        onSurface: Colors.white,
        onPrimary: Colors.black,
      ),
      hoverColor: Global.primary.withOpacity(0.08),
      textTheme: GoogleFonts.latoTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    ),
    getPages: AppPages.routes,
    initialRoute: Routes.splash,
    themeMode: controller.themeMode,
  )));
}

Generalcontoller controller = Get.find();

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Global.bg,
        child: Center(
          child: FadeIn(
              child: Image.asset(Images.logo, height: 120,)
          ),),
      ),
    );
  }
}
