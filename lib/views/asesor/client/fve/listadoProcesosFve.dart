
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/fveApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListadoProcesosFve extends StatefulWidget {
  final int idMipyme;
  final VoidCallback irADiagnosticos;

  const ListadoProcesosFve({
    super.key,
    required this.idMipyme,
    required this.irADiagnosticos,
  });

  @override
  State<ListadoProcesosFve> createState() =>
      _ListadoProcesosFveState();
}

class _ListadoProcesosFveState
    extends State<ListadoProcesosFve> {
  final cliente = Get.find<ClientController>();

  List<Map<String, dynamic>> procesos = [];

  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  void didUpdateWidget(
      covariant ListadoProcesosFve oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (
    oldWidget.idMipyme != widget.idMipyme
    ) {
      cargar();
    }
  }

  Future<void> cargar() async {
    final solicitado = widget.idMipyme;

    if (solicitado < 1) {
      if (mounted) {
        setState(() {
          cargando = false;
          error = 'Selecciona un cliente';
        });
      }
      return;
    }

    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final r = await listarProcesosFveApi(
        idMipyme: solicitado,
      );

      if (
      !mounted ||
          widget.idMipyme != solicitado
      ) {
        return;
      }

      setState(() => procesos = r);

    } catch (e) {
      if (
      mounted &&
          widget.idMipyme == solicitado
      ) {
        setState(() => error = e.toString());
      }

    } finally {
      if (
      mounted &&
          widget.idMipyme == solicitado
      ) {
        setState(() => cargando = false);
      }
    }
  }

  Future<void> abrir(
      Map<String, dynamic> proceso,
      ) async {
    cliente.setProcesoFve(proceso);

    // Índice de Finanzas verdes en el dashboard.
    cliente.setSelectedClientSection(5);

    await controller.setPage(
      AsesorRoutes.procesoFve,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Finanzas verdes',
                style: TextStyle(
                  color: Global.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            IconButton(
              onPressed: cargar,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
            ),
          ],
        ),

        Text(
          'Negociaciones comerciales asociadas '
              'a los diagnósticos del cliente.',
          style: TextStyle(
            color: Global.textSecondary,
          ),
        ),

        const SizedBox(height: 12),

        if (error != null)
          Card(
            child: ListTile(
              title: const Text(
                'No se pudieron cargar las negociaciones',
              ),
              subtitle: Text(error!),
              trailing: TextButton(
                onPressed: cargar,
                child: const Text('Reintentar'),
              ),
            ),
          ),

        if (
        error == null &&
            procesos.isEmpty
        )
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aún no hay negociaciones FVE '
                        'para este cliente.',
                  ),

                  const SizedBox(height: 12),

                  FilledButton.icon(
                    onPressed: widget.irADiagnosticos,
                    icon: const Icon(
                      Icons.fact_check_outlined,
                    ),
                    label: const Text(
                      'Ir a diagnósticos para iniciar una',
                    ),
                  ),
                ],
              ),
            ),
          ),

        for (final p in procesos)
          Card(
            color: Global.container,
            margin: const EdgeInsets.only(bottom: 12),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Negociación verde · '
                        '${p['titulo_diagnostico'] ?? 'Diagnóstico'}',
                    style: TextStyle(
                      color: Global.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Estado: '
                        '${p['estado']?.toString().replaceAll('_', ' ') ?? 'Sin estado'}',
                    style: TextStyle(
                      color: Global.textSecondary,
                    ),
                  ),

                  Text(
                    'Próxima actividad: '
                        '${p['paso_actual'] == 2 ? 'Revisar alternativas' : 'Continuar el proceso'}',
                    style: TextStyle(
                      color: Global.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  FilledButton.icon(
                    onPressed: () => abrir(p),
                    icon: const Icon(
                      Icons.arrow_forward,
                    ),
                    label: const Text(
                      'Continuar negociación',
                    ),
                  ),

                  Text(
                    'Referencia interna #${p['id_proceso']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Global.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
