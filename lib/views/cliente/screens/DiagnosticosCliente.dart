import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/diagnosticoApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class Diagnosticoscliente extends StatefulWidget {
  const Diagnosticoscliente({super.key});

  @override
  State<Diagnosticoscliente> createState() => _DiagnosticosclienteState();
}

class _DiagnosticosclienteState extends State<Diagnosticoscliente> {
  final ClientController clientController = Get.put(ClientController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDiagnosticosByUsuario(clientController: clientController);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {

        return Obx(() {
          final _ = controller.isDark;
          final diagnosticos = clientController.Diagnosticos ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ✅ TÍTULO
                Text(
                  "Diagnósticos",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// ✅ GRID RESPONSIVE
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: diagnosticos.map<Widget>((d) {

                    return SizedBox(
                      width: width > 800 ? 500 : width - 50,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // 🔥 clave

                          children: [

                            /// ✅ HEADER
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.psychology, color: Global.primary, size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    d["titulo"] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16, // 🔥 más grande
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// ✅ PROBLEMA
                            if (d["problema"]?["descripcion"] != null)
                              Text(
                                d["problema"]["descripcion"],
                                style: TextStyle(
                                  fontSize: 14, // 🔥 mejor legibilidad
                                  color: Global.textSecondary,
                                ),
                              ),

                            const SizedBox(height: 10),

                            /// ✅ INDICADORES
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _chip("Impacto",
                                    d["problema"]?["indicadores"]?["impacto_actual"]),
                                _chip("Ahorro",
                                    d["beneficios"]?["indicadores"]?["ahorro_estimado"]),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// ✅ BENEFICIO
                            if (d["beneficios"]?["descripcion"] != null)
                              Text(
                                d["beneficios"]["descripcion"],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Global.text,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          );
        });
      },
    );
  }

  Widget _chip(String label, dynamic value) {
    if (value == null) return SizedBox();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Global.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(fontSize: 10),
      ),
    );
  }
}
