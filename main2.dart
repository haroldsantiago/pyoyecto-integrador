import 'package:flutter/material.dart';

/// Flutter code sample for [AppBar].

final List<int> _items = List<int>.generate(51, (int index) => index);

void main() => runApp(const AppBarApp());

class AppBarApp extends StatefulWidget {
  const AppBarApp({super.key});

  @override
  State<AppBarApp> createState() => _AppBarAppState();
}

class _AppBarAppState extends State<AppBarApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: const Color(0xff6750a4)),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xff6750a4),
      ),
      themeMode: _themeMode,
      home: AppBarExample(toggleThemeMode: _toggleThemeMode, isDarkMode: _themeMode == ThemeMode.dark),
    );
  }
}

class AppBarExample extends StatefulWidget {
  final Function toggleThemeMode;
  final bool isDarkMode;
  
  const AppBarExample({
    super.key, 
    required this.toggleThemeMode,
    required this.isDarkMode,
  });

  @override
  State<AppBarExample> createState() => _AppBarExampleState();
}

class _AppBarExampleState extends State<AppBarExample> {
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Ajustamos los colores según el modo
    final Color oddItemColor = widget.isDarkMode 
        ? colorScheme.primary.withAlpha(100) 
        : colorScheme.primary.withAlpha(77);
    final Color evenItemColor = widget.isDarkMode 
        ? colorScheme.primary.withAlpha(150) 
        : colorScheme.primary.withAlpha(128);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor: shadowColor ? Theme.of(context).colorScheme.shadow : null,
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
            // tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
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
                  Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                  const SizedBox(width: 8),
                  Switch(
                    value: widget.isDarkMode,
                    onChanged: (value) {
                      widget.toggleThemeMode();
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(widget.isDarkMode ? 'Modo oscuro' : 'Modo claro'),
                ],
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    shadowColor = !shadowColor;
                  });
                },
                icon: Icon(shadowColor ? Icons.visibility_off : Icons.visibility),
                label: const Text('shadow color'),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  if (scrolledUnderElevation == null) {
                    setState(() {
                      // Default elevation is 3.0, increment by 1.0.
                      scrolledUnderElevation = 4.0;
                    });
                  } else {
                    setState(() {
                      scrolledUnderElevation = scrolledUnderElevation! + 1.0;
                    });
                  }
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