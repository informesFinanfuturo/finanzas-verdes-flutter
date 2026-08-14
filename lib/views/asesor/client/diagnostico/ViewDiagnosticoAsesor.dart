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
import 'package:finanzas_verdes/views/asesor/client/diagnostico/mostrarModalDecisionDiagnosticoAsesor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Viewdiagnosticoasesor extends StatefulWidget {
  const Viewdiagnosticoasesor({super.key});

  @override
  State<Viewdiagnosticoasesor> createState() => _ViewdiagnosticoasesorState();
}

class _ViewdiagnosticoasesorState extends State<Viewdiagnosticoasesor> {

  bool loading = false;

  final clientController = Get.find<ClientController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(clientController.Diagnostico);
  }


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
            child: diagnostico.isEmpty
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
                    child: SelectableText(
                      diagnostico["titulo"] ?? "Diagnóstico",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Global.container,
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: const [
                            Icon(
                              Icons.analytics_outlined,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Resumen Ejecutivo",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 15),

                        SelectableText(
                          diagnostico["problema"]?["resumen"] ??
                              "",
                          style: const TextStyle(
                            height: 1.5,
                            fontSize: 15,
                          ),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [

                      _metricCard(
                        "Ahorro mensual",
                        formatCurrency(
                          diagnostico["metricas"]?[
                          "ahorro_economico_mensual"
                          ] ?? 0,
                        ),
                        Icons.savings,
                        Colors.green,
                      ),

                      _metricCard(
                        "Inversión",
                        formatCurrency(
                          diagnostico["metricas"]?[
                          "inversion_total_requerida"
                          ] ?? 0,
                        ),
                        Icons.payments,
                        Colors.orange,
                      ),

                      _metricCard(
                        "ROI 5 años",
                        "${(diagnostico["metricas"]?["roi"] ?? 0).toStringAsFixed(1)}%",
                        Icons.trending_up,
                        Colors.purple,
                      ),

                      _metricCard(
                        "Payback",
                        "${(diagnostico["metricas"]?["payback"] ?? 0).toStringAsFixed(1)} meses",
                        Icons.schedule,
                        Colors.blue,
                      ),

                      _metricCard(
                        "Energía reducida",
                        "${(diagnostico["metricas"]?["reduccion_energia"] ?? 0).toStringAsFixed(1)} kWh",
                        Icons.bolt,
                        Colors.amber,
                      ),

                      _metricCard(
                        "Agua reducida",
                        "${(diagnostico["metricas"]?["reduccion_agua"] ?? 0).toStringAsFixed(1)} m³",
                        Icons.water_drop,
                        Colors.lightBlue,
                      ),

                      _metricCard(
                        "CO₂ evitado",
                        "${(diagnostico["metricas"]?["reduccion_carbono"] ?? 0).toStringAsFixed(1)} kg",
                        Icons.eco,
                        Colors.teal,
                      ),

                      _metricCard(
                        "Activos",
                        "${diagnostico["metricas"]?["activos"]?.length ?? 0}",
                        Icons.inventory_2_outlined,
                        Global.primary,
                      ),

                    ],
                  ),


                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: (

                        (diagnostico["metricas"]?["activos"]
                            ?? [])
                        as List

                    ).map((activo) {

                      final metricas =
                          activo["metricas"] ?? {};

                      return Container(

                        width: 420,

                        padding:
                        const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius:
                          BorderRadius.circular(18),
                          border: Border.all(
                            color: Global.primary
                                .withOpacity(.15),
                          ),
                        ),

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Row(

                              children: [

                                CircleAvatar(
                                  backgroundColor:
                                  Global.primary
                                      .withOpacity(.1),
                                  child: Icon(
                                    Icons.devices,
                                    color:
                                    Global.primary,
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [

                                      Text(
                                        activo[
                                        "nombre_activo"] ??
                                            "",
                                        style:
                                        const TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                        ),
                                      ),

                                      Text(
                                        "Prioridad ${activo["prioridad"]}",
                                      ),

                                    ],
                                  ),
                                ),

                                Chip(
                                  label: Text(
                                    activo["confianza"]
                                    ?["nivel"] ??
                                        "",
                                  ),
                                ),

                              ],

                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            _miniMetric(
                              "Ahorro",
                              formatCurrency(
                                metricas[
                                "ahorro_economico_mensual"] ??
                                    0,
                              ),
                            ),

                            _miniMetric(
                              "ROI 5 años",
                              metricas["roi_5_anios"] ==
                                  null
                                  ? "-"
                                  : "${metricas["roi_5_anios"].toStringAsFixed(1)}%",
                            ),

                            _miniMetric(
                              "Reducción energía",
                              metricas[
                              "reduccion_energia"] ==
                                  null
                                  ? "-"
                                  : "${metricas["reduccion_energia"].toStringAsFixed(1)} kWh",
                            ),

                            _miniMetric(
                              "Reducción agua",
                              metricas[
                              "reduccion_agua"] ==
                                  null
                                  ? "-"
                                  : "${metricas["reduccion_agua"].toStringAsFixed(1)} m³",
                            ),

                            _miniMetric(
                              "Reducción CO₂",
                              metricas[
                              "reduccion_carbono"] ==
                                  null
                                  ? "-"
                                  : "${metricas["reduccion_carbono"].toStringAsFixed(1)} kg",
                            ),

                            _miniMetric(
                              "Inversión",
                              formatCurrency(
                                metricas[
                                "inversion_total_requerida"] ??
                                    0,
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            Text(
                              activo["confianza"]
                              ?["motivo"] ??
                                  "",
                              style:
                              TextStyle(
                                color: Colors
                                    .grey.shade600,
                                height: 1.4,
                              ),
                            ),

                          ],

                        ),

                      );

                    }).toList(),
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

                  SizedBox(height: 10,),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Global.container,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Global.primary.withOpacity(.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: const [

                            Icon(
                              Icons.handshake_outlined,
                              color: Colors.green,
                            ),

                            SizedBox(width: 10),

                            Text(
                              "Decisión del cliente",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 15),

                        Text(
                          "Después de revisar el diagnóstico con el cliente, registra la decisión tomada para continuar el proceso.",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [

                            ElevatedButton.icon(
                              onPressed: () {
                                mostrarModalDecision(
                                    "confirmar", context
                                );
                              },
                              icon: const Icon(
                                Icons.check_circle,
                              ),
                              label: const Text(
                                "Continuar proceso",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.green,
                                foregroundColor:
                                Colors.white,
                              ),
                            ),

                            ElevatedButton.icon(
                              onPressed: () {
                                mostrarModalDecision(
                                    "posponer", context
                                );
                              },
                              icon: const Icon(
                                Icons.schedule,
                              ),
                              label: const Text(
                                "Posponer",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.orange,
                                foregroundColor:
                                Colors.white,
                              ),
                            ),

                            ElevatedButton.icon(
                              onPressed: () {
                                mostrarModalDecision("cancelar", context);
                              },
                              icon: const Icon(
                                Icons.cancel,
                              ),
                              label: const Text(
                                "No continuar",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.red,
                                foregroundColor:
                                Colors.white,
                              ),
                            ),

                          ],
                        ),

                      ],
                    ),
                  ),

                  SizedBox(height: 10,),
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
              SelectableText(
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
          SelectableText(
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

  Widget _metricCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {

    return Container(

      width: 220,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Global.container,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(.2),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            color: color,
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

        ],
      ),

    );

  }

  Widget _miniMetric(
      String nombre,
      String valor,
      ) {

    return Padding(

      padding:
      const EdgeInsets.symmetric(
        vertical: 4,
      ),

      child: Row(

        children: [

          Expanded(
            child: Text(
              nombre,
              style: TextStyle(
                color:
                Colors.grey.shade600,
              ),
            ),
          ),

          Text(
            valor,
            style: const TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),

        ],

      ),

    );

  }

  String formatCurrency(
      dynamic value,
      ) {

    final number =
    (value ?? 0).toDouble();

    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$ ',
      decimalDigits: 0,
    ).format(number);

  }
}
