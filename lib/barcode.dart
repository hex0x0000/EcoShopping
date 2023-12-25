import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'products.dart';
import 'data.dart';

class BarcodePage extends StatefulWidget {
  final ValueNotifier<Future<List<ProductCardWidget>>> productCards;
  const BarcodePage({super.key, required this.productCards});

  @override
  State<BarcodePage> createState() => _BarcodePage();
}

class _BarcodePage extends State<BarcodePage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _found = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scannerizza'),
        actions: [
          IconButton(
            onPressed: () => cameraController.toggleTorch(),
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
          ),
          IconButton(
            onPressed: () => cameraController.switchCamera(),
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
          ),
        ],
      ),
      body: MobileScanner(
        fit: BoxFit.contain,
        controller: cameraController,
        onDetect: (capture) {
          if (_found) {
            return;
          }
          for (final barcode in capture.barcodes) {
            if (barcode.format == BarcodeFormat.unknown) {
              continue;
            }
            debugPrint(
                "VALUE: ${barcode.rawValue} , FORMAT RAW: ${barcode.format.rawValue}");
            widget.productCards.value = addToSavedProductCards(
              widget.productCards.value,
              getCardFromId(barcode.rawValue, barcode.format.rawValue),
            );
            _found = true;
            Navigator.of(context).popUntil((route) => route.isFirst);
            return;
          }
        },
      ),
    );
  }
}
