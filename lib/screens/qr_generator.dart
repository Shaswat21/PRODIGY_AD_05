import 'dart:ui' as ui hide TextStyle;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class QRGenerator extends StatefulWidget {
  const QRGenerator({super.key});

  @override
  State<QRGenerator> createState() => _QRGeneratorState();
}

class _QRGeneratorState extends State<QRGenerator> {
  final TextEditingController _controller = TextEditingController();
  String qrData = '';
  bool transparentBackground = false;

  GlobalKey globalKey = new GlobalKey();

  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = (await getApplicationDocumentsDirectory()).path;
      final imgFile = File('$directory/qr_code.png');
      await imgFile.writeAsBytes(pngBytes);

      final result = await ImageGallerySaver.saveFile(imgFile.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code saved to gallery'),backgroundColor: Colors.green,),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving QR code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'QR Generator',
          style: TextStyle(fontSize: 30),
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.popAndPushNamed(context, 'qr_scanner'),
              icon: const Icon(Icons.qr_code_scanner))
        ],
      ),
      body: Container(
          padding: const EdgeInsets.all(21),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    qrData = value;
                  });
                },
                controller: _controller,
                decoration: InputDecoration(
                    hintText: 'Enter Text',
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _controller.text = '';
                                qrData = '';
                              });
                            },
                            icon: const Icon(Icons.close))
                        : null,
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 50))),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: qrData.isNotEmpty
                    ? RepaintBoundary(
                        key: globalKey,
                        child: QrImageView(
                          data: qrData,
                          backgroundColor: transparentBackground ? Colors.transparent :Colors.white,
                          errorStateBuilder: (cxt, err) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Something went wrong!')));
                            return const SizedBox.shrink();
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transparent Background',style: TextStyle(fontSize: 20),),
                      Switch(
                        value: transparentBackground,
                        onChanged: (value) {
                          setState(() {
                            transparentBackground = value;
                          });
                        },
                      )
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      if (qrData.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No QR Found')));
                        return;
                      }
                      _captureAndSavePng();
                    },
                    style: ButtonStyle(
                        backgroundColor: const MaterialStatePropertyAll(
                            Color.fromRGBO(25, 25, 25, 1)),
                        minimumSize: MaterialStatePropertyAll(
                            Size(MediaQuery.sizeOf(context).width, 50))),
                    child: const Text(
                      'Download',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
