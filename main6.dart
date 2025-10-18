import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Estado inicial: tema claro
  ThemeMode _themeMode = ThemeMode.light;

  // Cambia entre claro y oscuro
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tema Claro y Oscuro',
      debugShowCheckedModeBanner: false,

      // ☀️ Tema claro
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00C853), // Verde brillante (A700)
          onPrimary: Colors.white,
          background: Color(0xFFE8F5E9), // Verde muy claro
          onBackground: Color(0xFF1B5E20), // Verde muy oscuro para texto
        ),
        useMaterial3: true,
      ),

      // 🌙 Tema oscuro
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676), // Verde brillante (A400)
          onPrimary: Colors.black,
          background: Color(0xFF1B5E20), // Fondo verde muy oscuro
          onBackground: Color(0xFFE8F5E9), // Texto verde muy claro
        ),
        useMaterial3: true,
      ),

      // Tema actual
      themeMode: _themeMode,

      home: MyHomePage(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MyHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDarkMode ? "🌙 Tema Oscuro" : "☀️ Tema Claro"),
        backgroundColor: theme.primary,
        foregroundColor: theme.onPrimary,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: onToggleTheme,

          // 🌟 Ícono animado
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween(begin: 0.75, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              key: ValueKey<bool>(isDarkMode),
              size: 32,
            ),
          ),

          // Texto dinámico
          label: Text(
            isDarkMode ? "Cambiar a modo claro" : "Cambiar a modo oscuro",
          ),

          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: theme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
    );
  }
}

