import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'api_service.dart';
import 'defect_box.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;

  ResultScreen({required this.imageFile});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<DefectBox> defects = [];
  bool loading = true;
  File? finalImage;

  @override
  void initState() {
    super.initState();
    process();
  }

  Future<void> process() async {
    final response = await ApiService().upload(widget.imageFile);

    if (response != null) {
      defects = (response["defects"] as List)
          .map((d) =>
              DefectBox((d["x"] as num).toDouble(), (d["y"] as num).toDouble(),
                  (d["w"] as num).toDouble(), (d["h"] as num).toDouble()))
          .toList();

      finalImage = await drawBoxes(widget.imageFile);
      await GallerySaver.saveImage(finalImage!.path);

      setState(() => loading = false);
    }
  }

  Future<File> drawBoxes(File img) async {
    ui.Image decoded =
        await decodeImageFromList(await img.readAsBytes());

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint();
    final imgPaint = Paint();

    canvas.drawImage(decoded, Offset.zero, imgPaint);

    paint
      ..color = Colors.red
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (final d in defects) {
      Rect r = d.scale(decoded.width.toDouble(), decoded.height.toDouble());
      canvas.drawRect(r, paint);
    }

    final picture = recorder.endRecording();
    final imgFinal = await picture.toImage(decoded.width, decoded.height);
    final bytes = await imgFinal.toByteData(format: ui.ImageByteFormat.png);

    final out = File("${img.parent.path}/result.png");
    await out.writeAsBytes(bytes!.buffer.asUint8List());
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PCB Result")),
      body: Center(
        child: loading
            ? CircularProgressIndicator()
            : Image.file(finalImage!),
      ),
    );
  }
}
