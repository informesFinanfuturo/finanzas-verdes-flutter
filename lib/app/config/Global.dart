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
  static String baseUrl = "http://20.169.169.108:4000/api/";
  //static String baseUrl = "http://localhost:3000/api/";

  static List<Map<String, dynamic>> itemConfig = [

    /// ✅ ELECTRODOMÉSTICO GENERAL
    {
      "tipo_item": "Electrodoméstico",
      "tiposProveedorPermitidos": ["Electrodomésticos"],

      "campos": [
        {
          "key": "marca",
          "label": "Marca",
          "type": "text",
          "required": true
        },
        {
          "key": "voltaje",
          "label": "Voltaje",
          "type": "number",
          "required": true
        },
        {
          "key": "garantia",
          "label": "Meses de garantía",
          "type": "text"
        }
      ]
    },

    {
      "tipo_item": "Nevera",
      "tiposProveedorPermitidos": ["Electrodomésticos"],

      "campos": [
        {
          "key": "capacidad",
          "label": "Capacidad (Litros)",
          "type": "number",
          "required": true
        },
        {
          "key": "nivel_refrigerante",
          "label": "Nivel de refrigerante",
          "type": "number"
        },
        {
          "key": "consumo",
          "label": "Consumo energético",
          "type": "text"
        }
      ]
    },

    {
      "tipo_item": "Horno",
      "tiposProveedorPermitidos": ["Electrodomésticos", "Cocina Industrial"],

      "campos": [
        {
          "key": "tipo_horno",
          "label": "Tipo de horno",
          "type": "select",
          "options": ["Eléctrico", "Gas", "Industrial", "Convencional", "Convección"],
          "required": true
        },
        {
          "key": "capacidad_litros",
          "label": "Capacidad (Litros)",
          "type": "number",
          "required": true
        },
        {
          "key": "potencia",
          "label": "Potencia (W)",
          "type": "number"
        },
        {
          "key": "voltaje",
          "label": "Voltaje",
          "type": "select",
          "options": ["110V", "220V", "Mixto"]
        },
        {
          "key": "temperatura_max",
          "label": "Temperatura máxima (°C)",
          "type": "number"
        },
        {
          "key": "numero_parrillas",
          "label": "Número de parrillas",
          "type": "number"
        },
        {
          "key": "consumo_gas",
          "label": "Consumo de gas",
          "type": "text"
        },
        {
          "key": "eficiencia_energetica",
          "label": "Eficiencia energética",
          "type": "select",
          "options": ["A", "B", "C", "D", "E"]
        },
        {
          "key": "estado",
          "label": "Estado",
          "type": "select",
          "options": ["Nuevo", "Usado", "Reacondicionado"],
          "required": true
        }
      ]
    },

    /// ✅ SERVICIO GENERAL
    {
      "tipo_item": "Servicio",
      "tiposProveedorPermitidos": ["Servicios"],

      "campos": [
        {
          "key": "duracion",
          "label": "Duración",
          "type": "text",
          "required": true
        },
        {
          "key": "modalidad",
          "label": "Modalidad",
          "type": "select",
          "options": ["Virtual", "Presencial", "Mixto"]
        }
      ]
    },

    /// ✅ INSTALACIÓN
    {
      "tipo_item": "Instalación",
      "tiposProveedorPermitidos": ["Servicios"],

      "campos": [
        {
          "key": "tiempo_instalacion",
          "label": "Tiempo estimado",
          "type": "text"
        },
        {
          "key": "requiere_materiales",
          "label": "Requiere materiales",
          "type": "bool"
        }
      ]
    }

  ];

  static Map<String, Map<String, List<String>>> ubicaciones = {
    "Caldas": {
      "Manizales": [
        "Neira", "San José", "Centro",
        "El Cable", "San Jorge", "Otro"
      ],
      "Chinchiná": ["Marsella", "Palestina", "Otro"],
      "La Dorada": [
        "Caparrapí", "Guaduas", "Manzanares", "Marquetalia",
        "Norcasia", "Pensilvania", "Puerto Boyacá",
        "Puerto Salgar", "Puerto Triunfo", "Samaná",
        "Victoria", "Otro"
      ],
      "Riosucio": [
        "Anserma", "Belalcázar", "Belén de Umbría",
        "Guática", "Mistrató", "Quinchía",
        "Riosucio", "Risaralda", "Viterbo", "Otro"
      ],
      "Salamina": ["Aguadas", "Aranzazu", "Marulanda", "Pácora", "Otro"],
      "Supía": ["Caramanta", "Filadelfia", "La Merced", "Marmato", "Otro"],
      "Villamaría": ["Villamaría", "Otro"],
    },

    "Valle del Cauca": {
      "Buga": ["Tuluá", "Otro"]
    },

    "Cauca": {
      "Santander de Quilichao": ["Santander de Quilichao", "Otro"]
    },

    "Risaralda": {
      "Santa Rosa": ["Cartago", "Dosquebradas", "Pereira", "Obando", "Otro"]
    }
  };

  static List<String> tiposEmpresa = [
    "Restaurante",
    "Hotel",
    "Cafetería",
  ];

  static List<String> tiposActivo = [
    "Neveras",
    "Televisores",
    "Hornos",
    "Climatización",
    "Vitrinas",
    "Refrigeración",
    "Secadoras",
    "Iluminación",
    "Lavadoras",
    "Lava vajillas",
    "Sanitarios",
    "Orinales",
    "Grifos",
    "Otro"
  ];
}