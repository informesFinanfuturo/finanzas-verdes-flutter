import 'dart:async';

import 'package:finanzas_verdes/app/routes/routeNames.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/views/admin/permission/editPermissionAdmin.dart';
import 'package:finanzas_verdes/views/admin/permission/newPermissionAdmin.dart';
import 'package:finanzas_verdes/views/admin/rols/editRolAdmin.dart';
import 'package:finanzas_verdes/views/admin/rols/newRolAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/homeAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/moreAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/permissionAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/rolsAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/usersAdmin.dart';
import 'package:finanzas_verdes/views/admin/users/editUserAdmin.dart';
import 'package:finanzas_verdes/views/admin/users/newUserAdmin.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/editActivoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/newActivoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/consumo/editConsumoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/consumo/newConsumoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/dashBoardClientAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/editClientAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/mipyme/editMipymeAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/mipyme/newMipymeAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/newClientAsesor.dart';
import 'package:finanzas_verdes/views/asesor/screens/clientsAsesor.dart';
import 'package:finanzas_verdes/views/asesor/screens/homeAsesor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Generalcontoller extends GetxController{
  // VARIABLES
  Timer? timer;
  final isDark = false.obs;
  final page = "".obs;
  final pages = {
    // ADMINISTRADOR
    "homeAdmin" : Homeadmin(),
    "usersAdmin" : Usersadmin(),
    "newUserAdmin" : Newuseradmin(),
    "more" : Moreadmin(),
    "editUserAdmin" : Edituseradmin(),
    "rolsAdmin" : Rolsadmin(),
    "newRolAdmin" : Newroladmin(),
    "editRolAdmin" : Editroladmin(),
    "permissionsAdmin" : Permissionsadmin(),
    "newPermissionAdmin" : Newpermissionadmin(),
    "editPermissionAdmin" : Editpermissionadmin(),

    // ASESOR
    "homeAsesor" : Homeasesor(),
    "clientsAsesor" : Clientsasesor(),
    AsesorRoutes.newClient : Newclientasesor(),
    AsesorRoutes.editClient : Editclientasesor(),
    AsesorRoutes.dashBoardClient : Dashboardclientasesor(),
    AsesorRoutes.newMipyme : Newmipymeasesor(),
    AsesorRoutes.editMipyme : Editmipymeasesor(),
    AsesorRoutes.newActivo : Newactivoasesor(),
    AsesorRoutes.editActivo : Editactivoasesor(),
    AsesorRoutes.newConsumo : Newconsumoasesor(),
    AsesorRoutes.editConsumo : Editconsumoasesor(),
  }.obs;
  final user = {}.obs;

  // FUNCIONES
  void setSplash () {
    timer?.cancel();
    int seconds = 2;
    timer = Timer.periodic(Duration(seconds: 1), (timer){
      if(seconds > 0){
        seconds--;
      }else{
        timer.cancel();
        initUser();
      }
    });
  }

  void toggleTheme () {
    isDark.value = !isDark.value;
  }

  void setPage (String item){
    page.value = item;
  }

  void setUser (Map item){
    user.value = item;
  }

  void redirectToAndSave (Map user) {
    final box = GetStorage();
    box.write("user", user);
    if(user["rol"]["nombre_rol"] == "Administrador"){
      Get.toNamed(Routes.dashboardAdmin);
    }else if(user["rol"]["nombre_rol"] == "Asesor"){
      Get.toNamed(Routes.dashboardAsesor);
    }
  }

  void logOut () {
    Get.offAllNamed(Routes.login);
    controller.setUser({});
    final box = GetStorage();
    box.write("user", null);
    box.write("token", null);
  }

  void initUser (){
    final box = GetStorage();
    final userBox = box.read("user");
    if(userBox == null){
      Get.offNamed(Routes.login);
    }else{
      setUser(userBox);
      redirectToAndSave(userBox);
    }
  }

  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;
  Map get Pages => pages.value;
  String get Page => page.value;
  Map get User => user.value;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    isDark.value = brightness == Brightness.dark;
    setSplash();
  }
}