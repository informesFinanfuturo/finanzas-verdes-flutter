import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/controllers/PermissionController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/permissionApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Editroladmin extends StatefulWidget {
  const Editroladmin({super.key});

  @override
  State<Editroladmin> createState() => _EditroladminState();
}

class _EditroladminState extends State<Editroladmin> {
  final _formKey = GlobalKey<FormState>();
  final rolController = Get.find<RolController>();

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
    final rol = rolController.Rol;
    nombreController.text = rol["nombre_rol"] ?? "";
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
                controller.setPage(Adminroutes.rols);
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(CupertinoIcons.back),
              )
            ),
            Text("Editar datos del rol", style: GoogleFonts.poppins(fontSize: 18),)
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
                        'Editar rol',
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
        SizedBox(height: 10,),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Global.container,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Permisos", style: GoogleFonts.poppins(fontSize: 18),),
                SizedBox(height: 10,),
                Expanded(
                  child: ListView.builder(
                    itemCount: rolController.Rol["permisos"].length,
                    itemBuilder: (context, i){
                      final permission = rolController.Rol["permisos"][i];
                      return CheckboxListTile(
                        value: permission["enabled"],
                        onChanged: (value) async {
                          await toggleRolPermissionApi(id_permission: permission["id_permiso"], id_rol: rolController.Rol["id_rol"], rolController: rolController);
                          rolController.setRol(await getRolApi(id: rolController.Rol["id_rol"], rolController: rolController));
                        },
                        title: Text(permission["nombre_permiso"]),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        )
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
      await editRolApi(
        id: rolController.Rol["id_rol"],
        nombre: nombreController.text,
        rolController: rolController
      );

      controller.setPage(Adminroutes.rols);

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