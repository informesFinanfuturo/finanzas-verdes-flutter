import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/agenda/AgendaEvent.dart';
import 'package:finanzas_verdes/views/asesor/asesor/editCalendarioAsesor.dart';
import 'package:finanzas_verdes/views/asesor/asesor/viewCalendarioAsesor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AgendaCalendarWidget extends StatefulWidget {
  const AgendaCalendarWidget({
    super.key,
  });

  @override
  State<AgendaCalendarWidget> createState() =>
      _AgendaCalendarWidgetState();
}

class _AgendaCalendarWidgetState
    extends State<AgendaCalendarWidget> {
  final CalendarController _calendarController =
  CalendarController();

  CalendarView _view = CalendarView.week;

  DateTime _visibleDate = DateTime.now();

  DateTime? _firstDate;
  DateTime? _lastDate;

  bool _responsiveViewInitialized = false;

  @override
  void initState() {
    super.initState();

    _calendarController.view = _view;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadRange(
        controller.firstDate.value,
        controller.endDate.value,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_responsiveViewInitialized) {
      return;
    }

    final width =
        MediaQuery.sizeOf(context).width;

    /*
     * En móvil una semana de siete columnas
     * queda demasiado comprimida.
     */
    if (width < 700) {
      _view = CalendarView.schedule;
    } else {
      _view = CalendarView.week;
    }

    _calendarController.view = _view;
    _responsiveViewInitialized = true;
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final bool isMobile =
        size.width < 700;

    return Obx(
          () => Column(
        children: [
          _buildCalendarToolbar(
            isMobile: isMobile,
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(12),
              child: SfCalendar(
                controller:
                _calendarController,

                scheduleViewMonthHeaderBuilder: _buildScheduleMonthHeader,

                view: _view,

                dataSource:
                AgendaDataSource(
                  controller.Appointments,
                ),

                /*
                 * Ocultamos el header nativo
                 * porque utilizamos uno propio.
                 */
                headerHeight: 0,

                backgroundColor:
                Global.container,

                cellBorderColor:
                Global.text.withOpacity(
                  controller.isDark.value
                      ? 0.08
                      : 0.07,
                ),

                todayHighlightColor:
                Global.primary,

                showCurrentTimeIndicator: true,

                showNavigationArrow: false,

                selectionDecoration:
                BoxDecoration(
                  color: Global.primary
                      .withOpacity(0.04),
                  border: Border.all(
                    color: Global.primary
                        .withOpacity(0.60),
                    width: 1.2,
                  ),
                  borderRadius:
                  BorderRadius.circular(6),
                ),

                viewHeaderStyle:
                ViewHeaderStyle(
                  backgroundColor:
                  Global.container,
                  dayTextStyle:
                  GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight:
                    FontWeight.w500,
                    color:
                    Global.textSecondary,
                  ),
                  dateTextStyle:
                  GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
                    color: Global.text,
                  ),
                ),

                timeSlotViewSettings:
                TimeSlotViewSettings(
                  startHour: 6,
                  endHour: 20,

                  /*
                   * En móvil mostramos un poco
                   * más de altura táctil.
                   */
                  timeIntervalHeight:
                  isMobile ? 54 : 48,

                  timeFormat: 'h a',

                  timeTextStyle:
                  GoogleFonts.poppins(
                    fontSize: 10,
                    color:
                    Global.textSecondary,
                  ),

                  timeRulerSize:
                  isMobile ? 54 : 64,

                  timeInterval:
                  const Duration(
                    hours: 1,
                  ),
                ),

                monthViewSettings:
                const MonthViewSettings(
                  appointmentDisplayMode:
                  MonthAppointmentDisplayMode
                      .indicator,
                  showAgenda: true,
                  agendaViewHeight: 180,
                  navigationDirection:
                  MonthNavigationDirection
                      .horizontal,
                ),

                scheduleViewSettings:
                ScheduleViewSettings(
                  /*
   * Oculta semanas que no contienen eventos.
   * Esto elimina "sept 06 - 12",
   * "sept 20 - 26", etc. cuando están vacías.
   */
                  hideEmptyScheduleWeek: true,

                  /*
   * Altura suficiente para mostrar título,
   * empresa, cliente y hora.
   */
                  appointmentItemHeight: 88,

                  appointmentTextStyle:
                  GoogleFonts.poppins(
                    fontSize: 11,
                    color: Global.text,
                  ),

                  /*
   * Sustituye la cabecera turquesa gigante
   * por una franja compacta y neutra.
   */
                  monthHeaderSettings:
                  MonthHeaderSettings(
                    height: 64,
                    monthFormat: 'MMMM yyyy',
                    textAlign: TextAlign.left,
                    backgroundColor:
                    Global.primary.withOpacity(
                      controller.isDark.value
                          ? 0.12
                          : 0.06,
                    ),
                    monthTextStyle:
                    GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Global.primary,
                    ),
                  ),

                  /*
   * Encabezado semanal más pequeño.
   */
                  weekHeaderSettings:
                  WeekHeaderSettings(
                    height: 30,
                    startDateFormat: 'dd MMM',
                    endDateFormat: 'dd MMM',
                    textAlign: TextAlign.left,
                    backgroundColor:
                    Colors.transparent,
                    weekTextStyle:
                    GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: Global.textSecondary,
                    ),
                  ),

                  dayHeaderSettings:
                  DayHeaderSettings(
                    width: 62,
                    dayFormat: 'EEE',
                    dayTextStyle:
                    GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Global.textSecondary,
                    ),
                    dateTextStyle:
                    GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Global.primary,
                    ),
                  ),

                  placeholderTextStyle:
                  GoogleFonts.poppins(
                    fontSize: 12,
                    color: Global.textSecondary,
                  ),
                ),

                appointmentBuilder:
                _buildAppointment,

                onViewChanged:
                _onViewChanged,

                onTap:
                _onCalendarTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarToolbar({
    required bool isMobile,
  }) {
    final monthText =
    DateFormat(
      'MMMM yyyy',
      'es_CO',
    ).format(_visibleDate);

    final formattedMonth =
    monthText.isEmpty
        ? monthText
        : monthText[0].toUpperCase() +
        monthText.substring(1);

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formattedMonth,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                    color: Global.text,
                  ),
                ),
              ),

              _navigationButton(
                icon:
                Icons.chevron_left_rounded,
                tooltip: 'Anterior',
                onTap: _goBackward,
              ),

              const SizedBox(width: 4),

              _todayButton(),

              const SizedBox(width: 4),

              _navigationButton(
                icon:
                Icons.chevron_right_rounded,
                tooltip: 'Siguiente',
                onTap: _goForward,
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: _viewButton(
                    title: 'Agenda',
                    icon:
                    Icons.view_agenda_outlined,
                    view:
                    CalendarView.schedule,
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _viewButton(
                    title: 'Día',
                    icon:
                    Icons.calendar_view_day_outlined,
                    view:
                    CalendarView.day,
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _viewButton(
                    title: 'Mes',
                    icon:
                    Icons.calendar_month_outlined,
                    view:
                    CalendarView.month,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _navigationButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'Periodo anterior',
          onTap: _goBackward,
        ),

        const SizedBox(width: 4),

        _navigationButton(
          icon: Icons.chevron_right_rounded,
          tooltip: 'Periodo siguiente',
          onTap: _goForward,
        ),

        const SizedBox(width: 10),

        _todayButton(),

        const SizedBox(width: 16),

        Expanded(
          child: Text(
            formattedMonth,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Global.text,
            ),
          ),
        ),

        _viewButton(
          title: 'Día',
          icon:
          Icons.calendar_view_day_outlined,
          view: CalendarView.day,
        ),

        const SizedBox(width: 7),

        _viewButton(
          title: 'Semana',
          icon:
          Icons.calendar_view_week_outlined,
          view: CalendarView.week,
        ),

        const SizedBox(width: 7),

        _viewButton(
          title: 'Mes',
          icon:
          Icons.calendar_month_outlined,
          view: CalendarView.month,
        ),
      ],
    );
  }

  Widget _navigationButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Global.bg,
              borderRadius:
              BorderRadius.circular(10),
              border: Border.all(
                color: Global.text
                    .withOpacity(0.09),
              ),
            ),
            child: Icon(
              icon,
              size: 21,
              color: Global.text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _todayButton() {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: _goToday,
        style: OutlinedButton.styleFrom(
          foregroundColor: Global.primary,
          side: BorderSide(
            color:
            Global.primary.withOpacity(
              0.30,
            ),
          ),
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Hoy',
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _viewButton({
    required String title,
    required IconData icon,
    required CalendarView view,
  }) {
    final bool selected =
        _view == view;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _changeCalendarView(view);
        },
        borderRadius:
        BorderRadius.circular(10),
        child: AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 180,
          ),
          height: 40,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Global.primary
                .withOpacity(0.11)
                : Global.bg,
            borderRadius:
            BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? Global.primary
                  .withOpacity(0.45)
                  : Global.text
                  .withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? Global.primary
                    : Global.textSecondary,
              ),

              const SizedBox(width: 7),

              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: selected
                      ? Global.primary
                      : Global.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointment(
      BuildContext context,
      CalendarAppointmentDetails details,
      ) {
    final appointment =
    details.appointments.first as Appointment;

    final Map<String, dynamic> data =
    appointment.notes?.isNotEmpty == true
        ? Map<String, dynamic>.from(
      jsonDecode(appointment.notes!),
    )
        : <String, dynamic>{};

    final cliente =
        data["nombre_usuario"]?.toString() ?? '';

    final String empresa =
        data["nombre_mipyme"]
            ?.toString()
            .trim() ??
            appointment.location
                ?.trim() ??
            '';

    final horaInicio =
    TimeOfDay.fromDateTime(appointment.startTime)
        .format(context);

    final horaFin =
    TimeOfDay.fromDateTime(appointment.endTime)
        .format(context);

    return IgnorePointer(
      ignoring: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Global.primary.withOpacity(
              controller.isDark.value ? 0.22 : 0.08,
            ),
            border: Border.all(
              color: Global.primary.withOpacity(0.30),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                color: Global.primary,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Global.text,
                        ),
                      ),

                      if (empresa.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 12,
                              color: Global.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                empresa,
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  color:
                                  Global.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (cliente.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: Global.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                cliente,
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  color:
                                  Global.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: Global.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '$horaInicio - $horaFin',
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color:
                                Global.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCalendarTap(CalendarTapDetails details,) async {
    /*
   * No validamos details.target porque en:
   * - Schedule
   * - Agenda del mes
   * - Vista día
   * - Vista semana
   *
   * Syncfusion puede devolver objetivos diferentes.
   * La validación realmente importante es que exista
   * una cita dentro del toque.
   */
    if (details.appointments == null ||
        details.appointments!.isEmpty) {
      return;
    }

    final dynamic selectedItem =
        details.appointments!.first;

    if (selectedItem is! Appointment) {
      debugPrint(
        'El elemento seleccionado no es un Appointment',
      );
      return;
    }

    final Appointment appointment =
        selectedItem;

    final String? notes =
        appointment.notes;

    if (notes == null ||
        notes.trim().isEmpty) {
      debugPrint(
        'El evento seleccionado no contiene notes',
      );
      return;
    }

    try {
      final dynamic decoded =
      jsonDecode(notes);

      if (decoded is! Map) {
        debugPrint(
          'Los datos del evento no tienen formato de objeto',
        );
        return;
      }

      final cliente =
      Map<String, dynamic>.from(decoded);

      final fechaHora =
      DateTime.tryParse(
        cliente["fecha_hora"]
            ?.toString() ??
            '',
      );

      if (fechaHora == null) {
        debugPrint(
          'El evento no contiene una fecha_hora válida',
        );
        return;
      }

      /*
     * Quitamos la selección visual después
     * de haber identificado el evento.
     */
      _calendarController.selectedDate =
      null;

      if (!mounted) return;

      if (fechaHora.isBefore(
        DateTime.now(),
      )) {
        await mostrarModalDetalleCalendario(
          context,
          cliente,
        );

        return;
      }

      final bool actualizado =
          await mostrarModalEditarCalendario(
            context,
            cliente,
          ) ??
              false;

      if (!actualizado || !mounted) {
        return;
      }

      final DateTime fechaInicial =
          _firstDate ??
              controller.firstDate.value;

      final DateTime fechaFinal =
          _lastDate ??
              controller.endDate.value;

      await controller.loadRange(
        fechaInicial,
        fechaFinal,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Error abriendo el evento: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  Map<String, dynamic> _getAppointmentData(Appointment appointment,) {
    if (
    appointment.notes == null ||
        appointment.notes!.trim().isEmpty
    ) {
      return {};
    }

    try {
      final decoded =
      jsonDecode(
        appointment.notes!,
      );

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }
    } catch (error) {
      debugPrint(
        'No fue posible leer los datos del evento: $error',
      );
    }

    return {};
  }

  String _firstValidText(
      List<dynamic> values,
      ) {
    for (final value in values) {
      final text =
          value?.toString().trim() ??
              "";

      if (
      text.isNotEmpty &&
          text.toLowerCase() != "null"
      ) {
        return text;
      }
    }

    return "";
  }

  void _onViewChanged(
      ViewChangedDetails details,
      ) {
    if (details.visibleDates.isEmpty) {
      return;
    }

    final firstDate =
        details.visibleDates.first;

    final lastDate =
        details.visibleDates.last;

    final middleIndex =
        details.visibleDates.length ~/ 2;

    final visibleDate =
    details.visibleDates[
    middleIndex];

    _firstDate = firstDate;
    _lastDate = lastDate;

    controller.firstDate.value =
        firstDate;

    controller.endDate.value =
        lastDate;

    /*
     * onViewChanged puede ejecutarse durante
     * el proceso de renderizado.
     */
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _visibleDate = visibleDate;
      });
    });

    controller.loadRange(
      firstDate,
      lastDate,
    );
  }

  void _goBackward() {
    _calendarController.backward?.call();
  }

  void _goForward() {
    _calendarController.forward?.call();
  }

  void _goToday() {
    final now = DateTime.now();

    _calendarController.displayDate =
        now;

    setState(() {
      _visibleDate = now;
    });
  }

  Widget _buildScheduleMonthHeader(
      BuildContext context,
      ScheduleViewMonthHeaderDetails details,
      ) {
    final monthText =
    DateFormat(
      'MMMM yyyy',
      'es_CO',
    ).format(details.date);

    final formattedMonth =
    monthText.isEmpty
        ? monthText
        : monthText[0].toUpperCase() +
        monthText.substring(1);

    return Container(
      margin: const EdgeInsets.only(
        top: 10,
        bottom: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Global.primary.withOpacity(
          controller.isDark.value
              ? 0.14
              : 0.07,
        ),
        borderRadius:
        BorderRadius.circular(11),
        border: Border.all(
          color:
          Global.primary.withOpacity(
            0.12,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
              Global.primary.withOpacity(
                0.12,
              ),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 17,
              color: Global.primary,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              formattedMonth,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight:
                FontWeight.w600,
                color: Global.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeCalendarView(
      CalendarView newView,
      ) {
    if (_view == newView) {
      return;
    }

    final now = DateTime.now();

    /*
   * Limpiamos primero la fecha seleccionada
   * en la vista anterior.
   */
    _calendarController.selectedDate =
    null;

    setState(() {
      _view = newView;
    });

    _calendarController.view =
        newView;

    /*
   * Syncfusion actualiza internamente el
   * displayDate al cambiar de vista.
   * Por eso esperamos al siguiente frame
   * antes de fijar la fecha correcta.
   */
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      _calendarController.selectedDate =
      null;

      if (
      newView ==
          CalendarView.schedule
      ) {
        /*
       * Agenda siempre vuelve al día actual.
       */
        _calendarController.displayDate =
            now;

        setState(() {
          _visibleDate = now;
        });
      }
    });
  }
}