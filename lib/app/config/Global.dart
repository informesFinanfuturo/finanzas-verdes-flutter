import 'dart:ui';

import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';

class Global {
  static Color get bg => controller.isDark.value ? Color(0xFF232323) : Color(0xFFF2F3F4);
  static Color get primary => controller.isDark.value ? Color(0xFF0074c5) : Color(0xFF30664a);
  static Color get secondary => controller.isDark.value ? Color(0xFF8a0079) : Color(0xFF8a0079);
  static Color get contrast => controller.isDark.value ? Color(0xFFa9d42d) : Color(0xFFa9d42d);
  static Color get text => controller.isDark.value ? Colors.white : Colors.black;
  static Color get textSecondary => controller.isDark.value ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6);
  static Color get absolute => controller.isDark.value ? Colors.black : Colors.white;
  static Color get container => controller.isDark.value ? primary.withOpacity(0.1) : Colors.white.withOpacity(0.8);

  // API
  static String baseUrl = "http://192.168.200.153:3000/api/";
}