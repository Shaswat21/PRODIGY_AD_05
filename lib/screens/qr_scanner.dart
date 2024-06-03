import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isModalOpen = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'QR Scanner',
          style: TextStyle(fontSize: 30),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, 'qr_generator'),
            icon: const Icon(Icons.qr_code),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null && !isModalOpen) {
          isModalOpen =
              true;
          _showModalBottomSheet(context, result!);
        }
      });
    });
  }

  void _showModalBottomSheet(BuildContext context, Barcode result) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: MediaQuery.sizeOf(context).width / 2,
                    height: 5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey),
                  )),
              Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.code ?? ''))
                          .whenComplete(() => ScaffoldMessenger.of(context)
                              .showSnackBar(
                                  const SnackBar(content: Text('Copied!'))));
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.copy_rounded),
                  )),
              Text(
                'Barcode Type: ${describeEnum(result.format)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Data: ${result.code}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ).whenComplete(() {
      isModalOpen =
          false;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
