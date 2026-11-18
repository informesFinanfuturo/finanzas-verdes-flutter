import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/activoApi.dart';
import 'package:finanzas_verdes/models/api/fveInventarioApi.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/fichaTecnicaVerdeActivo.dart';
import 'package:finanzas_verdes/views/asesor/client/activo/perfilUsoActivo.dart';
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
import 'package:flutter/scheduler.dart';
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
  Map<String, dynamic>? _datosTecnicosFve;
  Map<String, dynamic>? _perfilUso;

  XFile? selectedImage;
  bool uploadingImage = false;

  final clientController = Get.find<ClientController>();

  bool analyzingWithAI = false;
  bool _buscandoReferencias = false;
  Map<String, dynamic>? _estadoReferencias;
  Map<String, dynamic>? _ultimoReporteBusquedaFve; // FVE_REPORTE_VISIBLE_CRAWLER_V1
  bool _ultimoReporteGuardadoFve = false;
  int _revisionFveIA = 0;
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
    final datosActivo = activo['datos'];
    final perfilGuardado = datosActivo is Map ? datosActivo['fve_perfil_uso'] : null;
    _perfilUso = perfilGuardado is Map
        ? Map<String, dynamic>.from(perfilGuardado) : null;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarEstadoReferencias());
  }

  // No notificar al padre mientras Flutter construye _FormScope.
  // El indicador global es observable; no requiere setState local.
  bool _markChangeAfterFrame = false;

  void _markAsChanged() {
    if (!mounted || loading || uploadingImage ||
        controller.hasUnsavedChanges.value) return;

    // Un TextFormField o la ficha FVE pueden avisar durante build.
    // Posponer el cambio evita setState/markNeedsBuild durante el render.
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      if (_markChangeAfterFrame) return;
      _markChangeAfterFrame = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _markChangeAfterFrame = false;
        if (!mounted || loading || uploadingImage ||
            controller.hasUnsavedChanges.value) return;
        controller.hasUnsavedChanges.value = true;
      });
      return;
    }

    controller.hasUnsavedChanges.value = true;
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
                onSave: (loading || uploadingImage) ? null : _submit,
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
          validator: required
              ? (value) => value == null || value.trim().isEmpty
                  ? 'Campo obligatorio'
                  : null
              : null,
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

  // Alta y edicion comparten esta misma pantalla. No se crea un activo
  // hasta pulsar Guardar o Subir imagen.
  Future<int> _asegurarActivoCreado() async {
    final existente = int.tryParse(
      '${clientController.Activo['id_activo'] ?? ''}',
    );
    if (existente != null && existente > 0) return existente;

    final nombre = nombreCtrl.text.trim();
    final tipo = tipoSeleccionado?.trim();
    if (nombre.isEmpty || tipo == null || tipo.isEmpty) {
      throw StateError('Indica el nombre y el tipo de activo antes de continuar.');
    }

    final nuevo = await createActivoApi(
      nombre: nombre,
      tipo: tipo,
      idMipyme: clientController.Client['mipyme']['id_mipyme'],
      marca: marcaCtrl.text.trim(),
      modelo: modeloCtrl.text.trim().isEmpty ? null : modeloCtrl.text.trim(),
      descripcion: descripcionCtrl.text.trim().isEmpty
          ? null
          : descripcionCtrl.text.trim(),
      perfilUso: _perfilUso,
    );

    final idNuevo = int.tryParse('${nuevo['id_activo'] ?? ''}');
    if (idNuevo == null || idNuevo <= 0) {
      throw StateError('La API no devolvio el ID del activo creado.');
    }

    // Registrar de inmediato el ID para evitar duplicados ante un error
    // posterior de actualizacion, ficha tecnica o carga de fotografia.
    clientController.setActivo(Map<String, dynamic>.from(nuevo));
    return idNuevo;
  }

  Future<void> _guardarDatosDelActivo(
    int idActivo,
    Map<String, dynamic>? datosTecnicosPendientes,
  ) async {
    await updateActivoApi(
      idActivo: idActivo,
      updatedBy: controller.User['id_usuario'],
      nombre: nombreCtrl.text.trim(),
      tipo: tipoSeleccionado,
      descripcion: descripcionCtrl.text.trim().isEmpty
          ? null
          : descripcionCtrl.text.trim(),
      marca: marcaCtrl.text.trim(),
      modelo: modeloCtrl.text.trim(),
      cantidad: int.parse(cantidadCtrl.text.trim()),
      perfilUso: _perfilUso,
    );

    if (datosTecnicosPendientes != null) {
      await guardarInventarioFveApi(
        idActivo: idActivo,
        datosTecnicos: datosTecnicosPendientes,
      );
    }
  }

  Future<void> _submit() async {
    if (loading || uploadingImage) return;
    if (!_formKey.currentState!.validate()) return;

    // El cambio de idActivo al crear provoca una recarga de la ficha FVE.
    // Conservar antes los datos escritos para no perderlos durante esa recarga.
    final datosPendientes = _datosTecnicosFve == null
        ? null
        : Map<String, dynamic>.from(_datosTecnicosFve!);

    setState(() => loading = true);
    try {
      final idActivo = await _asegurarActivoCreado();
      await _guardarDatosDelActivo(idActivo, datosPendientes);

      clientController.setActivo(await getActivoApi(idActivo: idActivo));
      await clientController.refreshClient();
      controller.hasUnsavedChanges.value = false;

      if (mounted) controller.backPage();
    } catch (e) {
      Get.snackbar(
        'No fue posible guardar el activo',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => loading = false);
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
    if (selectedImage == null || uploadingImage || loading) {
      if (selectedImage == null) {
        Get.snackbar('Falta una fotografia', 'Selecciona una imagen primero.');
      }
      return;
    }

    // En un activo nuevo, la imagen necesita un registro al cual vincularse.
    // Validamos los dos campos obligatorios sin abrir un formulario previo.
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Datos obligatorios',
        'Completa nombre, tipo y cantidad antes de subir la fotografia.',
      );
      return;
    }

    final datosPendientes = _datosTecnicosFve == null
        ? null
        : Map<String, dynamic>.from(_datosTecnicosFve!);

    setState(() => uploadingImage = true);
    String etapa = 'crear el activo';
    try {
      final idActivo = await _asegurarActivoCreado();
      etapa = 'guardar los datos del activo';
      // Guarda los datos escritos en esta unica pantalla antes de adjuntar.
      await _guardarDatosDelActivo(idActivo, datosPendientes);
      etapa = 'subir la fotografia';
      await uploadImagenActivoApi(
        idActivo: idActivo,
        createdBy: controller.User['id_usuario'],
        image: selectedImage!,
      );

      etapa = 'actualizar la galeria';
      clientController.setActivo(await getActivoApi(idActivo: idActivo));
      await clientController.refreshClient();
      if (!mounted) return;
      setState(() => selectedImage = null);
      controller.hasUnsavedChanges.value = false;
      Get.snackbar('OK', 'Fotografia subida correctamente.');
    } catch (e) {
      Get.snackbar(
        'No fue posible subir la fotografia',
        'Fallo en $etapa. $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => uploadingImage = false);
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

          PerfilUsoActivo(
            tipo: tipoSeleccionado ?? 'Otro',
            inicial: _perfilUso,
            horarioEmpresa: clientController.Client['mipyme']?['horario_operacion'],
            onChanged: (v) {
              _perfilUso = v;
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          FichaTecnicaVerdeActivo(
            key: ValueKey("fve_ia_${_revisionFveIA}"),
            aplicarSugerenciasIA: _revisionFveIA > 0,
            idActivo: int.tryParse('${clientController.Activo['id_activo'] ?? ''}'),
            tipo: tipoSeleccionado ?? '',
            nombre: nombreCtrl.text,
            onChanged: (datos) {
              // null indica reinicializacion por cambio de id/tipo;
              // no representa una edicion del asesor.
              _datosTecnicosFve = datos;
              if (datos != null) _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
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
              _perfilUso = null;
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

  Future<void> _cargarEstadoReferencias() async {
    final id = int.tryParse('${clientController.Activo['id_activo'] ?? ''}');
    if (id == null || !mounted) return;
    try {
      final estado = await obtenerEstadoEstimacionesIA(id);
      if (mounted) setState(() => _estadoReferencias = estado);
    } catch (e) {
      debugPrint('Estado referencias IA: $e');
    }
  }

  Future<void> _buscarReferencias() async {
    final id = int.tryParse('${clientController.Activo['id_activo'] ?? ''}');
    if (id == null || _buscandoReferencias) return;
    setState(() => _buscandoReferencias = true);
    try {
      final r = await investigarReferenciasActivoIA(id);
      await _cargarEstadoReferencias();
      if (!mounted) return;
      setState(() {
        _ultimoReporteBusquedaFve = r['reporte_busqueda'] is Map
          ? Map<String, dynamic>.from(r['reporte_busqueda']) : null;
        _ultimoReporteGuardadoFve = r['guardado'] == true;
      });
      await _mostrarReporteBusquedaFve(r);
    } catch (e) {
      if (mounted) Get.snackbar('No se completó la búsqueda', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally { if (mounted) setState(() => _buscandoReferencias = false); }
  }


  // FVE_REPORTE_VISIBLE_CRAWLER_V1: resumen visible y comprobable de la ultima investigacion.
  Future<void> _mostrarReporteBusquedaFve(Map<String, dynamic> respuesta) async {
    final reporte = respuesta['reporte_busqueda'];
    if (reporte is! Map) {
      Get.snackbar('Búsqueda de referencias', respuesta['guardado'] == true
        ? 'Se guardaron estimaciones por separado.'
        : 'No hubo estimaciones aprobadas. Revisa los logs del servidor.',
        snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final docs = reporte['documentos'] is List ? reporte['documentos'] as List : <dynamic>[];
    final rechazos = reporte['rechazos'] is List ? reporte['rechazos'] as List : <dynamic>[];
    final aceptados = reporte['campos_con_estimacion_aceptada'] is List
      ? reporte['campos_con_estimacion_aceptada'] as List : <dynamic>[];
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Resultado de la búsqueda técnica'),
      content: SizedBox(width: 650, child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(respuesta['guardado'] == true
            ? 'Se guardaron estimaciones aproximadas y se conserva su origen.'
            : 'Se revisaron fuentes, pero ninguna estimación superó todas las validaciones.',
            style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 9),
          Text('Google Search verificado: ${reporte['google_busqueda_verificada'] == true ? 'Sí' : 'No'}'),
          Text('Crawler ejecutado: ${reporte['crawler_ejecutado'] == true ? 'Sí' : 'No'}'),
          Text('Páginas visitadas: ${reporte['paginas_visitadas'] ?? 0}; leídas: ${reporte['paginas_leidas'] ?? 0}; errores: ${reporte['errores_lectura'] ?? 0}'),
          Text('Fichas técnicas encontradas: ${docs.length}; métricas aprobadas: ${aceptados.length}'),
          if (reporte['error_analisis'] is Map) ...[
            const SizedBox(height: 9),
            Text('El crawler encontró documentos, pero Gemini no pudo analizarlos. '
              'No se guardaron esas referencias. Intentos: '
              '${(reporte['error_analisis'] as Map)['intentos'] ?? 1}.',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
          if (reporte['ajustes_clasificacion'] is List &&
              (reporte['ajustes_clasificacion'] as List).isNotEmpty) ...[
            const SizedBox(height: 9),
            const Text('Modelo identificado solo por familia comercial: '
              'las fichas corresponden a modelos comparables, no al equipo exacto.'),
          ], // FVE_CRAWLER_ESTABILIDAD_V2
          const SizedBox(height: 12),
          Text('Fuentes encontradas', style: TextStyle(color: Global.text, fontWeight: FontWeight.bold)),
          if (docs.isEmpty)
            const Text('No se pudo recuperar ninguna ficha técnica en esta búsqueda.'),
          for (final doc in docs)
            if (doc is Map) Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all(color: Colors.orange.withOpacity(.35)),
                borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${doc['titulo'] ?? 'Ficha técnica'}', style: const TextStyle(fontWeight: FontWeight.w600)),
                if (doc['consumos_detectados_kwh_mes'] is List &&
                    (doc['consumos_detectados_kwh_mes'] as List).isNotEmpty)
                  Text('Consumos mencionados: ${(doc['consumos_detectados_kwh_mes'] as List).join(', ')} kWh/mes'),
                if (doc['capacidad_titulo_l'] != null)
                  Text('Capacidad indicada en el título: ${doc['capacidad_titulo_l']} L'),
                const SizedBox(height: 4),
                SelectableText('${doc['url'] ?? ''}',
                  style: TextStyle(fontSize: 11, color: Global.primary)),
              ]),
            ),
          if (rechazos.isNotEmpty) ...[
            const SizedBox(height: 13),
            Text('Motivos de rechazo', style: TextStyle(color: Global.text, fontWeight: FontWeight.bold)),
            for (final item in rechazos)
              if (item is Map) Padding(padding: const EdgeInsets.only(top: 4),
                child: Text(item['motivo'] == 'FUENTES_EXTRAIDAS_INSUFICIENTES'
                  ? '${item['codigo']}: faltan sitios independientes (${item['dominios_validos']} de ${item['dominios_necesarios']})'
                  : '${item['codigo']}: ${item['motivo'] ?? 'Sin soporte suficiente'}',
                  style: const TextStyle(fontSize: 12))),
          ],
          const SizedBox(height: 12),
          Text('${reporte['advertencia'] ?? 'Referencias orientativas, no mediciones del activo.'}',
            style: TextStyle(fontSize: 12, color: Global.textSecondary)),
        ]),
      )),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar'))],
    ));
  }

  Widget _panelReferencias() {
    final e = _estadoReferencias;
    if (e == null) return const SizedBox.shrink();
    final faltantes = e['faltantes'] is List ? (e['faltantes'] as List) : <dynamic>[];
    final estimaciones = e['estimaciones'] is Map ? e['estimaciones'] as Map : {};
    final camposEstimados = estimaciones['campos'] is Map ? estimaciones['campos'] as Map : {};
    if (faltantes.isEmpty && camposEstimados.isEmpty) return const SizedBox.shrink();
    final puedeBuscar = faltantes.any((f) => f is Map && f['estimable'] == true);
    final nombres = faltantes.whereType<Map>().map((f) => '${f['etiqueta']}').join(', ');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(.08), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(.35))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.warning_amber_rounded, color: Colors.orange), const SizedBox(width: 8),
          Expanded(child: Text('Informacion tecnica incompleta', style: TextStyle(color: Global.text,fontWeight: FontWeight.w700)))]),
        const SizedBox(height: 7),
        if (faltantes.isNotEmpty) Text('No se detectó: $nombres.', style: TextStyle(color: Global.text)),
        const SizedBox(height: 6),
        Text('Sin esos datos, el diagnostico puede carecer de metricas. La busqueda IA genera aproximaciones, NO mediciones.',
          style: TextStyle(color: Global.textSecondary, fontSize: 12)),
        if (camposEstimados.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Referencias aproximadas guardadas:', style: TextStyle(color: Global.text,fontWeight: FontWeight.w600)),
          for (final x in camposEstimados.entries)
            if (x.value is Map) Padding(padding: const EdgeInsets.only(top: 5),
              child: Text('${x.key}: ${x.value['valor']} ${x.value['unidad']} • ${x.value['coincidencia']} (IA, sin verificar)',
                style: TextStyle(color: Global.text, fontSize: 12))),
          for (final x in camposEstimados.entries)
            if (x.value is Map) ...[
              const SizedBox(height: 7),
              Text('Método: ${x.value['metodo'] ?? 'No especificado'}',
                style: TextStyle(color: Global.textSecondary,fontSize: 11)),
              for (final f in (x.value['fuentes'] is List ? x.value['fuentes'] as List : <dynamic>[]))
                if (f is Map && f['url'] != null)
                  Padding(padding: const EdgeInsets.only(top: 3),
                    child: SelectableText('Fuente IA: ${f['url']}',
                      style: TextStyle(color: Global.primary,fontSize: 11))),
            ],
          Text('Estas referencias no se han copiado a la ficha tecnica. Las fuentes citadas requieren validacion humana.',
            style: TextStyle(color: Global.textSecondary,fontSize: 11)),
        ],
        if (_ultimoReporteBusquedaFve != null) ...[
          const SizedBox(height: 10),
          Text('Última búsqueda: ${(_ultimoReporteBusquedaFve!['documentos'] as List?)?.length ?? 0} fichas encontradas; '
            '${(_ultimoReporteBusquedaFve!['campos_con_estimacion_aceptada'] as List?)?.length ?? 0} métricas aprobadas.',
            style: TextStyle(fontSize: 12, color: Global.text, fontWeight: FontWeight.w600)),
          TextButton.icon(
            icon: const Icon(Icons.receipt_long_outlined, size: 17),
            label: const Text('Ver fuentes y motivos de rechazo'),
            onPressed: () => _mostrarReporteBusquedaFve({
              'reporte_busqueda': _ultimoReporteBusquedaFve,
              'guardado': _ultimoReporteGuardadoFve,
            }),
          ),
        ],
        if (puedeBuscar) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: _buscandoReferencias ? null : _buscarReferencias,
            icon: _buscandoReferencias
              ? const SizedBox(width: 16,height: 16,child:CircularProgressIndicator(strokeWidth:2))
              : const Icon(Icons.travel_explore_outlined),
            label: Text(_buscandoReferencias ? 'Buscando fuentes...' : 'Buscar referencias aproximadas con IA')),
        ],
      ]),
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

          _panelReferencias(),
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
      _revisionFveIA++;

      _synchronizeAssetForm();
      await _cargarEstadoReferencias();

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
    final datosActivo = asset['datos'];
    final perfilGuardado = datosActivo is Map ? datosActivo['fve_perfil_uso'] : null;
    _perfilUso = perfilGuardado is Map
        ? Map<String, dynamic>.from(perfilGuardado) : null;

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
                  (uploadingImage || loading) ? null : pickImage,
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
                  (uploadingImage || loading) ? null : takePhoto,
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
                      onPressed: (uploadingImage || loading)
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
                  headers: Utils.imageHeaders,
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