import 'dart:io';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/activoApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/takePhotoActivo.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/viewGaleriaImagesActivo.dart';
import 'package:finanzas_verdes/views/asesor/client/viewOneImageAsesorCliente.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Editactivoasesor extends StatefulWidget {
  const Editactivoasesor({super.key});

  @override
  State<Editactivoasesor> createState() => _EditactivoasesorState();
}

class _EditactivoasesorState extends State<Editactivoasesor> {

  final _formKey = GlobalKey<FormState>();

  // CAMPOS MIPYME
  final nombreCtrl = TextEditingController();
  String? tipoSeleccionado;
  final descripcionCtrl = TextEditingController();
  final marcaCtrl = TextEditingController();
  final modeloCtrl = TextEditingController();
  bool loading = false;

  final List<String> tipos = [
    "Electrodoméstico",
    "Iluminación",
    "Climatización",
    "Equipos de cocina",
    "Maquinaria",
    "Sistemas de bombeo",
    "Computo",
    "Otro"
  ];

  // CAMPOS IMAGE
  XFile? selectedImage;
  bool uploadingImage = false;

  final clientController = Get.find<ClientController>();


  @override
  void dispose() {
    nombreCtrl.dispose();
    descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (clientController.Activo != null) {
      nombreCtrl.text = clientController.Activo["nombre"] ?? '';
      tipoSeleccionado = clientController.Activo["tipo"] ?? '';
      descripcionCtrl.text = clientController.Activo["descripcion"] ?? '';
      marcaCtrl.text = clientController.Activo["marca"] ?? '';
      modeloCtrl.text = clientController.Activo["modelo"] ?? '';
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
              onTap: () {
                controller.backPage();
              },
              borderRadius: BorderRadius.circular(15),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(CupertinoIcons.back),
              ),
            ),
            Text("Editar Activo",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Tipo de activo"),
                              DropdownButtonFormField<String>(
                                initialValue: tipoSeleccionado,
                                items: tipos.map((tipo) {
                                  return DropdownMenuItem(
                                    value: tipo,
                                    child: Text(tipo),
                                  );
                                }).toList(),

                                onChanged: (value) {
                                  setState(() {
                                    tipoSeleccionado = value;
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
                          const SizedBox(height: 12),
                        ],
                      )
                  ),
                ),
                SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Global.container,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Subir imágen", style: GoogleFonts.poppins(fontSize: 18),),
                      SizedBox(height: 10,),
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
                                    :
                                InkWell(
                                  onTap: (){
                                    viewOneImageAsesorCliente(selectedImage!);
                                  },
                                  child: ClipRRect(
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

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
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
                          ),
                          SizedBox(width: 5,),
                          IconButton(
                              onPressed: (){
                                setState(() {
                                  selectedImage = null;
                                });
                              },
                              icon: Icon(Icons.delete, color: Colors.red, size: 40,)
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10,),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Global.container,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Imágenes del activo", style: GoogleFonts.poppins(fontSize: 18),),
                      SizedBox(height: 10,),
                      clientController.Activo["imagenes"].isEmpty
                          ? Center(child: Text("Sin imágenes"))
                          :
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: clientController.Activo["imagenes"].length,
                          itemBuilder: (context, index) {
                            final img = clientController.Activo["imagenes"][index];

                            final url = "${Utils.buildUrl(img)}";

                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: (){
                                      openGaleriaActivo(
                                        clientController.Activo["imagenes"],
                                        index,
                                      );
                                    },
                                    child: ClipRRect(
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
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                ),

                SizedBox(height: 10,),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Global.primary,      // color 1
                        Global.secondary
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(1.5), // 🔥 grosor del borde
                  child: Container(
                    decoration: BoxDecoration(
                      color: Global.bg,
                      borderRadius: BorderRadius.circular(14), // un poco más pequeño
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Diagnóstico de inteligencia artificial", style: GoogleFonts.poppins(),),
                          clientController.Activo["datos"] == null ?
                          SizedBox(
                            height: 120,
                            child: Center(
                              child: Text("No hay datos generados"),
                            ),
                          )
                          :

                          DatosActivosWidget(
                            clientController.Activo["datos"] is Map && clientController.Activo["datos"].containsKey("datos")
                                ? clientController.Activo["datos"]["datos"]
                                : clientController.Activo["datos"],
                          ),
                          Center(
                            child: SizedBox(
                              width: 200,
                              child: MagicWrapper(
                                onTap: () async {
                                  await analizarActivoApi(idActivo: clientController.Activo["id_activo"]);
                                  clientController.setActivo(await getActivoApi(idActivo: clientController.Activo["id_activo"]));
                                  if (clientController.Activo != null) {
                                    nombreCtrl.text = clientController.Activo["nombre"] ?? '';
                                    tipoSeleccionado = clientController.Activo["tipo"] ?? '';
                                    descripcionCtrl.text = clientController.Activo["descripcion"] ?? '';
                                    marcaCtrl.text = clientController.Activo["marca"] ?? '';
                                    modeloCtrl.text = clientController.Activo["modelo"] ?? '';
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: Wapp.ButtonDecorationGradient(
                                    Global.primary,
                                    Global.secondary,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Generar", style: TextStyle(color: Colors.white),),
                                      SizedBox(width: 5),
                                      Icon(Icons.auto_awesome, color: Colors.white,)
                                    ],
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

                SizedBox(height: 10,),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Global.primary,      // color 1
                        Global.secondary
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(1.5), // 🔥 grosor del borde
                  child: Container(
                    decoration: BoxDecoration(
                      color: Global.bg,
                      borderRadius: BorderRadius.circular(14), // un poco más pequeño
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Observaciones IA", style: GoogleFonts.poppins(),),
                          SizedBox(height: 10,),
                          clientController.Activo["observacion_ia"] == null ?
                          SizedBox(
                            height: 120,
                            child: Center(
                              child: Text("No hay observaciones registradas"),
                            ),
                          )
                          :
                          Center(
                            child: Text(clientController.Activo["observacion_ia"]),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                InkWell(
                  onTap: confirmDeleteActivo,
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
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Eliminar activo",
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

                SizedBox(height: 10,),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final clientController = Get.find<ClientController>();
      final activo = Get.find<ClientController>().Activo;

      await updateActivoApi(
        idActivo: activo["id_activo"], // ✅ clave
        updatedBy: controller.User["id_usuario"],

        nombre: nombreCtrl.text,
        tipo: tipoSeleccionado,
        descripcion: descripcionCtrl.text.isEmpty
            ? null
            : descripcionCtrl.text,
        marca: marcaCtrl.text,
        modelo: modeloCtrl.text,
      );

      // ✅ refrescar datos
      clientController.setClient(
        await getClientDetailApi(
          idUsuario: clientController.Client["user"]["id_usuario"],
        ),
      );

      controller.backPage();

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

  Future<void> _uploadImage() async {
    if (selectedImage == null) {
      Get.snackbar("Error", "Selecciona una imagen primero");
      return;
    }

    setState(() => uploadingImage = true);

    try {
      final activo = Get.find<ClientController>().Activo;

      await uploadImagenActivoApi(
        idActivo: activo["id_activo"],
        createdBy: controller.User["id_usuario"],
        image: selectedImage!,
      );

      Get.find<ClientController>().setActivo(await getActivoApi(idActivo: activo["id_activo"]));

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
          builder: (_) => Takephotoactivo(),
        ),
      );

      if (image != null) {
        setState(() {
          selectedImage = image;
        });
      }
    }
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

  Widget DatosActivosWidget(Map<String, dynamic>? datos) {
    if (datos == null || datos.isEmpty) {
      return Center(child: Text("Sin información disponible"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: datos.entries.map((entry) {
        return buildItem(entry.key, entry.value);
      }).toList(),
    );
  }

  Future<void> confirmDeleteActivo() async {
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
                "¿Estás seguro de eliminar este activo?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              Text(
                "Esta acción solo se podrá revertir con un administrador.",
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
                      child: Text("Eliminar", style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
    if (result == true) {
      await deleteActivoApi(
        idActivo: Get.find<ClientController>().Activo["id_activo"],
      );

      clientController.setActivo({});
      clientController.refreshClient();
      controller.backPage();
    }
  }
}