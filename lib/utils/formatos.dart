import 'package:intl/intl.dart';

String formatearFecha(String fecha) {
  DateTime fechaDateTime = DateTime.parse(fecha);
  return DateFormat('dd/MM/yyyy HH:mm').format(fechaDateTime);
}
