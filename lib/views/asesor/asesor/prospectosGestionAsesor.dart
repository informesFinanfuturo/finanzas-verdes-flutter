
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/models/api/prospectoApi.dart';
import 'package:flutter/material.dart';

class ProspectosGestionAsesor extends StatefulWidget {
  const ProspectosGestionAsesor({super.key});

  @override
  State<ProspectosGestionAsesor> createState() =>
      _ProspectosGestionAsesorState();
}

class _ProspectosGestionAsesorState
    extends State<ProspectosGestionAsesor> {
  final _busqueda = TextEditingController();

  List<Map<String, dynamic>> _prospectos = [];
  String _estado = '';
  String? _error;
  bool _cargando = false;
  bool _procesando = false;
  int _pagina = 1;
  int _total = 0;
  int _paginas = 1;
  int _solicitud = 0;

  static const _estados = <String, String>{
    '': 'Todos los estados',
    'nuevo': 'Nuevo',
    'en_gestion': 'En gestión',
    'agendado': 'Agendado',
    'descartado': 'Descartado',
    'convertido': 'Convertido',
  };

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _solicitud++;
    _busqueda.dispose();
    super.dispose();
  }

  String _mensaje(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> _cargar({int? pagina}) async {
    final solicitudActual = ++_solicitud;
    final siguiente = pagina ?? _pagina;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final data = await listarProspectosManualApi(
        page: siguiente,
        limit: 10,
        search: _busqueda.text.trim(),
        estado: _estado,
      );

      if (!mounted || solicitudActual != _solicitud) return;

      final lista = data['prospectos'] as List? ?? [];
      final pagination = data['pagination'] as Map? ?? {};

      setState(() {
        _prospectos = lista
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        _pagina = siguiente;
        _total = int.tryParse(
          '${pagination['total'] ?? 0}',
        ) ??
            0;
        _paginas = int.tryParse(
          '${pagination['total_pages'] ?? 1}',
        ) ??
            1;
      });
    } catch (e) {
      if (!mounted || solicitudActual != _solicitud) return;
      setState(() => _error = _mensaje(e));
    } finally {
      if (mounted && solicitudActual == _solicitud) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _nuevoProspecto() async {
    final datos = <String, String>{};
    final form = GlobalKey<FormState>();
    bool guardando = false;

    Widget campo(
        String key,
        String label, {
          bool required = false,
          TextInputType? keyboard,
        }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          keyboardType: keyboard,
          onSaved: (v) => datos[key] = v?.trim() ?? '',
          maxLength: key == 'documento' ? 15 : null,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          validator: (value) {
            final text = value?.trim() ?? '';

            if (required && text.isEmpty) {
              return 'Campo obligatorio';
            }

            if (key == 'documento' &&
                !RegExp(r'^\d{5,15}$').hasMatch(text)) {
              return 'Documento de 5 a 15 dígitos';
            }

            if (key == 'correo' &&
                text.isNotEmpty &&
                !RegExp(
                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                ).hasMatch(text)) {
              return 'Correo inválido';
            }

            return null;
          },
        ),
      );
    }

    final creado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateDialog) => AlertDialog(
          title: const Text('Registrar prospecto'),
          scrollable: true,
          content: SizedBox(
            width: 500,
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Información declarada por el interesado. '
                        'Este registro no es una evaluación financiera.',
                  ),
                  const SizedBox(height: 16),
                  campo(
                    'documento',
                    'Documento *',
                    required: true,
                    keyboard: TextInputType.number,
                  ),
                  campo(
                    'nombres',
                    'Nombres *',
                    required: true,
                  ),
                  campo('apellidos', 'Apellidos'),
                  campo(
                    'telefono',
                    'Teléfono',
                    keyboard: TextInputType.phone,
                  ),
                  campo(
                    'correo',
                    'Correo',
                    keyboard: TextInputType.emailAddress,
                  ),
                  campo('nombre_negocio', 'Nombre del negocio'),
                  campo('municipio', 'Municipio'),
                  campo('direccion_negocio', 'Dirección del negocio'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: guardando
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: guardando
                  ? null
                  : () async {
                if (!form.currentState!.validate()) return;

                form.currentState!.save();

                if ((datos['telefono'] ?? '').isEmpty &&
                    (datos['correo'] ?? '').isEmpty) {
                  ScaffoldMessenger.of(dialogContext)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ingresa teléfono o correo.',
                      ),
                    ),
                  );
                  return;
                }

                updateDialog(() => guardando = true);

                try {
                  await registrarProspectoManualApi(
                    datos: datos,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext)
                        .showSnackBar(
                      SnackBar(
                        content: Text(_mensaje(e)),
                      ),
                    );
                  }
                } finally {
                  if (dialogContext.mounted) {
                    updateDialog(() => guardando = false);
                  }
                }
              },
              child: Text(
                guardando ? 'Guardando...' : 'Guardar',
              ),
            ),
          ],
        ),
      ),
    );

    if (!mounted || creado != true) return;

    _avisar('Prospecto registrado correctamente.');
    _cargar(pagina: 1);
  }

  Future<void> _cambiarEstado(
      Map<String, dynamic> item,
      String decision,
      ) async {
    if (_procesando) return;

    final id = int.tryParse('${item['id_prospecto']}');
    if (id == null) return;

    String motivo = '';

    if (decision == 'descartado') {
      String observacion = '';

      final valor = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Descartar prospecto'),
          content: SizedBox(
            width: 440,
            child: TextField(
              onChanged: (v) => observacion = v,
              maxLength: 2000,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo obligatorio',
                hintText:
                'Explica por qué no continuará la gestión',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (observacion.trim().isEmpty) return;

                Navigator.pop(
                  dialogContext,
                  observacion.trim(),
                );
              },
              child: const Text('Confirmar descarte'),
            ),
          ],
        ),
      );

      if (valor == null || valor.isEmpty || !mounted) return;
      motivo = valor;
    }

    setState(() => _procesando = true);

    try {
      await actualizarDecisionProspectoApi(
        idProspecto: id,
        decision: decision,
        motivo: motivo,
      );

      if (!mounted) return;

      _avisar('Estado actualizado correctamente.');
      await _cargar();
    } catch (e) {
      if (mounted) _avisar(_mensaje(e));
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }


  void _verHistorial(
      Map<String, dynamic> prospecto,
      ) {
    final id = int.tryParse(
      '${prospecto['id_prospecto']}',
    );

    if (id == null) return;

    final future = obtenerHistorialProspectoApi(
      idProspecto: id,
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Historial del prospecto',
          ),
          content: SizedBox(
            width: 520,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SizedBox(
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    _mensaje(snapshot.error!),
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  );
                }

                final eventos = snapshot.data ?? [];

                if (eventos.isEmpty) {
                  return const Text(
                    'Este prospecto todavía no tiene eventos.',
                  );
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 420,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: eventos.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final evento = eventos[index];

                      final tipo =
                          '${evento['tipo_evento'] ?? ''}';

                      final detalle =
                      evento['detalle'] is Map
                          ? Map<String, dynamic>.from(
                        evento['detalle'] as Map,
                      )
                          : <String, dynamic>{};

                      String titulo;
                      String descripcion;

                      if (tipo == 'registro_manual') {
                        titulo = 'Registro inicial';
                        descripcion =
                        'Prospecto registrado manualmente.';
                      } else if (tipo == 'cambio_estado') {
                        titulo = 'Cambio de estado';

                        descripcion =
                        '${detalle['anterior'] ?? ''} '
                            '→ ${detalle['nuevo'] ?? ''}';

                        final motivo =
                        '${detalle['motivo'] ?? ''}'.trim();

                        if (motivo.isNotEmpty) {
                          descripcion +=
                          '\nMotivo: $motivo';
                        }
                      } else {
                        titulo = tipo;
                        descripcion =
                        'Evento registrado en el proceso.';
                      }

                      final fecha = DateTime.tryParse(
                        '${evento['created_at'] ?? ''}',
                      );

                      final fechaTexto = fecha == null
                          ? 'Fecha no disponible'
                          : fecha.toLocal().toString()
                          .substring(0, 16);

                      return ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 0,
                        ),
                        leading: const Icon(
                          Icons.history_rounded,
                        ),
                        title: Text(titulo),
                        subtitle: Text(
                          '$descripcion\n'
                              '$fechaTexto\n'
                              'Responsable: '
                              '${evento['registrado_por'] ?? 'No disponible'}',
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }


  Widget _tarjeta(
      Map<String, dynamic> p,
      double width,
      ) {
    final estado = '${p['estado'] ?? 'nuevo'}';
    final disponible =
        estado == 'nuevo' || estado == 'en_gestion';

    String valor(dynamic x) =>
        x == null || '$x'.trim().isEmpty
            ? 'No registrado'
            : '$x';

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Global.text.withOpacity(0.09),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                Global.primary.withOpacity(0.12),
                child: Icon(
                  Icons.person_outline,
                  color: Global.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p['nombres'] ?? ''} '
                          '${p['apellidos'] ?? ''}'
                          .trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Global.text,
                      ),
                    ),
                    Text(
                      'Documento: ${valor(p['documento'])}',
                      style: TextStyle(
                        color: Global.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  _estados[estado] ?? estado,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Negocio: ${valor(p['nombre_negocio'])}',
          ),
          Text(
            'Municipio: ${valor(p['municipio'])}',
          ),
          Text(
            'Contacto: ${valor(p['telefono'] ?? p['correo'])}',
          ),
          const SizedBox(height: 12),
          if (disponible)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (estado == 'nuevo')
                  OutlinedButton.icon(
                    onPressed: _procesando
                        ? null
                        : () => _cambiarEstado(
                      p,
                      'en_gestion',
                    ),
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                    ),
                    label: const Text('Iniciar gestión'),
                  ),
                OutlinedButton.icon(
                  onPressed: _procesando
                      ? null
                      : () => _cambiarEstado(
                    p,
                    'descartado',
                  ),
                  icon: const Icon(
                    Icons.block_outlined,
                    size: 18,
                  ),
                  label: const Text('Descartar'),
                ),
              ],
            ),
          if (!disponible)
            Text(
              'Sin acciones pendientes en esta etapa.',
              style: TextStyle(
                fontSize: 12,
                color: Global.textSecondary,
              ),
            ),


          const SizedBox(height: 10),

          TextButton.icon(
            onPressed: () => _verHistorial(p),
            icon: const Icon(
              Icons.history_rounded,
              size: 18,
            ),
            label: const Text('Ver historial'),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Global.text.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prospectos registrados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Global.text,
                    ),
                  ),
                  Text(
                    'Seguimiento de información '
                        'declarada por el interesado.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Global.textSecondary,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: _nuevoProspecto,
                icon: const Icon(
                  Icons.person_add_alt_1_rounded,
                ),
                label: const Text('Nuevo prospecto'),
                style: FilledButton.styleFrom(
                  backgroundColor: Global.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 650;

              final campo = TextField(
                controller: _busqueda,
                onSubmitted: (_) => _cargar(pagina: 1),
                decoration: InputDecoration(
                  hintText:
                  'Buscar por nombre, documento o negocio',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    tooltip: 'Buscar',
                    onPressed: () => _cargar(pagina: 1),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              );

              final filtro = DropdownButtonFormField<String>(
                key: ValueKey(_estado),
                initialValue: _estado,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  labelText: 'Estado',
                ),
                items: _estados.entries
                    .map(
                      (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  setState(() => _estado = v ?? '');
                  _cargar(pagina: 1);
                },
              );

              if (mobile) {
                return Column(
                  children: [
                    campo,
                    const SizedBox(height: 10),
                    filtro,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: campo),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 210,
                    child: filtro,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (_cargando)
            const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (!_cargando && _error == null) ...[
            Text(
              '$_total prospecto(s) en este resultado',
              style: TextStyle(
                fontSize: 12,
                color: Global.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            if (_prospectos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No hay prospectos para este filtro.',
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 12.0;
                  final ancho = constraints.maxWidth >= 850
                      ? (constraints.maxWidth - gap) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: _prospectos
                        .map((p) => _tarjeta(p, ancho))
                        .toList(),
                  );
                },
              ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Página anterior',
                  onPressed: _pagina > 1
                      ? () => _cargar(
                    pagina: _pagina - 1,
                  )
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Página $_pagina de $_paginas'),
                IconButton(
                  tooltip: 'Página siguiente',
                  onPressed: _pagina < _paginas
                      ? () => _cargar(
                    pagina: _pagina + 1,
                  )
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: () => _cargar(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
