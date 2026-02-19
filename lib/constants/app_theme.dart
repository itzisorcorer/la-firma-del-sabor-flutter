import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores basadas en el logo de la firma del sabor

  // 1. Azul Marino:
  // Usado para dar seriedad y estructura.
  static const Color navyBlue = Color(0xFF0D253F);

  // 2. Naranja Intenso (De la base del maíz)
  // Usado para llamar a la acción (Comer, Comprar).
  static const Color orangeBrand = Color(0xFFFF6F00);

  // 3. Amarillo Dorado (De la palabra "Firma")
  // Usado para detalles (estrellas, iconos secundarios).
  static const Color goldAccent = Color(0xFFFFCA28);

  // Fondos
  static const Color backgroundLight = Color(0xFFF9FAFB); // Un gris azulado casi blanco
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // Estados
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // Amarillo del Mockup (Barras de navegación)
  static const Color brandYellow = Color(0xFFF6B93B);

  //TEMA GLOBAL
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Esquema de colores generado desde el Naranja del maíz
      colorScheme: ColorScheme.fromSeed(
        seedColor: orangeBrand,
        primary: orangeBrand,       // Los botones serán Naranja
        onPrimary: Colors.white,    // El texto dentro de los botones será Blanco
        secondary: navyBlue,        // Elementos secundarios en Azul
        onSecondary: Colors.white,
        surface: surfaceWhite,
        background: backgroundLight,
        error: error,
      ),

      scaffoldBackgroundColor: backgroundLight,

      //APP BAR

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: navyBlue, // Iconos y texto en Azul
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: navyBlue,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),

      //BOTONES
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orangeBrand, // Botones Naranjas
          foregroundColor: Colors.white, // Texto Blanco
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      //INPUTS (Cajas de texto)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: navyBlue.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: navyBlue.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: orangeBrand, width: 2),
        ),
        labelStyle: TextStyle(color: navyBlue.withOpacity(0.7)),
        prefixIconColor: navyBlue,
      ),

      //TEXTOS
      textTheme: const TextTheme(
        // Títulos grandes en Azul Marino
        displayLarge: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: navyBlue, fontWeight: FontWeight.bold, fontSize: 22),

        // Cuerpo de texto en un gris muy oscuro (casi negro)
        bodyLarge: TextStyle(color: navyBlue, fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF455A64), fontSize: 14), // Un gris azulado para subtítulos
      ),
    );
  }
}