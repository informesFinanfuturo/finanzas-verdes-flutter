import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/models/api/diagnosticoApi.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

Future<Map<String, dynamic>?>
mostrarSelectorAlternativaDiagnostico({
  required BuildContext context,
  required int idDiagnostico,
  required int idActivo,
  Map<String, dynamic>? seleccionActual,
}) async {

  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return _SelectorAlternativaDialog(
        idDiagnostico: idDiagnostico,
        idActivo: idActivo,
        seleccionActual: seleccionActual,
      );
    },
  );
}

class _SelectorAlternativaDialog
    extends StatefulWidget {

  final int idDiagnostico;
  final int idActivo;

  final Map<String, dynamic>?
  seleccionActual;

  const _SelectorAlternativaDialog({
    required this.idDiagnostico,
    required this.idActivo,
    this.seleccionActual,
  });

  @override
  State<_SelectorAlternativaDialog>
  createState() =>
      _SelectorAlternativaDialogState();
}

class _SelectorAlternativaDialogState
    extends State<_SelectorAlternativaDialog> {

  final TextEditingController
  _searchController =
  TextEditingController();

  bool _loading = true;

  String? _error;

  Map<String, dynamic> _activo = {};

  List<Map<String, dynamic>>
  _alternativas = [];

  // FVE_ALTERNATIVA_TRAZABLE_V1: preseleccion visual, no aprobacion comercial.
  Map<String, dynamic>? _sugerenciaIA;

  Map<String, dynamic>?
  _alternativaSeleccionada;

  String? _proveedorSeleccionado;

  late int _idActivoConsulta;
  Map<String, dynamic>? _vinculoPendiente;
  Map<String, dynamic>? _diagnosticoReparado;

  @override
  void initState() {
    super.initState();
    _idActivoConsulta = widget.idActivo;
    _cargarAlternativas();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _cargarAlternativas() async {

    setState(() {
      _loading = true;
      _error = null;
      _vinculoPendiente = null;
    });

    try {

      final response =
      await getAlternativasActivoDiagnosticoApi(
        idDiagnostico:
        widget.idDiagnostico,

        idActivo:
        _idActivoConsulta,
      );

      if (response['codigo'] == 'ACTIVO_SIN_VINCULO') {
        if (mounted) {
          setState(() {
            _vinculoPendiente = response;
            _loading = false;
          });
        }
        return;
      }

      final activoResponse =
      response["activo"];

      final alternativasResponse =
      response["alternativas"];

      final alternativas =
      alternativasResponse is List
          ? alternativasResponse
          .whereType<Map>()
          .map(
            (item) =>
        Map<String, dynamic>.from(
          item,
        ),
      )
          .toList()
          : <Map<String, dynamic>>[];

      Map<String, dynamic>?
      seleccionEncontrada;

      final idSeleccionado =
      _toInt(
        widget.seleccionActual?["id_item"],
      );

      final sugerenciaRaw = response['sugerencia_ia'];
      final sugerencia = sugerenciaRaw is Map
          ? Map<String, dynamic>.from(sugerenciaRaw) : null;
      final idSugerido = _toInt(sugerencia?['id_item']);
      // Una seleccion humana existente prevalece. Si no existe, se
      // destaca la opcion del diagnostico (sin persistirla).
      final idInicial = idSeleccionado ?? idSugerido;
      if (idInicial != null) {
        for (final alternativa
        in alternativas) {

          if (
          _toInt(
            alternativa["id_item"],
          ) ==
              idInicial
          ) {
            seleccionEncontrada =
                alternativa;

            break;
          }
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _activo =
        activoResponse is Map
            ? Map<String, dynamic>.from(
          activoResponse,
        )
            : {};

        _alternativas =
            alternativas;

        _sugerenciaIA = sugerencia;
        _alternativaSeleccionada =
            seleccionEncontrada;

        _loading = false;
      });

    } catch (error) {

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;

        _error =
            error
                .toString()
                .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  List<Map<String, dynamic>>
  get _alternativasFiltradas {

    final search =
    _searchController
        .text
        .trim()
        .toLowerCase();

    return _alternativas.where(
          (alternativa) {

        final proveedor =
        _nombreProveedor(
          alternativa,
        );

        final coincideProveedor =
            _proveedorSeleccionado ==
                null ||
                proveedor ==
                    _proveedorSeleccionado;

        final text = [
          alternativa["nombre"],
          alternativa["tipo_item"],
          alternativa["descripcion"],
          proveedor,
        ]
            .whereType<Object>()
            .map(
              (value) =>
              value
                  .toString()
                  .toLowerCase(),
        )
            .join(' ');

        final coincideBusqueda =
            search.isEmpty ||
                text.contains(search);

        return coincideProveedor &&
            coincideBusqueda;
      },
    ).toList();
  }

  List<String> get _proveedores {

    final proveedores =
    _alternativas
        .map(_nombreProveedor)
        .where(
          (nombre) =>
      nombre.isNotEmpty,
    )
        .toSet()
        .toList();

    proveedores.sort();

    return proveedores;
  }

  @override
  Widget build(BuildContext context) {

    final size =
    MediaQuery.sizeOf(context);

    final isMobile =
        size.width < 700;

    return Dialog(
      insetPadding:
      EdgeInsets.symmetric(
        horizontal:
        isMobile ? 10 : 40,
        vertical:
        isMobile ? 12 : 28,
      ),
      backgroundColor:
      Colors.transparent,
      child: Container(
        width: isMobile ? size.width : 980,
        height:
        isMobile
            ? size.height * .94
            : size.height * .86,
        decoration: BoxDecoration(
          color: Global.absolute.withOpacity(0.9),
          borderRadius:
          BorderRadius.circular(
            isMobile ? 20 : 24,
          ),
          border: Border.all(
            color:
            Global.text
                .withOpacity(.08),
          ),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black
                  .withOpacity(.15),
              blurRadius: 30,
              offset:
              const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior:
        Clip.antiAlias,
        child: Column(
          children: [
            _buildHeader(
              isMobile,
            ),

            Divider(
              height: 1,
              color:
              Global.text
                  .withOpacity(.08),
            ),

            Expanded(
              child:
              _buildContent(
                isMobile,
              ),
            ),

            Divider(
              height: 1,
              color:
              Global.text
                  .withOpacity(.08),
            ),

            _buildFooter(
              isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Map<String,dynamic>? _resultadoCierre() {
    if (_diagnosticoReparado == null) return null;
    return {
      'solo_vinculo': true,
      'id_activo_resuelto': _idActivoConsulta,
      'diagnostico_actualizado': _diagnosticoReparado,
    };
  }

  Widget _buildHeader(
      bool isMobile,
      ) {

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 17 : 24,
        isMobile ? 17 : 22,
        isMobile ? 12 : 18,
        isMobile ? 15 : 20,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
              Global.primary
                  .withOpacity(.11),
              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              Icons.compare_arrows_rounded,
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
                  'Comparar alternativas',
                  style:
                  GoogleFonts.poppins(
                    fontSize:
                    isMobile
                        ? 16
                        : 18,
                    fontWeight:
                    FontWeight.w600,
                    color: Global.text,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _activo.isEmpty
                      ? 'Selecciona un producto y proveedor.'
                      : '${_activo["nombre"] ?? "Activo"} · '
                      '${_activo["tipo"] ?? "Sin categoría"}',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 11,
                    color:
                    Global
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Cerrar',
            onPressed: () {
              Navigator.of(context).pop(_resultadoCierre());
            },
            icon: Icon(
              Icons.close_rounded,
              color: Global.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      bool isMobile,
      ) {

    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Global.primary,
            ),

            const SizedBox(height: 15),

            Text(
              'Consultando productos disponibles...',
              style:
              GoogleFonts.poppins(
                fontSize: 12,
                color:
                Global.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildError();
    }
    if (_vinculoPendiente != null) {
      return _buildVinculoPendiente();
    }

    return Column(
      children: [
        _buildFilters(
          isMobile,
        ),
        if (_sugerenciaIA != null) _buildAvisoSugerencia(),

        Expanded(
          child:
          _buildAlternatives(),
        ),
      ],
    );
  }

  Future<void> _vincularActivo({int? idReal, bool crear = false}) async {
    final nombre = _vinculoPendiente?['activo_diagnostico']?['nombre']?.toString() ?? 'este activo';
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(crear ? 'Registrar activo' : 'Vincular activo'),
        content: Text(crear
          ? 'Se registrara "$nombre" en el inventario de esta empresa. Confirma que el equipo existe realmente. Sus datos tecnicos quedaran pendientes.'
          : 'Confirma que este equipo del inventario corresponde al activo "$nombre" del diagnostico. Se conservara la referencia anterior.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final resultado = await vincularActivoDiagnosticoApi(
        idDiagnostico: widget.idDiagnostico,
        idActivoOriginal: widget.idActivo,
        idActivoReal: idReal,
        crearDesdeDiagnostico: crear,
      );
      if (!mounted) return;
      final nuevoId = _toInt(resultado['id_activo_real']);
      if (nuevoId == null) throw Exception('La API no devolvio un activo valido.');
      _idActivoConsulta = nuevoId;
      if (resultado['diagnostico'] is Map) {
        _diagnosticoReparado=Map<String,dynamic>.from(resultado['diagnostico']);
      }
      await _cargarAlternativas();
    } catch (e) {
      if(!mounted) return;
      setState(() {
        _loading=false;
        _error=e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _buildVinculoPendiente() {
    final datos = _vinculoPendiente!;
    final opcionesRaw = datos['opciones'];
    final opciones = opcionesRaw is List
      ? opcionesRaw.whereType<Map>().map((a)=>Map<String,dynamic>.from(a)).toList()
      : <Map<String,dynamic>>[];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_off_rounded, color: Global.primary, size: 36),
              const SizedBox(height: 12),
              Text('Vincular activo al inventario',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 17,
                  fontWeight: FontWeight.w600, color: Global.text)),
              const SizedBox(height: 8),
              Text('El diagnostico conserva este equipo, pero su identificador ya no corresponde al inventario vigente. Elige el activo correcto o registralo si realmente falta.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 11,color: Global.textSecondary)),
              const SizedBox(height: 18),
              if (opciones.isNotEmpty) ...[
                Align(alignment: Alignment.centerLeft,
                  child: Text('Equipos de esta empresa con la misma categoria',
                    style: GoogleFonts.poppins(fontSize: 12,fontWeight: FontWeight.w600,color: Global.text))),
                const SizedBox(height: 8),
                ...opciones.map((opcion) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _toInt(opcion['id_activo']) == null ? null
                        : () => _vincularActivo(idReal: _toInt(opcion['id_activo'])),
                      icon: const Icon(Icons.link_rounded, size: 17),
                      label: Text("${opcion['nombre'] ?? 'Activo'}  •  #${opcion['id_activo']}",
                        overflow: TextOverflow.ellipsis),
                    ),
                  ),
                )),
              ],
              if (datos['puede_registrar'] == true) ...[
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: () => _vincularActivo(crear: true),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('El equipo no existe: registrarlo en el inventario'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(
      bool isMobile,
      ) {

    final searchField =
    TextField(
      controller:
      _searchController,

      onChanged: (_) {
        setState(() {});
      },

      style:
      GoogleFonts.poppins(
        fontSize: 12,
        color: Global.text,
      ),

      decoration: InputDecoration(
        hintText:
        'Buscar producto o proveedor',

        hintStyle:
        GoogleFonts.poppins(
          fontSize: 12,
          color:
          Global.textSecondary,
        ),

        prefixIcon:
        Icon(
          Icons.search_rounded,
          color:
          Global.textSecondary,
        ),

        suffixIcon:
        _searchController
            .text
            .isEmpty
            ? null
            : IconButton(
          tooltip:
          'Limpiar búsqueda',
          onPressed: () {
            _searchController
                .clear();

            setState(() {});
          },
          icon:
          const Icon(
            Icons.close_rounded,
          ),
        ),

        filled: true,

        fillColor:
        Global.text
            .withOpacity(.035),

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            13,
          ),
          borderSide:
          BorderSide.none,
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            13,
          ),
          borderSide:
          BorderSide(
            color:
            Global.text
                .withOpacity(.08),
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            13,
          ),
          borderSide:
          BorderSide(
            color:
            Global.primary,
            width: 1.3,
          ),
        ),
      ),
    );

    final providerField =
    DropdownButtonFormField<String>(
      value:
      _proveedorSeleccionado,

      isExpanded: true,

      decoration:
      InputDecoration(
        labelText:
        'Proveedor',

        labelStyle:
        GoogleFonts.poppins(
          fontSize: 11,
          color:
          Global.textSecondary,
        ),

        prefixIcon:
        Icon(
          Icons.storefront_outlined,
          color:
          Global.textSecondary,
        ),

        filled: true,

        fillColor:
        Global.text
            .withOpacity(.035),

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            13,
          ),
          borderSide:
          BorderSide.none,
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            13,
          ),
          borderSide:
          BorderSide(
            color:
            Global.text
                .withOpacity(.08),
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            13,
          ),
          borderSide:
          BorderSide(
            color:
            Global.primary,
          ),
        ),
      ),

      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text(
            'Todos los proveedores',
          ),
        ),

        ..._proveedores.map(
              (proveedor) =>
              DropdownMenuItem<String>(
                value: proveedor,
                child: Text(
                  proveedor,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),
        ),
      ],

      onChanged: (value) {
        setState(() {
          _proveedorSeleccionado =
              value;
        });
      },
    );

    return Padding(
      padding:
      EdgeInsets.all(
        isMobile ? 14 : 20,
      ),
      child: isMobile
          ? Column(
        children: [
          searchField,
          const SizedBox(
            height: 10,
          ),
          providerField,
        ],
      )
          : Row(
        children: [
          Expanded(
            flex: 3,
            child: searchField,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            flex: 2,
            child:
            providerField,
          ),
        ],
      ),
    );
  }

  // FVE_REFERENCIA_CONSUMO_IA_V1: referencia textual de producto, no metrica evaluada.
  Widget _buildAvisoSugerencia() {
    final s = _sugerenciaIA!;
    final energia = s['consumo_energia_proyectado_mes'];
    final agua = s['consumo_agua_proyectado_mes'];
    final dato = energia is num ? '${energia.toString().replaceAll('.', ',')} kWh/mes'
        : agua is num ? '${agua.toString().replaceAll('.', ',')} m³/mes'
        : null;
    final referencia = s['consumo_referencia_ia'];
    final referenciaValor = referencia is Map ? referencia['valor'] : null;
    final referenciaTexto = referenciaValor is num
        ? '${referenciaValor.toString().replaceAll('.', ',')} kWh/mes' : null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Global.primary.withOpacity(.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Global.primary.withOpacity(.20)),
      ),
      child: Row(children: [
        Icon(Icons.auto_awesome_rounded, color: Global.primary, size: 19),
        const SizedBox(width: 10),
        Expanded(child: Text(
          'Sugerencia del diagnóstico: ${s['nombre'] ?? 'Producto'}.'
          '${dato == null ? '' : ' Proyección del diagnóstico: $dato.'}'
          '${referenciaTexto == null ? '' : ' Consumo citado como referencia: $referenciaTexto (sin verificación independiente).'}'
          ' Revisa el producto y confirma tu elección. No hay ahorro verificable sin línea base.'
          '${s['origen'] == 'modelo_unico_precio_actualizado' ? ' El precio del catálogo ha cambiado.' : ''}',
          style: GoogleFonts.poppins(fontSize: 10.5, color: Global.text),
          maxLines: 5, overflow: TextOverflow.ellipsis,
        )),
      ]),
    );
  }

  Widget _buildAlternatives() {

    final alternativas =
        _alternativasFiltradas;

    if (_alternativas.isEmpty) {
      return _buildEmpty(
        title:
        'No hay alternativas disponibles',
        description:
        'El catálogo no contiene productos disponibles para el tipo de activo seleccionado.',
      );
    }

    if (alternativas.isEmpty) {
      return _buildEmpty(
        title:
        'No encontramos coincidencias',
        description:
        'Cambia el proveedor o los términos de búsqueda.',
      );
    }

    return LayoutBuilder(
      builder:
          (context, constraints) {

        final columns =
        constraints.maxWidth >= 850
            ? 3
            : constraints.maxWidth >=
            560
            ? 2
            : 1;

        const spacing = 12.0;

        final cardWidth =
            (constraints.maxWidth -
                28 -
                (
                    spacing *
                        (columns - 1)
                ))
                /
                columns;

        return SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            14,
            2,
            14,
            18,
          ),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children:
            alternativas.map(
                  (alternativa) {

                return SizedBox(
                  width: cardWidth,
                  child:
                  _buildAlternativeCard(
                    alternativa,
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAlternativeCard(
      Map<String, dynamic>
      alternativa,
      ) {

    final idItem =
    _toInt(
      alternativa["id_item"],
    );

    final selected =
        idItem != null &&
            idItem ==
                _toInt(
                  _alternativaSeleccionada?[
                  "id_item"],
                );

    final recomendadaPorDiagnostico = idItem != null &&
        idItem == _toInt(_sugerenciaIA?['id_item']);
    final proveedor =
    _nombreProveedor(
      alternativa,
    );

    final especificaciones =
    _specificationEntries(
      alternativa["especificaciones"],
    );

    return Semantics(
      button: true,
      selected: selected,
      label:
      '${alternativa["nombre"] ?? "Producto"} de $proveedor',
      child: InkWell(
        onTap: () {
          setState(() {
            _alternativaSeleccionada =
                alternativa;
          });
        },
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        child: AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 180,
          ),
          padding:
          const EdgeInsets.all(
            15,
          ),
          decoration:
          BoxDecoration(
            color: selected
                ? Global.primary
                .withOpacity(.075)
                : Global.text
                .withOpacity(.025),

            borderRadius:
            BorderRadius.circular(
              17,
            ),

            border: Border.all(
              color: selected
                  ? Global.primary
                  : Global.text
                  .withOpacity(.09),

              width:
              selected
                  ? 1.5
                  : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration:
                    BoxDecoration(
                      color:
                      Global.primary
                          .withOpacity(
                        .11,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        11,
                      ),
                    ),
                    child: Icon(
                      Icons
                          .inventory_2_outlined,
                      color:
                      Global.primary,
                      size: 20,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Text(
                      alternativa[
                      "nombre"]
                          ?.toString() ??
                          'Producto sin nombre',
                      maxLines: 2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts
                          .poppins(
                        fontSize: 13,
                        fontWeight:
                        FontWeight
                            .w600,
                        color:
                        Global.text,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  AnimatedContainer(
                    duration:
                    const Duration(
                      milliseconds:
                      180,
                    ),
                    width: 25,
                    height: 25,
                    decoration:
                    BoxDecoration(
                      color: selected
                          ? Global.primary
                          : Colors
                          .transparent,
                      shape:
                      BoxShape.circle,
                      border:
                      Border.all(
                        color: selected
                            ? Global
                            .primary
                            : Global.text
                            .withOpacity(
                          .23,
                        ),
                      ),
                    ),
                    child: selected
                        ? const Icon(
                      Icons
                          .check_rounded,
                      size: 16,
                      color:
                      Colors.white,
                    )
                        : null,
                  ),
                ],
              ),

              if (recomendadaPorDiagnostico) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.auto_awesome_rounded, color: Global.primary, size: 13),
                  const SizedBox(width: 5),
                  Expanded(child: Text('Sugerida por el diagnóstico',
                    style: GoogleFonts.poppins(fontSize: 10, color: Global.primary,
                      fontWeight: FontWeight.w600))),
                ]),
              ],
              const SizedBox(
                height: 13,
              ),

              _infoLine(
                icon:
                Icons.storefront_outlined,
                label:
                proveedor.isEmpty
                    ? 'Proveedor no informado'
                    : proveedor,
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                _formatCurrency(
                  alternativa[
                  "precio_base"],
                ),
                style:
                GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Global.primary,
                ),
              ),

              if (
              alternativa["descripcion"]
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
                  true
              ) ...[
                const SizedBox(
                  height: 9,
                ),

                Text(
                  alternativa[
                  "descripcion"]
                      .toString(),
                  maxLines: 3,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  GoogleFonts
                      .poppins(
                    fontSize: 10.5,
                    height: 1.45,
                    color:
                    Global
                        .textSecondary,
                  ),
                ),
              ],

              if (
              especificaciones
                  .isNotEmpty
              ) ...[
                const SizedBox(
                  height: 12,
                ),

                Divider(
                  height: 1,
                  color:
                  Global.text
                      .withOpacity(.07),
                ),

                const SizedBox(
                  height: 10,
                ),

                ...especificaciones
                    .take(3)
                    .map(
                      (entry) =>
                      Padding(
                        padding:
                        const EdgeInsets
                            .only(
                          bottom: 5,
                        ),
                        child:
                        _specificationLine(
                          entry.key,
                          entry.value,
                        ),
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoLine({
    required IconData icon,
    required String label,
  }) {

    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color:
          Global.textSecondary,
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            GoogleFonts.poppins(
              fontSize: 10.5,
              color:
              Global.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _specificationLine(
      String label,
      dynamic value,
      ) {

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            _humanize(label),
            style:
            GoogleFonts.poppins(
              fontSize: 9.5,
              color:
              Global.textSecondary,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Text(
            value?.toString() ?? '-',
            textAlign:
            TextAlign.right,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style:
            GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight:
              FontWeight.w500,
              color: Global.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty({
    required String title,
    required String description,
  }) {

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .inventory_2_outlined,
              size: 44,
              color:
              Global.primary
                  .withOpacity(.65),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              title,
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.poppins(
                fontSize: 15,
                fontWeight:
                FontWeight.w600,
                color: Global.text,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              description,
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.poppins(
                fontSize: 11,
                height: 1.5,
                color:
                Global
                    .textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 44,
              color:
              Color(0xFFD74C4C),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              'No fue posible cargar las alternativas',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.poppins(
                fontSize: 15,
                fontWeight:
                FontWeight.w600,
                color: Global.text,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              _error ??
                  'Inténtalo nuevamente.',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.poppins(
                fontSize: 11,
                color:
                Global
                    .textSecondary,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            OutlinedButton.icon(
              onPressed:
              _cargarAlternativas,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Reintentar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isMobile,) {

    final cancelButton =
    OutlinedButton(
      onPressed: () {
        Navigator.of(context).pop(_resultadoCierre());
      },
      style:
      OutlinedButton.styleFrom(
        foregroundColor:
        Global.text,

        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),

        side: BorderSide(
          color:
          Global.text
              .withOpacity(.16),
        ),

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
      ),
      child:
      const Text('Cancelar'),
    );

    final selectButton =
    FilledButton.icon(
      onPressed:
      _alternativaSeleccionada ==
          null
          ? null
          : () {
        final resultado =
        Map<String, dynamic>.from(
          _alternativaSeleccionada!,
        );

        if (_toInt(resultado['id_item']) == _toInt(_sugerenciaIA?['id_item']) &&
            _sugerenciaIA != null) {
          // Proyeccion perteneciente UNICAMENTE al producto recomendado.
          // FVE_METRICAS_ALTERNATIVA_V1: si la API ya adjunto una proyeccion al producto
          // coincidente, nunca sustituir un numero por un null del resumen.
          final proyeccionProductoRaw = resultado['proyeccion_ia'];
          final proyeccionProducto = proyeccionProductoRaw is Map
              ? Map<String, dynamic>.from(proyeccionProductoRaw) : <String, dynamic>{};
          resultado['proyeccion_ia'] = {
            'consumo_energia_proyectado_mes':
                proyeccionProducto['consumo_energia_proyectado_mes'] ??
                _sugerenciaIA!['consumo_energia_proyectado_mes'],
            'consumo_agua_proyectado_mes':
                proyeccionProducto['consumo_agua_proyectado_mes'] ??
                _sugerenciaIA!['consumo_agua_proyectado_mes'],
          };
          resultado['origen_recomendacion'] =
              resultado['origen_recomendacion'] ?? _sugerenciaIA!['origen'];
          resultado['consumo_referencia_ia'] =
              resultado['consumo_referencia_ia'] ?? _sugerenciaIA!['consumo_referencia_ia'];
        }
        resultado['id_activo_resuelto'] = _idActivoConsulta;
        if (_diagnosticoReparado != null) {
          resultado['diagnostico_actualizado'] = _diagnosticoReparado;
        }

        resultado[
        "cantidad_activo"
        ] =
            _activo["cantidad"] ??
                resultado[
                "cantidad_activo"
                ] ??
                1;

        Navigator.of(
          context,
        ).pop(
          resultado,
        );
      },

      style:
      FilledButton.styleFrom(
        backgroundColor:
        Global.primary,

        foregroundColor:
        Colors.white,

        padding:
        const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 15,
        ),

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
      ),

      icon:
      const Icon(
        Icons.check_rounded,
        size: 18,
      ),

      label:
      const Text(
        'Elegir alternativa',
      ),
    );

    return Padding(
      padding:
      EdgeInsets.all(
        isMobile ? 14 : 18,
      ),
      child: isMobile
          ? Row(
        children: [
          Expanded(
            child: cancelButton,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: selectButton,
          ),
        ],
      )
          : Row(
        mainAxisAlignment:
        MainAxisAlignment.end,
        children: [
          cancelButton,

          const SizedBox(
            width: 10,
          ),

          selectButton,
        ],
      ),
    );
  }

  String _nombreProveedor(
      Map<String, dynamic>
      alternativa,
      ) {

    final proveedor =
    alternativa["proveedor"];

    if (proveedor is Map) {
      return proveedor["nombre"]
          ?.toString()
          .trim() ??
          '';
    }

    return '';
  }

  List<MapEntry<String, dynamic>>
  _specificationEntries(
      dynamic value,
      ) {

    if (value is Map) {
      return value.entries
          .where(
            (entry) =>
        entry.value != null &&
            entry.value
                .toString()
                .trim()
                .isNotEmpty,
      )
          .map(
            (entry) =>
            MapEntry(
              entry.key.toString(),
              entry.value,
            ),
      )
          .toList();
    }

    return [];
  }

  int? _toInt(
      dynamic value,
      ) {

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  String _humanize(
      String value,
      ) {

    if (value.trim().isEmpty) {
      return 'Especificación';
    }

    final formatted =
    value
        .replaceAll('_', ' ')
        .trim();

    return formatted[0]
        .toUpperCase() +
        formatted.substring(1);
  }

  String _formatCurrency(
      dynamic value,
      ) {

    final amount =
    value is num
        ? value.toDouble()
        : double.tryParse(
      value
          ?.toString()
          .replaceAll(
        ',',
        '.',
      ) ??
          '',
    ) ??
        0;

    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$ ',
      decimalDigits: 0,
    ).format(amount);
  }

}