import 'package:flutter/material.dart';

void main() => runApp(const AppBarApp());

class AppBarApp extends StatelessWidget {
  const AppBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppBar Demo',
      debugShowCheckedModeBanner: false, // 🔹 quita la etiqueta "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green, // 🔹 color principal de la app
          brightness: Brightness.light, // 🔹 modo claro
        ),
        useMaterial3: true, // 🔹 diseño Material 3 (más moderno)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 15, 228, 22), // 🔹 AppBar verde
          foregroundColor: Colors.black, // 🔹 texto e íconos blancos
          elevation: 3, // 🔹 pequeña sombra debajo del AppBar
          centerTitle: false,
        ),
      ),
      home: const AppBarExample(),
    );
  }
}

class AppBarExample extends StatelessWidget {
  const AppBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        leading: const Icon(Icons.menu), // Agregando un icono de menú a la izquierda
        actions: <Widget>[
          // 🔔 Botón 1: muestra SnackBar
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Este es el primer SnackBar',
                    style: TextStyle(color: Colors.black), // Color del texto negro
                  ),
                  duration: const Duration(seconds: 5), // Duración personalizada: 5 segundos
                  backgroundColor: const Color.fromARGB(255, 211, 229, 8), // Color de fondo personalizado
                ),
              );
            },
          ),

          // ➡️ Botón 2: navega a otra página
          IconButton(
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Go to the next page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return const NextPage();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Hola a todos, bienvenidos a la app!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagina anterior'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Función para volver a la página anterior
          },
        ),
      ),
      body: const Center(
        child: Text(
          'Esta es la siguiente pagina',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

