import 'package:animate_do/animate_do.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/routeNames.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Morecliente extends StatefulWidget{
  const Morecliente({super.key});

  @override
  State<Morecliente> createState() => _MoreclienteState();
}

class _MoreclienteState extends State<Morecliente> {
  @override
  Widget build(BuildContext context) {
    return
      LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileCard(),
                  const SizedBox(height: 30),

                  isMobile
                      ? Column(
                    children: _actionButtons(),
                  )
                      : Row(
                    children: _actionButtons()
                        .map((e) => Expanded(child: e))
                        .toList(),
                  ),

                  const SizedBox(height: 30),

                  _ExtrasSection(),
                ],
              ),
            ),
          );
        },
      );
  }
}


List<Widget> _actionButtons() => [
  Obx(() => _ActionCard(
    icon: controller.isDark.value
        ? CupertinoIcons.sun_max_fill
        : CupertinoIcons.moon_fill,
    title: 'Cambiar tema',
    subtitle: controller.isDark.value
        ? 'Modo claro'
        : 'Modo oscuro',
    onTap: controller.toggleTheme,
    color: Global.contrast,
  ),),
  const SizedBox(width: 20, height: 20),
  _ActionCard(
    icon: Icons.logout,
    title: 'Cerrar sesión',
    subtitle: 'Salir de la cuenta',
    color: Global.contrast,
    onTap: () {
      controller.logOut();
    },
  ),
];

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.person_alt_circle,
            size: 140,
            color: Global.text.withOpacity(0.6),
          ),
          SizedBox(height: 10),
          Text(
            controller.User["nombre_usuario"] ?? "",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Global.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.User["email"] ?? '',
            style: TextStyle(
              color: Global.text.withOpacity(0.6),
            ),
          ),
        ],
      ),
    ));
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Global.container,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color ?? Global.secondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Global.text.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _ExtrasSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Otras opciones',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            _ExtraItem(
              icon: CupertinoIcons.info,
              label: 'Acerca de',
            ),
            _ExtraItem(
              icon: CupertinoIcons.doc_text,
              label: 'Términos',
            ),
            _ExtraItem(
              icon: CupertinoIcons.gear,
              label: 'Configuración',
            ),
          ],
        ),
      ],
    );
  }
}

class _ExtraItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ExtraItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Global.primary, size: 30),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    ));
  }
}
