import 'package:flutter/material.dart';
import 'cling_ble_service.dart';

class MinuteDataScreen extends StatelessWidget {
  const MinuteDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minute Data'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ClingBleService.deregisterDevice();
              Navigator.pop(context);
            },
            child: const Text('De-register Device'),
          ),


        ],
      ),
      body: StreamBuilder(
        stream: ClingBleService.minuteDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Waiting for minute data...'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No minute data received yet'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              snapshot.data.toString(),
              style: const TextStyle(fontSize: 14),
            ),
          );
        },
      ),
    );
  }
}

