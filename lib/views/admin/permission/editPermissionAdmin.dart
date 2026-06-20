import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/controllers/PermissionController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/permissionApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Editpermissionadmin extends StatefulWidget {
  const Editpermissionadmin({super.key});

  @override
  State<Editpermissionadmin> createState() => _EditpermissionadminState();
}

class _EditpermissionadminState extends State<Editpermissionadmin> {
  final _formKey = GlobalKey<FormState>();
  final permissionController = Get.find<PermissionController>();

  final nombreController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
   nombreController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final permission = permissionController.Permission;
    nombreController.text = permission["nombre"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: (){
                controller.setPage(Adminroutes.permissions);
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(CupertinoIcons.back),
              )
            ),
            Text("Editar datos del permiso", style: GoogleFonts.poppins(fontSize: 18),)
          ],
        ),
        SizedBox(height: 10,),
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
                _input(nombreController, 'Nombre', Icons.security),

                const SizedBox(height: 24),

                /// ✅ BOTÓN
                InkWell(
                  onTap: loading ? null : _submit,
                  child: Container(
                    height: 50,
                    decoration: Wapp.ButtonDecorationGradient(
                      Global.secondary,
                      Global.secondary,
                    ),
                    child: Center(
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Editar permiso',
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
    ));
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
      await editPermissionApi(
        id: permissionController.Permission["id_permiso"],
        nombre: nombreController.text,
        permissionController: permissionController
      );

      controller.setPage(Adminroutes.permissions);

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