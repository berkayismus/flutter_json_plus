import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class OutputPanel extends StatelessWidget {
  final String generatedCode;
  final VoidCallback onCopy;

  const OutputPanel({
    super.key,
    required this.generatedCode,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Generated Code',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: generatedCode.isEmpty ? null : onCopy,
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFF23241F),
              ),
              child: generatedCode.isEmpty
                  ? const Center(
                      child: Text(
                        'Generated code will appear here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: HighlightView(
                        generatedCode,
                        language: 'dart',
                        theme: monokaiSublimeTheme,
                        padding: const EdgeInsets.all(0),
                        textStyle: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
