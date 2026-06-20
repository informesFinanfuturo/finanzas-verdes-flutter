import 'dart:io';

import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Editconsumoasesor extends StatefulWidget {
  const Editconsumoasesor({super.key});

  @override
  State<Editconsumoasesor> createState() => _EditconsumoasesorState();
}

class _EditconsumoasesorState extends State<Editconsumoasesor> {

  final _formKey = GlobalKey<FormState>();

  final tipoCtrl = TextEditingController();
  final proveedorCtrl = TextEditingController();
  final valorCtrl = TextEditingController();
  final consumoCtrl = TextEditingController();
  final unidadCtrl = TextEditingController();
  final periodoCtrl = TextEditingController();
  final observacionesCtrl = TextEditingController();

  bool loading = false;

  final clientController = Get.find<ClientController>();

  XFile? selectedImage;
  bool uploadingImage = false;


  @override
  void dispose() {
    tipoCtrl.dispose();
    proveedorCtrl.dispose();
    valorCtrl.dispose();
    consumoCtrl.dispose();
    unidadCtrl.dispose();
    periodoCtrl.dispose();
    observacionesCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (clientController.Consumo != null) {
      tipoCtrl.text = clientController.Consumo["tipo"] ?? '';
      proveedorCtrl.text = clientController.Consumo["proveedor"] ?? '';
      valorCtrl.text = clientController.Consumo["valor"] ?? '';
      consumoCtrl.text = clientController.Consumo["consumo"] ?? '';
      consumoCtrl.text = clientController.Consumo["consumo"] ?? '';
      unidadCtrl.text = clientController.Consumo["unidad"] ?? '';
      periodoCtrl.text = clientController.Consumo["periodo"] ?? '';
      observacionesCtrl.text = clientController.Consumo["observaciones"] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  controller.setPage(AsesorRoutes.dashBoardClient);
                },
                borderRadius: BorderRadius.circular(15),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(CupertinoIcons.back),
                ),
              ),
              Text("Editar Factura de consumo", style: GoogleFonts.poppins(fontSize: 18)),
            ],
          ),
      
          const SizedBox(height: 10),
      
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

                    _input(tipoCtrl, "Tipo (luz, agua, gas)", Icons.category, required: true,),
                    const SizedBox(height: 12),
      
                    _input(proveedorCtrl, "Proveedor", Icons.business, required: false),
                    const SizedBox(height: 12),
      
                    _input(valorCtrl, "Valor factura", Icons.attach_money, keyboardType: TextInputType.number, required: false),
                    const SizedBox(height: 12),
      
                    _input(consumoCtrl, "Consumo", Icons.bolt, keyboardType: TextInputType.number, required: false),
                    const SizedBox(height: 12),
      
                    _input(unidadCtrl, "Unidad (kWh, m3)", Icons.speed, required: false),
                    const SizedBox(height: 12),
      
                    _input(periodoCtrl, "Periodo (2026-06-01)", Icons.date_range, required: false),
                    const SizedBox(height: 12),
      
                    _input(observacionesCtrl, "Observaciones", Icons.description, required: false),
                    const SizedBox(height: 24),
      
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
                            'Editar Consumo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ),
          const SizedBox(height: 20),
      
          SizedBox(
            height: 160,
            child: clientController.Consumo["imagenes"].isEmpty
                ? Center(child: Text("Sin imágenes"))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: clientController.Consumo["imagenes"].length,
              itemBuilder: (context, index) {
                final img = clientController.Consumo["imagenes"][index];
      
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

                            final consumo = Get.find<ClientController>().Consumo;

                            await deleteImagenConsumoApi(
                              idArchivo: img["id_archivo"],
                            ); // ✅ ESPERAR

                            final updated = await getConsumoApi(
                              idConsumo: consumo["id_consumo"],
                            );

                            Get.find<ClientController>().setConsumo(updated);
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
      
      
          const SizedBox(height: 20),

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

        const SizedBox(height: 10),

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
    ));
  }

  Widget _input(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool required = false,
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
          ? (v) => (v == null || v.trim().isEmpty)
          ? 'Campo obligatorio'
          : null
          : null,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final clientController = Get.find<ClientController>();


      await updateConsumoApi(
        idConsumo: clientController.Consumo["id_consumo"], // ✅ clave
        updatedBy: controller.User["id_usuario"],

        // ✅ SOLO LO QUE CAMBIA
        tipo: tipoCtrl.text.trim().isEmpty
            ? null
            : tipoCtrl.text.trim(),

        proveedor: proveedorCtrl.text.trim().isEmpty
            ? null
            : proveedorCtrl.text.trim(),

        periodo: periodoCtrl.text.trim().isEmpty
            ? null
            : periodoCtrl.text.trim(),

        valor: valorCtrl.text.isEmpty
            ? null
            : double.tryParse(valorCtrl.text),

        consumo: consumoCtrl.text.isEmpty
            ? null
            : double.tryParse(consumoCtrl.text),

        unidad: unidadCtrl.text.trim().isEmpty
            ? null
            : unidadCtrl.text.trim(),

        observaciones: observacionesCtrl.text.trim().isEmpty
            ? null
            : observacionesCtrl.text.trim(),
      );


      // ✅ feedback al usuario
      Get.snackbar("OK", "Factura creada");

      clientController.setClient(
        await getClientDetailApi(
          idUsuario: clientController.Client["user"]["id_usuario"],
        ),
      );

      controller.setPage(AsesorRoutes.dashBoardClient);

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
      source: ImageSource.gallery,
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
      final consumo = Get.find<ClientController>().Consumo;

      await uploadImagenConsumoApi(
        idConsumo: consumo["id_consumo"],
        createdBy: controller.User["id_usuario"],
        image: selectedImage!,
      );

      Get.find<ClientController>().setConsumo(await getConsumoApi(idConsumo: consumo["id_consumo"]));

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
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: kIsWeb
          ? ImageSource.gallery // ✅ web
          : ImageSource.camera, // ✅ móvil
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
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

}