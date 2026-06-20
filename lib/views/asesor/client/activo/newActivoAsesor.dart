import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/activoApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Newactivoasesor extends StatefulWidget {
  const Newactivoasesor({super.key});

  @override
  State<Newactivoasesor> createState() => _NewactivoasesorState();
}

class _NewactivoasesorState extends State<Newactivoasesor> {

  final _formKey = GlobalKey<FormState>();

  // ✅ CAMPOS MIPYME
  final nombreCtrl = TextEditingController();
  final tipoCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    nombreCtrl.dispose();
    tipoCtrl.dispose();
    descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(()=> Column(
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
            Text("Registrar Activo",
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

                  _input(nombreCtrl, "Nombre del activo", Icons.inventory,),
                  const SizedBox(height: 12),

                  _input(tipoCtrl, "Tipo de activo", Icons.category),
                  const SizedBox(height: 12),

                  _input(descripcionCtrl, "Descripción (opcional)", Icons.description, required: false),
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
                          'Guardar Activo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
          ),
        ),
      ],
    ));
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final clientController = Get.find<ClientController>();

      await createActivoApi(
        nombre: nombreCtrl.text,
        tipo: tipoCtrl.text,
        descripcion: descripcionCtrl.text.isEmpty ? null : descripcionCtrl.text,
        idMipyme: clientController.Client["mipyme"]["id_mipyme"], // ✅ clave
        createdBy: controller.User["id_usuario"],
      );

      // ✅ refrescar cliente (para traer activos nuevos)
      clientController.setClient(
        await getClientDetailApi(
          idUsuario: clientController.Client["user"]["id_usuario"],
        ),
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