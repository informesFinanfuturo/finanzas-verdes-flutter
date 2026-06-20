import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/activoApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
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
  final tipoCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  bool loading = false;

  // CAMPOS IMAGE
  XFile? selectedImage;
  bool uploadingImage = false;

  final clientController = Get.find<ClientController>();


  @override
  void dispose() {
    nombreCtrl.dispose();
    tipoCtrl.dispose();
    descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (clientController.Activo != null) {
      nombreCtrl.text = clientController.Activo["nombre"] ?? '';
      tipoCtrl.text = clientController.Activo["tipo"] ?? '';
      descripcionCtrl.text = clientController.Activo["descripcion"] ?? '';
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
              Text("Registrar Activo",
                  style: GoogleFonts.poppins(fontSize: 18)),
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
      
                    _input(nombreCtrl, "Nombre del activo", Icons.inventory,),
                    const SizedBox(height: 12),
      
                    _input(tipoCtrl, "Tipo de activo", Icons.category),
                    const SizedBox(height: 12),
      
                    _input(descripcionCtrl, "Descripción (opcional)", Icons.description, required: false),
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
                            'Editar Activo',
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
            child: clientController.Activo["imagenes"].isEmpty
                ? Center(child: Text("Sin imágenes"))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: clientController.Activo["imagenes"].length,
              itemBuilder: (context, index) {
                final img = clientController.Activo["imagenes"][index];
      
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
                          await deleteImagenActivoApi(idArchivo: img["id_archivo"]);
                          clientController.setActivo(await getActivoApi(idActivo: clientController.Activo["id_activo"]));
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
      
          InkWell(
            onTap: pickImage,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Global.secondary),
              ),
              child: Center(
                child: selectedImage == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, color: Global.secondary, size: 40),
                    Text("Seleccionar imagen"),
                  ],
                )
                    : Image.network(
                  selectedImage!.path, // ✅ funciona en WEB
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
      IconData icon,
      {bool required = false,
        TextInputType keyboardType = TextInputType.text}) {

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: Wapp.TextFieldDecoration(
        Global.primary,
        true,
        hint,
        icon,
      ),
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
        tipo: tipoCtrl.text,
        descripcion: descripcionCtrl.text.isEmpty
            ? null
            : descripcionCtrl.text,
      );

      // ✅ refrescar datos
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
}