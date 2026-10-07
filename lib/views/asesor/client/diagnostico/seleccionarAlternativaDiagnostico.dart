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

  Map<String, dynamic>?
  _alternativaSeleccionada;

  String? _proveedorSeleccionado;

  @override
  void initState() {
    super.initState();

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
    });

    try {

      final response =
      await getAlternativasActivoDiagnosticoApi(
        idDiagnostico:
        widget.idDiagnostico,

        idActivo:
        widget.idActivo,
      );

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

      if (idSeleccionado != null) {
        for (final alternativa
        in alternativas) {

          if (
          _toInt(
            alternativa["id_item"],
          ) ==
              idSeleccionado
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
              Navigator.of(context)
                  .pop();
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

    return Column(
      children: [
        _buildFilters(
          isMobile,
        ),

        Expanded(
          child:
          _buildAlternatives(),
        ),
      ],
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
        Navigator.of(
          context,
        ).pop();
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