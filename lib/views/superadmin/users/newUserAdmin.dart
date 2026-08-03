import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/proveedorApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Newuseradmin extends StatefulWidget {
  const Newuseradmin({super.key});

  @override
  State<Newuseradmin> createState() => _NewuseradminState();
}

class _NewuseradminState extends State<Newuseradmin> {
  final _formKey = GlobalKey<FormState>();

  final documentoCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nombreCargoCtrl = TextEditingController();
  final sedeCtrl = TextEditingController();

  final razonSocialCtrl = TextEditingController();
  final nitCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final calificacionCtrl = TextEditingController();

  bool loading = false;
  bool showPassword = false;

  /// ✅ Roles por ahora en String
  final rolController = Get.find<RolController>();
  final userController = Get.find<UserController>();
  final ProveedorController proveedorController = Get.put(ProveedorController());
  int? selectedRol;
  static int rolAsesor = 3;
  static int rolProveedor = 4;

  @override
  void dispose() {
    documentoCtrl.dispose();
    nombreCtrl.dispose();
    emailCtrl.dispose();
    telefonoCtrl.dispose();
    passwordCtrl.dispose();
    nombreCargoCtrl.dispose();
    sedeCtrl.dispose();

    razonSocialCtrl.dispose();
    nitCtrl.dispose();
    direccionCtrl.dispose();
    calificacionCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRolsApi(rolController: rolController);
    getTipoProveedoresApi(proveedorController: proveedorController);
    userController.setTiposProveedor([]);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if(rolController.Rols == true){
        return Center(
          child: CircularProgressIndicator(color: Global.primary,),
        );
      }else{
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: (){
                      controller.setPage(Adminroutes.users);
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(CupertinoIcons.back),
                    )
                ),
                Text("Crear nuevo usuario", style: GoogleFonts.poppins(fontSize: 18),)
              ],
            ),
            SizedBox(height: 10,),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Global.container,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _input(documentoCtrl, 'Documento', Icons.badge),
                          const SizedBox(height: 12),

                          _input(nombreCtrl, 'Nombre de usuario', Icons.person),
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

                          /// ✅ SELECT DE ROL
                          DropdownButtonFormField<String>(
                            decoration: Wapp.TextFieldDecoration(
                              Global.primary,
                              true,
                              'Rol',
                              Icons.security,
                            ),
                            items: rolController.Rols
                                .map(
                                  (rol) => DropdownMenuItem(
                                value: rol["id_rol"].toString(),
                                child: Text(rol["nombre_rol"]),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() => selectedRol = int.parse(value.toString()));
                            },
                            validator: (value) =>
                            value == null ? 'Selecciona un rol' : null,
                          ),
                          const SizedBox(height: 12),

                      // ✅ CAMPOS ASESOR
                          if (selectedRol == rolAsesor) ...[
                            _input(nombreCargoCtrl, 'Nombre del cargo', Icons.work),
                            const SizedBox(height: 12),
                            _input(sedeCtrl, 'Sede', Icons.location_on),
                            const SizedBox(height: 12),
                          ],

                      // ✅ CAMPOS PROVEEDOR
                          if (selectedRol == rolProveedor) ...[
                            _input(razonSocialCtrl, 'Razón social', Icons.business),
                            const SizedBox(height: 12),
                            _input(nitCtrl, 'NIT', Icons.credit_card),
                            const SizedBox(height: 12),
                            _input(direccionCtrl, 'Dirección', Icons.location_on),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: calificacionCtrl,
                              keyboardType: TextInputType.number,
                              decoration: Wapp.TextFieldDecoration(
                                Global.primary,
                                true,
                                'Calificación (opcional)',
                                Icons.star,
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],


                          /// 🔒 Password
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

                          if(selectedRol == rolProveedor) ...[
                            const SizedBox(height: 24),
                            Text("Categorías", style: GoogleFonts.poppins(),),
                            Divider(),
                            const SizedBox(height: 24),


                            proveedorController.TiposProveedores == [] ? Center(child: CircularProgressIndicator(),) :
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: proveedorController.TiposProveedores.length,
                              itemBuilder: (context, i){
                                final tipo = proveedorController.TiposProveedores[i];
                                final enabled = userController.TiposProveedor.contains(tipo["id_tipo_proveedor"]);
                                return CheckboxListTile(
                                  value: enabled,
                                  onChanged: (value) async {
                                    if(enabled){
                                      userController.tiposProveedor.value.remove(tipo["id_tipo_proveedor"]);
                                    }else{
                                      userController.tiposProveedor.value.add(tipo["id_tipo_proveedor"]);
                                    }
                                    proveedorController.tiposProveedores.refresh();
                                  },
                                  title: Text(tipo["nombre_tipo"]),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Divider(),
                          ],

                          const SizedBox(height: 24),

                          /// ✅ BOTÓN
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
                                  'Crear usuario',
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
                ),
              ),
            ),
          ],
        );
      }
    });
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
      await newUserApi(
        documento: documentoCtrl.text,
        nombreUsuario: nombreCtrl.text,
        email: emailCtrl.text,
        telefono: telefonoCtrl.text.isEmpty ? null : telefonoCtrl.text,
        password: passwordCtrl.text,
        idRol: selectedRol!,
        createdBy: controller.User["id_usuario"],
        userController: Get.find<UserController>(),

        // ✅ asesor
        nombreCargo: selectedRol == rolAsesor ? nombreCargoCtrl.text : null,
        sede: selectedRol == rolAsesor ? sedeCtrl.text : null,

        // ✅ proveedor
        razonSocial: selectedRol == rolProveedor ? razonSocialCtrl.text : null,
        nit: selectedRol == rolProveedor ? nitCtrl.text : null,
        direccion: selectedRol == rolProveedor ? direccionCtrl.text : null,
        calificacion: selectedRol == rolProveedor
            ? double.tryParse(calificacionCtrl.text)
            : null,
        tiposProveedores: userController.TiposProveedor
      );

      controller.setPage(Adminroutes.users);

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