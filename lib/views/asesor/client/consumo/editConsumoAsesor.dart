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
import 'package:finanzas_verdes/utils/currency_formatter.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:finanzas_verdes/views/asesor/client/consumo/takePhotoConsumo.dart';
import 'package:finanzas_verdes/views/asesor/client/consumo/viewGaleriaImagesConsumo.dart';
import 'package:finanzas_verdes/views/asesor/client/viewOneImageAsesorCliente.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final consumoActualCtrl = TextEditingController();
  final consumoPromedioCtrl = TextEditingController();
  List<TextEditingController> consumosAnterioresCtrls = [];
  final unidadCtrl = TextEditingController();
  final periodoInicioCtrl = TextEditingController();
  final periodoFinCtrl = TextEditingController();
  final observacionesCtrl = TextEditingController();

  DateTime? fechaInicio;
  DateTime? fechaFin;


  String? tipoSeleccionado;

  List<String> tipos = ["Agua", "Energía", "Gas"];

  bool loading = false;

  final clientController = Get.find<ClientController>();

  XFile? selectedImage;
  bool uploadingImage = false;


  @override
  void dispose() {
    tipoCtrl.dispose();
    proveedorCtrl.dispose();
    valorCtrl.dispose();
    consumoActualCtrl.dispose();
    consumoPromedioCtrl.dispose();
    unidadCtrl.dispose();
    periodoInicioCtrl.dispose();
    periodoFinCtrl.dispose();
    observacionesCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (clientController.Consumo != null) {
      tipoSeleccionado = clientController.Consumo["tipo"] ?? '';
      proveedorCtrl.text = clientController.Consumo["proveedor"] ?? '';
      valorCtrl.text = Utils.formatMiles(
          clientController.Consumo["valor"] ?? 0
      );
      final consumo = clientController.Consumo["consumo"];

      if (consumo != null && consumo is Map) {
        consumoActualCtrl.text = consumo["actual"]?.toString() ?? '';
        consumoPromedioCtrl.text = consumo["promedio"]?.toString() ?? '';

        if (consumo["anteriores"] is List) {
          consumosAnterioresCtrls = (consumo["anteriores"] as List)
              .map<TextEditingController>((v) =>
              TextEditingController(text: v.toString()))
              .toList();
        }
      }
      unidadCtrl.text = clientController.Consumo["unidad"] ?? '';
      final inicio = clientController.Consumo["periodo_inicio"];
      final fin = clientController.Consumo["periodo_fin"];

      if (inicio != null && inicio.toString().isNotEmpty) {
        fechaInicio = DateTime.tryParse(inicio);

        periodoInicioCtrl.text =
            Utils.formatFechaBonita(inicio);
      }

      if (fin != null && fin.toString().isNotEmpty) {
        fechaFin = DateTime.tryParse(fin);

        periodoFinCtrl.text =
            Utils.formatFechaBonita(fin);
      }
      observacionesCtrl.text = clientController.Consumo["observaciones"] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Text("Editar Factura", style: GoogleFonts.poppins(fontSize: 18)),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Tipo de factura de consumo"),
                              DropdownButtonFormField<String>(
                                value: tipoSeleccionado,
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
                              )

                            ],
                          ),
                          const SizedBox(height: 12),

                          _input(proveedorCtrl, "Proveedor", Icons.business, required: false),
                          const SizedBox(height: 12),

                          _inputMoney(valorCtrl, "Valor factura", CupertinoIcons.money_dollar, "Valor factura"),
                          const SizedBox(height: 12),

                          _inputNumber(consumoActualCtrl, "Consumo actual", Icons.bolt, keyboardType: TextInputType.number, required: false),
                          SizedBox(height: 12),

                          _inputNumber(consumoPromedioCtrl, "Consumo promedio", Icons.analytics, keyboardType: TextInputType.number, required: false),
                          SizedBox(height: 12),

                          _input(unidadCtrl, "Unidad (kWh, m3)", Icons.speed, required: false),
                          const SizedBox(height: 12),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text("Consumos anteriores"),

                              const SizedBox(height: 10),

                              // ✅ LISTA
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: consumosAnterioresCtrls.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [

                                      /// INPUT
                                      Expanded(
                                        child: TextFormField(
                                          controller: consumosAnterioresCtrls[index],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            labelText: "Consumo ${index + 1}",
                                          ),
                                        ),
                                      ),

                                      /// ELIMINAR
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            consumosAnterioresCtrls.removeAt(index);
                                          });
                                        },
                                      )
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 10),

                              /// ✅ AGREGAR NUEVO
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    consumosAnterioresCtrls.add(TextEditingController());
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Global.primary),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, color: Global.primary),
                                        SizedBox(width: 5),
                                        Text("Agregar consumo",
                                            style: TextStyle(color: Global.primary)),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10,),

                          _dateField(
                            periodoInicioCtrl,
                            "Fecha de inicio",
                          ),

                          const SizedBox(height: 12),

                          _dateField(
                            periodoFinCtrl,
                            "Fecha de fin",
                          ),

                          _inputArea(observacionesCtrl, "Ejemplo: frecuencia de uso, reparaciones, daños, modificaciones, ubicación, antigüedad, etc.", Icons.description, "Observaciones de la factura", required: false),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              MagicWrapper(
                                onTap: () async {
                                  await analizarConsumoApi(idConsumo: clientController.Consumo["id_consumo"]);
                                  clientController.setConsumo(await getConsumoApi(idConsumo: clientController.Consumo["id_consumo"]));
                                  if (clientController.Consumo != null) {
                                    tipoCtrl.text = clientController.Consumo["tipo"] ?? '';
                                    proveedorCtrl.text = clientController.Consumo["proveedor"] ?? '';
                                    valorCtrl.text = Utils.formatMiles(
                                        clientController.Consumo["valor"] ?? 0
                                    );
                                    final consumo = clientController.Consumo["consumo"];
                                    if (consumo != null && consumo is Map) {
                                      consumoActualCtrl.text = consumo["actual"]?.toString() ?? '';
                                      consumoPromedioCtrl.text = consumo["promedio"]?.toString() ?? '';

                                      if (consumo["anteriores"] is List) {
                                        consumosAnterioresCtrls = (consumo["anteriores"] as List)
                                            .map<TextEditingController>((v) =>
                                            TextEditingController(text: v.toString()))
                                            .toList();
                                      }
                                    }
                                    unidadCtrl.text = clientController.Consumo["unidad"] ?? '';
                                    final inicio = clientController.Consumo["periodo_inicio"];
                                    final fin = clientController.Consumo["periodo_fin"];

                                    if (inicio != null) {
                                      fechaInicio = DateTime.tryParse(inicio);

                                      periodoInicioCtrl.text =
                                          Utils.formatFechaBonita(inicio);
                                    }

                                    if (fin != null) {
                                      fechaFin = DateTime.tryParse(fin);

                                      periodoFinCtrl.text =
                                          Utils.formatFechaBonita(fin);
                                    }
                                    observacionesCtrl.text = clientController.Consumo["observaciones"] ?? '';
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
                            ],
                          ),
                        ],
                      )
                  ),
                ),
                const SizedBox(height: 10),

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
                          clientController.Consumo["observacion_ia"] == null ?
                          SizedBox(
                            height: 120,
                            child: Center(
                              child: Text("No hay observaciones registradas"),
                            ),
                          )
                              :
                          Center(
                            child: Text(clientController.Consumo["observacion_ia"]),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Subir imágenes
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
                                ) :
                                InkWell(
                                  onTap: (){
                                    viewOneImageAsesorCliente(selectedImage!);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: kIsWeb ? Image.network(
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

                const SizedBox(height: 10),

                //Imágenes
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Global.container,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Imágenes de la factura del consumo", style: GoogleFonts.poppins(fontSize: 18),),
                      SizedBox(height: 10,),
                      clientController.Consumo["imagenes"].isEmpty
                          ? Center(child: Text("Sin imágenes"))
                          :
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: clientController.Consumo["imagenes"].length,
                          itemBuilder: (context, index) {
                            final img = clientController.Consumo["imagenes"][index];

                            final url = "${Utils.buildUrl(img)}";

                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: (){
                                      openGaleriaConsumo(
                                        clientController.Consumo["imagenes"],
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
                                        },
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

                const SizedBox(height: 10),

                InkWell(
                  onTap: confirmDeleteConsumo,
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
                          "Eliminar factura",
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

                const SizedBox(height: 10),
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
        bool required = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
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
          validator: required
              ? (v) => (v == null || v.trim().isEmpty)
              ? 'Campo obligatorio'
              : null
              : null,
        ),
      ],
    );
  }

  Widget _inputNumber(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool required = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
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
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: required
              ? (v) => (v == null || v.trim().isEmpty)
              ? 'Campo obligatorio'
              : null
              : null,
        ),
      ],
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
        tipo: tipoSeleccionado,
        proveedor: proveedorCtrl.text.trim(),
        periodo_inicio: fechaBackend(fechaInicio),
        periodo_fin: fechaBackend(fechaFin),
        unidad: unidadCtrl.text.trim(),
        observaciones: observacionesCtrl.text.trim(),
        valor: valorCtrl.text.trim().isEmpty
            ? null
            : Utils.parseMoney(valorCtrl.text),

        consumoActual: consumoActualCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(consumoActualCtrl.text.trim()),

        consumoPromedio: consumoPromedioCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(consumoPromedioCtrl.text.trim()),
        consumoAnteriores: consumosAnterioresCtrls.isEmpty
            ? []
            : consumosAnterioresCtrls
            .map((c) => int.tryParse(c.text.trim()))
            .where((v) => v != null)
            .cast<int>()
            .toList(),
      );

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
          builder: (_) => Takephotoconsumo(),
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

  Widget DatosConsumosWidget(Map<String, dynamic>? datos) {
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

  Future<void> confirmDeleteConsumo() async {
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
                "¿Estás seguro de eliminar esta factura?",
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
      await deleteConsumoApi(
        idConsumo: Get.find<ClientController>().Consumo["id_consumo"],
      );

      clientController.setConsumo({});
      clientController.refreshClient();
      controller.backPage();
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {

    DateTime initialDate = DateTime.now();

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (_) {}
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected != null) {

      if (controller == periodoInicioCtrl) {
        fechaInicio = selected;
      } else if (controller == periodoFinCtrl) {
        fechaFin = selected;
      }

      controller.text = Utils.formatFechaBonita(
        selected.toIso8601String(),
      );
    }
  }

  Widget _dateField(
      TextEditingController controller,
      String label,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickDate(controller),
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            label,
            Icons.calendar_today,
          ).copyWith(
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () => _pickDate(controller),
            ),
          ),
        ),
      ],
    );
  }

  String? fechaBackend(DateTime? fecha) {

    if (fecha == null) return null;

    return
      '${fecha.year}-'
          '${fecha.month.toString().padLeft(2, '0')}-'
          '${fecha.day.toString().padLeft(2, '0')}';
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

  Widget _inputMoney(
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
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandsFormatter(),
          ],
        ),
      ],
    );
  }
}