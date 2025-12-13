import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/generation_options.dart';
import '../services/dart_generator.dart';
import '../services/json_parser.dart';
import '../widgets/json_input_panel.dart';
import '../widgets/options_panel.dart';
import '../widgets/output_panel.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _classNameController = TextEditingController(
    text: 'MyClass',
  );
  final TextEditingController _jsonController = TextEditingController();

  GenerationOptions _options = const GenerationOptions();
  String _generatedCode = '';

  final JsonParser _parser = JsonParser();
  final DartGenerator _generator = DartGenerator();

  @override
  void dispose() {
    _classNameController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  void _generateCode() {
    final className = _classNameController.text.trim();
    final jsonText = _jsonController.text.trim();

    // Validate class name
    if (className.isEmpty) {
      _showError('Please enter a class name');
      return;
    }

    // Validate JSON
    if (jsonText.isEmpty) {
      _showError('Please enter JSON data');
      return;
    }

    // Parse JSON
    final parseResult = _parser.parseJson(jsonText, className);

    if (!parseResult.success) {
      setState(() {
        _generatedCode = '';
      });
      _showError('Invalid JSON format');
      return;
    }

    // Generate code
    final code = _generator.generateCode(parseResult, _options);

    setState(() {
      _generatedCode = code;
    });
  }

  void _copyToClipboard() {
    if (_generatedCode.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _generatedCode));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON to Dart Class Converter'),
        centerTitle: true,
      ),
      body: isWideScreen ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left panel - Input and Options
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: JsonInputPanel(
                  classNameController: _classNameController,
                  jsonController: _jsonController,
                ),
              ),
              Expanded(
                flex: 2,
                child: OptionsPanel(
                  options: _options,
                  onOptionsChanged: (newOptions) {
                    setState(() {
                      _options = newOptions;
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _generateCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Generate', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),

        // Right panel - Output
        Expanded(
          flex: 3,
          child: OutputPanel(
            generatedCode: _generatedCode,
            onCopy: _copyToClipboard,
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        // Top section - Input and Options
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: JsonInputPanel(
                    classNameController: _classNameController,
                    jsonController: _jsonController,
                  ),
                ),
                SizedBox(
                  height: 400,
                  child: OptionsPanel(
                    options: _options,
                    onOptionsChanged: (newOptions) {
                      setState(() {
                        _options = newOptions;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _generateCode,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Generate',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom section - Output
        Expanded(
          child: OutputPanel(
            generatedCode: _generatedCode,
            onCopy: _copyToClipboard,
          ),
        ),
      ],
    );
  }
}
