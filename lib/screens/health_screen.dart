// lib/screens/health_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For formatting dates
import '../providers/user_data_provider.dart';
import '../utils/sound_manager.dart'; // <-- IMPORT SOUND MANAGER

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  void _showFeedback(BuildContext context, String? message, bool isError) {
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final userData = context.watch<UserDataProvider>().userData;

    String lastWaterText = userData?.lastWaterTime != null
        ? 'Last logged: ${DateFormat.jm().format(userData!.lastWaterTime!)}'
        : 'Not logged yet today/recently.';

    String lastBrushText = userData?.lastBrushTime != null
        ? 'Last logged: ${DateFormat.yMd().add_jm().format(userData!.lastBrushTime!)}'
        : 'Not logged recently.';

    int waterToday = userData?.waterCountToday ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Health Activities'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Water Logging
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drink Water ($waterToday/6 Today)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(lastWaterText, style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 15),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.local_drink),
                        label: const Text('Log 1 Glass of Water'),
                        onPressed: () async {
                          SoundManager.playClickSound(); // <-- PLAY SOUND
                          String? result = await userDataProvider.logWater();
                          _showFeedback(context, result, result != null && !result.startsWith("Water logged"));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Brushing Logging
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brush Teeth',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(lastBrushText, style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 15),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.wash),
                        label: const Text('Log Brushing'),
                        onPressed: () async {
                          SoundManager.playClickSound(); // <-- PLAY SOUND
                          String? result = await userDataProvider.logBrush();
                          _showFeedback(context, result, result != null && !result.startsWith("Brushing logged"));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
