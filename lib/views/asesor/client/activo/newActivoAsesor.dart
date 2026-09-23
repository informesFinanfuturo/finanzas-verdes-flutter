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
  String tipoSeleccionado = "Neveras";
  final descripcionCtrl = TextEditingController();
  final marcaCtrl = TextEditingController();
  final modeloCtrl = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    nombreCtrl.dispose();
    descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(()=> Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  controller.backPage();
                },
                borderRadius: BorderRadius.circular(15),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(CupertinoIcons.back),
                ),
              ),
              Text("Registrar Activo",
                  style: GoogleFonts.poppins(fontSize: 18)),
              TextButton(
                  onPressed: (){
                    _submit();
                  },
                  child: Text("Guardar", style: TextStyle(fontSize: 18),)
              )
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              child: Container(
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

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tipo de activo"),
                            DropdownButtonFormField<String>(
                              value: tipoSeleccionado,
                              items: Global.tiposActivo.map((tipo) {
                                return DropdownMenuItem(
                                  value: tipo,
                                  child: Text(tipo),
                                );
                              }).toList(),

                              onChanged: (value) {
                                setState(() {
                                  tipoSeleccionado = value!;
                                });
                              },

                              decoration: Wapp.TextFieldDecoration(
                                Global.primary,
                                true,
                                "Tipo",
                                Icons.category,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _input(marcaCtrl, "Marca", Icons.branding_watermark),
                        const SizedBox(height: 12),

                        _input(modeloCtrl, "Modelo", Icons.precision_manufacturing),
                        const SizedBox(height: 12),

                        _inputArea(descripcionCtrl, "Ejemplo: frecuencia de uso, reparaciones, daños, modificaciones, ubicación, antigüedad, etc.", Icons.description, "Observaciones del activo", required: false),
                        const SizedBox(height: 24),
                      ],
                    )
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _input(
      TextEditingController controller,
      String hint,
      IconData icon,
      {bool required = false,
        TextInputType keyboardType = TextInputType.text}) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            hint,
            icon,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final clientController = Get.find<ClientController>();

      final activo = await createActivoApi(
        nombre: nombreCtrl.text,
        tipo: tipoSeleccionado!,
        descripcion: descripcionCtrl.text.isEmpty ? null : descripcionCtrl.text,
        idMipyme: clientController.Client["mipyme"]["id_mipyme"], // ✅ clave
        createdBy: controller.User["id_usuario"],
        marca: marcaCtrl.text,
        modelo: modeloCtrl.text.isEmpty ? null : modeloCtrl.text
      );

      // ✅ refrescar cliente (para traer activos nuevos)
      clientController.setClient(
        await getClientDetailApi(
          idUsuario: clientController.Client["user"]["id_usuario"],
        ),
      );

      if(activo["id_activo"] != null){
        controller.backPage();
        clientController.setActivo(await getActivoApi(idActivo: activo["id_activo"]));
        controller.setPage(AsesorRoutes.editActivo);
      }


    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _inputArea(
      TextEditingController controller,
      String hint,
      IconData icon,
      String label,
      {bool required = false,
        TextInputType keyboardType = TextInputType.text}) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            hint,
            icon,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}