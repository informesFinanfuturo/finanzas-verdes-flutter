import 'package:syncfusion_flutter_calendar/calendar.dart';

class AgendaEvent {

  final int idCalendario;

  final String titulo;

  final String cliente;

  final String direccion;

  final DateTime fechaHora;

  AgendaEvent({
    required this.idCalendario,
    required this.titulo,
    required this.cliente,
    required this.direccion,
    required this.fechaHora,
  });

}

class AgendaDataSource
    extends CalendarDataSource {

  AgendaDataSource(
      List<Appointment> source,
      ) {
    appointments = source;
  }

}