import 'dart:async';

import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/models/api/servicesApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/currency_formatter.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Editmipymeasesor extends StatefulWidget {
  const Editmipymeasesor({super.key});

  @override
  State<Editmipymeasesor> createState() =>
      _EditmipymeasesorState();
}

class _EditmipymeasesorState
    extends State<Editmipymeasesor> {
  final _formKey = GlobalKey<FormState>();

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
  final ingresosCtrl = TextEditingController();
  final egresosCtrl = TextEditingController();
  final ciiuCtrl = TextEditingController();
  String tipoPersona = 'Natural';


  bool loading = false;

  final ClientController clientController = Get.find<ClientController>();

  @override
  void dispose() {
    nombreMipymeCtrl.dispose();
    nitCtrl.dispose();
    direccionCtrl.dispose();
    municipioCtrl.dispose();
    descripcionCtrl.dispose();
    empleadosCtrl.dispose();
    ingresosCtrl.dispose();
    egresosCtrl.dispose();
    ciiuCtrl.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nombreMipymeCtrl.text = clientController.Client["mipyme"]["nombre_mipyme"] ?? '';
    nitCtrl.text = clientController.Client["mipyme"]["nit"] ?? '';
    selectedDepartamento = clientController.Client["mipyme"]["departamento"];
    selectedMunicipio = clientController.Client["mipyme"]["municipio"];
    selectedBarrio = clientController.Client["mipyme"]["barrio"];
    direccionCtrl.text = clientController.Client["mipyme"]["direccion"] ?? '';
    ciiuCtrl.text = clientController.Client["mipyme"]["codigo_ciiu"] ?? '';
    selectedEstrato = clientController.Client["mipyme"]["estrato"];
    selectedTipoEmpresa = clientController.Client["mipyme"]["tipo_empresa"];
    empleadosCtrl.text = (clientController.Client["mipyme"]["cantidad_empleados"] ?? "").toString();
    ingresosCtrl.text = Utils.formatMiles(
        clientController.Client["mipyme"]["ingresos"] ?? 0
    );
    egresosCtrl.text = Utils.formatMiles(
        clientController.Client["mipyme"]["egresos"] ?? 0
    );
    descripcionCtrl.text = clientController.Client["mipyme"]["descripcion_empresa"] ?? "";
    tipoPersona = clientController.Client["mipyme"]["tipo_persona"] ?? "Natural";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth > 900;
        final fieldWidth = twoColumns
            ? (constraints.maxWidth / 2) - 30
            : double.infinity;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    controller.backPage();
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(CupertinoIcons.back),
                  ),
                ),
                Text(
                  "Editar empresa",
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
                TextButton(
                    onPressed: () async {
                      loading ? null : await _submit();
                    },
                    child: Center(
                      child: loading
                          ? CircularProgressIndicator(
                        color: Global.primary,
                      )
                          : Text(
                        'Guardar',
                        style: TextStyle(
                          color: Global.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                )
              ],
            ),
        
            const SizedBox(height: 12),
        
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Datos de la mipyme",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Puedes dejar campos vacíos si no tienes toda la información todavía.",
                              style: TextStyle(
                                color: Global.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                        
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: fieldWidth,
                                  child: _input(
                                    nombreMipymeCtrl,
                                    'Nombre de la mipyme',
                                    Icons.business,
                                    required: false,
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _input(
                                    nitCtrl,
                                    'NIT',
                                    Icons.confirmation_number,
                                    required: false,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      const Text("Tipo de persona"),

                                      const SizedBox(height: 8),

                                      Wrap(
                                        spacing: 10,
                                        children: [

                                          ChoiceChip(
                                            label: const Text("Natural"),
                                            selected: tipoPersona == "Natural",
                                            onSelected: (_) {
                                              setState(() {
                                                tipoPersona = "Natural";
                                              });
                                            },
                                          ),

                                          ChoiceChip(
                                            label: const Text("Jurídica"),
                                            selected: tipoPersona == "Jurídica",
                                            onSelected: (_) {
                                              setState(() {
                                                tipoPersona = "Jurídica";
                                              });
                                            },
                                          ),

                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Departamento"),
                                    SizedBox(
                                      width: fieldWidth,
                                      child: DropdownButtonFormField<String>(
                                        initialValue: selectedDepartamento,
                                        value: selectedDepartamento,
                                        decoration: Wapp.TextFieldDecoration(
                                          Global.primary,
                                          true,
                                          "Departamento",
                                          Icons.map,
                                        ),
                                        items: Global.ubicaciones.keys.map((dep) {
                                          return DropdownMenuItem(value: dep, child: Text(dep));
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedDepartamento = value;
                                            selectedMunicipio = null;
                                            selectedBarrio = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Municipio"),
                                    SizedBox(
                                      width: fieldWidth,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedMunicipio,
                                        initialValue: selectedMunicipio,
                                        decoration: Wapp.TextFieldDecoration(
                                          Global.primary,
                                          true,
                                          "Municipio",
                                          Icons.location_city,
                                        ),
                                        items: selectedDepartamento == null
                                            ? []
                                            : Global.ubicaciones[selectedDepartamento!]!
                                            .keys
                                            .map<DropdownMenuItem<String>>((mun) {
                                          return DropdownMenuItem<String>(
                                            value: mun,
                                            child: Text(mun),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedMunicipio = value;
                                            selectedBarrio = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Barrio"),
                                    SizedBox(
                                      width: fieldWidth,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedBarrio,
                                        initialValue: selectedBarrio,
                                        decoration: Wapp.TextFieldDecoration(
                                          Global.primary,
                                          true,
                                          "Barrio",
                                          Icons.location_on,
                                        ),
                                        items: selectedMunicipio == null
                                            ? []
                                            : Global
                                            .ubicaciones[selectedDepartamento!]![selectedMunicipio!]!
                                            .map<DropdownMenuItem<String>>((barrio) {
                                          return DropdownMenuItem<String>(
                                            value: barrio,
                                            child: Text(barrio),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedBarrio = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _input(
                                    direccionCtrl,
                                    'Dirección',
                                    Icons.location_on_outlined,
                                    required: false,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Tipo de empresa"),
                                    SizedBox(
                                      width: fieldWidth,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedTipoEmpresa,
                                        decoration: Wapp.TextFieldDecoration(
                                          Global.primary,
                                          true,
                                          "Tipo de empresa",
                                          Icons.apartment,
                                        ),
                                        items: Global.tiposEmpresa.map<DropdownMenuItem<String>>((tipoEmpresa){
                                          return DropdownMenuItem<String>(
                                            value: tipoEmpresa,
                                            child: Text(tipoEmpresa),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedTipoEmpresa = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Código CIIU"),
                                      TextFormField(
                                        controller: ciiuCtrl,
                                        readOnly: true,
                                        onTap: _openCiiuSelector,
                                        decoration: Wapp.TextFieldDecoration(
                                          Global.primary,
                                          true,
                                          "Seleccionar código CIIU",
                                          Icons.qr_code,
                                        ).copyWith(
                                          suffixIcon: IconButton(
                                            onPressed: _openCiiuSelector,
                                            icon: Icon(Icons.search, color: Global.primary),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Estrato"),
                                    SizedBox(
                                      width: fieldWidth,
                                      child: DropdownButtonFormField<int>(
                                        value: selectedEstrato,
                                        decoration: Wapp.TextFieldDecoration(
                                          Global.primary,
                                          true,
                                          "Estrato",
                                          Icons.apartment,
                                        ),
                                        items: List.generate(6, (index) {
                                          final estrato = index + 1;
                                          return DropdownMenuItem<int>(
                                            value: estrato,
                                            child: Text("Estrato $estrato"),
                                          );
                                        }),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedEstrato = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _input(
                                    empleadosCtrl,
                                    'Cantidad de empleados',
                                    Icons.groups_2_outlined,
                                    required: false,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _inputMoney(
                                    ingresosCtrl,
                                    'Ingresos',
                                    Icons.trending_up,
                                    'Ingresos',
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _inputMoney(
                                    egresosCtrl,
                                    'Egresos',
                                    Icons.trending_down,
                                    "Egresos"
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _input(
                                    descripcionCtrl,
                                    'Descripción de la empresa',
                                    Icons.description,
                                    required: false,
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                        
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
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

    setState(() => loading = true);

    try {
      await updateMipymeApi(
        idMipyme: clientController.Client["mipyme"]["id_mipyme"],
        updatedBy: controller.User["id_usuario"],

        direccion: direccionCtrl.text.trim().isEmpty
            ? null
            : direccionCtrl.text.trim(),

        departamento: selectedDepartamento,
        municipio: selectedMunicipio,
        barrio: barrioFinal,
        tipo_persona: tipoPersona,
        tipo_empresa: selectedTipoEmpresa,

        /// RESTO
        nombreMipyme: nombreMipymeCtrl.text.trim().isEmpty
            ? null
            : nombreMipymeCtrl.text.trim(),

        nit: nitCtrl.text.trim().isEmpty
            ? null
            : nitCtrl.text.trim(),

        descripcionEmpresa: descripcionCtrl.text.trim().isEmpty
            ? null
            : descripcionCtrl.text.trim(),

        cantidadEmpleados: empleadosCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(empleadosCtrl.text.trim()),

        ingresos: ingresosCtrl.text.trim().isEmpty
            ? null
            : Utils.parseMoney(ingresosCtrl.text),

        egresos: egresosCtrl.text.trim().isEmpty
            ? null
            : Utils.parseMoney(egresosCtrl.text),

        codigoCiiu: ciiuCtrl.text.trim().isEmpty
            ? null
            : ciiuCtrl.text.trim(),

        estrato: selectedEstrato,
      );

      controller.backPage();
      clientController.refreshClient();

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openCiiuSelector() async {

    final searchCtrl = TextEditingController();
    final results = [].obs;
    final loading = false.obs;

    Timer? debounce;

    void doSearch(String query) async {
      if (query.trim().isEmpty) {
        results.clear();
        return;
      }

      loading.value = true;

      try {
        final data = await searchCiiuApi(query: query);
        results.assignAll(data);
      } catch (e) {
        results.clear();
      }

      loading.value = false;
    }

    await Get.bottomSheet(
      SafeArea(
        child: Container(
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Global.bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Buscar CIIU"),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  )
                ],
              ),

              const SizedBox(height: 10),

              /// INPUT
              TextField(
                controller: searchCtrl,
                autofocus: false,
                decoration: Wapp.TextFieldDecoration(
                  Global.primary,
                  true,
                  "Buscar actividad o código",
                  Icons.search,
                ),
                onChanged: (value) {
                  debounce?.cancel();
                  debounce = Timer(
                    const Duration(milliseconds: 300),
                        () => doSearch(value),
                  );
                },
              ),

              const SizedBox(height: 10),

              /// RESULTADOS
              Expanded(
                child: Obx(() {

                  if (loading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (results.isEmpty) {
                    return const Center(
                      child: Text("Sin resultados"),
                    );
                  }

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, index) {

                      final item = results[index];

                      final codigo = item["codigo"].toString();
                      final nombre = item["nombre"] ??
                          item["descripcion"] ??
                          item["actividad"] ??
                          "Sin nombre";

                      return ListTile(
                        title: Text("$codigo - $nombre"),

                        onTap: () {

                          debounce?.cancel();

                          /// ✅ ACTUALIZA SOLO EL CAMPO
                          ciiuCtrl.text = codigo;

                          /// ✅ CERRAR SIN BUG
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );

    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    debounce?.cancel();
    searchCtrl.dispose();
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