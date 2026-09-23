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
import 'package:flutter/services.dart';
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
  final cantidadCtrl = TextEditingController();
  bool loading = false;

  XFile? selectedImage;
  bool uploadingImage = false;

  final clientController = Get.find<ClientController>();

  bool analyzingWithAI = false;
  bool _isAiExpanded = false;

  @override
  void dispose() {
    nombreCtrl.dispose();
    descripcionCtrl.dispose();
    marcaCtrl.dispose();
    modeloCtrl.dispose();
    cantidadCtrl.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();

    final activo = clientController.Activo;

    nombreCtrl.text =
        activo["nombre"]?.toString() ?? '';

    tipoSeleccionado =
        activo["tipo"]?.toString();

    descripcionCtrl.text =
        activo["descripcion"]?.toString() ?? '';

    marcaCtrl.text =
        activo["marca"]?.toString() ?? '';

    modeloCtrl.text =
        activo["modelo"]?.toString() ?? '';

    cantidadCtrl.text =
        activo["cantidad"]?.toString() ?? '1';

    if (cantidadCtrl.text == 'null' ||
        cantidadCtrl.text.isEmpty) {
      cantidadCtrl.text = '1';
    }

    nombreCtrl.addListener(_markAsChanged);
    descripcionCtrl.addListener(_markAsChanged);
    marcaCtrl.addListener(_markAsChanged);
    modeloCtrl.addListener(_markAsChanged);
    cantidadCtrl.addListener(_markAsChanged);
  }

  void _markAsChanged() {
    if (!controller.hasUnsavedChanges.value) {
      setState(() {
        controller.hasUnsavedChanges.value = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNewAsset =
        clientController.Activo["id_activo"] == null;

    return Obx(() {
      final _ = controller.isDark.value;
      return LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop =
              constraints.maxWidth >= 1000;

          return Column(
            children: [
              PremiumEditorHeader(
                title: isNewAsset
                    ? 'Nuevo activo'
                    : 'Editar activo',
                hasUnsavedChanges:
                controller.hasUnsavedChanges.value,
                loading: loading,
                onBack: controller.backPage,
                onSave: loading ? null : _submit,
              ),

              const Divider(height: 1),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 28 : 14,
                    20,
                    isDesktop ? 28 : 14,
                    MediaQuery.paddingOf(context).bottom + 100,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1440,
                      ),
                      child: Column(
                        children: [
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _buildMainForm(
                                    isDesktop: true,
                                  ),
                                ),

                                const SizedBox(width: 20),

                                SizedBox(
                                  width: 390,
                                  child: _buildMediaPanel(),
                                ),
                              ],
                            )
                          else ...[
                            _buildMainForm(
                              isDesktop: false,
                            ),

                            const SizedBox(height: 16),

                            _buildMediaPanel(),
                          ],

                          const SizedBox(height: 20),

                          // La IA ahora aprovecha todo el ancho disponible.
                          _buildAiCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
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
        idActivo: activo["id_activo"],
        updatedBy: controller.User["id_usuario"],

        nombre: nombreCtrl.text,
        tipo: tipoSeleccionado,
        descripcion: descripcionCtrl.text.isEmpty
            ? null
            : descripcionCtrl.text,
        marca: marcaCtrl.text,
        modelo: modeloCtrl.text,
        cantidad: int.tryParse(cantidadCtrl.text) ?? 1,
      );

      controller.hasUnsavedChanges.value = false;

      clientController.refreshClient();

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
      controller.hasUnsavedChanges.value = true;
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

      controller.hasUnsavedChanges.value = true;

      Get.find<ClientController>().setActivo(await getActivoApi(idActivo: activo["id_activo"]));
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
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        setState(() {
          selectedImage = image;
        });
        controller.hasUnsavedChanges.value = true;
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
              ),
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

  Widget _buildMainForm({
    required bool isDesktop,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          PremiumSectionCard(
            title: 'Información del activo',
            subtitle:
            'Datos principales y clasificación',
            icon: Icons.inventory_2_rounded,
            color: Global.primary,
            child: _buildAssetFields(isDesktop),
          ),

          const SizedBox(height: 16),

          PremiumSectionCard(
            title: 'Descripción y condiciones',
            subtitle:
            'Información relevante para el diagnóstico',
            icon: Icons.description_outlined,
            color: const Color(0xFFF5A000),
            child: _inputArea(
              descripcionCtrl,
              'Incluya frecuencia de uso, reparaciones, daños, ubicación, modificaciones o antigüedad.',
              Icons.description_outlined,
              'Observaciones del activo',
            ),
          ),

          if (clientController.Activo["id_activo"] !=
              null) ...[
            const SizedBox(height: 24),
            _buildDangerZone(),
          ],
        ],
      ),
    );
  }

  Widget _responsiveFields({
    required bool isDesktop,
    required List<Widget> children,
  }) {
    if (!isDesktop) {
      return Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const SizedBox(height: 14),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1)
            const SizedBox(width: 14),
        ],
      ],
    );
  }

  Widget _buildAssetFields(bool isDesktop) {
    return Column(
      children: [
        _responsiveFields(
          isDesktop: isDesktop,
          children: [
            _input(
              nombreCtrl,
              'Nombre del activo',
              Icons.inventory_2_outlined,
              required: true,
            ),
            _buildAssetTypeField(),
          ],
        ),

        const SizedBox(height: 14),

        _responsiveFields(
          isDesktop: isDesktop,
          children: [
            _input(
              marcaCtrl,
              'Marca',
              Icons.branding_watermark_outlined,
            ),
            _input(
              modeloCtrl,
              'Modelo',
              Icons.precision_manufacturing_outlined,
            ),
          ],
        ),

        const SizedBox(height: 18),

        _buildQuantityField(),
      ],
    );
  }

  Widget _buildAssetTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de activo',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Global.text,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: tipoSeleccionado,
          isExpanded: true,
          items: Global.tiposActivo.map((tipo) {
            return DropdownMenuItem<String>(
              value: tipo,
              child: Text(
                tipo,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              tipoSeleccionado = value;
            });

            _markAsChanged();
          },
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            'Seleccione el tipo',
            Icons.category_outlined,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleccione un tipo de activo';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    int currentQuantity() {
      return int.tryParse(cantidadCtrl.text) ?? 1;
    }

    void updateQuantity(int value) {
      final safeValue = value.clamp(1, 999);

      cantidadCtrl.text = safeValue.toString();

      setState(() {});
      _markAsChanged();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cantidad de activos',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Global.text,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: 190,
          height: 48,
          decoration: BoxDecoration(
            color: Global.bg.withOpacity(0.55),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: Global.text.withOpacity(0.10),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: currentQuantity() > 1
                    ? () {
                  updateQuantity(
                    currentQuantity() - 1,
                  );
                }
                    : null,
                tooltip: 'Disminuir cantidad',
                icon: const Icon(
                  Icons.remove_rounded,
                ),
              ),

              Expanded(
                child: TextFormField(
                  controller: cantidadCtrl,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    final quantity =
                    int.tryParse(value ?? '');

                    if (quantity == null ||
                        quantity < 1) {
                      return 'Cantidad inválida';
                    }

                    return null;
                  },
                ),
              ),

              IconButton(
                onPressed: currentQuantity() < 999
                    ? () {
                  updateQuantity(
                    currentQuantity() + 1,
                  );
                }
                    : null,
                tooltip: 'Aumentar cantidad',
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPanel() {
    return Column(
      children: [
        _buildImageUploader(),

        const SizedBox(height: 16),

        _buildExistingImages(),
      ],
    );
  }

  Widget _buildAiCard() {
    final images = List<Map<String, dynamic>>.from(
      clientController.Activo["imagenes"] ?? [],
    );

    final dynamic rawData =
    clientController.Activo["datos"];

    final String observation =
    (clientController.Activo["observacion_ia"] ?? '')
        .toString()
        .trim();

    final bool canAnalyze =
        clientController.Activo["id_activo"] != null &&
            images.isNotEmpty;

    final Map<String, dynamic>? data =
    rawData is Map<String, dynamic>
        ? rawData["datos"] is Map<String, dynamic>
        ? Map<String, dynamic>.from(
      rawData["datos"],
    )
        : Map<String, dynamic>.from(rawData)
        : null;

    final bool hasAnalysis =
        data != null && data.isNotEmpty;

    return PremiumSectionCard(
      title: 'Análisis inteligente del activo',
      subtitle: hasAnalysis
          ? 'Consulta los hallazgos técnicos y recomendaciones'
          : 'Genera información técnica a partir de las evidencias',
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFF8E44C2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasAnalysis)
            _buildAiEmptyState(canAnalyze)
          else ...[
            _buildAiSummary(
              observation: observation,
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isAiExpanded = !_isAiExpanded;
                  });
                },
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 220),
                  turns: _isAiExpanded ? 0.5 : 0,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                  ),
                ),
                label: Text(
                  _isAiExpanded
                      ? 'Ocultar análisis completo'
                      : 'Ver análisis completo',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                  const Color(0xFF8E44C2),
                  side: BorderSide(
                    color: const Color(0xFF8E44C2)
                        .withOpacity(0.35),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: !_isAiExpanded
                  ? const SizedBox(
                width: double.infinity,
              )
                  : Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    DatosActivosWidget(data),

                    if (observation.isNotEmpty) ...[
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E44C2)
                              .withOpacity(0.07),
                          borderRadius:
                          BorderRadius.circular(14),
                          border: Border.all(
                            color:
                            const Color(0xFF8E44C2)
                                .withOpacity(0.14),
                          ),
                        ),
                        child: SelectableText(
                          observation,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.55,
                            color:
                            Global.text.withOpacity(0.78),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed:
              canAnalyze && !analyzingWithAI
                  ? _analyzeAsset
                  : null,
              icon: analyzingWithAI
                  ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.auto_awesome_rounded,
              ),
              label: Text(
                analyzingWithAI
                    ? 'Analizando activo...'
                    : hasAnalysis
                    ? 'Actualizar análisis'
                    : 'Analizar con IA',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF8E44C2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSummary({required String observation,}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8E44C2).withOpacity(0.12),
            const Color(0xFF8E44C2).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF8E44C2)
              .withOpacity(0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF8E44C2)
                  .withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF8E44C2),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análisis disponible',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  observation.isNotEmpty
                      ? observation
                      : 'La IA identificó información técnica del activo.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.45,
                    color: Global.text.withOpacity(0.62),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiEmptyState(bool canAnalyze) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: Global.bg.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 34,
            color: Global.text.withOpacity(0.30),
          ),
          const SizedBox(height: 8),
          Text(
            'No hay análisis generado',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Global.text.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            canAnalyze
                ? 'La evidencia está lista para analizar.'
                : 'Guarde el activo y adjunte al menos una imagen.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Global.text.withOpacity(0.48),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeAsset() async {
    final idAsset =
    clientController.Activo["id_activo"];

    final images =
        clientController.Activo["imagenes"] ?? [];

    if (idAsset == null || images.isEmpty) {
      Get.snackbar(
        'Información incompleta',
        'Guarde el activo y adjunte una imagen.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      analyzingWithAI = true;
    });

    try {
      await analizarActivoApi(
        idActivo: idAsset,
      );

      final asset = await getActivoApi(
        idActivo: idAsset,
      );

      clientController.setActivo(asset);

      _synchronizeAssetForm();

      Get.snackbar(
        'Análisis completado',
        'El activo fue analizado correctamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Error en el análisis',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          analyzingWithAI = false;
        });
      }
    }
  }

  void _synchronizeAssetForm() {
    final asset = clientController.Activo;

    nombreCtrl.text =
        asset["nombre"]?.toString() ?? '';

    tipoSeleccionado =
        asset["tipo"]?.toString();

    descripcionCtrl.text =
        asset["descripcion"]?.toString() ?? '';

    marcaCtrl.text =
        asset["marca"]?.toString() ?? '';

    modeloCtrl.text =
        asset["modelo"]?.toString() ?? '';

    cantidadCtrl.text =
        asset["cantidad"]?.toString() ?? '1';

    controller.hasUnsavedChanges.value = false;

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildImageUploader() {
    return PremiumSectionCard(
      title: 'Adjuntar evidencia',
      subtitle: 'Fotografía del activo',
      icon: Icons.add_photo_alternate_outlined,
      color: const Color(0xFF2196F3),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: Global.bg.withOpacity(0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedImage != null
                    ? Global.primary.withOpacity(0.35)
                    : Global.text.withOpacity(0.10),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImagePreview(),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                  uploadingImage ? null : pickImage,
                  icon: const Icon(
                    Icons.image_outlined,
                  ),
                  label: const Text('Galería'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                  uploadingImage ? null : takePhoto,
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                  ),
                  label: const Text('Cámara'),
                ),
              ),
            ],
          ),

          if (selectedImage != null) ...[
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: uploadingImage
                          ? null
                          : _uploadImage,
                      icon: uploadingImage
                          ? const SizedBox(
                        width: 17,
                        height: 17,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.cloud_upload_rounded,
                      ),
                      label: Text(
                        uploadingImage
                            ? 'Subiendo...'
                            : 'Subir imagen',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Global.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: uploadingImage
                      ? null
                      : () {
                    setState(() {
                      selectedImage = null;
                    });
                  },
                  tooltip: 'Quitar imagen',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (selectedImage == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 42,
            color: Global.text.withOpacity(0.30),
          ),
          const SizedBox(height: 8),
          Text(
            'Ninguna imagen seleccionada',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Global.text.withOpacity(0.55),
            ),
          ),
        ],
      );
    }

    return FutureBuilder<Uint8List>(
      future: selectedImage!.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Icon(Icons.image_not_supported_outlined),
          );
        }

        return InkWell(
          onTap: () {
            viewOneImageAsesorCliente(selectedImage!);
          },
          child: Image.memory(
            snapshot.data!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  Widget _buildExistingImages() {
    final images = List<Map<String, dynamic>>.from(
      clientController.Activo["imagenes"] ?? [],
    );

    return PremiumSectionCard(
      title: 'Imágenes del activo',
      subtitle:
      '${images.length} imágenes registradas',
      icon: Icons.photo_library_outlined,
      color: const Color(0xFFF5A000),
      child: images.isEmpty
          ? Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 28,
        ),
        child: Column(
          children: [
            Icon(
              Icons.hide_image_outlined,
              size: 34,
              color: Global.text.withOpacity(0.30),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay imágenes registradas',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Global.text.withOpacity(0.55),
              ),
            ),
          ],
        ),
      )
          : SizedBox(
        height: 112,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: images.length,
          separatorBuilder: (_, __) {
            return const SizedBox(width: 8);
          },
          itemBuilder: (context, index) {
            final image = images[index];

            return InkWell(
              onTap: () async {
                await _openGalleryAndRefresh(
                  images,
                  index,
                );
              },
              borderRadius: BorderRadius.circular(11),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.network(
                  Utils.buildUrl(image),
                  width: 112,
                  height: 112,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, error, stackTrace) {
                    return Container(
                      width: 112,
                      height: 112,
                      color: Global.bg,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color:
                        Global.text.withOpacity(0.35),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Eliminar activo',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                Text(
                  'Esta acción requiere confirmación.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Global.text.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: confirmDeleteActivo,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(
                color: Colors.red.withOpacity(0.45),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openGalleryAndRefresh(List<Map<String, dynamic>> images, int index,) async {
    final dynamic idActivo =
    clientController.Activo["id_activo"];

    if (idActivo == null) {
      return;
    }

    final bool changed = await openGaleriaActivo(
      images,
      index,
    );

    if (!changed || !mounted) {
      return;
    }

    try {
      final updatedAsset = await getActivoApi(
        idActivo: idActivo,
      );

      clientController.setActivo(updatedAsset);

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      Get.snackbar(
        'No fue posible actualizar',
        'La imagen fue eliminada, pero no se pudo recargar la información del activo.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class PremiumEditorHeader extends StatelessWidget {
  final String title;
  final bool hasUnsavedChanges;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback? onSave;

  const PremiumEditorHeader({
    super.key,
    required this.title,
    required this.hasUnsavedChanges,
    required this.loading,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Global.container,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  controller.isDark.value ? 0.20 : 0.06,
                ),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  onPressed: loading ? null : onBack,
                  tooltip: 'Volver',
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                  ),
                  color: Global.text,
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: isCompact ? 17 : 21,
                          fontWeight: FontWeight.w600,
                          color: Global.text,
                        ),
                      ),

                      if (hasUnsavedChanges)
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5A000),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Cambios sin guardar',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFFF5A000),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                FilledButton.icon(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: Global.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(
                      isCompact ? 46 : 130,
                      46,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 12 : 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: loading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.save_outlined,
                    size: 20,
                  ),
                  label: isCompact
                      ? const SizedBox.shrink()
                      : Text(
                    loading ? 'Guardando...' : 'Guardar cambios',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PremiumSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Widget child;

  const PremiumSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = controller.isDark.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? 0.16 : 0.05,
            ),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Global.text,
                      ),
                    ),

                    if (subtitle != null &&
                        subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: Global.text.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Divider(
            height: 1,
            color: Global.text.withOpacity(0.08),
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}