import 'dart:io';

import 'package:camera/camera.dart';
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
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:finanzas_verdes/views/proveedor/catalogo/takePhotoCatalogo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Editcatalogoproveedor extends StatefulWidget {
  const Editcatalogoproveedor({super.key});

  @override
  State<Editcatalogoproveedor> createState() => _EditcatalogoproveedorState();
}

class _EditcatalogoproveedorState extends State<Editcatalogoproveedor> {
  final _formKey = GlobalKey<FormState>();

  final UserController userController = Get.find();
  final ProveedorController proveedorController = Get.find();

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();

  String? selectedTipoItem;

  XFile? selectedImage;
  bool uploadingImage = false;


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

    final item = proveedorController.Item;

    nombreController.text = item["nombre"] ?? "";
    descripcionController.text = item["descripcion"] ?? "";
    selectedTipoItem = item["tipo_item"];
    precioController.text = (item["precio_base"] ?? "").toString();

    // ✅ EJECUTA PARA CREAR LOS CONTROLLERS
    onChangeTipo(selectedTipoItem!);

    // ✅ OBTENER ESPECIFICACIONES
    final specs = item["especificaciones"] ?? {};

    final config = Global.itemConfig
        .firstWhere((e) => e["tipo_item"] == selectedTipoItem);

    for (var campo in config["campos"]) {
      final key = campo["key"];
      final type = campo["type"];

      final value = specs[key];

      if (value == null) continue;

      if (type == "bool" || type == "select") {
        valuesDinamicos[key] = value;
      } else {
        controllersDinamicos[key]?.text = value.toString();
      }
    }

    setState(() {});
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
            Text("Editar item", style: GoogleFonts.poppins(fontSize: 18),)
          ],
        ),
        SizedBox(height: 10,),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        TextFormField(
                          initialValue: selectedTipoItem,
                          readOnly: true,
                          decoration: Wapp.TextFieldDecoration(
                            Global.primary,
                            true,
                            'Tipo de item',
                            Icons.category,
                          ),
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
                              Global.primary,
                            ),
                            child: Center(
                              child: loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'Editar catálogo',
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Global.container,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SizedBox(
                    height: 160,
                    child: proveedorController.Item["imagenes"].isEmpty
                        ? Center(child: Text("Sin imágenes"))
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: proveedorController.Item["imagenes"].length,
                      itemBuilder: (context, index) {
                        final img = proveedorController.Item["imagenes"][index];

                        final url = "${Utils.buildUrl(img)}";

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                    url,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, error, ___) {
                                      return Icon(Icons.image_not_supported, size: 120, color: Global.textSecondary,);
                                    }
                                ),
                              ),
                              InkWell(
                                  onTap: () async {
                                    await deleteImagenItem(idArchivo: img["id_archivo"]);
                                    proveedorController.setItem(await getItemById(id_item: proveedorController.Item["id_item"]));
                                  },
                                  borderRadius: BorderRadius.circular(15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.delete),
                                  )
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Global.container,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      LayoutBuilder(
                        builder: (context, constraints) {

                          final isWeb = kIsWeb;

                          // ✅ tamaños dinámicos
                          final width = isWeb
                              ? constraints.maxWidth * 0.7
                              : constraints.maxWidth;

                          final height = isWeb ? 300.0 : 120.0;

                          return Center(
                            child: Container(
                              width: width,
                              height: height,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Global.secondary),
                              ),
                              child: Center(
                                child: selectedImage == null
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, color: Global.secondary, size: isWeb ? 60 : 40),
                                    Text("Sin imagen seleccionada"),
                                  ],
                                )
                                    : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child:
                                  kIsWeb
                                      ? Image.network(
                                    selectedImage!.path, // ✅ web (blob url)
                                    fit: BoxFit.contain,
                                  )
                                      : Image.file(
                                    File(selectedImage!.path), // ✅ móvil (archivo real)
                                    fit: BoxFit.contain,
                                  ),

                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 10,),

                      Row(
                        children: [
                          Expanded(
                            child: _button("Galería", Icons.image, pickImage, Global.secondary),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _button("Cámara", Icons.camera_alt, takePhoto, Global.contrast),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      InkWell(
                        onTap: uploadingImage ? null : _uploadImage,
                        child: Container(
                          height: 50,
                          decoration: Wapp.ButtonDecorationGradient(
                            Global.secondary,
                            Global.secondary,
                          ),
                          child: Center(
                            child: uploadingImage
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                              "Subir imagen",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
      final ok = await updateItemApi(
        id: proveedorController.Item["id_item"], // ✅ CLAVE
        tipoItem: selectedTipoItem!,
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        especificaciones: especificaciones,
        precioBase: precio,
        idProveedor: userController.User["extra"]["id_proveedor"],
        updated_by: controller.User["id_usuario"], // ✅ CAMBIO
      );

      /// ✅ éxito
      if (ok) {
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

  Widget _button(String text, IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery, // ✅ sirve en web y móvil
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<void> takePhoto() async {
    if (kIsWeb) {
      // ✅ Web sigue igual
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        setState(() {
          selectedImage = image;
        });
      }

    } else {
      final image = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Takephotocatalogo(),
        ),
      );

      if (image != null) {
        setState(() {
          selectedImage = image;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (selectedImage == null) {
      Get.snackbar("Error", "Selecciona una imagen primero");
      return;
    }

    setState(() => uploadingImage = true);

    try {
      final item = Get.find<ProveedorController>().Item;

      await uploadImagenItemApi(
        idItem: item["id_item"],
        createdBy: controller.User["id_usuario"],
        image: selectedImage!,
      );

      Get.find<ProveedorController>().setItem(await getItemById(id_item: item["id_item"]));

      // ✅ RESET COMPLETO DEL PICKER
      setState(() {
        selectedImage = null;
      });

      Get.snackbar("OK", "Imagen subida correctamente");

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => uploadingImage = false);
    }
  }
}