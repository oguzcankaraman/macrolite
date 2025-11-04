import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite, // Tüm alanı kapla
      painter: _ScannerOverlayPainter(),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Çerçevenin boyutlarını ve konumunu hesapla
    final screenWidth = size.width;
    final screenHeight = size.height;
    final boxWidth = screenWidth * 0.8; // Çerçeve genişliği (ekranın %80'i)
    final boxHeight = boxWidth * 0.6;   // Çerçeve yüksekliği (oranı ayarlanabilir)
    final left = (screenWidth - boxWidth) / 2;
    final top = (screenHeight - boxHeight) / 2;

    // Bulanıklaştırma efekti için yarı saydam siyah bir katman çiz
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.5);

    // Ortadaki çerçeveyi "kesmek" için bir yol (path) oluştur
    final cutoutPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight)),
      Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, boxWidth, boxHeight),
        const Radius.circular(16), // Köşeleri yuvarlat
      )),
    );

    // Bulanık katmanı, ortası kesik şekilde ekrana çiz
    canvas.drawPath(cutoutPath, backgroundPaint);

    // Çerçevenin etrafına beyaz bir kenarlık çiz (opsiyonel ama şık)
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, boxWidth, boxHeight),
        const Radius.circular(16),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}