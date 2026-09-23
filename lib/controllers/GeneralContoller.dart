import 'dart:async';
import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/routeNames.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/clienteRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/proveedorRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/superadminRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/calendarioApi.dart';
import 'package:finanzas_verdes/views/admin/permission/editPermissionAdmin.dart';
import 'package:finanzas_verdes/views/admin/permission/newPermissionAdmin.dart';
import 'package:finanzas_verdes/views/admin/rols/editRolAdmin.dart';
import 'package:finanzas_verdes/views/admin/rols/newRolAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/homeAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/moreAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/permissionAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/proveedoresAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/rolsAdmin.dart';
import 'package:finanzas_verdes/views/admin/screens/usersAdmin.dart';
import 'package:finanzas_verdes/views/admin/users/editUserAdmin.dart';
import 'package:finanzas_verdes/views/admin/users/newUserAdmin.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/editActivoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/newActivoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/consumo/editConsumoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/dashBoardClientAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/diagnostico/ViewDiagnosticoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/diagnostico/newDiagnosticoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/editClientAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/mipyme/editMipymeAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/newClientAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/mipyme/newClientWithMipymeAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/plan_trabajo/editPlanTrabajoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/plan_trabajo/newPlanTrabajoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/plan_trabajo/viewPlanTrabajoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/client/requerimiento/newRequerimientoAsesor.dart';
import 'package:finanzas_verdes/views/asesor/screens/clientsAsesor.dart';
import 'package:finanzas_verdes/views/asesor/screens/homeAsesor.dart';
import 'package:finanzas_verdes/views/asesor/screens/moreAsesor.dart';
import 'package:finanzas_verdes/views/cliente/screens/ActivosCliente.dart';
import 'package:finanzas_verdes/views/cliente/screens/ConsumosCliente.dart';
import 'package:finanzas_verdes/views/cliente/screens/DiagnosticosCliente.dart';
import 'package:finanzas_verdes/views/cliente/screens/Homecliente.dart';
import 'package:finanzas_verdes/views/cliente/screens/moreCliente.dart';
import 'package:finanzas_verdes/views/proveedor/catalogo/editCatalogoProveedor.dart';
import 'package:finanzas_verdes/views/proveedor/catalogo/newCatalogoProveedor.dart';
import 'package:finanzas_verdes/views/proveedor/screens/CatalogoProveedor.dart';
import 'package:finanzas_verdes/views/proveedor/screens/Homeproveedor.dart';
import 'package:finanzas_verdes/views/proveedor/screens/moreProveedor.dart';
import 'package:finanzas_verdes/views/superadmin/screens/homeAdmin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Generalcontoller extends GetxController{
  // VARIABLES
  Timer? timer;
  final isDark = false.obs;
  final page = "".obs;
  final historyPages = [].obs;
  final calendario = [].obs;
  final agenda = [].obs;
  final pages = {
    // ADMINISTRADOR
    Adminroutes.home : Homeadmin(),
    Adminroutes.users : Usersadmin(),
    Adminroutes.newUser : Newuseradmin(),
    Adminroutes.more : Moreadmin(),
    Adminroutes.editUser : Edituseradmin(),
    Adminroutes.rols : Rolsadmin(),
    Adminroutes.newRol : Newroladmin(),
    Adminroutes.editRol : Editroladmin(),
    Adminroutes.permissions : Permissionsadmin(),
    Adminroutes.newPermission : Newpermissionadmin(),
    Adminroutes.editPermission : Editpermissionadmin(),
    Adminroutes.homeProveedores : Proveedoresadmin(),

    // ASESOR
    AsesorRoutes.home : Homeasesor(),
    AsesorRoutes.more : Moreasesor(),
    AsesorRoutes.clients : Clientsasesor(),
    AsesorRoutes.newClient : Newclientasesor(),
    AsesorRoutes.newClientMipyme : Newclientwithmipymeasesor(),
    AsesorRoutes.editClient : Editclientasesor(),
    AsesorRoutes.dashBoardClient : Dashboardclientasesor(),
    AsesorRoutes.editMipyme : Editmipymeasesor(),
    AsesorRoutes.newActivo : Newactivoasesor(),
    AsesorRoutes.editActivo : Editactivoasesor(),
    AsesorRoutes.editConsumo : Editconsumoasesor(),
    AsesorRoutes.newDiagnostico : Newdiagnosticoasesor(),
    AsesorRoutes.viewDiagnostico : Viewdiagnosticoasesor(),
    AsesorRoutes.newPlanTrabajo : Newplantrabajoasesor(),
    AsesorRoutes.editPlanTrabajo : Editplantrabajoasesor(),
    AsesorRoutes.viewPlanTrabajo : Viewplantrabajoasesor(),
    AsesorRoutes.newRequerimiento : Newrequerimientoasesor(),

    // CLIENTE
    ClienteRoutes.home : Homecliente(),
    ClienteRoutes.more : Morecliente(),
    ClienteRoutes.activos : Activoscliente(),
    ClienteRoutes.consumos: Consumoscliente(),
    ClienteRoutes.diagnosticos: Diagnosticoscliente(),

    // PROVEEDOR
    ProveedorRoutes.home : Homeproveedor(),
    ProveedorRoutes.more : Moreproveedor(),
    ProveedorRoutes.catalogo : Catalogoproveedor(),
    ProveedorRoutes.newCatalogo : Newcatalogoproveedor(),
    ProveedorRoutes.editCatalogo : Editcatalogoproveedor(),

    // SUPER ADMIN
    SuperadminRoutes.home : Homesuperadmin(),

  }.obs;
  final user = {}.obs;
  final appointments = <Appointment>[].obs;

  final firstDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;
  final hasUnsavedChanges = false.obs;

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

  void setPage(String item) {
    if (page.value != item && page.value != "") {
      historyPages.add(page.value);
    }

    page.value = item;


    print("SET PAGE => $item");
    print("HISTORY => $historyPages");

  }

  Future<void> backPage() async {

    if (hasUnsavedChanges.value) {

      final salir = await Get.dialog<bool>(
        AlertDialog(
          title: const Text("Cambios sin guardar"),
          content: const Text(
            "Tienes cambios sin guardar. "
                "¿Deseas salir de todas formas?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(result: false);
              },
              child: const Text(
                "Continuar editando",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(result: true);
              },
              child: const Text(
                "Salir",
              ),
            ),
          ],
        ),
      );

      if (salir != true) {
        hasUnsavedChanges.value = false;
        return;
      }
    }

    if (historyPages.isEmpty) {
      Get.back();
      return;
    }

    hasUnsavedChanges.value = false;
    page.value = historyPages.value.removeLast();
  }

  void setUser (Map item){
    user.value = item;
  }

  void redirectToAndSave (Map user) async {
    final box = GetStorage();
    print(user);
    box.write("user", user);
    if(user["rol"]["nombre_rol"] == "Administrador"){
      Get.toNamed(Routes.dashboardAdmin);
    }else if(user["rol"]["nombre_rol"] == "Asesor"){
      Get.toNamed(Routes.dashboardAsesor);
    }else if(user["rol"]["nombre_rol"] == "Cliente"){
      Get.toNamed(Routes.dashboardCliente);
    }else if(user["rol"]["nombre_rol"] == "Proveedor"){
      Get.toNamed(Routes.dashboardProveedor);
    }else if(user["rol"]["nombre_rol"] == "Super administrador"){
      Get.toNamed(Routes.dashboardSuperAdmin);
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

  void setCalendario (List item){
    calendario.value = item;
  }

  void setAgenda (List item){
    agenda.value = item;
  }

  void setAppointments (List<Appointment> item) {
    appointments.value = item;
  }

  Future<void> loadRange(
      DateTime start,
      DateTime end,
      ) async {
    final agenda =
    await getClientsAgendaRangeApi(
      fechaInicio: start,
      fechaFin: end,
    );

    final appointments =
    agenda.map<Appointment>((item) {
      final fecha =
      DateTime.parse(
        item["fecha_hora"],
      );

      /*
     * Título o tipo principal del evento.
     * Cambia el orden si tu API utiliza
     * otro nombre de campo.
     */
      final String eventTitle =
      _firstValidAgendaText([
        item["titulo"],
        item["tipo_visita"],
        item["tipo"],
        item["motivo"],
        item["descripcion"],
        "Visita programada",
      ]);

      final String companyName =
      _firstValidAgendaText([
        item["nombre_mipyme"],
        item["nombre_usuario"],
        "Cliente sin empresa",
      ]);

      return Appointment(
        /*
       * Toda la información queda disponible
       * para el appointmentBuilder y los modales.
       */
        notes: jsonEncode(item),

        startTime: fecha,

        endTime: fecha.add(
          const Duration(
            hours: 2,
          ),
        ),

        /*
       * Syncfusion utilizará el tipo del evento
       * como título principal.
       */
        subject: eventTitle,

        /*
       * Podemos aprovechar location para guardar
       * temporalmente el nombre de la empresa.
       */
        location: companyName,

        color: Global.primary,
      );
    }).toList();

    controller.setAppointments(
      appointments,
    );
  }

  String _firstValidAgendaText(
      List<dynamic> values,
      ) {
    for (final value in values) {
      final text =
          value?.toString().trim() ??
              "";

      if (
      text.isNotEmpty &&
          text.toLowerCase() != "null"
      ) {
        return text;
      }
    }

    return "";
  }

  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;
  Map get Pages => pages.value;
  String get Page => page.value;
  Map get User => user.value;
  List get Calendario => calendario.value;
  List get Agenda => agenda.value;
  List<Appointment> get Appointments => appointments.value;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    isDark.value = brightness == Brightness.dark;
    setSplash();
    final presente = DateTime.now();

    firstDate.value = DateTime(
      presente.year,
      presente.month,
      presente.day - (presente.weekday - 1),
    );

    endDate.value = DateTime(
      presente.year,
      presente.month,
      presente.day + (7 - presente.weekday),
    );
  }
}