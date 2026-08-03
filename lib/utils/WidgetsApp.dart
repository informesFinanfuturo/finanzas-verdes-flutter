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

  static Widget input(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool required = false,
        TextInputType keyboardType = TextInputType.text,
        String? label
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label ?? hint),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            hint,
            icon,
          ),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty)
              ? 'Campo obligatorio'
              : null
              : null,
        ),
      ],
    );
  }

  static Widget inputArea(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool required = false,
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 3,
        String? label,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label ?? hint),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            hint,
            icon,
          ),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty)
              ? 'Campo obligatorio'
              : null
              : null,
        ),
      ],
    );
  }

  static Widget dateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    DateTime? initialDate,
    Function(DateTime)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: Wapp.TextFieldDecoration(
            Global.primary,
            true,
            label,
            Icons.calendar_month,
          ),
          onTap: () async {

            final selected = await showDatePicker(
              context: context,
              initialDate:
              initialDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );

            if (selected == null) return;

            controller.text =
            "${selected.day.toString().padLeft(2, '0')}/"
                "${selected.month.toString().padLeft(2, '0')}/"
                "${selected.year}";

            onChanged?.call(selected);
          },
        ),
      ],
    );
  }
}

class MagicWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const MagicWrapper({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<MagicWrapper> createState() => _MagicWrapperState();
}

class _MagicWrapperState extends State<MagicWrapper> {
  bool isHover = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) {
          setState(() => isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => isPressed = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),

          // 🔥 EFECTO ESCALA
          transform: Matrix4.identity()
            ..scale(isPressed ? 0.97 : isHover ? 1.05 : 1.0),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),

            boxShadow: [
              // 🌟 GLOW MÁGICO
              BoxShadow(
                color: Global.primary.withOpacity(
                  isPressed
                      ? 0.4   // más fuerte al presionar
                      : isHover
                      ? 0.6 // brillo hover
                      : 0.2,
                ),
                blurRadius: isPressed
                    ? 25
                    : isHover
                    ? 30
                    : 10,
                spreadRadius: isHover ? 2 : 0,
              ),
            ],
          ),

          child: widget.child,
        ),
      ),
    );
  }
}

Widget buildItem(String key, dynamic value) {
  if (value is Map<String, dynamic>) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Global.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Global.primary,
            ),
          ),
          SizedBox(height: 8),
          ...value.entries.map((e) => buildItem(e.key, e.value)).toList(),
        ],
      ),
    );
  }

  if (value is List) {
    // ✅ LISTA
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...value.map((item) => buildItem("-", item)).toList(),
        ],
      ),
    );
  }

  // ✅ VALOR SIMPLE
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$key: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Global.text,
          ),
        ),
        Expanded(
          child: Text(
            value.toString() == "null" ? "No identificado" : value.toString(),
            style: TextStyle(
              color: Global.text.withOpacity(0.7),
            ),
          ),
        ),
      ],
    ),
  );
}
