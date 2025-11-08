import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // CustomPaint'i SizedBox içine alarak tam ekran yap
            SizedBox.expand(
              child: CustomPaint(
                painter: _ScannerOverlayPainter(),
              ),
            ),
            // Yönerge metni
            _buildInstructionText(constraints),
          ],
        );
      },
    );
  }

  Widget _buildInstructionText(BoxConstraints constraints) {
    final boxWidth = constraints.maxWidth * 0.8;
    final boxHeight = boxWidth * 0.6;
    final top = (constraints.maxHeight - boxHeight) / 2;

    return Positioned(
      top: top + boxHeight + 20, // Kutunun altına yerleştir
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Column(
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: Colors.white.withValues(alpha: 0.9),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Barkodu kutunun içine hizalayın',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Tarama otomatik olarak başlayacak',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final screenWidth = size.width;
    final screenHeight = size.height;
    final boxWidth = screenWidth * 0.8;
    final boxHeight = boxWidth * 0.6;
    final left = (screenWidth - boxWidth) / 2;
    final top = (screenHeight - boxHeight) / 2;

    // Bulanık arka plan
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    final cutoutPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight)),
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, boxWidth, boxHeight),
          const Radius.circular(16),
        ),
      ),
    );

    canvas.drawPath(cutoutPath, backgroundPaint);

    // Animasyonlu köşe çizgileri
    final cornerPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    final rect = Rect.fromLTWH(left, top, boxWidth, boxHeight);

    // Sol üst köşe
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // Sağ üst köşe
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Sol alt köşe
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // Sağ alt köşe
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
