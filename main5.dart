import 'package:flutter/material.dart';

/// Flutter code sample for [AppBar] with dynamic color, SnackBar, and Switch.

final List<int> _items = List<int>.generate(51, (int index) => index);

void main() => runApp(const AppBarApp());

class AppBarApp extends StatelessWidget {
  const AppBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: const Color(0xff00BCD4)),
      debugShowCheckedModeBanner: false, // Añadido para quitar el banner de debug
      home: const AppBarExample(),
    );
  }
}

class AppBarExample extends StatefulWidget {
  const AppBarExample({super.key});

  @override
  State<AppBarExample> createState() => _AppBarExampleState();
}

class _AppBarExampleState extends State<AppBarExample> {
  bool shadowColor = false;
  double? scrolledUnderElevation;
  Color appBarColor = const Color(0xFF0D47A1);
  Color scaffoldBackgroundColor = const Color(0xFFF5F5F5);
  final List<Color> _appBarColors = [
    const Color(0xFF0D47A1), // Azul profundo
    const Color(0xFF1B5E20), // Verde muy oscuro
    const Color(0xFFB71C1C), // Rojo muy oscuro
    const Color(0xFF4A148C), // Morado muy oscuro
    const Color(0xFF004D40), // Teal muy oscuro
  ];
  final List<Color> _scaffoldColors = [
    const Color(0xFFF5F5F5), // Gris muy claro
    const Color(0xFFFFF8E1), // Ámbar muy claro
    const Color(0xFFE8F5E9), // Verde muy claro
    const Color(0xFFE3F2FD), // Azul muy claro
    const Color(0xFFFFEBEE), // Rojo muy claro
  ];
  int _currentAppBarColorIndex = 0;
  int _currentScaffoldColorIndex = 0;

  void _changeAppBarColor(int newIndex, bool isAppBar) {
    setState(() {
      if (isAppBar) {
        _currentAppBarColorIndex = newIndex;
        appBarColor = _appBarColors[_currentAppBarColorIndex];
      } else {
        _currentScaffoldColorIndex = newIndex;
        scaffoldBackgroundColor = _scaffoldColors[_currentScaffoldColorIndex];
      }
    });
  }

  void _showElevationSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('scrolledUnderElevation: ${scrolledUnderElevation ?? 'default'}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('AppBar Demo', style: TextStyle(color: Colors.white)),
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor: shadowColor ? Theme.of(context).colorScheme.shadow : null,
        backgroundColor: appBarColor,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.color_lens, color: Colors.white),
            tooltip: 'Colores del AppBar',
            onSelected: (int newIndex) => _changeAppBarColor(newIndex, true),
            itemBuilder: (BuildContext context) {
              return _appBarColors.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                return PopupMenuItem<int>(
                  value: index,
                  child: ListTile(
                    leading: Container(width: 20, height: 20, color: color),
                    title: Text(
                      'Color del AppBar ${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList();
            },
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.format_color_fill, color: Colors.white),
            tooltip: 'Color de fondo',
            onSelected: (int newIndex) => _changeAppBarColor(newIndex, false),
            itemBuilder: (BuildContext context) {
              return _scaffoldColors.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                return PopupMenuItem<int>(
                  value: index,
                  child: ListTile(
                    leading: Container(width: 20, height: 20, color: color),
                    title: Text(
                      'Color de fondo ${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: GridView.builder(
        itemCount: _items.length,
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.0,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Center(
              child: Text(
                'Scroll to see the Appbar in effect.',
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
            );
          }
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: _items[index].isOdd ? oddItemColor : evenItemColor,
            ),
            child: Text('Item $index'),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: OverflowBar(
            overflowAlignment: OverflowBarAlignment.center,
            alignment: MainAxisAlignment.center,
            overflowSpacing: 5.0,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Shadow Color'),
                  Switch(
                    value: shadowColor,
                    onChanged: (bool value) {
                      setState(() {
                        shadowColor = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (scrolledUnderElevation == null) {
                      scrolledUnderElevation = 4.0;
                    } else {
                      scrolledUnderElevation = scrolledUnderElevation! + 1.0;
                    }
                    _showElevationSnackBar();
                  });
                },
                child: Text('scrolledUnderElevation: ${scrolledUnderElevation ?? 'default'}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
