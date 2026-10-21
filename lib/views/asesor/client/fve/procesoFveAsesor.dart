
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/fveApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Procesofveasesor extends StatefulWidget {
  const Procesofveasesor({super.key});

  @override
  State<Procesofveasesor> createState() =>
      _ProcesofveasesorState();
}

class _ProcesofveasesorState
    extends State<Procesofveasesor> {
  final cliente = Get.find<ClientController>();

  bool cargando = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) => recargar(),
    );
  }

  Future<void> recargar() async {
    final id = int.tryParse(
      '${cliente.ProcesoFve['id_proceso'] ?? ''}',
    );

    if (id == null || cargando) return;

    setState(() => cargando = true);

    try {
      final p = await obtenerProcesoFveApi(
        idProceso: id,
      );

      cliente.setProcesoFve(p);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }

    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = cliente.ProcesoFve;

      final empresa =
          '${p['nombre_mipyme'] ?? cliente.Client['mipyme']?['nombre_mipyme'] ?? 'Cliente'}';

      final paso = int.tryParse(
        '${p['paso_actual'] ?? 2}',
      ) ??
          2;

      final estado =
      '${p['estado'] ?? 'en_preparacion'}'
          .replaceAll('_', ' ');

      return Column(
        children: [
          Container(
            color: Global.container,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),

            child: Row(
              children: [
                IconButton(
                  onPressed: controller.backPage,
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Negociación verde · $empresa',
                    style: TextStyle(
                      color: Global.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: cargando
                      ? null
                      : recargar,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  tooltip: 'Actualizar',
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Card(
                  color: Global.container,

                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Negociación en $estado',
                          style: TextStyle(
                            color: Global.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Avance del proceso: etapa $paso de 9',
                          style: TextStyle(
                            color: Global.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value: paso.clamp(0, 9) / 9,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Diagnóstico de origen: '
                              '${p['titulo_diagnostico'] ?? 'Registrado'}',
                          style: TextStyle(
                            color: Global.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  color: Global.container,

                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Siguiente actividad: revisar alternativas',
                          style: TextStyle(
                            color: Global.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Esta actividad se habilitará '
                              'en la Entrega 04. '
                              'El proceso ya está registrado '
                              'y puede retomarse desde la '
                              'pestaña Finanzas verdes '
                              'del dashboard.',
                          style: TextStyle(
                            color: Global.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 10),

                        OutlinedButton.icon(
                          onPressed: controller.backPage,
                          icon: const Icon(
                            Icons.arrow_back,
                          ),
                          label: const Text('Volver'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Referencia interna del proceso: '
                      '${p['id_proceso'] ?? '-'}',
                  style: TextStyle(
                    color: Global.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
