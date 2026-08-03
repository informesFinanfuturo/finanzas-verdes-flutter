import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Newrequerimientoasesor extends StatefulWidget {
  const Newrequerimientoasesor({super.key});

  @override
  State<Newrequerimientoasesor> createState() => _NewrequerimientoasesorState();
}

class _NewrequerimientoasesorState extends State<Newrequerimientoasesor> {
  final _formKey = GlobalKey<FormState>();
  ClientController clientController = Get.put(ClientController());

  final nombreCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final presupuestoCtrl = TextEditingController();
  String? selectedTipoProveedor;

  bool loading = false;

  final Map<String, TextEditingController> controllersDinamicos = {};
  final Map<String, dynamic> valuesDinamicos = {};

  @override
  void dispose() {
    nombreCtrl.dispose();
    descripcionCtrl.dispose();
    presupuestoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            Text("Solicitud para proveedores", style: GoogleFonts.poppins(fontSize: 18)),
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
                  'Publicar',
                  style: TextStyle(
                    color: Global.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),

        const SizedBox(height: 10),

        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Global.container,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _input(nombreCtrl, "Nombre del requerimiento", CupertinoIcons.tag),
                    SizedBox(height: 10,),
                    _inputArea(descripcionCtrl, "Descripción del requerimiento", CupertinoIcons.tag),
                    SizedBox(height: 10,),
                    _inputNumber(presupuestoCtrl, "Presupuesto estimado", CupertinoIcons.money_dollar),
                    SizedBox(height: 10,),
                    Text("Tipo de proveedor"),
                    DropdownButtonFormField<String>(
                      value: selectedTipoProveedor,
                      hint: Text("Seleccione el tipo de proveedor"),
                      decoration: Wapp.TextFieldDecoration(Global.primary, true, "Seleccione el tipo de proveedor", Icons.groups),
                      items: Global.itemConfig.map<DropdownMenuItem<String>>((t) {
                        return DropdownMenuItem(
                          value: t["tipo_item"],
                          child: Text(t["tipo_item"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) onChangeTipo(value);
                      },
                    ),
                    if (selectedTipoProveedor != null) ...[
                      const SizedBox(height: 10),

                      ...Global.itemConfig
                          .firstWhere((e) => e["tipo_item"] == selectedTipoProveedor)["campos"]
                          .map<Widget>((campo) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(campo["label"]),
                          buildCampo(campo),
                          const SizedBox(height: 10),
                        ],
                      ))
                          .toList(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {

    setState(() => loading = true);

    try {

      // await createMipymeApi(
      //   idUsuario: clientController.Client["user"]["id_usuario"],
      //   createdBy: controller.User["id_usuario"],
      //
      //   nombreMipyme: nombreCtrl.text.isEmpty ? null : nombreCtrl.text,
      //   nit: nitCtrl.text.isEmpty ? null : nitCtrl.text,
      //   sectorEconomico: sectorCtrl.text.isEmpty ? null : sectorCtrl.text,
      //   direccion: direccionCtrl.text.isEmpty ? null : direccionCtrl.text,
      //   municipio: municipioCtrl.text.isEmpty ? null : municipioCtrl.text,
      //   descripcionEmpresa: descripcionCtrl.text.isEmpty ? null : descripcionCtrl.text,
      //   cantidadEmpleados: empleadosCtrl.text.isEmpty
      //       ? null
      //       : int.tryParse(empleadosCtrl.text),
      //   ingresos: ingresosCtrl.text.isEmpty
      //       ? null
      //       : double.tryParse(ingresosCtrl.text),
      //   egresos: egresosCtrl.text.isEmpty
      //       ? null
      //       : double.tryParse(egresosCtrl.text),
      //   codigoCiiu: ciiuCtrl.text.isEmpty ? null : ciiuCtrl.text,
      // );

      // clientController.setClient(await getClientDetailApi(idUsuario: clientController.Client["user"]["id_usuario"]));

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

  Widget _inputNumber(
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
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly
          ],
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
          maxLines: 3,
        ),
      ],
    );
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
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly
          ],
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
          decoration: Wapp.TextFieldDecoration(Global.primary, true, campo["label"], Icons.edit),
        );

      default:
        return SizedBox();
    }
  }

  void onChangeTipo(String tipo) {
    selectedTipoProveedor = tipo;

    controllersDinamicos.clear();
    valuesDinamicos.clear();

    final config = Global.itemConfig.firstWhere((e) => e["tipo_item"] == tipo);

    for (var campo in config["campos"]) {
      controllersDinamicos[campo["key"]] = TextEditingController();
    }

    setState(() {});
  }

  Map<String, dynamic> buildEspecificaciones() {
    final Map<String, dynamic> specs = {};

    final config = Global.itemConfig.firstWhere((e) => e["tipo_item"] == selectedTipoProveedor);

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
}
