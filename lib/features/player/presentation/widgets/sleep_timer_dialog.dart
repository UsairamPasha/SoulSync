import 'package:flutter/material.dart';
import 'package:soulsync/shared/widgets/snackbars/app_snackbars.dart';

class SleepTimerDialog extends StatelessWidget {
  const SleepTimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      {'label': '15 minutes', 'minutes': 15},
      {'label': '30 minutes', 'minutes': 30},
      {'label': '45 minutes', 'minutes': 45},
      {'label': '60 minutes', 'minutes': 60},
      {'label': 'Turn Off', 'minutes': 0},
    ];

    return AlertDialog(
      title: const Text('Sleep Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final label = opt['label'] as String;
          final mins = opt['minutes'] as int;
          return ListTile(
            title: Text(label),
            onTap: () {
              Navigator.of(context).pop();
              if (mins > 0) {
                AppSnackBars.showSuccess(
                    context, 'Sleep timer set for $mins minutes.');
              } else {
                AppSnackBars.showInfo(context, 'Sleep timer turned off.');
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
