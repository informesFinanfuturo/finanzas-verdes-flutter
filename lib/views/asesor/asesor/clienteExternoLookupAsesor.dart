import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/models/api/calendarioApi.dart';
import 'package:finanzas_verdes/models/api/prospectoApi.dart';
import 'package:finanzas_verdes/views/asesor/asesor/createCalendarioAsesor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


class ClienteExternoLookupAsesor
    extends StatefulWidget {

  const ClienteExternoLookupAsesor({
    super.key,
  });


  @override
  State<ClienteExternoLookupAsesor>
  createState() =>
      _ClienteExternoLookupAsesorState();
}


class _ClienteExternoLookupAsesorState
    extends State<ClienteExternoLookupAsesor> {

  final TextEditingController
  documentoController =
  TextEditingController();


  Map<String, dynamic>?
  resultado;


  bool buscando =
  false;


  bool procesando =
  false;


  String? error;


  @override
  void dispose() {

    documentoController
        .dispose();

    super.dispose();

  }


  Future<void> _consultar() async {

    final documento =
    documentoController
        .text
        .trim();


    if (documento.isEmpty) {

      setState(() {
        error =
        'Ingresa el documento del cliente.';
      });

      return;

    }


    setState(() {

      buscando =
      true;

      error =
      null;

      resultado =
      null;

    });


    try {

      final data =
      await consultarClienteExternoApi(
        documento:
        documento,
      );


      if (!mounted) {
        return;
      }


      setState(() {
        resultado =
            data;
      });


    } catch (e) {

      if (!mounted) {
        return;
      }


      setState(() {

        error =
            e
                .toString()
                .replaceFirst(
              'Exception: ',
              '',
            );

      });


    } finally {

      if (mounted) {

        setState(() {
          buscando =
          false;
        });

      }

    }

  }


  Future<void> _descartar() async {

    if (
    resultado ==
        null
    ) {
      return;
    }


    final idConsulta =
    resultado![
    'consulta']?[
    'id_consulta'];


    if (
    idConsulta ==
        null
    ) {
      return;
    }


    final result = await _mostrarModalDescarte();


    if (
    result ==
        null
    ) {
      return;
    }


    setState(() {
      procesando =
      true;
    });


    try {

      await descartarConsultaClienteApi(
        idConsulta: idConsulta,
        motivoCodigo: result['codigo']!,
        motivo: result['motivo']!,
      );


      if (!mounted) {
        return;
      }


      ScaffoldMessenger
          .of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text(
            'Cliente descartado correctamente.',
          ),
        ),
      );


      setState(() {

        resultado =
        null;

        documentoController
            .clear();

      });


    } catch (e) {

      if (!mounted) {
        return;
      }


      ScaffoldMessenger
          .of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text(
            e
                .toString()
                .replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );


    } finally {

      if (mounted) {

        setState(() {
          procesando =
          false;
        });

      }

    }

  }


  Future<void> _agendar() async {

    if (
    resultado ==
        null
    ) {
      return;
    }


    final cliente =
    Map<String, dynamic>
        .from(
      resultado![
      'cliente'] ??
          {},
    );


    final estadoLocal =
    Map<String, dynamic>
        .from(
      resultado![
      'estado_local'] ??
          {},
    );


    /*
     * Si ya es cliente FV,
     * utilizamos el flujo de
     * calendario tradicional.
     */
    if (
    estadoLocal[
    'es_cliente_finanzas_verdes'] ==
        true
    ) {

      final local =
      Map<String, dynamic>
          .from(
        estadoLocal[
        'cliente'] ??
            {},
      );


      await mostrarModalCrearCalendario(
        context,
        local,
        'Visita de seguimiento',
      );


      return;

    }


    final consulta =
    Map<String, dynamic>
        .from(
      resultado![
      'consulta'] ??
          {},
    );


    final name =
    [
      cliente[
      'nombres'],
      cliente[
      'apellidos'],
    ]
        .where(
          (e) =>
      e !=
          null,
    )
        .join(
      ' ',
    );


    final dataForCalendar =
    <String, dynamic>{

      'id_consulta':
      consulta[
      'id_consulta'],

      'nombre_usuario':
      name,

      'email':
      cliente[
      'correo'],

      'documento':
      cliente[
      'documento'],

      'direccion_negocio':
      cliente[
      'direccion_negocio'],

      'nombre_mipyme':
      'Cliente corporativo',

    };


    final created =
    await mostrarModalCrearCalendario(
      context,
      dataForCalendar,
      'Presentación Finanzas Verdes',
    );


    if (
    created ==
        true
    ) {

      await getClientsAgendaApi();


      if (!mounted) {
        return;
      }


      setState(() {

        resultado =
        null;

        documentoController
            .clear();

      });

    }

  }


  Future<Map<String, String>?> _mostrarModalDescarte() async {

    String codigo =
        'no_cumple_perfil';


    final observacionCtrl =
    TextEditingController();


    final response =
    await showDialog<
        Map<String, String>>(
      context:
      context,

      builder:
          (dialogContext) {

        return StatefulBuilder(
          builder:
              (
              context,
              setModalState,
              ) {

            return AlertDialog(

              title:
              const Text(
                'No agendar cliente',
              ),

              content:
              SizedBox(
                width:
                460,

                child:
                Column(
                  mainAxisSize:
                  MainAxisSize
                      .min,

                  crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,

                  children: [

                    const Text(
                      'Selecciona el motivo por el cual el cliente no continuará a agendamiento.',
                    ),

                    const SizedBox(
                      height:
                      18,
                    ),

                    DropdownButtonFormField<String>(

                      initialValue:
                      codigo,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Motivo',
                        border:
                        OutlineInputBorder(),
                      ),

                      items:
                      const [

                        DropdownMenuItem(
                          value:
                          'no_cumple_perfil',
                          child:
                          Text(
                            'No cumple el perfil',
                          ),
                        ),

                        DropdownMenuItem(
                          value:
                          'puntajes',
                          child:
                          Text(
                            'Puntajes',
                          ),
                        ),

                        DropdownMenuItem(
                          value:
                          'informacion_insuficiente',
                          child:
                          Text(
                            'Información insuficiente',
                          ),
                        ),

                        DropdownMenuItem(
                          value:
                          'ya_contactado',
                          child:
                          Text(
                            'Ya fue contactado',
                          ),
                        ),

                        DropdownMenuItem(
                          value:
                          'otro',
                          child:
                          Text(
                            'Otro',
                          ),
                        ),

                      ],

                      onChanged:
                          (value) {

                        if (
                        value ==
                            null
                        ) {
                          return;
                        }


                        setModalState(
                              () {
                            codigo =
                                value;
                          },
                        );

                      },

                    ),

                    const SizedBox(
                      height:
                      14,
                    ),

                    TextField(

                      controller:
                      observacionCtrl,

                      maxLines:
                      3,

                      decoration:
                      const InputDecoration(

                        labelText:
                        'Observación',

                        hintText:
                        'Explica brevemente la razón.',

                        border:
                        OutlineInputBorder(),

                      ),

                    ),

                  ],

                ),

              ),

              actions:
              [

                TextButton(
                  onPressed:
                      () =>
                      Navigator.pop(
                        dialogContext,
                      ),
                  child:
                  const Text(
                    'Cancelar',
                  ),
                ),

                FilledButton(
                  onPressed:
                      () {

                    final observation =
                    observacionCtrl
                        .text
                        .trim();


                    if (
                    observation
                        .isEmpty
                    ) {

                      ScaffoldMessenger
                          .of(
                        dialogContext,
                      )
                          .showSnackBar(
                        const SnackBar(
                          content:
                          Text(
                            'Debes registrar una observación.',
                          ),
                        ),
                      );

                      return;

                    }


                    Navigator.pop(
                      dialogContext,
                      {
                        'codigo':
                        codigo,
                        'motivo':
                        observation,
                      },
                    );

                  },
                  child:
                  const Text(
                    'Guardar',
                  ),
                ),

              ],

            );

          },
        );

      },
    );


    observacionCtrl
        .dispose();


    return response;

  }


  @override
  Widget build(
      BuildContext context,
      ) {

    final cliente =
    resultado?[
    'cliente']
    as Map<String, dynamic>?;


    final scores =
    resultado?[
    'puntajes']
    as Map<String, dynamic>?;


    final local =
    resultado?[
    'estado_local']
    as Map<String, dynamic>?;


    final prospect =
    local?[
    'prospecto']
    as Map<String, dynamic>?;


    final alreadyScheduled =
        prospect?[
        'estado'] ==
            'agendado';


    return Column(

      crossAxisAlignment:
      CrossAxisAlignment
          .stretch,

      children: [

        Container(

          padding:
          const EdgeInsets.all(
            20,
          ),

          decoration:
          BoxDecoration(

            color:
            Global.container,

            borderRadius:
            BorderRadius.circular(
              16,
            ),

            border:
            Border.all(
              color:
              Global.text
                  .withOpacity(
                .08,
              ),
            ),

          ),

          child:
          Column(

            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [

              Text(
                'Consultar cliente',
                style:
                GoogleFonts.poppins(
                  fontSize:
                  18,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Global.text,
                ),
              ),

              const SizedBox(
                height:
                4,
              ),

              Text(
                'Ingresa el documento para consultar la información corporativa y su evaluación.',
                style:
                GoogleFonts.poppins(
                  fontSize:
                  12,
                  color:
                  Global.textSecondary,
                ),
              ),

              const SizedBox(
                height:
                18,
              ),

              LayoutBuilder(
                builder:
                    (
                    context,
                    constraints,
                    ) {

                  final mobile =
                      constraints
                          .maxWidth <
                          650;


                  final field =
                  TextField(

                    controller:
                    documentoController,

                    keyboardType:
                    TextInputType
                        .number,

                    inputFormatters:
                    [
                      FilteringTextInputFormatter
                          .digitsOnly,
                    ],

                    onSubmitted:
                        (_) =>
                        _consultar(),

                    decoration:
                    InputDecoration(

                      labelText:
                      'Documento',

                      prefixIcon:
                      const Icon(
                        Icons
                            .badge_outlined,
                      ),

                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),

                    ),

                  );


                  final button =
                  FilledButton.icon(

                    onPressed:
                    buscando
                        ? null
                        : _consultar,

                    icon:
                    buscando
                        ? const SizedBox(
                      width:
                      18,
                      height:
                      18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                        color:
                        Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons
                          .search_rounded,
                    ),

                    label:
                    Text(
                      buscando
                          ? 'Consultando...'
                          : 'Consultar',
                    ),

                    style:
                    FilledButton.styleFrom(
                      minimumSize:
                      const Size(
                        150,
                        54,
                      ),
                      backgroundColor:
                      Global.primary,
                    ),

                  );


                  if (mobile) {

                    return Column(
                      children: [

                        field,

                        const SizedBox(
                          height:
                          10,
                        ),

                        SizedBox(
                          width:
                          double.infinity,
                          child:
                          button,
                        ),

                      ],
                    );

                  }


                  return Row(
                    children: [

                      Expanded(
                        child:
                        field,
                      ),

                      const SizedBox(
                        width:
                        12,
                      ),

                      button,

                    ],
                  );

                },
              ),

              if (
              error !=
                  null
              ) ...[

                const SizedBox(
                  height:
                  14,
                ),

                Text(
                  error!,
                  style:
                  const TextStyle(
                    color:
                    Colors.red,
                  ),
                ),

              ],

            ],

          ),

        ),


        if (
        cliente !=
            null
        ) ...[

          const SizedBox(
            height:
            16,
          ),

          _buildClientInfo(
            cliente,
          ),

          const SizedBox(
            height:
            14,
          ),

          _buildScores(
            scores,
          ),

          if (
          local?[
          'es_cliente_finanzas_verdes'] ==
              true
          ) ...[

            const SizedBox(
              height:
              12,
            ),

            _statusMessage(
              'Este cliente ya pertenece a Finanzas Verdes.',
              Icons
                  .verified_user_outlined,
            ),

          ] else if (
          prospect !=
              null
          ) ...[

              const SizedBox(
                height:
                12,
              ),

              _statusMessage(
                'Este documento ya tiene un prospecto con estado: ${prospect['estado'] ?? 'sin estado'}.',
                Icons
                    .history_rounded,
              ),

            ],


          const SizedBox(
            height:
            16,
          ),

          LayoutBuilder(
            builder:
                (
                context,
                constraints,
                ) {

              final mobile =
                  constraints
                      .maxWidth <
                      600;


              final noButton =
              OutlinedButton.icon(

                onPressed:
                procesando
                    ? null
                    : _descartar,

                icon:
                const Icon(
                  Icons
                      .close_rounded,
                ),

                label:
                const Text(
                  'No agendar',
                ),

                style:
                OutlinedButton.styleFrom(
                  foregroundColor:
                  Colors.red,
                  minimumSize:
                  const Size(
                    160,
                    48,
                  ),
                ),

              );


              final yesButton =
              FilledButton.icon(

                onPressed:
                procesando ||
                    alreadyScheduled
                    ? null
                    : _agendar,

                icon:
                const Icon(
                  Icons
                      .event_available_rounded,
                ),

                label:
                Text(
                  alreadyScheduled
                      ? 'Ya agendado'
                      : 'Agendar',
                ),

                style:
                FilledButton.styleFrom(
                  backgroundColor:
                  Global.primary,
                  minimumSize:
                  const Size(
                    160,
                    48,
                  ),
                ),

              );


              if (mobile) {

                return Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
                  children: [

                    noButton,

                    const SizedBox(
                      height:
                      10,
                    ),

                    yesButton,

                  ],
                );

              }


              return Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .end,
                children: [

                  noButton,

                  const SizedBox(
                    width:
                    10,
                  ),

                  yesButton,

                ],
              );

            },
          ),

        ],

      ],

    );

  }


  Widget _buildClientInfo(
      Map<String, dynamic> client,
      ) {

    return Container(

      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        18,
      ),

      decoration:
      BoxDecoration(

        color:
        Global.container,

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        border:
        Border.all(
          color:
          Global.text
              .withOpacity(
            .08,
          ),
        ),

      ),

      child:
      Wrap(

        spacing:
        24,

        runSpacing:
        16,

        children:
        [

          _field(
            'Documento',
            client[
            'documento'],
          ),

          _field(
            'Nombres',
            client[
            'nombres'],
          ),

          _field(
            'Apellidos',
            client[
            'apellidos'],
          ),

          _field(
            'Municipio',
            client[
            'municipio'],
          ),

          _field(
            'Sucursal',
            client[
            'sucursal'],
          ),

          _field(
            'Dirección del negocio',
            client[
            'direccion_negocio'],
          ),

          _field(
            'Código CIIU',
            client[
            'codigo_ciiu'],
          ),

          _field(
            'Celular',
            client[
            'celular'],
          ),

          _field(
            'Correo',
            client[
            'correo'],
          ),

        ].map(
              (item) =>
              SizedBox(
                width:
                250,
                child:
                item,
              ),
        ).toList(),

      ),

    );

  }


  Widget _field(
      String label,
      dynamic value,
      ) {

    final text =
    value
        ?.toString()
        .trim();


    return Column(

      crossAxisAlignment:
      CrossAxisAlignment
          .start,

      children: [

        Text(
          label,
          style:
          GoogleFonts.poppins(
            fontSize:
            11,
            color:
            Global.textSecondary,
          ),
        ),

        const SizedBox(
          height:
          3,
        ),

        Text(
          text ==
              null ||
              text.isEmpty
              ? 'No disponible'
              : text,
          style:
          GoogleFonts.poppins(
            fontSize:
            13,
            fontWeight:
            FontWeight.w600,
            color:
            Global.text,
          ),
        ),

      ],

    );

  }


  Widget _buildScores(
      Map<String, dynamic>? scores,
      ) {

    return Container(

      padding:
      const EdgeInsets.all(
        18,
      ),

      decoration:
      BoxDecoration(

        color:
        Global.container,

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        border:
        Border.all(
          color:
          Global.text
              .withOpacity(
            .08,
          ),
        ),

      ),

      child:
      Column(

        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [

          Text(
            'Evaluación del cliente',
            style:
            GoogleFonts.poppins(
              fontSize:
              16,
              fontWeight:
              FontWeight.w600,
              color:
              Global.text,
            ),
          ),

          const SizedBox(
            height:
            14,
          ),

          Wrap(
            spacing:
            12,
            runSpacing:
            12,
            children: [

              _score(
                'Puntaje LINIX',
                scores?[
                'puntaje_linix'],
              ),

              _score(
                'Puntaje Aicoll',
                scores?[
                'puntaje_aicoll'],
              ),

              _score(
                'Puntaje externo',
                scores?[
                'puntaje_externo'],
              ),

            ],
          ),

        ],

      ),

    );

  }


  Widget _score(
      String label,
      dynamic value,
      ) {

    return Container(

      width:
      190,

      padding:
      const EdgeInsets.all(
        14,
      ),

      decoration:
      BoxDecoration(

        color:
        Global.bg,

        borderRadius:
        BorderRadius.circular(
          12,
        ),

      ),

      child:
      Column(

        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [

          Text(
            label,
            style:
            GoogleFonts.poppins(
              fontSize:
              11,
              color:
              Global.textSecondary,
            ),
          ),

          const SizedBox(
            height:
            4,
          ),

          Text(
            value
                ?.toString() ??
                'No disponible',
            style:
            GoogleFonts.poppins(
              fontSize:
              21,
              fontWeight:
              FontWeight.w600,
              color:
              Global.text,
            ),
          ),

        ],

      ),

    );

  }


  Widget _statusMessage(
      String message,
      IconData icon,
      ) {

    return Container(

      padding:
      const EdgeInsets.all(
        12,
      ),

      decoration:
      BoxDecoration(

        color:
        Global.primary
            .withOpacity(
          .08,
        ),

        borderRadius:
        BorderRadius.circular(
          10,
        ),

      ),

      child:
      Row(

        children: [

          Icon(
            icon,
            color:
            Global.primary,
          ),

          const SizedBox(
            width:
            10,
          ),

          Expanded(
            child:
            Text(
              message,
            ),
          ),

        ],

      ),

    );

  }

}