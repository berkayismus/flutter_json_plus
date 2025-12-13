import 'package:flutter/material.dart';

class JsonInputPanel extends StatelessWidget {
  final TextEditingController classNameController;
  final TextEditingController jsonController;

  const JsonInputPanel({
    super.key,
    required this.classNameController,
    required this.jsonController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Input', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: classNameController,
            decoration: const InputDecoration(
              labelText: 'Class Name',
              border: OutlineInputBorder(),
              hintText: 'e.g., User',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: jsonController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                labelText: 'JSON Data',
                border: OutlineInputBorder(),
                hintText: 'Paste your JSON here...',
                alignLabelWithHint: true,
              ),
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ],
      ),
    );
  }
}
