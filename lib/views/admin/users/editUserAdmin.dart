import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Edituseradmin extends StatefulWidget {
  const Edituseradmin({super.key});

  @override
  State<Edituseradmin> createState() => _EdituseradminState();
}

class _EdituseradminState extends State<Edituseradmin> {
  final _formKey = GlobalKey<FormState>();
  final userController = Get.find<UserController>();

  final documentoCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();

  // ASESOR
  final nombreCargoCtrl = TextEditingController();
  final sedeCtrl = TextEditingController();

// PROVEEDOR
  final razonSocialCtrl = TextEditingController();
  final nitCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final calificacionCtrl = TextEditingController();

  bool loading = false;
  bool showPassword = false;

  /// ✅ Roles por ahora en String
  final RolController rolController = Get.put(RolController());
  int? selectedRol;
  static int rolAsesor = 3;
  static int rolProveedor = 4;


  @override
  void dispose() {
    documentoCtrl.dispose();
    nombreCtrl.dispose();
    emailCtrl.dispose();
    telefonoCtrl.dispose();
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
    final user = userController.user;
    documentoCtrl.text = user["documento"];
    nombreCtrl.text = user["nombre_usuario"];
    emailCtrl.text = user["email"];
    telefonoCtrl.text = user["telefono"] ?? '';
    selectedRol = user["rol"]["id_rol"];


    final extra = user["extra"];

    if (extra != null) {
      nombreCargoCtrl.text = extra["nombre_cargo"] ?? '';
      sedeCtrl.text = extra["sede"] ?? '';

      razonSocialCtrl.text = extra["razon_social"] ?? '';
      nitCtrl.text = extra["nit"] ?? '';
      direccionCtrl.text = extra["direccion"] ?? '';
      calificacionCtrl.text = extra["calificacion"]?.toString() ?? '';
    }

  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
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
            Text("Editar datos del usuario", style: GoogleFonts.poppins(fontSize: 18),)
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
                  initialValue: userController.user["rol"]["id_rol"].toString(),
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

// ✅ ASESOR
                if (selectedRol == rolAsesor) ...[
                  _input(nombreCargoCtrl, 'Nombre del cargo', Icons.work),
                  const SizedBox(height: 12),
                  _input(sedeCtrl, 'Sede', Icons.location_on),
                  const SizedBox(height: 12),
                ],

// ✅ PROVEEDOR
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
                        'Editar usuario',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                            fontSize: 18
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
      await editUserApi(
        idUsuario: userController.user["id_usuario"],
        updatedBy: controller.User["id_usuario"],
        userController: userController,
        documento: documentoCtrl.text,
        nombreUsuario: nombreCtrl.text,
        email: emailCtrl.text,
        telefono: telefonoCtrl.text,
        idRol: selectedRol,

        // ✅ ASESOR
        nombreCargo: selectedRol == rolAsesor ? nombreCargoCtrl.text : null,
        sede: selectedRol == rolAsesor ? sedeCtrl.text : null,

        // ✅ PROVEEDOR
        razonSocial: selectedRol == rolProveedor ? razonSocialCtrl.text : null,
        nit: selectedRol == rolProveedor ? nitCtrl.text : null,
        direccion: selectedRol == rolProveedor ? direccionCtrl.text : null,
        calificacion: selectedRol == rolProveedor
            ? double.tryParse(calificacionCtrl.text)
            : null,
      );

      controller.setPage(Adminroutes.users);

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      print(e);
    } finally {
      setState(() => loading = false);
    }
  }
}