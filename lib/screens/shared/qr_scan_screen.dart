import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/api_service.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final MobileScannerController controller = MobileScannerController();

  bool isScanning = false;
  bool isLoading = false;
  String? errorMessage;
  String? scanResult;

  bool _hasNavigated = false;

  // =========================
  // STOP CAMERA SAFELY
  // =========================
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // =========================
  // ON QR DETECTED
  // =========================
  Future<void> onDetect(BarcodeCapture capture) async {
    if (_hasNavigated) return;

    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;

    if (value == null) return;

    setState(() {
      scanResult = value;
      isLoading = true;
    });

    try {
      await controller.stop();

      setState(() {
        isScanning = false;
      });

      // =========================
      // FORMAT CHECK
      // =========================
      if (value.startsWith("artisan:")) {
        final artisanId = value.replaceFirst("artisan:", "");

        // OPTIONAL: verify backend existence
        await ApiService.get("/artisans/$artisanId");

        _hasNavigated = true;

        // 👉 OPEN PUBLIC PROFILE
        Get.offNamed("/artisan/public/$artisanId");
      } else {
        setState(() {
          errorMessage = "QR code invalide";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur lors du chargement du profil";
        isLoading = false;
      });
    }
  }

  // =========================
  // START SCAN
  // =========================
  void startScan() {
    setState(() {
      errorMessage = null;
      scanResult = null;
      isScanning = true;
      isLoading = false;
      _hasNavigated = false;
    });
  }

  // =========================
  // STOP SCAN
  // =========================
  Future<void> stopScan() async {
    await controller.stop();
    setState(() {
      isScanning = false;
    });
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: const Text("Scanner QR Code"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  Icon(Icons.qr_code_scanner,
                      size: 60, color: Colors.blue),

                  SizedBox(height: 10),

                  Text(
                    "Scanner un artisan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Pointez la caméra vers le QR code",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= ERROR =================
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // ================= SCAN RESULT =================
            if (scanResult != null && errorMessage == null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        scanResult!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),

            // ================= SCANNER =================
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    if (isScanning)
                      MobileScanner(
                        controller: controller,
                        onDetect: onDetect,
                      )
                    else
                      Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    if (isLoading)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isScanning ? stopScan : startScan,
                icon: Icon(isScanning ? Icons.stop : Icons.camera_alt),
                label: Text(
                  isScanning ? "Arrêter le scan" : "Démarrer le scan",
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor:
                  isScanning ? Colors.red : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= HELP =================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Comment ça marche ?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text("1. Démarrer le scan"),
                  Text("2. Autoriser la caméra"),
                  Text("3. Scanner QR artisan"),
                  Text("4. Ouverture du profil automatiquement"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}