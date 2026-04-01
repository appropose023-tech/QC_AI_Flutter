import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import 'result_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? controller;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    initCam();
  }

  Future<void> initCam() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras.first, ResolutionPreset.max);

    await controller!.initialize();
    setState(() => initialized = true);
  }

  Future<void> captureImage() async {
    if (!controller!.value.isInitialized) return;

    final XFile img = await controller!.takePicture();

    final Directory temp = await getTemporaryDirectory();
    final File file = File("${temp.path}/pcb_input.jpg");
    File(img.path).copySync(file.path);

    final processed = await ApiService().uploadImage(file);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          original: file,
          processed: processed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(controller!),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: captureImage,
                child: const Text("Capture PCB"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
