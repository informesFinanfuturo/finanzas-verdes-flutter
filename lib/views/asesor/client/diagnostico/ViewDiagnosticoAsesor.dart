import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/models/api/diagnosticoApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Viewdiagnosticoasesor extends StatefulWidget {
  const Viewdiagnosticoasesor({super.key});

  @override
  State<Viewdiagnosticoasesor> createState() => _ViewdiagnosticoasesorState();
}

class _ViewdiagnosticoasesorState extends State<Viewdiagnosticoasesor> {

  bool loading = false;

  final clientController = Get.find<ClientController>();


  @override
  Widget build(BuildContext context) {
    final diagnostico = clientController.Diagnostico;

    return Obx (() {
      final _ = controller.isDark;
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
                  padding: EdgeInsets.all(8),
                  child: Icon(CupertinoIcons.back),
                ),
              ),

              Text(
                "Diagnóstico",
                style: GoogleFonts.poppins(fontSize: 18),
              ),

              const SizedBox(width: 40), // placeholder para centrar
            ],
          ),

          const SizedBox(height: 15),

          /// ✅ CONTENIDO
          Expanded(
            child: diagnostico == null
                ? Center(child: Text("No hay diagnóstico disponible"))
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ✅ TITULO
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Global.primary, Global.secondary],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      diagnostico["titulo"] ?? "Diagnóstico",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// ✅ PROBLEMA
                  _cardDetalle(
                    title: "Problema identificado",
                    text: diagnostico["problema"]?["detalle"],
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 10),

                  /// ✅ BENEFICIOS
                  _cardDetalle(
                    title: "Beneficio / Oportunidad",
                    text: diagnostico["beneficios"]?["detalle"],
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _cardDetalle({
    required String title,
    required String? text,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// TEXTO
          Text(
            text ?? "Sin información disponible",
            style: TextStyle(
              fontSize: 16,
              height: 1.6, // ✅ mejora lectura
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
