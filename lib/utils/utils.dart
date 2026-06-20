import 'package:finanzas_verdes/app/config/Global.dart';

class Utils {


  static String buildUrl(Map<String, dynamic> archivo) {
    String path = archivo["ubicacion"] ?? '';

    // asegurar que empieza con /api/
    if (!path.startsWith('/api/')) {
      path = '/$path';
    }

    return "http://192.168.200.153:3000$path";
  }


}