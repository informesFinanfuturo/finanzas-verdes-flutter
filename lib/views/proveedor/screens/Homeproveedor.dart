import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homeproveedor extends StatelessWidget {
  const Homeproveedor({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Global.container,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel del proveedor',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona tu catálogo de productos y la información asociada desde las opciones disponibles.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Global.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
