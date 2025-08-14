import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:around_you/widgets/glassmorphic_container.dart';
// To use the AR features, you'll need to uncomment the following lines
// and complete the setup for the ar_flutter_plugin.
// import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
// import 'package:ar_flutter_plugin/datatypes/node_types.dart';
// import 'package:ar_flutter_plugin/models/ar_node.dart';

class ARMemoryScreen extends StatefulWidget {
  const ARMemoryScreen({super.key});

  @override
  State<ARMemoryScreen> createState() => _ARMemoryScreenState();
}

class _ARMemoryScreenState extends State<ARMemoryScreen> {
  // late ARSessionManager arSessionManager;
  // late ARObjectManager arObjectManager;

  // This function will be called when the AR View is created
  // void onARViewCreated(ARSessionManager sessionManager, ARObjectManager objectManager) {
  //   arSessionManager = sessionManager;
  //   arObjectManager = objectManager;
  //   arSessionManager.onInitialize(
  //     showFeaturePoints: false,
  //     showPlanes: true,
  //     customPlaneTexturePath: "assets/triangle.png", // Example texture
  //     showWorldOrigin: true,
  //     handleTaps: true,
  //   );
  //   arObjectManager.onInitialize();
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Your Memory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // The AR view would go here. It's commented out because it requires
          // native setup and the ar_flutter_plugin.
          // ARView(onARViewCreated: onARViewCreated),
          
          // Placeholder for the AR view to allow UI development
          Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.view_in_ar_outlined, color: theme.primaryColor, size: 100),
                  const SizedBox(height: 20),
                  const Text(
                    'AR Camera View',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                   Text(
                    'Move your phone to detect a surface',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // UI for adding memory details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 320,
              borderRadius: 20,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Customize Your Memory', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 15),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Add a message...',
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMediaButton(context, icon: Icons.photo_camera_back_outlined, label: 'Photo'),
                        _buildMediaButton(context, icon: Icons.mic_none_outlined, label: 'Audio'),
                        _buildMediaButton(context, icon: Icons.view_in_ar_outlined, label: 'Object'),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Save memory to Firestore with geolocation
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
                      child: const Text('ANCHOR MEMORY HERE'),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMediaButton(BuildContext context, {required IconData icon, required String label}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 35, color: theme.colorScheme.primary),
          onPressed: () { /* TODO: Implement media selection logic */ },
        ),
        Text(label, style: TextStyle(color: theme.colorScheme.primary)),
      ],
    );
  }
}
