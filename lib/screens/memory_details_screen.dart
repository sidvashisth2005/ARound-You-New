import 'package:flutter/material.dart';
import 'package:around_you/widgets/glassmorphic_container.dart';

class MemoryDetailsScreen extends StatelessWidget {
  final String memoryId;

  const MemoryDetailsScreen({super.key, required this.memoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Memory Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassmorphicContainer(
              width: double.infinity,
              height: 200,
              borderRadius: 20,
              blur: 20,
              border: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.memory,
                    size: 64,
                    color: Colors.cyan.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memory ID: $memoryId',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Memory Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphicContainer(
              width: double.infinity,
              height: 200,
              borderRadius: 15,
              blur: 20,
              border: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This is a placeholder for memory details.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You can add more details here like:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Location',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '• Date & Time',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '• Description',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '• Media attachments',
                      style: TextStyle(color: Colors.white70),
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
