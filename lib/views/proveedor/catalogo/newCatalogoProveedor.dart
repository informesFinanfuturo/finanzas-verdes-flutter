import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/proveedorRoutes.dart';
import 'package:finanzas_verdes/controllers/PermissionController.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/catalogoApi.dart';
import 'package:finanzas_verdes/models/api/permissionApi.dart';
import 'package:finanzas_verdes/models/api/proveedorApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Newcatalogoproveedor extends StatefulWidget {
  const Newcatalogoproveedor({super.key});

  @override
  State<Newcatalogoproveedor> createState() => _NewcatalogoproveedorState();
}

class _NewcatalogoproveedorState extends State<Newcatalogoproveedor> {
  final _formKey = GlobalKey<FormState>();

  final UserController userController = Get.find();
  final ProveedorController proveedorController = Get.find();

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();

  String? selectedTipoItem;

// dinámicos
  final Map<String, TextEditingController> controllersDinamicos = {};
  final Map<String, dynamic> valuesDinamicos = {};

  List<Map<String, dynamic>> getTiposPermitidos() {
    final List userTipos =
        userController.user["extra"]?["tipos_proveedor"] ?? [];

    final nombresProveedor = proveedorController.TiposProveedores
        .where((p) => userTipos.contains(p["id_tipo_proveedor"]))
        .map((p) => p["nombre_tipo"])
        .toList();

    return Global.itemConfig.where((item) {
      final List permitidos = item["tiposProveedorPermitidos"];
      return permitidos.any((p) => nombresProveedor.contains(p));
    }).toList();
  }


  bool loading = false;

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
                  controller.backPage();
                },
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(CupertinoIcons.back),
                )
            ),
            Text("Crear nuevo item", style: GoogleFonts.poppins(fontSize: 18),)
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedTipoItem,
                      hint: Text("Tipo de item"),
                      items: getTiposPermitidos().map<DropdownMenuItem<String>>((t) {
                        return DropdownMenuItem(
                          value: t["tipo_item"],
                          child: Text(t["tipo_item"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) onChangeTipo(value);
                      },
                    ),
                    SizedBox(height: 10,),
                    _input(nombreController, 'Nombre', Icons.security),
            
                    SizedBox(height: 10,),
            
                    _input(descripcionController, 'Descripción', Icons.notes, required: false),
            
                    const SizedBox(height: 12),
            
                    _input(precioController, "Precio base", CupertinoIcons.money_dollar, required: true),
            
                    if (selectedTipoItem != null) ...[
                      const SizedBox(height: 12),
            
                      ...Global.itemConfig
                          .firstWhere((e) => e["tipo_item"] == selectedTipoItem)["campos"]
                          .map<Widget>((campo) => Column(
                        children: [
                          buildCampo(campo),
                          const SizedBox(height: 10),
                        ],
                      ))
                          .toList(),
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
                            'Crear catálogo',
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
        SizedBox(height: 10,)
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
    /// ✅ VALIDAR FORM BASE
    if (!_formKey.currentState!.validate()) return;

    final config = Global.itemConfig
        .firstWhere((e) => e["tipo_item"] == selectedTipoItem);

    for (var campo in config["campos"]) {
      if (campo["required"] == true) {
        final key = campo["key"];

        final controller = controllersDinamicos[key];
        final value = valuesDinamicos[key];

        if ((controller != null && controller.text.isEmpty) &&
            (value == null)) {
          Get.snackbar(
            'Error',
            'El campo ${campo["label"]} es obligatorio',
            snackPosition: SnackPosition.BOTTOM,
          );

          setState(() => loading = false);
          return;
        }
      }
    }

    /// ✅ validar tipo
    if (selectedTipoItem == null) {
      Get.snackbar(
        'Error',
        'Debes seleccionar un tipo de item',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => loading = true);

    try {
      /// ✅ construir JSON dinámico
      final especificaciones = buildEspecificaciones();
      print(especificaciones);

      /// ✅ parsear precio
      final precio = double.tryParse(precioController.text);

      if (precio == null) {
        Get.snackbar(
          'Error',
          'Precio inválido',
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => loading = false);
        return;
      }

      /// ✅ LLAMAR API
      final ok = await createItemApi(
        tipoItem: selectedTipoItem!,
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        especificaciones: especificaciones,
        precioBase: precio,
        idProveedor: userController.User["extra"]["id_proveedor"],
        createdBy: controller.User["id_usuario"],
      );

      /// ✅ éxito
      if (ok) {

        nombreController.clear();
        descripcionController.clear();
        precioController.clear();

        controllersDinamicos.clear();
        valuesDinamicos.clear();

        selectedTipoItem = null;

        setState(() {});
        controller.backPage();
      }

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

  void onChangeTipo(String tipo) {
    selectedTipoItem = tipo;

    controllersDinamicos.clear();
    valuesDinamicos.clear();

    final config = Global.itemConfig.firstWhere((e) => e["tipo_item"] == tipo);

    for (var campo in config["campos"]) {
      controllersDinamicos[campo["key"]] = TextEditingController();
    }

    setState(() {});
  }

  Widget buildCampo(Map campo) {
    final key = campo["key"];
    final type = campo["type"];

    switch (type) {
      case "text":
        return TextFormField(
          controller: controllersDinamicos[key],
          keyboardType: type == "number"
              ? TextInputType.number
              : TextInputType.text,
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            campo["label"],
            Icons.edit,
          ),
          validator: (v) {
            if (campo["required"] == true && (v == null || v.isEmpty)) {
              return 'Campo requerido';
            }

            return null;
          },
        );
      case "number":
        return TextFormField(
          controller: controllersDinamicos[key],
          keyboardType: type == "number"
              ? TextInputType.number
              : TextInputType.text,
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            campo["label"],
            Icons.edit,
          ),
          validator: (v) {
            if (campo["required"] == true && (v == null || v.isEmpty)) {
              return 'Campo requerido';
            }


            if (v != null && v.isNotEmpty) {
              final parsed = double.tryParse(v);

              if (parsed == null) {
                return 'Debe ser un número válido';
              }
            }

            return null;
          },
        );

      case "textarea":
        return TextFormField(
          controller: controllersDinamicos[key],
          maxLines: 3,
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            campo["label"],
            Icons.notes,
          ),
        );

      case "bool":
        return Obx(() {
          final val = valuesDinamicos[key] ?? false;

          return SwitchListTile(
            value: val,
            onChanged: (v) {
              setState(() {
                valuesDinamicos[key] = v;
              });
            },
            title: Text(campo["label"]),
          );
        });

      case "select":
        return DropdownButtonFormField<String>(
          items: (campo["options"] as List)
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            setState(() {
              valuesDinamicos[key] = v;
            });
          },
          decoration: InputDecoration(labelText: campo["label"]),
        );

      default:
        return SizedBox();
    }
  }

  Map<String, dynamic> buildEspecificaciones() {
    final Map<String, dynamic> specs = {};

    final config = Global.itemConfig
        .firstWhere((e) => e["tipo_item"] == selectedTipoItem);

    for (var campo in config["campos"]) {
      final key = campo["key"];
      final type = campo["type"];

      final controller = controllersDinamicos[key];

      if (controller != null && controller.text.isNotEmpty) {
        if (type == "number") {
          specs[key] = double.tryParse(controller.text);
        } else {
          specs[key] = controller.text;
        }
      }
    }

    valuesDinamicos.forEach((key, value) {
      specs[key] = value;
    });

    return specs;
  }
}