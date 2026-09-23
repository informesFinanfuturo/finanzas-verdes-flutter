import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
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

class Editclientasesor extends StatefulWidget {
  const Editclientasesor({super.key});

  @override
  State<Editclientasesor> createState() => _EditclientasesorState();
}

class _EditclientasesorState extends State<Editclientasesor> {
  final _formKey = GlobalKey<FormState>();
  final clientController = Get.find<ClientController>(); // aquí viene el cliente seleccionado

  final documentoCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    final client = clientController.client; // cliente actual

    documentoCtrl.text = client["documento"] ?? '';
    nombreCtrl.text    = client["nombre_usuario"] ?? '';
    emailCtrl.text     = client["email"] ?? '';
    telefonoCtrl.text  = client["telefono"] ?? '';
  }

  @override
  void dispose() {
    documentoCtrl.dispose();
    nombreCtrl.dispose();
    emailCtrl.dispose();
    telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => controller.backPage(),
                borderRadius: BorderRadius.circular(15),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(CupertinoIcons.back),
                ),
              ),
              Text(
                "Editar cliente",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              TextButton(
                onPressed: () async {
                  loading ? null : await _submit();
                },
                child: Center(
                  child: loading
                      ? CircularProgressIndicator(
                    color: Global.primary,
                  )
                      : Text(
                    'Guardar',
                    style: TextStyle(
                      color: Global.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Global.container,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _input(documentoCtrl, 'Documento', Icons.badge),
                          const SizedBox(height: 12),

                          _input(nombreCtrl, 'Nombre del cliente', Icons.person),
                          const SizedBox(height: 12),

                          _input(
                            emailCtrl,
                            'Email',
                            Icons.email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),

                          _input(
                            telefonoCtrl,
                            'Teléfono (opcional)',
                            Icons.phone,
                            required: false,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  InkWell(
                    onTap: confirmDeleteCliente,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade400,
                            Colors.red.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Desactivar cliente",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool required = true,
        TextInputType keyboardType = TextInputType.text,
      }) {
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
          validator: required
              ? (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null
              : null,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await editClientApi(
        idUsuario: clientController.client["id_usuario"],
        updatedBy: controller.User["id_usuario"],
        clientController: Get.find<ClientController>(),
        documento: documentoCtrl.text,
        nombreUsuario: nombreCtrl.text,
        email: emailCtrl.text,
        telefono: telefonoCtrl.text.isEmpty ? null : telefonoCtrl.text,
      );

      controller.backPage();
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

  Future<void> confirmDeleteCliente() async {
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(Icons.warning_amber_rounded, size: 50, color: Colors.red),

              SizedBox(height: 10),

              Text(
                "¿Estás seguro de desactivar este cliente?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              Text(
                "Este cliente quedará como inactivo.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),

              SizedBox(height: 20),

              Row(
                children: [

                  /// ✅ CANCELAR
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      child: Text("Cancelar", style: TextStyle(color: Global.text),),
                    ),
                  ),

                  SizedBox(width: 10),

                  /// ✅ CONFIRMAR
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Get.back(result: true),
                      child: Text("Desactivar", style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    /// ✅ SI CONFIRMA
    if (result == true) {
      await inactiveClientApi(
        idClient: Get.find<ClientController>().Client["id_usuario"],
      );

      getClientApi(clientController: clientController);
      controller.backPage();
    }
  }
}