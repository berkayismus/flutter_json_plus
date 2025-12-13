import 'package:flutter/material.dart';

import '../models/generation_options.dart';

class OptionsPanel extends StatelessWidget {
  final GenerationOptions options;
  final ValueChanged<GenerationOptions> onOptionsChanged;

  const OptionsPanel({
    super.key,
    required this.options,
    required this.onOptionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Options', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                SwitchListTile(
                  title: const Text('Use final'),
                  subtitle: const Text('Make fields final'),
                  value: options.useFinal,
                  onChanged: (value) {
                    onOptionsChanged(options.copyWith(useFinal: value));
                  },
                ),
                SwitchListTile(
                  title: const Text('Nullable'),
                  subtitle: const Text('Make fields nullable'),
                  value: options.makeNullable,
                  onChanged: (value) {
                    onOptionsChanged(options.copyWith(makeNullable: value));
                  },
                ),
                SwitchListTile(
                  title: const Text('fromJson / toJson'),
                  subtitle: const Text('Generate serialization methods'),
                  value: options.generateFromToJson,
                  onChanged: (value) {
                    onOptionsChanged(
                      options.copyWith(generateFromToJson: value),
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('copyWith'),
                  subtitle: const Text('Generate copyWith method'),
                  value: options.generateCopyWith,
                  onChanged: (value) {
                    onOptionsChanged(options.copyWith(generateCopyWith: value));
                  },
                ),
                SwitchListTile(
                  title: const Text('Required parameters'),
                  subtitle: const Text(
                    'Mark constructor parameters as required',
                  ),
                  value: options.useRequired,
                  onChanged: (value) {
                    onOptionsChanged(options.copyWith(useRequired: value));
                  },
                ),
                SwitchListTile(
                  title: const Text('Types only'),
                  subtitle: const Text('Generate only field declarations'),
                  value: options.typesOnly,
                  onChanged: (value) {
                    onOptionsChanged(options.copyWith(typesOnly: value));
                  },
                ),
                SwitchListTile(
                  title: const Text('Data class'),
                  subtitle: const Text('Override == and hashCode'),
                  value: options.generateDataClass,
                  onChanged: (value) {
                    onOptionsChanged(
                      options.copyWith(generateDataClass: value),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
