import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import 'result_screen.dart';

class CaptureScreen extends StatefulWidget {
  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? controller;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cams = await availableCameras();
    controller = CameraController(cams[0], ResolutionPreset.max);
    await controller!.initialize();
    setState(() => initialized = true);
  }

  Future<void> captureAndAnalyze() async {
    if (!controller!.value.isInitialized) return;

    final dir = await getTemporaryDirectory();
    final path = "${dir.path}/capture.jpg";

    await controller!.takePicture().then((XFile file) {
      File(file.path).copySync(path);
    });

    File captured = File(path);

    var result = await ApiService().analyzePCB(captured);

    if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Server error")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          processedBase64: result["processed_image"],
          defectCount: result["defect_count"],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Capture PCB")),
      body: Column(
        children: [
          Expanded(child: CameraPreview(controller!)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: captureAndAnalyze,
              child: Text("Capture & Analyze"),
            ),
          )
        ],
      ),
    );
  }
}
