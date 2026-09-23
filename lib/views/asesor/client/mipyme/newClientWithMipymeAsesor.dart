import 'dart:async';
import 'dart:ui' as ui;

import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/models/api/servicesApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/currency_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Newclientwithmipymeasesor extends StatefulWidget {
  const Newclientwithmipymeasesor({super.key});

  @override
  State<Newclientwithmipymeasesor> createState() =>
      _NewclientwithmipymeasesorState();
}

class _NewclientwithmipymeasesorState
    extends State<Newclientwithmipymeasesor> {
  final _formKey = GlobalKey<FormState>();

  // ✅ CLIENTE
  final documentoCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();

  String? selectedDepartamento;
  String? selectedMunicipio;
  String? selectedBarrio;
  int? selectedEstrato;
  String? selectedTipoEmpresa;
  bool nitEditadoManualmente = false;

  final barrioOtroCtrl = TextEditingController();

  // ✅ MIPYME
  final nombreMipymeCtrl = TextEditingController();
  final nitCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final municipioCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final empleadosCtrl = TextEditingController();
  // final ingresosCtrl = TextEditingController();
  // final egresosCtrl = TextEditingController();
  final ciiuCtrl = TextEditingController();
  final ciiuDisplayCtrl = TextEditingController();
  String tipoPersona = 'Natural';

  bool loading = false;

  final ClientController clientController = Get.find<ClientController>();

  @override
  void dispose() {
    documentoCtrl.removeListener(_onDocumentoChanged);
    nitCtrl.removeListener(_onNitChanged);

    documentoCtrl.dispose();
    nitCtrl.dispose();
    nombreCtrl.dispose();
    emailCtrl.dispose();
    telefonoCtrl.dispose();

    nombreMipymeCtrl.dispose();
    direccionCtrl.dispose();
    municipioCtrl.dispose();
    barrioOtroCtrl.dispose();
    descripcionCtrl.dispose();
    empleadosCtrl.dispose();
    ciiuCtrl.dispose();
    ciiuDisplayCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    documentoCtrl.addListener(_onDocumentoChanged);
    nitCtrl.addListener(_onNitChanged);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth > 900;
        final fieldWidth = twoColumns
            ? (constraints.maxWidth / 2) - 30
            : double.infinity;

        return Obx(() {
          final _ = controller.isDark;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ✅ HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: controller.backPage,
                      tooltip: 'Volver',
                      icon: const Icon(
                        CupertinoIcons.back,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        'Crear cliente y mipyme',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Global.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isDesktop = constraints.maxWidth >= 900;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        isDesktop ? 28 : 14,
                        16,
                        isDesktop ? 28 : 14,
                        MediaQuery.paddingOf(context).bottom + 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1400,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildClientSection(),
                                const SizedBox(height: 18),
                                _buildMipymeSection(),
                                const SizedBox(height: 24),
                                _buildSubmitButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _input(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool required = true,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            hint,
            icon,
          ),
          validator: required
              ? (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null
              : null,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final barrioFinal = selectedBarrio == "Otro"
        ? barrioOtroCtrl.text.trim()
        : selectedBarrio;

    final direccionFinal =
        "$barrioFinal, $selectedMunicipio, $selectedDepartamento";

    setState(() => loading = true);

    try {
      await createClientWithMipymeApi(
        documento: documentoCtrl.text.trim(),
        nombreUsuario: nombreCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        telefono: telefonoCtrl.text.trim().isEmpty
            ? null
            : telefonoCtrl.text.trim(),

        nombreMipyme: nombreMipymeCtrl.text.trim().isEmpty
            ? null
            : nombreMipymeCtrl.text.trim(),
        nit: nitCtrl.text.trim().isEmpty ? null : nitCtrl.text.trim(),

        departamento: selectedDepartamento,
        municipio: selectedMunicipio,
        barrio: barrioFinal,
        direccion: direccionFinal,

        descripcionEmpresa: descripcionCtrl.text.trim().isEmpty
            ? null
            : descripcionCtrl.text.trim(),

        cantidadEmpleados: empleadosCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(empleadosCtrl.text.trim()),

        // ingresos: ingresosCtrl.text.trim().isEmpty
        //     ? null
        //     : double.tryParse(ingresosCtrl.text.trim()),
        //
        // egresos: egresosCtrl.text.trim().isEmpty
        //     ? null
        //     : double.tryParse(egresosCtrl.text.trim()),

        codigoCiiu: ciiuCtrl.text.trim().isEmpty
            ? null
            : ciiuCtrl.text.trim(),

        estrato: selectedEstrato,
        tipo_empresa: selectedTipoEmpresa,
        tipo_persona: tipoPersona,

        /// EXTRA
        tipoRelacion: 'propietario',
        createdBy: controller.User["id_usuario"],
        clientController: clientController,
      );

      controller.backPage();

    } catch (e) {
      // Get.snackbar(
      //   'Error',
      //   e.toString(),
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    } finally {
      setState(() => loading = false);
    }
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

  Widget _buildClientSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Global.text.withOpacity(0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Datos del cliente',
            subtitle: 'Información personal y de contacto',
            icon: Icons.person_outline_rounded,
            color: Global.primary,
          ),

          const SizedBox(height: 20),

          ResponsiveFormGrid(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _input(
                    documentoCtrl,
                    'Documento',
                    Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),

                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: documentoCtrl.text.trim().isEmpty
                          ? null
                          : () {
                        setState(() {
                          nitEditadoManualmente = false;
                          nitCtrl.text =
                              documentoCtrl.text.trim();
                        });
                      },
                      icon: const Icon(
                        Icons.content_copy_rounded,
                        size: 17,
                      ),
                      label: const Text(
                        'Usar documento como NIT',
                      ),
                    ),
                  ),
                ],
              ),

              _input(
                nombreCtrl,
                'Nombre del cliente',
                Icons.person_outline_rounded,
              ),

              _input(
                emailCtrl,
                'Correo electrónico',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              _input(
                telefonoCtrl,
                'Teléfono',
                Icons.phone_outlined,
                required: false,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Global.text,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: Global.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMipymeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Global.text.withOpacity(0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Datos de la mipyme',
            subtitle:
            'Completa únicamente la información disponible',
            icon: Icons.business_rounded,
            color: const Color(0xFF2E7D5B),
          ),

          const SizedBox(height: 20),

          ResponsiveFormGrid(
            children: [
              _input(
                nombreMipymeCtrl,
                'Nombre de la mipyme',
                Icons.business_outlined,
                required: false,
              ),

              _input(
                nitCtrl,
                'NIT',
                Icons.confirmation_number_outlined,
                required: false,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),

              _buildTipoPersonaField(),

              _buildDepartamentoField(),

              _buildMunicipioField(),

              _buildBarrioField(),

              _input(
                direccionCtrl,
                'Dirección',
                Icons.location_on_outlined,
                required: false,
              ),

              _buildTipoEmpresaField(),

              _buildCiiuField(),

              _buildEstratoField(),

              _input(
                empleadosCtrl,
                'Cantidad de empleados',
                Icons.groups_2_outlined,
                required: false,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // La descripción aprovecha todo el ancho.
          _input(
            descripcionCtrl,
            'Descripción de la empresa',
            Icons.description_outlined,
            required: false,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildEstratoField() {
    return _labeledField(
      label: 'Estrato',
      optional: true,
      child: DropdownButtonFormField<int>(
        value: selectedEstrato,
        isExpanded: true,
        decoration: _formDecoration(
          hint: 'Seleccionar estrato',
          icon: Icons.layers_outlined,
        ),
        items: List.generate(6, (index) {
          final int estrato = index + 1;

          return DropdownMenuItem<int>(
            value: estrato,
            child: Text('Estrato $estrato'),
          );
        }),
        onChanged: (value) {
          setState(() {
            selectedEstrato = value;
          });
        },
      ),
    );
  }

  Widget _buildDepartamentoField() {
    return _labeledField(
      label: 'Departamento',
      child: DropdownButtonFormField<String>(
        value: selectedDepartamento,
        isExpanded: true,
        decoration: _formDecoration(
          hint: 'Seleccionar departamento',
          icon: Icons.map_outlined,
        ),
        items: Global.ubicaciones.keys.map((departamento) {
          return DropdownMenuItem<String>(
            value: departamento,
            child: Text(
              departamento,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedDepartamento = value;
            selectedMunicipio = null;
            selectedBarrio = null;
          });
        },
      ),
    );
  }

  Widget _buildMunicipioField() {
    final List<String> municipios =
    selectedDepartamento == null
        ? <String>[]
        : Global.ubicaciones[selectedDepartamento!]!
        .keys
        .toList();

    final bool enabled = selectedDepartamento != null;

    return _labeledField(
      label: 'Municipio',
      child: DropdownButtonFormField<String>(
        value: selectedMunicipio,
        isExpanded: true,
        decoration: _formDecoration(
          hint: enabled
              ? 'Seleccionar municipio'
              : 'Primero selecciona departamento',
          icon: Icons.location_city_outlined,
          enabled: enabled,
        ),
        items: municipios.map((municipio) {
          return DropdownMenuItem<String>(
            value: municipio,
            child: Text(
              municipio,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: !enabled
            ? null
            : (value) {
          setState(() {
            selectedMunicipio = value;
            selectedBarrio = null;
          });
        },
      ),
    );
  }

  Widget _buildBarrioField() {
    final bool enabled =
        selectedDepartamento != null &&
            selectedMunicipio != null;

    final List<String> barrios = !enabled
        ? <String>[]
        : List<String>.from(
      Global.ubicaciones[selectedDepartamento!]![
      selectedMunicipio!]!,
    );

    return _labeledField(
      label: 'Barrio',
      optional: true,
      child: DropdownButtonFormField<String>(
        value: selectedBarrio,
        isExpanded: true,
        decoration: _formDecoration(
          hint: enabled
              ? 'Seleccionar barrio'
              : 'Primero selecciona municipio',
          icon: Icons.location_on_outlined,
          enabled: enabled,
        ),
        items: barrios.map((barrio) {
          return DropdownMenuItem<String>(
            value: barrio,
            child: Text(
              barrio,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: !enabled
            ? null
            : (value) {
          setState(() {
            selectedBarrio = value;
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Align(
          alignment: isMobile
              ? Alignment.center
              : Alignment.centerRight,
          child: SizedBox(
            width: isMobile ? double.infinity : 240,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: loading ? null : _submit,
              icon: loading
                  ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.add_business_rounded,
              ),
              label: Text(
                loading
                    ? 'Creando...'
                    : 'Crear cliente',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Global.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipoPersonaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de persona',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Global.text.withOpacity(0.75),
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 56,
          ),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Global.bg.withOpacity(0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Global.text.withOpacity(0.10),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool compact =
                  constraints.maxWidth < 240;

              if (compact) {
                return Column(
                  children: [
                    _buildTipoPersonaOption(
                      label: 'Natural',
                      icon: Icons.person_outline_rounded,
                      value: 'Natural',
                    ),
                    const SizedBox(height: 5),
                    _buildTipoPersonaOption(
                      label: 'Jurídica',
                      icon: Icons.business_outlined,
                      value: 'Jurídica',
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildTipoPersonaOption(
                      label: 'Natural',
                      icon: Icons.person_outline_rounded,
                      value: 'Natural',
                    ),
                  ),

                  const SizedBox(width: 5),

                  Expanded(
                    child: _buildTipoPersonaOption(
                      label: 'Jurídica',
                      icon: Icons.business_outlined,
                      value: 'Jurídica',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTipoPersonaOption({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final bool isSelected = tipoPersona == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            tipoPersona = value;
          });
        },
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Global.primary.withOpacity(0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isSelected
                  ? Global.primary.withOpacity(0.45)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Global.primary
                    : Global.textSecondary,
              ),

              const SizedBox(width: 7),

              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isSelected
                        ? Global.primary
                        : Global.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoEmpresaField() {
    return _labeledField(
      label: 'Tipo de empresa',
      optional: true,
      child: DropdownButtonFormField<String>(
        value: selectedTipoEmpresa,
        isExpanded: true,
        decoration: _formDecoration(
          hint: 'Seleccionar tipo de empresa',
          icon: Icons.apartment_outlined,
        ),
        items: Global.tiposEmpresa.map((tipo) {
          return DropdownMenuItem<String>(
            value: tipo,
            child: Text(
              tipo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedTipoEmpresa = value;
          });
        },
      ),
    );
  }

  Widget _buildCiiuField() {
    return _labeledField(
      label: 'Actividad económica — CIIU',
      optional: true,
      child: TextFormField(
        controller: ciiuDisplayCtrl,
        readOnly: true,
        onTap: _openCiiuSelector,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Global.text,
        ),
        decoration: _formDecoration(
          hint: 'Seleccionar actividad económica',
          icon: Icons.account_tree_outlined,
          suffixIcon: IconButton(
            onPressed: _openCiiuSelector,
            tooltip: 'Buscar actividad económica',
            icon: Icon(
              Icons.search_rounded,
              color: Global.primary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCiiuSelector() async {
    final searchCtrl = TextEditingController();

    final RxList<dynamic> results = <dynamic>[].obs;
    final RxBool searching = false.obs;

    Timer? debounce;

    Future<void> doSearch(String query) async {
      final normalizedQuery = query.trim();

      if (normalizedQuery.isEmpty) {
        results.clear();
        searching.value = false;
        return;
      }

      searching.value = true;

      try {
        final data = await searchCiiuApi(
          query: normalizedQuery,
        );

        results.assignAll(data);
      } catch (error) {
        results.clear();

        Get.snackbar(
          'No fue posible buscar',
          'Ocurrió un problema consultando los códigos CIIU.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        debounce?.cancel();

        // Espera a que finalice la animación del BottomSheet.
        await Future<void>.delayed(
          const Duration(milliseconds: 350),
        );

        searchCtrl.dispose();
      }
    }

    try {
      await Get.bottomSheet(
        SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.88,
            child: Obx(() {
              final bool isDark = controller.isDark.value;

              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: isDark ? 22 : 16,
                    sigmaY: isDark ? 22 : 16,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),

                      // Cristal oscuro / acrílico claro.
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                          const Color(0xFF153240)
                              .withOpacity(0.88),
                          const Color(0xFF071C29)
                              .withOpacity(0.82),
                          const Color(0xFF0A2431)
                              .withOpacity(0.90),
                        ]
                            : [
                          Colors.white.withOpacity(0.96),
                          const Color(0xFFF5F8FA)
                              .withOpacity(0.92),
                          const Color(0xFFE7EFF3)
                              .withOpacity(0.94),
                        ],
                      ),

                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.13)
                            : Colors.white.withOpacity(0.95),
                        width: 1.2,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.40)
                              : const Color(0xFF486674)
                              .withOpacity(0.16),
                          blurRadius: isDark ? 34 : 28,
                          offset: const Offset(0, -8),
                        ),
                        BoxShadow(
                          color: isDark
                              ? Global.primary.withOpacity(0.07)
                              : Colors.white.withOpacity(0.70),
                          blurRadius: 14,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Reflejo superior del cristal/acrílico.
                        Positioned(
                          top: 0,
                          left: 28,
                          right: 28,
                          child: Container(
                            height: 1.2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(
                                    isDark ? 0.34 : 0.95,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Brillo diagonal muy sutil.
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius:
                                const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [
                                    0.0,
                                    0.28,
                                    0.55,
                                    1.0,
                                  ],
                                  colors: isDark
                                      ? [
                                    Colors.white.withOpacity(0.05),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Global.primary.withOpacity(0.025),
                                  ]
                                      : [
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.15),
                                    Colors.transparent,
                                    const Color(0xFFB6CAD3)
                                        .withOpacity(0.10),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            18,
                            12,
                            18,
                            18,
                          ),
                          child: Column(
                            children: [
                              // Indicador para arrastrar.
                              Container(
                                width: 42,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.24)
                                      : Global.text.withOpacity(0.18),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Encabezado.
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Global.primary.withOpacity(
                                        isDark ? 0.18 : 0.11,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Global.primary.withOpacity(
                                          isDark ? 0.22 : 0.13,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.account_tree_outlined,
                                      color: Global.primary,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Seleccionar código CIIU',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.w600,
                                            color: Global.text,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Busca por código o actividad económica',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color:
                                            Global.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: Get.back,
                                    tooltip: 'Cerrar',
                                    style: IconButton.styleFrom(
                                      backgroundColor: isDark
                                          ? Colors.white.withOpacity(0.06)
                                          : Colors.black.withOpacity(0.04),
                                    ),
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: Global.text,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Buscador.
                              TextField(
                                controller: searchCtrl,
                                autofocus: true,
                                textInputAction:
                                TextInputAction.search,
                                onSubmitted: doSearch,
                                onChanged: (value) {
                                  // Fuerza la actualización del estado vacío.
                                  searching.refresh();

                                  debounce?.cancel();

                                  debounce = Timer(
                                    const Duration(
                                      milliseconds: 350,
                                    ),
                                        () => doSearch(value),
                                  );
                                },
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Global.text,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                  'Buscar actividad o código',
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Global.textSecondary,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: Global.primary,
                                  ),
                                  suffixIcon:
                                  searchCtrl.text.isNotEmpty
                                      ? IconButton(
                                    tooltip:
                                    'Limpiar búsqueda',
                                    onPressed: () {
                                      debounce?.cancel();
                                      searchCtrl.clear();
                                      results.clear();
                                      searching.refresh();
                                    },
                                    icon: Icon(
                                      Icons.close_rounded,
                                      size: 19,
                                      color:
                                      Global.textSecondary,
                                    ),
                                  )
                                      : null,
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.black.withOpacity(0.16)
                                      : Colors.white.withOpacity(0.72),
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.10)
                                          : const Color(0xFF78909C)
                                          .withOpacity(0.22),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Global.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Resultados.
                              Expanded(
                                child: Obx(() {
                                  if (searching.value) {
                                    return Center(
                                      child:
                                      CircularProgressIndicator(
                                        color: Global.primary,
                                      ),
                                    );
                                  }

                                  if (searchCtrl.text
                                      .trim()
                                      .isEmpty) {
                                    return _buildCiiuMessage(
                                      icon: Icons.search_rounded,
                                      title:
                                      'Busca una actividad económica',
                                      description:
                                      'Escribe una palabra o un código para comenzar.',
                                    );
                                  }

                                  if (results.isEmpty) {
                                    return _buildCiiuMessage(
                                      icon:
                                      Icons.search_off_rounded,
                                      title: 'Sin resultados',
                                      description:
                                      'Intenta con otra actividad o código.',
                                    );
                                  }

                                  return ListView.separated(
                                    keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior
                                        .onDrag,
                                    padding:
                                    const EdgeInsets.only(top: 2),
                                    itemCount: results.length,
                                    separatorBuilder: (_, __) =>
                                        Divider(
                                          height: 1,
                                          indent: 70,
                                          color: Global.text
                                              .withOpacity(0.08),
                                        ),
                                    itemBuilder: (context, index) {
                                      final item =
                                      results[index];

                                      final String codigo =
                                          item['codigo']
                                              ?.toString() ??
                                              '';

                                      final String nombre =
                                          item['nombre']
                                              ?.toString() ??
                                              item['descripcion']
                                                  ?.toString() ??
                                              item['actividad']
                                                  ?.toString() ??
                                              'Sin descripción';

                                      final bool selected =
                                          ciiuCtrl.text.trim() ==
                                              codigo;

                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            debounce?.cancel();

                                            setState(() {
                                              // Código enviado a la API.
                                              ciiuCtrl.text =
                                                  codigo;

                                              // Actividad visible.
                                              ciiuDisplayCtrl
                                                  .text = nombre;
                                            });

                                            Get.back();
                                          },
                                          borderRadius:
                                          BorderRadius.circular(
                                            13,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? Global.primary
                                                  .withOpacity(
                                                isDark
                                                    ? 0.14
                                                    : 0.09,
                                              )
                                                  : Colors.transparent,
                                              borderRadius:
                                              BorderRadius.circular(
                                                13,
                                              ),
                                              border: Border.all(
                                                color: selected
                                                    ? Global.primary
                                                    .withOpacity(0.28)
                                                    : Colors.transparent,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 58,
                                                  height: 42,
                                                  alignment:
                                                  Alignment.center,
                                                  decoration:
                                                  BoxDecoration(
                                                    color: Global.primary
                                                        .withOpacity(
                                                      isDark
                                                          ? 0.17
                                                          : 0.10,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(11),
                                                  ),
                                                  child: Text(
                                                    codigo,
                                                    maxLines: 1,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style:
                                                    GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      color:
                                                      Global.primary,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(
                                                  width: 12,
                                                ),

                                                Expanded(
                                                  child: Text(
                                                    nombre,
                                                    maxLines: 2,
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    style:
                                                    GoogleFonts.poppins(
                                                      fontSize: 12.5,
                                                      height: 1.35,
                                                      fontWeight: selected
                                                          ? FontWeight.w500
                                                          : FontWeight.w400,
                                                      color: Global.text,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 8),

                                                if (selected)
                                                  Icon(
                                                    Icons
                                                        .check_circle_rounded,
                                                    color:
                                                    Global.primary,
                                                  )
                                                else
                                                  Icon(
                                                    Icons
                                                        .chevron_right_rounded,
                                                    color: Global
                                                        .textSecondary,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.transparent,
      );
    } finally {
      debounce?.cancel();
      searchCtrl.dispose();
    }
  }

  void _onDocumentoChanged() {
    final String documento = documentoCtrl.text.trim();

    if (!nitEditadoManualmente &&
        nitCtrl.text != documento) {
      nitCtrl.value = TextEditingValue(
        text: documento,
        selection: TextSelection.collapsed(
          offset: documento.length,
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onNitChanged() {
    final String nit = nitCtrl.text.trim();
    final String documento = documentoCtrl.text.trim();

    if (nit != documento) {
      nitEditadoManualmente = true;
    }
  }

  Widget _buildCiiuMessage({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 42,
              color: Global.text.withOpacity(0.25),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Global.text,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: Global.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _formDecoration({
    required String hint,
    required IconData icon,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    final Color borderColor =
    Global.text.withOpacity(enabled ? 0.13 : 0.07);
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: Global.textSecondary.withOpacity(
          enabled ? 0.90 : 0.55,
        ),
      ),
      prefixIcon: Icon(
        icon,
        size: 20,
        color: enabled
            ? Global.primary
            : Global.textSecondary.withOpacity(0.45),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: enabled
          ? Global.bg.withOpacity(0.55)
          : Global.bg.withOpacity(0.28),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: Global.primary,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _labeledField({
    required String label,
    required Widget child,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Global.text.withOpacity(0.78),
                  ),
                ),
              ),

              if (optional) ...[
                const SizedBox(width: 5),
                Text(
                  'Opcional',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Global.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 6),

        child,
      ],
    );
  }
}

class ResponsiveFormGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveFormGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;

        int columns;

        if (availableWidth >= 1200) {
          columns = 4;
        } else if (availableWidth >= 850) {
          columns = 3;
        } else if (availableWidth >= 560) {
          columns = 2;
        } else {
          columns = 1;
        }

        final double fieldWidth =
            (availableWidth - (spacing * (columns - 1))) /
                columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: children.map((child) {
            return SizedBox(
              width: fieldWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}