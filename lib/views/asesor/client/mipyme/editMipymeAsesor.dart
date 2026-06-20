import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Editmipymeasesor extends StatefulWidget {
  const Editmipymeasesor({super.key});

  @override
  State<Editmipymeasesor> createState() => _EditmipymeasesorState();
}

class _EditmipymeasesorState extends State<Editmipymeasesor> {

  final _formKey = GlobalKey<FormState>();

  // ✅ CAMPOS MIPYME
  final nombreCtrl = TextEditingController();
  final nitCtrl = TextEditingController();
  final sectorCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final municipioCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final empleadosCtrl = TextEditingController();
  final ingresosCtrl = TextEditingController();
  final egresosCtrl = TextEditingController();
  final ciiuCtrl = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    nombreCtrl.dispose();
    nitCtrl.dispose();
    sectorCtrl.dispose();
    direccionCtrl.dispose();
    municipioCtrl.dispose();
    descripcionCtrl.dispose();
    empleadosCtrl.dispose();
    ingresosCtrl.dispose();
    egresosCtrl.dispose();
    ciiuCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final client = Get.find<ClientController>().Client;
    final mipyme = client["mipyme"];

    if (mipyme != null) {
      nombreCtrl.text = mipyme["nombre_mipyme"] ?? '';
      nitCtrl.text = mipyme["nit"] ?? '';
      sectorCtrl.text = mipyme["sector_economico"] ?? '';
      direccionCtrl.text = mipyme["direccion"] ?? '';
      municipioCtrl.text = mipyme["municipio"] ?? '';
      descripcionCtrl.text = mipyme["descripcion_empresa"] ?? '';
      empleadosCtrl.text = mipyme["cantidad_empleados"]?.toString() ?? '';
      ingresosCtrl.text = mipyme["ingresos"]?.toString() ?? '';
      egresosCtrl.text = mipyme["egresos"]?.toString() ?? '';
      ciiuCtrl.text = mipyme["codigo_ciiu"] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                controller.setPage(AsesorRoutes.dashBoardClient);
              },
              borderRadius: BorderRadius.circular(15),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(CupertinoIcons.back),
              ),
            ),
            Text("Editar Mipyme",
                style: GoogleFonts.poppins(fontSize: 18)),
          ],
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Global.container,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                _input(nombreCtrl, "Nombre de la mipyme", Icons.business),
                const SizedBox(height: 12),

                _input(nitCtrl, "NIT", Icons.badge),
                const SizedBox(height: 12),

                _input(sectorCtrl, "Sector económico", Icons.bar_chart),
                const SizedBox(height: 12),

                _input(direccionCtrl, "Dirección", Icons.location_on),
                const SizedBox(height: 12),

                _input(municipioCtrl, "Municipio", Icons.map),
                const SizedBox(height: 12),

                _input(descripcionCtrl, "Descripción", Icons.description),
                const SizedBox(height: 12),

                _input(empleadosCtrl, "Cantidad empleados",
                    Icons.people, keyboardType: TextInputType.number),
                const SizedBox(height: 12),

                _input(ingresosCtrl, "Ingresos",
                    Icons.trending_up, keyboardType: TextInputType.number),
                const SizedBox(height: 12),

                _input(egresosCtrl, "Egresos",
                    Icons.trending_down, keyboardType: TextInputType.number),
                const SizedBox(height: 12),

                _input(ciiuCtrl, "Código CIIU", Icons.code),
                const SizedBox(height: 24),

                InkWell(
                  onTap: loading ? null : _submit,
                  child: Container(
                    height: 50,
                    decoration: Wapp.ButtonDecorationGradient(
                      Global.primary,
                      Global.secondary,
                    ),
                    child: Center(
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Editar Mipyme',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _input(
      TextEditingController controller,
      String hint,
      IconData icon,
      {bool required = false,
        TextInputType keyboardType = TextInputType.text}) {

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: Wapp.TextFieldDecoration(
        Global.primary,
        true,
        hint,
        icon,
      ),
    );
  }

  Future<void> _submit() async {

    setState(() => loading = true);

    try {
      final clientController = Get.find<ClientController>();

      await updateMipymeApi(
        idMipyme: clientController.Client["mipyme"]["id_mipyme"], // ✅ clave
        updatedBy: controller.User["id_usuario"],

        nombreMipyme: nombreCtrl.text.isEmpty ? null : nombreCtrl.text,
        nit: nitCtrl.text.isEmpty ? null : nitCtrl.text,
        sectorEconomico: sectorCtrl.text.isEmpty ? null : sectorCtrl.text,
        direccion: direccionCtrl.text.isEmpty ? null : direccionCtrl.text,
        municipio: municipioCtrl.text.isEmpty ? null : municipioCtrl.text,
        descripcionEmpresa: descripcionCtrl.text.isEmpty ? null : descripcionCtrl.text,
        cantidadEmpleados: empleadosCtrl.text.isEmpty
            ? null
            : int.tryParse(empleadosCtrl.text),
        ingresos: ingresosCtrl.text.isEmpty
            ? null
            : double.tryParse(ingresosCtrl.text),
        egresos: egresosCtrl.text.isEmpty
            ? null
            : double.tryParse(egresosCtrl.text),
        codigoCiiu: ciiuCtrl.text.isEmpty ? null : ciiuCtrl.text,
      );

      clientController.setClient(
          await getClientDetailApi(
              idUsuario: clientController.Client["user"]["id_usuario"]
          )
      );

      controller.setPage(AsesorRoutes.dashBoardClient);

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => loading = false);
    }
  }
}