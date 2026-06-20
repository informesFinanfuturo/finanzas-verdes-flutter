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

class Newclientasesor extends StatefulWidget {
  const Newclientasesor({super.key});

  @override
  State<Newclientasesor> createState() => _NewclientasesorState();
}

class _NewclientasesorState extends State<Newclientasesor> {
  final _formKey = GlobalKey<FormState>();

  final documentoCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool loading = false;
  bool showPassword = false;

  @override
  void dispose() {
    documentoCtrl.dispose();
    nombreCtrl.dispose();
    emailCtrl.dispose();
    telefonoCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
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
                controller.setPage(AsesorRoutes.clients);
              },
              borderRadius: BorderRadius.circular(15),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(CupertinoIcons.back),
              ),
            ),
            Text(
              "Crear nuevo cliente",
              style: GoogleFonts.poppins(fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 10),
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
                const SizedBox(height: 12),

                TextFormField(
                  controller: passwordCtrl,
                  obscureText: !showPassword,
                  decoration: Wapp.TextFieldDecoration(
                    Global.primary,
                    true,
                    'Contraseña',
                    Icons.lock,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Global.primary,
                      ),
                      onPressed: () {
                        setState(() => showPassword = !showPassword);
                      },
                    ),
                  ),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Campo obligatorio' : null,
                ),
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
                        'Crear cliente',
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
      IconData icon, {
        bool required = true,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
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
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await createClientApi(
        documento: documentoCtrl.text,
        nombreUsuario: nombreCtrl.text,
        email: emailCtrl.text,
        telefono:
        telefonoCtrl.text.isEmpty ? null : telefonoCtrl.text,
        password: passwordCtrl.text,
        createdBy: controller.User["id_usuario"],
        clientController: Get.find<ClientController>(),
      );

      controller.setPage(AsesorRoutes.clients);

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