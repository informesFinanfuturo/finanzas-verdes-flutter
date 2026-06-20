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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Newconsumoasesor extends StatefulWidget {
  const Newconsumoasesor({super.key});

  @override
  State<Newconsumoasesor> createState() => _NewconsumoasesorState();
}

class _NewconsumoasesorState extends State<Newconsumoasesor> {

  final _formKey = GlobalKey<FormState>();

  final tipoCtrl = TextEditingController();
  final proveedorCtrl = TextEditingController();
  final valorCtrl = TextEditingController();
  final consumoCtrl = TextEditingController();
  final unidadCtrl = TextEditingController();
  final periodoCtrl = TextEditingController();
  final observacionesCtrl = TextEditingController();

  bool loading = false;


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
  Widget build(BuildContext context) {
    return Obx(() => Column(
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
            Text("Registrar Factura de consumo",
                style: GoogleFonts.poppins(fontSize: 18)),
          ],
        ),

        const SizedBox(height: 10),

        Text("Puedes ingresar únicamente el tipo de factura para crear el registro. Si lo prefieres, luego podrás añadir las imágenes de la factura para que la IA complete automáticamente la información restante."),

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

                  _input(tipoCtrl, "Tipo (luz, agua, gas)", Icons.category),
                  const SizedBox(height: 12),

                  _input(proveedorCtrl, "Proveedor", Icons.business, required: false),
                  const SizedBox(height: 12),

                  _input(valorCtrl, "Valor factura", Icons.attach_money, keyboardType: TextInputType.number, required: false),
                  const SizedBox(height: 12),

                  _input(consumoCtrl, "Consumo", Icons.bolt, keyboardType: TextInputType.number, required: false),
                  const SizedBox(height: 12),

                  _input(unidadCtrl, "Unidad (kWh, m3)", Icons.speed, required: false),
                  const SizedBox(height: 12),

                  _input(periodoCtrl, "Periodo (aaaa-mm-dd)", Icons.date_range, required: false),
                  const SizedBox(height: 12),

                  _input(observacionesCtrl, "Observaciones", Icons.description, required: false),
                  const SizedBox(height: 24),

                  InkWell(
                    onTap: loading ? null : _submit,
                    child: Container(
                      height: 50,
                      decoration: Wapp.ButtonDecorationGradient(
                        Global.primary,
                        Global.secondary,
                      ),
                      child: Center(
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Guardar Consumo',
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
      ],
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

      await createConsumoApi(
        tipo: tipoCtrl.text,

        // ✅ automático (NO se pide en UI)
        idMipyme: clientController.Client["mipyme"]["id_mipyme"],
        createdBy: controller.User["id_usuario"],

        proveedor: proveedorCtrl.text.isEmpty ? null : proveedorCtrl.text,
        periodo: periodoCtrl.text.isEmpty ? null : periodoCtrl.text,
        valor: valorCtrl.text.isEmpty ? null : double.tryParse(valorCtrl.text),
        consumo: consumoCtrl.text.isEmpty ? null : double.tryParse(consumoCtrl.text),
        unidad: unidadCtrl.text.isEmpty ? null : unidadCtrl.text,
        observaciones: observacionesCtrl.text.isEmpty ? null : observacionesCtrl.text,
      );


      // ✅ refrescar cliente (para traer activos nuevos)
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
}