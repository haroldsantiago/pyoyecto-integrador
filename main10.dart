import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulario Accesible',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AccessibleFormScreen(),
    );
  }
}

class AccessibleFormScreen extends StatefulWidget {
  @override
  _AccessibleFormScreenState createState() => _AccessibleFormScreenState();
}

class _AccessibleFormScreenState extends State<AccessibleFormScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final _formKey = GlobalKey<FormState>();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _listening = false;
  String _localeId = 'es-ES';
  TextEditingController? _activeController;
  double _soundLevel = 0.0;
  String _baseTextDuringListening = '';
  
  // Controladores para los campos de texto
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _telefonoController = TextEditingController();
  TextEditingController _mensajeController = TextEditingController();
  
  String _selectedOption = 'Opción 1';
  bool _aceptoTerminos = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();
  }

  _initTts() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
  }

  _speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        // Optional: you can provide auditory feedback with TTS
      },
      onError: (error) {
        // Optional: handle errors gracefully
      },
    );
    if (!mounted) return;
    _speechAvailable = available;

    // Try to select Spanish locale if available
    try {
      final locales = await _speech.locales();
      // Prefer es-CO for mejor reconocimiento en Colombia;
      // si no existe, usa el primer 'es-*', si no, cualquiera disponible.
      final esCO = locales.where((l) => l.localeId.toLowerCase() == 'es-co').toList();
      if (esCO.isNotEmpty) {
        _localeId = esCO.first.localeId;
      } else {
        final esLocale = locales.firstWhere(
          (l) => l.localeId.toLowerCase().startsWith('es'),
          orElse: () => locales.isNotEmpty ? locales.first : stt.LocaleName('en_US', 'English (US)'),
        );
        _localeId = esLocale.localeId;
      }
    } catch (_) {
      _localeId = 'es-ES';
    }
    // Forzar español como idioma de dictado (preferencia Colombia)
    _localeId = 'es-CO';
    setState(() {});
  }

  Future<void> _toggleListeningForController(TextEditingController controller) async {
    if (!_speechAvailable) {
      _speak('Reconocimiento de voz no disponible en este navegador.');
      return;
    }
    if (_listening) {
      await _speech.stop();
      setState(() {
        _listening = false;
        _activeController = null;
      });
      return;
    }
    _activeController = controller;
    _baseTextDuringListening = controller.text;
    setState(() {
      _listening = true;
    });
    // Asegurar que no haya TTS activo que interfiera con el dictado
    await flutterTts.stop();
    await _speech.listen(
      localeId: _localeId,
      onResult: (result) {
        // Escritura en tiempo real, pero los emails solo se confirman al final
        if (_activeController != null) {
          if (result.finalResult) {
            _commitFinalRecognizedText(_activeController!, result.recognizedWords);
            _speech.stop();
            setState(() {
              _listening = false;
              _activeController = null;
              _baseTextDuringListening = '';
            });
          } else {
            if (_activeController == _emailController) {
              // Evitar parciales en email para no generar formatos inválidos temporales
              return;
            }
            _showPartialRecognizedText(_activeController!, result.recognizedWords);
          }
        }
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 60),
      onSoundLevelChange: (level) {
        setState(() {
          _soundLevel = level;
        });
      },
      cancelOnError: true,
    );
  }

  void _showPartialRecognizedText(TextEditingController controller, String recognized) {
    String merged;
    if (controller == _emailController) {
      merged = _mergeEmail(_baseTextDuringListening, recognized);
    } else if (controller == _telefonoController) {
      merged = _mergePhone(_baseTextDuringListening, recognized);
    } else {
      merged = _mergeWithSpace(_baseTextDuringListening, recognized);
    }
    controller.text = merged;
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
  }

  void _commitFinalRecognizedText(TextEditingController controller, String recognized) {
    String merged;
    if (controller == _emailController) {
      merged = _mergeEmail(_baseTextDuringListening, recognized);
    } else if (controller == _telefonoController) {
      merged = _mergePhone(_baseTextDuringListening, recognized);
    } else {
      merged = _mergeWithSpace(_baseTextDuringListening, recognized);
    }
    controller.text = merged;
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
  }

  String _mergeWithSpace(String base, String addition) {
    final b = base.trimRight();
    final a = addition.trim();
    if (b.isEmpty) return a;
    final needsSpace = !b.endsWith(' ') && !b.endsWith('.') && !b.endsWith(',') && !b.endsWith(';') && !b.endsWith(':');
    return needsSpace ? '$b $a' : '$b$a';
  }

  String _mergeEmail(String base, String addition) {
    final b = _normalizeEmailDictation(base);
    final a = _normalizeEmailDictation(addition);
    return (b + a).replaceAll(' ', '');
  }

  String _normalizeEmailDictation(String input) {
    var s = input.toLowerCase();
    // eliminar espacios hablados
    s = s.replaceAll(RegExp(r'\bespacios?\b'), '');
    // símbolos comunes
    s = s.replaceAll(RegExp(r'\barroba\b'), '@');
    s = s.replaceAll(RegExp(r'\bat\b'), '@');
    s = s.replaceAll(RegExp(r'\bpunto\b'), '.');
    s = s.replaceAll(RegExp(r'\bguion bajo\b'), '_');
    s = s.replaceAll(RegExp(r'\bguion\b'), '-');
    s = s.replaceAll(RegExp(r'\bmenos\b'), '-');
    s = s.replaceAll(RegExp(r'\bmas\b'), '+');
    s = s.replaceAll(RegExp(r'\bmás\b'), '+');
    s = s.replaceAll(RegExp(r'\bdot\b'), '.');
    s = s.replaceAll(RegExp(r'\bplus\b'), '+');
    // dominios comunes hablados
    s = s.replaceAll(RegExp(r'punto\s*com'), '.com');
    s = s.replaceAll(RegExp(r'punto\s*co'), '.co');
    s = s.replaceAll(RegExp(r'punto\s*net'), '.net');
    s = s.replaceAll(RegExp(r'punto\s*org'), '.org');
    // quitar espacios y puntuación al final
    s = s.replaceAll(' ', '');
    s = s.replaceAll(RegExp(r'[\s\u00A0]'), '');
    s = s.replaceAll(RegExp(r'[，、]'), ''); // puntuación oriental por si acaso
    s = s.replaceAll(RegExp(r'[;:]'), '');
    return s;
  }

  String _mergePhone(String base, String addition) {
    final b = _normalizePhoneDictation(base);
    final a = _normalizePhoneDictation(addition);
    return b + a;
  }

  String _normalizePhoneDictation(String input) {
    var s = input.toLowerCase().trim();
    // Manejo de "<decena> y <unidad>" -> número (50 + 7 = 57)
    final tensMap = {
      'diez': 10,
      'veinte': 20,
      'treinta': 30,
      'cuarenta': 40,
      'cincuenta': 50,
      'sesenta': 60,
      'setenta': 70,
      'ochenta': 80,
      'noventa': 90,
    };
    final unitMap = {
      'cero': 0,
      'uno': 1,
      'una': 1,
      'dos': 2,
      'tres': 3,
      'cuatro': 4,
      'cinco': 5,
      'seis': 6,
      'siete': 7,
      'ocho': 8,
      'nueve': 9,
    };
    String replaceTensUnit(String text) {
      final regex = RegExp(r'(diez|veinte|treinta|cuarenta|cincuenta|sesenta|setenta|ochenta|noventa)\s+y\s+(cero|uno|una|dos|tres|cuatro|cinco|seis|siete|ocho|nueve)');
      return text.replaceAllMapped(regex, (m) {
        final tens = tensMap[m.group(1)!] ?? 0;
        final unit = unitMap[m.group(2)!] ?? 0;
        return (tens + unit).toString();
      });
    }
    s = replaceTensUnit(s);
    // reemplazar palabras por dígitos / símbolos
    final map = {
      'cero': '0',
      'uno': '1', 'una': '1',
      'dos': '2',
      'tres': '3',
      'cuatro': '4',
      'cinco': '5',
      'seis': '6',
      'siete': '7',
      'ocho': '8',
      'nueve': '9',
      'y': '',
      'más': '+', 'mas': '+', 'plus': '+',
      'guion': '-', 'guion medio': '-', 'guión': '-',
      'espacio': '', 'espacios': '',
      'parentesis': '', 'paréntesis': '',
    };
    map.forEach((k, v) {
      s = s.replaceAll(RegExp('\\b' + RegExp.escape(k) + '\\b'), v);
    });
    // quitar cualquier carácter no permitido
    s = s.replaceAll(RegExp(r'[^0-9+\-]'), '');
    return s;
  }

  // Función para leer la descripción de un campo
  _readFieldDescription(String fieldName, String description) {
    _speak("Campo $fieldName. $description");
  }

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_aceptoTerminos) {
        _speak("Debe aceptar los términos y condiciones");
        return;
      }
      
      _speak("Formulario enviado correctamente. Gracias por registrarse");
      // Aquí procesarías el formulario
    } else {
      _speak("Por favor, corrija los errores en el formulario");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FORMULARIO ACCESIBLE'),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: () => _speak("Formulario de registro. Complete todos los campos marcados como requeridos"),
            tooltip: 'Leer instrucciones',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título con botón de lectura
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Complete el formulario:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.record_voice_over),
                    onPressed: () => _speak("Formulario de registro. Complete todos los campos marcados con asterisco"),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Campo Nombre
              _buildTextFieldWithSpeech(
                controller: _nombreController,
                label: 'Nombre completo *',
                hint: 'Ingrese su nombre completo',
                fieldName: 'Nombre completo',
                description: 'Requerido. Escriba su nombre y apellido',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  }
                  return null;
                },
              ),

              SizedBox(height: 15),

              // Campo Email
              _buildTextFieldWithSpeech(
                controller: _emailController,
                label: 'Correo electrónico *',
                hint: 'ejemplo@correo.com',
                fieldName: 'Correo electrónico',
                description: 'Requerido. Ingrese un email válido',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su email';
                  }
                  if (!value.contains('@')) {
                    return 'Ingrese un email válido';
                  }
                  return null;
                },
              ),

              SizedBox(height: 15),

              // Campo Teléfono
              _buildTextFieldWithSpeech(
                controller: _telefonoController,
                label: 'Teléfono',
                hint: '+57 300 123 4567',
                fieldName: 'Teléfono',
                description: 'Opcional. Ingrese su número de contacto',
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 15),

              // Dropdown con lectura
              _buildDropdownWithSpeech(),

              SizedBox(height: 15),

              // Campo Mensaje
              _buildTextFieldWithSpeech(
                controller: _mensajeController,
                label: 'Mensaje o comentarios',
                hint: 'Escriba su mensaje aquí...',
                fieldName: 'Mensaje',
                description: 'Opcional. Escriba cualquier comentario adicional',
                maxLines: 4,
              ),

              SizedBox(height: 20),

              // Checkbox términos
              _buildCheckboxWithSpeech(),

              SizedBox(height: 30),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: Icon(Icons.send),
                      label: Text('ENVIAR FORMULARIO'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.volume_up),
                    onPressed: () => _speak("Botón enviar formulario. Presione para enviar la información"),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Botón para leer todo el formulario
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => _readFormSummary(),
                  icon: Icon(Icons.audio_file),
                  label: Text('LEER RESUMEN DEL FORMULARIO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithSpeech({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String fieldName,
    required String description,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.help_outline, size: 18),
              onPressed: () => _readFieldDescription(fieldName, description),
              tooltip: 'Leer descripción',
            ),
          ],
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
            suffixIcon: IconButton(
              icon: Icon(_listening && _activeController == controller ? Icons.mic : Icons.mic_none,
                  color: _listening && _activeController == controller && _soundLevel > 0.1 ? Colors.redAccent : null),
              tooltip: _listening && _activeController == controller ? 'Escuchando… toque para detener' : 'Dictar con voz',
              onPressed: () => _toggleListeningForController(controller),
            ),
          ),
          onTap: () => _readFieldDescription(fieldName, description),
        ),
      ],
    );
  }

  Widget _buildDropdownWithSpeech() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tipo de consulta *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.help_outline, size: 18),
              onPressed: () => _speak("Tipo de consulta. Seleccione una opción del menú desplegable"),
              tooltip: 'Leer descripción',
            ),
          ],
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _selectedOption,
          items: [
            'Opción 1',
            'Opción 2', 
            'Opción 3',
            'Opción 4',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedOption = newValue!;
            });
            _speak("Seleccionado: $newValue");
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxWithSpeech() {
    return Row(
      children: [
        Checkbox(
          value: _aceptoTerminos,
          onChanged: (bool? value) {
            setState(() {
              _aceptoTerminos = value!;
            });
            _speak(value! ? "Términos aceptados" : "Términos no aceptados");
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _aceptoTerminos = !_aceptoTerminos;
              });
              _speak(_aceptoTerminos ? "Términos aceptados" : "Términos no aceptados");
            },
            child: Text(
              'Acepto los términos y condiciones *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.help_outline, size: 18),
          onPressed: () => _speak("Debe aceptar los términos y condiciones para continuar"),
          tooltip: 'Leer descripción',
        ),
      ],
    );
  }

  void _readFormSummary() {
    String summary = """
      Resumen del formulario.
      Nombre: ${_nombreController.text.isEmpty ? 'No ingresado' : _nombreController.text}.
      Email: ${_emailController.text.isEmpty ? 'No ingresado' : _emailController.text}.
      Teléfono: ${_telefonoController.text.isEmpty ? 'No ingresado' : _telefonoController.text}.
      Tipo de consulta: $_selectedOption.
      Mensaje: ${_mensajeController.text.isEmpty ? 'No ingresado' : _mensajeController.text}.
      Términos: ${_aceptoTerminos ? 'Aceptados' : 'No aceptados'}.
    """;
    _speak(summary);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _mensajeController.dispose();
    _speech.stop();
    flutterTts.stop();
    super.dispose();
  }
}