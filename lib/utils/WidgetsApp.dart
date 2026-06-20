import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:flutter/material.dart';

class Wapp {
  static InputDecoration TextFieldDecoration (Color color, bool fill, String hint, IconData icon){
    return InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
              color: color
          )
      ),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.transparent,
          )
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
              color: color,
              width: 2
          )
      ),
      filled: fill,
      fillColor: color.withOpacity(0.1),
      prefixIcon: Icon(icon, color: color,),
      hintText: hint,
      hintStyle: TextStyle(color: Global.text.withOpacity(0.4)),
    );
  }

  static Decoration ButtonDecorationGradient (Color color1, Color color2) {
    return BoxDecoration(
        gradient: LinearGradient(
            colors: [
              color1,
              color2
            ]
        ),
        borderRadius: BorderRadius.circular(5)
    );
  }
}