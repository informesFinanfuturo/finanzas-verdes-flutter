import 'package:file_picker/file_picker.dart';
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
import 'package:url_launcher/url_launcher.dart';

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
  PlatformFile? selectedDocument;

  final Set<int> deletingDocumentIds = <int>{};

  bool analyzingWithAI = false;

  DateTime? fechaInicio;
  DateTime? fechaFin;


  String? tipoSeleccionado;

  List<String> tipos = ["Agua", "Energía", "Gas"];

  bool loading = false;

  final clientController = Get.find<ClientController>();

  XFile? selectedImage;
  bool uploadingImage = false;
  bool isDocumentSelected = false;

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

    for (final fieldController
    in consumosAnterioresCtrls) {
      fieldController.dispose();
    }

    super.dispose();
  }

  void _markAsChanged() {
    if (!controller.hasUnsavedChanges.value) {
      setState(() {
        controller.hasUnsavedChanges.value = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final invoice = clientController.Consumo;
    final consumption = invoice["consumo"];

    tipoSeleccionado =
        invoice["tipo"]?.toString() ?? 'Agua';

    proveedorCtrl.text =
        invoice["proveedor"]?.toString() ?? '';

    valorCtrl.text = Utils.formatMiles(
      invoice["valor"] ?? 0,
    );

    unidadCtrl.text =
        invoice["unidad"]?.toString() ?? '';

    observacionesCtrl.text =
        invoice["observaciones"]?.toString() ?? '';

    if (consumption is Map) {
      consumoActualCtrl.text =
          consumption["actual"]?.toString() ?? '';

      consumoPromedioCtrl.text =
          consumption["promedio"]?.toString() ?? '';

      if (consumption["anteriores"] is List) {
        consumosAnterioresCtrls =
            (consumption["anteriores"] as List)
                .map((value) {
              final fieldController =
              TextEditingController(
                text: value.toString(),
              );

              fieldController.addListener(
                _markAsChanged,
              );

              return fieldController;
            }).toList();
      }
    }

    final start = invoice["periodo_inicio"];
    final end = invoice["periodo_fin"];

    if (start != null &&
        start.toString().isNotEmpty) {
      fechaInicio =
          DateTime.tryParse(start.toString());

      periodoInicioCtrl.text =
          Utils.formatFechaBonita(
            start.toString(),
          );
    }

    if (end != null &&
        end.toString().isNotEmpty) {
      fechaFin = DateTime.tryParse(
        end.toString(),
      );

      periodoFinCtrl.text =
          Utils.formatFechaBonita(
            end.toString(),
          );
    }

    tipoCtrl.addListener(_markAsChanged);
    proveedorCtrl.addListener(_markAsChanged);
    valorCtrl.addListener(_markAsChanged);
    consumoActualCtrl.addListener(_markAsChanged);
    consumoPromedioCtrl.addListener(_markAsChanged);
    unidadCtrl.addListener(_markAsChanged);
    periodoInicioCtrl.addListener(_markAsChanged);
    periodoFinCtrl.addListener(_markAsChanged);
    observacionesCtrl.addListener(_markAsChanged);
  }

  @override
  Widget build(BuildContext context) {
    final bool isNewInvoice =
        clientController.Consumo["id_consumo"] == null;

    return Obx(() {
      final _ = controller.isDark.value;
      return LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop =
              constraints.maxWidth >= 1000;

          return Column(
            children: [
              _PremiumHeader(
                title: isNewInvoice
                    ? 'Nueva factura'
                    : 'Editar factura',
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
                      child: isDesktop
                          ? Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                            child: _buildSidePanel(),
                          ),
                        ],
                      )
                          : Column(
                        children: [
                          _buildMainForm(
                            isDesktop: false,
                          ),
                          const SizedBox(height: 16),
                          _buildSidePanel(),
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

    if(clientController.Consumo["id_consumo"] == null){
      final idConsumo = await createConsumoApi(tipo: tipoSeleccionado!, idMipyme: clientController.Client["mipyme"]["id_mipyme"], createdBy: controller.User["id_usuario"]);
      final consumo = await getConsumoApi(idConsumo: idConsumo);
      clientController.setConsumo(consumo);
      clientController.refreshClient();
    }

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

      clientController.refreshClient();
      controller.hasUnsavedChanges.value = false;
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
        controller.hasUnsavedChanges.value = true;
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

  Future<void> pickDocument() async {
    final List<PlatformFile>? result =
    await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'csv',
      ],
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        selectedDocument = result.first;
        selectedImage = null;
        isDocumentSelected = true;
        controller.hasUnsavedChanges.value = true;
      });
    }
  }

  Future<void> _uploadDocument() async {

    if (selectedDocument == null) {

      Get.snackbar(
        "Error",
        "Selecciona un documento primero",
      );

      return;
    }

    setState(() {
      uploadingImage = true;
    });

    try {

      final consumo =
          clientController.Consumo;

      await uploadDocumentoConsumoApi(
        idConsumo:
        consumo["id_consumo"],
        createdBy:
        controller.User["id_usuario"],
        documento:
        selectedDocument!,
      );

      clientController.setConsumo(
        await getConsumoApi(
          idConsumo:
          consumo["id_consumo"],
        ),
      );

      setState(() {

        selectedDocument = null;
        isDocumentSelected = false;

      });

      Get.snackbar(
        "Éxito",
        "Documento subido correctamente",
      );

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      setState(() {
        uploadingImage = false;
      });

    }
  }

  Widget _documentIcon(String? ext) {

    ext =
        (ext ?? "")
            .toLowerCase();

    switch (ext) {

      case "pdf":
        return Icon(
          Icons.picture_as_pdf,
          color: Colors.red,
        );

      case "xls":
      case "xlsx":
        return Icon(
          Icons.table_chart,
          color: Colors.green,
        );

      case "doc":
      case "docx":
        return Icon(
          Icons.description,
          color: Colors.blue,
        );

      default:
        return Icon(
          Icons.insert_drive_file,
        );

    }
  }

  Future<void> openDocumento(
      Map<String, dynamic> doc,
      ) async {
    final String url = Utils.buildUrl(doc);
    final Uri? uri = Uri.tryParse(url);

    if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw Exception('La URL del documento no es válida: $url');
    }

    final bool abierto = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );

    if (!abierto) {
      throw Exception('No fue posible abrir el documento: $url');
    }
  }

  Future<void> abrirEnlace(String url) async {
    final uri = Uri.parse(url);

    final abierto = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!abierto) {
      throw Exception('No fue posible abrir el enlace: $url');
    }
  }

  Widget _buildMainForm({required bool isDesktop,}) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _SectionCard(
            title: 'Datos de la factura',
            subtitle:
            'Información principal del documento',
            icon: Icons.receipt_long_rounded,
            color: Global.primary,
            child: _buildInvoiceFields(isDesktop),
          ),

          const SizedBox(height: 16),

          _SectionCard(
            title: 'Información de consumo',
            subtitle:
            'Lecturas actuales, promedio e histórico',
            icon: Icons.analytics_outlined,
            color: const Color(0xFF2196F3),
            child: _buildConsumptionFields(
              isDesktop,
            ),
          ),

          const SizedBox(height: 16),

          _SectionCard(
            title: 'Periodo y observaciones',
            subtitle:
            'Vigencia e información complementaria',
            icon: Icons.calendar_month_rounded,
            color: const Color(0xFFF5A000),
            child: _buildPeriodFields(isDesktop),
          ),

          if (clientController.Consumo["id_consumo"] !=
              null) ...[
            const SizedBox(height: 24),
            _buildDangerZone(),
          ],
        ],
      ),
    );
  }

  Widget _responsiveFields({required bool isDesktop, required List<Widget> children,}) {
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

  Widget _buildConsumptionFields(bool isDesktop) {
    return Column(
      children: [
        _responsiveFields(
          isDesktop: isDesktop,
          children: [
            _inputNumber(
              consumoActualCtrl,
              'Consumo actual',
              Icons.bolt_rounded,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _inputNumber(
              consumoPromedioCtrl,
              'Consumo promedio',
              Icons.analytics_outlined,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        _buildPreviousConsumptions(),
      ],
    );
  }

  Widget _buildPeriodFields(bool isDesktop) {
    return Column(
      children: [
        _responsiveFields(
          isDesktop: isDesktop,
          children: [
            _dateField(
              periodoInicioCtrl,
              'Fecha de inicio',
            ),
            _dateField(
              periodoFinCtrl,
              'Fecha de finalización',
            ),
          ],
        ),

        const SizedBox(height: 14),

        _inputArea(
          observacionesCtrl,
          'Incluya frecuencia de uso, daños, reparaciones o información relevante.',
          Icons.description_outlined,
          'Observaciones',
        ),
      ],
    );
  }

  Widget _buildPreviousConsumptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Consumos anteriores',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Global.text,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                final newController =
                TextEditingController();

                newController.addListener(
                  _markAsChanged,
                );

                setState(() {
                  consumosAnterioresCtrls.add(
                    newController,
                  );
                });

                _markAsChanged();
              },
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
              ),
              label: const Text('Agregar'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        if (consumosAnterioresCtrls.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Global.bg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Global.text.withOpacity(0.07),
              ),
            ),
            child: Text(
              'No hay consumos anteriores registrados.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Global.text.withOpacity(0.55),
              ),
            ),
          )
        else
          ...List.generate(
            consumosAnterioresCtrls.length,
                (index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller:
                        consumosAnterioresCtrls[index],
                        keyboardType:
                        const TextInputType
                            .numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[\.,]?\d*'),
                          ),
                        ],
                        decoration:
                        Wapp.TextFieldDecoration(
                          Global.primary,
                          true,
                          'Consumo ${index + 1}',
                          Icons.history_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () {
                        final removed =
                        consumosAnterioresCtrls
                            .removeAt(index);

                        removed.dispose();
                        _markAsChanged();

                        setState(() {});
                      },
                      tooltip: 'Eliminar consumo',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSidePanel() {
    return Column(
      children: [
        _buildAiCard(),
        const SizedBox(height: 16),
        _buildEvidenceUploader(),
        const SizedBox(height: 16),
        _buildExistingFiles(),
      ],
    );
  }

  Widget _buildAiCard() {
    final archivos =
        clientController.Consumo["imagenes"] ?? [];

    final String aiObservation =
    (clientController.Consumo["observacion_ia"] ?? '')
        .toString()
        .trim();

    final bool canAnalyze =
        clientController.Consumo["id_consumo"] != null &&
            archivos.isNotEmpty;

    return _SectionCard(
      title: 'Análisis con IA',
      subtitle:
      'Identificación automática de datos y hallazgos',
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFF8E44C2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (aiObservation.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 26,
              ),
              decoration: BoxDecoration(
                color: Global.bg.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Global.text.withOpacity(0.07),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 34,
                    color: Global.text.withOpacity(0.35),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No hay observaciones generadas',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Global.text.withOpacity(0.65),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    canAnalyze
                        ? 'Puedes analizar la factura utilizando la evidencia adjunta.'
                        : 'Primero guarda la factura y adjunta una evidencia.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Global.text.withOpacity(0.48),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF8E44C2)
                    .withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8E44C2)
                      .withOpacity(0.15),
                ),
              ),
              child: Text(
                aiObservation,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.5,
                  color: Global.text.withOpacity(0.78),
                ),
              ),
            ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: canAnalyze && !analyzingWithAI
                  ? _analyzeConsumption
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
                size: 19,
              ),
              label: Text(
                analyzingWithAI
                    ? 'Analizando...'
                    : 'Analizar factura con IA',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF8E44C2),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                Global.text.withOpacity(0.10),
                disabledForegroundColor:
                Global.text.withOpacity(0.35),
                elevation: 0,
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

  Future<void> _analyzeConsumption() async {
    final idConsumo =
    clientController.Consumo["id_consumo"];

    final archivos =
        clientController.Consumo["imagenes"] ?? [];

    if (idConsumo == null) {
      Get.snackbar(
        'Factura sin guardar',
        'Guarde la factura antes de analizarla.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (archivos.isEmpty) {
      Get.snackbar(
        'Sin evidencia',
        'Adjunte una imagen o documento para analizar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      analyzingWithAI = true;
    });

    try {
      await analizarConsumoApi(
        idConsumo: idConsumo,
      );

      await clientController.refreshConsumo();
      await clientController.refreshClient();

      _synchronizeForm();

      controller.hasUnsavedChanges.value = false;

      Get.snackbar(
        'Análisis completado',
        'La factura fue analizada correctamente.',
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

  void _synchronizeForm() {
    final invoice = clientController.Consumo;
    final consumption = invoice["consumo"];

    proveedorCtrl.text =
        invoice["proveedor"]?.toString() ?? '';

    valorCtrl.text = Utils.formatMiles(
      invoice["valor"] ?? 0,
    );

    unidadCtrl.text =
        invoice["unidad"]?.toString() ?? '';

    observacionesCtrl.text =
        invoice["observaciones"]?.toString() ?? '';

    tipoSeleccionado =
        invoice["tipo"]?.toString() ?? 'Agua';

    if (consumption is Map) {
      consumoActualCtrl.text =
          consumption["actual"]?.toString() ?? '';

      consumoPromedioCtrl.text =
          consumption["promedio"]?.toString() ?? '';

      for (final fieldController
      in consumosAnterioresCtrls) {
        fieldController.dispose();
      }

      consumosAnterioresCtrls = [];

      if (consumption["anteriores"] is List) {
        consumosAnterioresCtrls =
            (consumption["anteriores"] as List)
                .map((value) {
              final fieldController =
              TextEditingController(
                text: value.toString(),
              );

              fieldController.addListener(
                _markAsChanged,
              );

              return fieldController;
            }).toList();
      }
    }

    final start = invoice["periodo_inicio"];
    final end = invoice["periodo_fin"];

    fechaInicio = start == null
        ? null
        : DateTime.tryParse(start.toString());

    fechaFin = end == null
        ? null
        : DateTime.tryParse(end.toString());

    periodoInicioCtrl.text = start == null
        ? ''
        : Utils.formatFechaBonita(
      start.toString(),
    );

    periodoFinCtrl.text = end == null
        ? ''
        : Utils.formatFechaBonita(
      end.toString(),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openConsumptionGallery(List<Map<String, dynamic>> images, int index,) async {
    final bool changed = await openGaleriaConsumo(
      images,
      index,
    );

    if (!changed || !mounted) {
      return;
    }

    setState(() {});
  }

  Widget _buildEvidenceUploader() {
    final bool hasSelection =
        selectedImage != null ||
            selectedDocument != null;

    return _SectionCard(
      title: 'Adjuntar evidencia',
      subtitle:
      'Imágenes o documentos de la factura',
      icon: Icons.cloud_upload_outlined,
      color: const Color(0xFF2196F3),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 150,
              maxHeight: 260,
            ),
            decoration: BoxDecoration(
              color: Global.bg.withOpacity(0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasSelection
                    ? Global.primary.withOpacity(0.35)
                    : Global.text.withOpacity(0.10),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildSelectedFilePreview(),
          ),

          const SizedBox(height: 14),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _evidenceSourceButton(
                label: 'Galería',
                icon: Icons.image_outlined,
                onPressed:
                uploadingImage ? null : pickImage,
              ),
              _evidenceSourceButton(
                label: 'Cámara',
                icon: Icons.camera_alt_outlined,
                onPressed:
                uploadingImage ? null : takePhoto,
              ),
              _evidenceSourceButton(
                label: 'Documento',
                icon: Icons.description_outlined,
                onPressed:
                uploadingImage ? null : pickDocument,
              ),
            ],
          ),

          if (hasSelection) ...[
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: uploadingImage
                          ? null
                          : _uploadSelectedEvidence,
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
                            : 'Subir evidencia',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Global.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton.outlined(
                  onPressed: uploadingImage
                      ? null
                      : _clearSelection,
                  tooltip: 'Quitar selección',
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

  Widget _buildSelectedFilePreview() {
    if (selectedImage == null &&
        selectedDocument == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 42,
            color: Global.text.withOpacity(0.30),
          ),
          const SizedBox(height: 10),
          Text(
            'Ningún archivo seleccionado',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Global.text.withOpacity(0.60),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Seleccione una imagen o documento',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Global.text.withOpacity(0.42),
            ),
          ),
        ],
      );
    }

    if (selectedDocument != null) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _documentIcon(
              selectedDocument!.extension,
            ),
            const SizedBox(height: 10),
            Text(
              selectedDocument!.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Global.text,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Documento seleccionado',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Global.text.withOpacity(0.50),
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: selectedImage!.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
            ),
          );
        }

        return InkWell(
          onTap: () {
            viewOneImageAsesorCliente(
              selectedImage!,
            );
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

  Future<void> _uploadSelectedEvidence() async {
    if (selectedImage == null &&
        selectedDocument == null) {
      return;
    }

    try {
      if (clientController.Consumo["id_consumo"] ==
          null) {
        final idConsumo = await createConsumoApi(
          tipo: tipoSeleccionado ?? 'Agua',
          idMipyme: clientController
              .Client["mipyme"]["id_mipyme"],
          createdBy:
          controller.User["id_usuario"],
        );

        final invoice = await getConsumoApi(
          idConsumo: idConsumo,
        );

        clientController.setConsumo(invoice);

        await clientController.refreshClient();
      }

      if (selectedImage != null) {
        await _uploadImage();
      } else if (selectedDocument != null) {
        await _uploadDocument();
      }

      controller.hasUnsavedChanges.value = false;
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _clearSelection() {
    setState(() {
      selectedImage = null;
      selectedDocument = null;
      isDocumentSelected = false;
    });
  }

  Widget _buildExistingFiles() {
    final files = List<Map<String, dynamic>>.from(
      clientController.Consumo["imagenes"] ?? [],
    );

    final images = files.where((file) {
      final extension = (file["extension"] ?? "")
          .toString()
          .toLowerCase();

      return [
        "jpg",
        "jpeg",
        "png",
        "gif",
        "webp",
      ].contains(extension);
    }).toList();

    final documents = files.where((file) {
      final extension = (file["extension"] ?? "")
          .toString()
          .toLowerCase();

      return [
        "pdf",
        "doc",
        "docx",
        "xls",
        "xlsx",
        "csv",
      ].contains(extension);
    }).toList();

    return _SectionCard(
      title: 'Archivos adjuntos',
      subtitle: '${files.length} archivos registrados',
      icon: Icons.folder_copy_outlined,
      color: const Color(0xFFF5A000),
      child: files.isEmpty
          ? Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 28,
        ),
        child: Column(
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 34,
              color: Global.text.withOpacity(0.30),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay archivos adjuntos',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Global.text.withOpacity(0.55),
              ),
            ),
          ],
        ),
      )
          : Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          if (images.isNotEmpty) ...[
            Text(
              'Imágenes',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Global.text,
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics:
                const BouncingScrollPhysics(),
                itemCount: images.length,
                separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final image = images[index];

                  return InkWell(
                    onTap: () async {
                      await _openConsumptionGallery(
                        images,
                        index,
                      );
                    },
                    borderRadius:
                    BorderRadius.circular(11),
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(11),
                      child: Image.network(
                        Utils.buildUrl(image),
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, error, stackTrace) {
                          return Container(
                            width: 104,
                            height: 104,
                            color: Global.bg,
                            child: Icon(
                              Icons
                                  .image_not_supported_outlined,
                              color: Global.text
                                  .withOpacity(0.35),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          if (images.isNotEmpty &&
              documents.isNotEmpty)
            const SizedBox(height: 18),

          if (documents.isNotEmpty) ...[
            Text(
              'Documentos',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Global.text,
              ),
            ),
            const SizedBox(height: 8),

            ...documents.map((document) {
              final String extension =
              (document["extension"] ?? "")
                  .toString()
                  .toUpperCase();

              final String documentName =
                  document["nombre_original"]
                      ?.toString() ??
                      'Documento';

              final int? idArchivo = int.tryParse(
                document["id_archivo"]
                    ?.toString() ??
                    '',
              );

              final bool deleting =
                  idArchivo != null &&
                      deletingDocumentIds.contains(
                        idArchivo,
                      );

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Global.bg.withOpacity(0.55),
                    borderRadius:
                    BorderRadius.circular(12),
                    border: Border.all(
                      color: deleting
                          ? Colors.red.withOpacity(0.30)
                          : Global.text.withOpacity(0.07),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Zona que abre el documento.
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: deleting
                                ? null
                                : () async {
                              try {
                                await openDocumento(
                                  document,
                                );
                              } catch (error) {
                                Get.snackbar(
                                  'No fue posible abrirlo',
                                  error.toString(),
                                  snackPosition:
                                  SnackPosition.BOTTOM,
                                );
                              }
                            },
                            borderRadius:
                            const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                            child: Padding(
                              padding:
                              const EdgeInsets.all(11),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    alignment:
                                    Alignment.center,
                                    decoration:
                                    BoxDecoration(
                                      color: Global.container,
                                      borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                    child: _documentIcon(
                                      document["extension"],
                                    ),
                                  ),

                                  const SizedBox(width: 11),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          documentName,
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow
                                              .ellipsis,
                                          style:
                                          GoogleFonts.poppins(
                                            fontSize: 12.5,
                                            fontWeight:
                                            FontWeight.w500,
                                            color: Global.text,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 2,
                                        ),

                                        Text(
                                          extension.isEmpty
                                              ? 'Documento'
                                              : extension,
                                          style:
                                          GoogleFonts.poppins(
                                            fontSize: 10.5,
                                            color: Global
                                                .textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Icon(
                                    Icons.open_in_new_rounded,
                                    size: 18,
                                    color: Global.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 42,
                        color:
                        Global.text.withOpacity(0.08),
                      ),

                      // Acción independiente para eliminar.
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                        child: IconButton(
                          onPressed:
                          deleting || idArchivo == null
                              ? null
                              : () {
                            _confirmDeleteDocument(
                              document,
                            );
                          },
                          tooltip: deleting
                              ? 'Eliminando...'
                              : 'Eliminar documento',
                          icon: deleting
                              ? const SizedBox(
                            width: 19,
                            height: 19,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                              : const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
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
                  'Eliminar factura',
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
            onPressed: confirmDeleteConsumo,
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

  Widget _buildInvoiceFields(bool isDesktop) {
    return Column(
      children: [
        _responsiveFields(
          isDesktop: isDesktop,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo de consumo',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Global.text,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  items: tipos.map((tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
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
                    'Tipo de consumo',
                    Icons.category_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Seleccione un tipo de consumo';
                    }

                    return null;
                  },
                ),
              ],
            ),

            _input(
              proveedorCtrl,
              'Proveedor',
              Icons.business_outlined,
            ),
          ],
        ),

        const SizedBox(height: 14),

        _responsiveFields(
          isDesktop: isDesktop,
          children: [
            _inputMoney(
              valorCtrl,
              'Valor factura',
              Icons.attach_money_rounded,
              'Valor de la factura',
            ),

            _input(
              unidadCtrl,
              'Unidad (kWh, m³)',
              Icons.straighten_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _evidenceSourceButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Global.primary,
        disabledForegroundColor:
        Global.text.withOpacity(0.30),
        side: BorderSide(
          color: onPressed == null
              ? Global.text.withOpacity(0.10)
              : Global.primary.withOpacity(0.35),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteDocument(Map<String, dynamic> document,) async {
    final int? idArchivo = int.tryParse(
      document["id_archivo"]?.toString() ?? '',
    );

    if (idArchivo == null) {
      Get.snackbar(
        'Información incompleta',
        'El documento no contiene un id_archivo válido.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final String documentName =
        document["nombre_original"]?.toString() ??
            'Documento';

    final bool confirmed =
        await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Eliminar documento',
                  ),
                ),
              ],
            ),
            content: Text(
              '¿Deseas eliminar “$documentName”?\n\n'
                  'Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(result: false);
                },
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Get.back(result: true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
                label: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
            false;

    if (!confirmed || !mounted) {
      return;
    }

    final dynamic idConsumo =
    clientController.Consumo["id_consumo"];

    if (idConsumo == null) {
      Get.snackbar(
        'Información incompleta',
        'No se encontró el consumo relacionado.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      deletingDocumentIds.add(idArchivo);
    });

    try {
      await deleteImagenConsumoApi(
        idArchivo: idArchivo,
      );

      final updatedConsumption =
      await getConsumoApi(
        idConsumo: idConsumo,
      );

      clientController.setConsumo(
        updatedConsumption,
      );

      if (!mounted) {
        return;
      }

      setState(() {});

      Get.snackbar(
        'Documento eliminado',
        'El documento fue eliminado correctamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      Get.snackbar(
        'No fue posible eliminar',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      if (mounted) {
        setState(() {
          deletingDocumentIds.remove(idArchivo);
        });
      }
    }
  }
}

class _PremiumHeader extends StatelessWidget {
  final String title;
  final bool hasUnsavedChanges;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback? onSave;

  const _PremiumHeader({
    required this.title,
    required this.hasUnsavedChanges,
    required this.loading,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        MediaQuery.sizeOf(context).width >= 800;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      color: Global.bg,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Volver',
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 20 : 17,
                    fontWeight: FontWeight.w600,
                    color: Global.text,
                  ),
                ),
                if (hasUnsavedChanges)
                  Text(
                    'Cambios sin guardar',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: loading
                  ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.save_outlined,
                size: 19,
              ),
              label: isDesktop
                  ? Text(
                loading
                    ? 'Guardando...'
                    : 'Guardar',
              )
                  : const SizedBox.shrink(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Global.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Global.text.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius:
                  BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Global.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Global.text
                            .withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

