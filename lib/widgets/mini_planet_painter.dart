import 'package:flutter/material.dart';
import 'dart:math' as math;

class MiniPlanetPainter extends CustomPainter {
  final Color color;
  final String name;

  MiniPlanetPainter(this.color, this.name);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 行星漸層效果
    final planetGradient = RadialGradient(
      colors: [
        color,
        color.withOpacity(0.8),
        color.withOpacity(0.6),
      ],
      stops: const [0.4, 0.8, 1.0],
    );

    final gradientPaint = Paint()
      ..shader = planetGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    // 根據不同行星繪製不同效果
    switch (name) {
      case "太陽":
        // 1. 外層光暈效果（先畫最外層）
        for (var i = 0; i < 4; i++) {
          canvas.drawCircle(
            center,
            radius * (1.8 - i * 0.2),
            Paint()
              ..color = Colors.yellow.withOpacity(0.05)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }

        // 2. 基礎漸層
        final sunGradient = RadialGradient(
          colors: [
            Colors.yellow[300]!, // 明亮的黃色核心
            Colors.yellow[500]!,
            Colors.orange[500]!,
            Colors.orange[700]!,
            Colors.red[700]!,
          ],
          stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
        );

        // 3. 繪製基礎太陽體
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..shader = sunGradient.createShader(
              Rect.fromCircle(center: center, radius: radius),
            )
        );

        // 4. 添加表面細節紋理
        final random = math.Random(1);
        for (var i = 0; i < 8; i++) {
          final angle = i * (math.pi / 4);
          final distance = radius * 0.7;
          final length = radius * 0.8;
          final width = radius * 0.15;
          
          final flareGradient = RadialGradient(
            colors: [
              Colors.yellow[300]!.withOpacity(0.4),
              Colors.orange[500]!.withOpacity(0.2),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          );

          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.rotate(angle);
          
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(distance * 0.5, 0),
              width: length,
              height: width,
            ),
            Paint()
              ..shader = flareGradient.createShader(
                Rect.fromCircle(center: Offset.zero, radius: radius),
              )
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
          );
          canvas.restore();
        }

        // 5. 中層發光效果
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            center,
            radius * (1.2 - i * 0.1),
            Paint()
              ..color = Colors.yellow.withOpacity(0.2 - i * 0.05)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
        break;

      case "水星":
        // 基本球體
        canvas.drawCircle(center, radius, gradientPaint);
        
        // 添加隕石坑
        final craterPaint = Paint()
          ..color = Colors.grey[800]!.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        
        final random = math.Random(1);
        for (var i = 0; i < 3; i++) {
          final craterRadius = radius * (0.1 + random.nextDouble() * 0.15);
          final angle = random.nextDouble() * 2 * math.pi;
          final distance = radius * random.nextDouble() * 0.6;
          canvas.drawCircle(
            Offset(
              center.dx + math.cos(angle) * distance,
              center.dy + math.sin(angle) * distance,
            ),
            craterRadius,
            craterPaint,
          );
        }
        break;

      case "金星":
        // 基本球體
        canvas.drawCircle(center, radius, gradientPaint);
        
        // 添加大氣層效果
        for (var i = 0; i < 2; i++) {
          canvas.drawCircle(
            center,
            radius * (1.1 + i * 0.05),
            Paint()
              ..color = Colors.orange[300]!.withOpacity(0.1)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
          );
        }
        break;

      case "地球":
        // 基本球體
        canvas.drawCircle(center, radius, gradientPaint);
        
        // 使用裁剪確保效果在圓形內
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
        
        // 添加陸地
        final random = math.Random(2);
        final landPaint = Paint()
          ..color = Colors.green[800]!.withOpacity(0.6);
        
        for (var i = 0; i < 4; i++) {
          final angle = random.nextDouble() * 2 * math.pi;
          final distance = radius * random.nextDouble() * 0.7;
          final size = radius * 0.4;
          canvas.drawCircle(
            Offset(
              center.dx + math.cos(angle) * distance,
              center.dy + math.sin(angle) * distance,
            ),
            size,
            landPaint,
          );
        }
        
        // 添加雲層
        final cloudPaint = Paint()
          ..color = Colors.white.withOpacity(0.3);
        for (var i = 0; i < 3; i++) {
          final angle = random.nextDouble() * 2 * math.pi;
          final distance = radius * random.nextDouble() * 0.8;
          canvas.drawCircle(
            Offset(
              center.dx + math.cos(angle) * distance,
              center.dy + math.sin(angle) * distance,
            ),
            radius * 0.2,
            cloudPaint,
          );
        }
        canvas.restore();
        break;

      case "火星":
        // 基本球體
        canvas.drawCircle(center, radius, gradientPaint);
        
        // 表面特徵
        final featurePaint = Paint()
          ..color = Colors.red[900]!.withOpacity(0.3);
        for (var i = 0; i < 2; i++) {
          final angle = i * math.pi;
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(
                center.dx + math.cos(angle) * radius * 0.3,
                center.dy + math.sin(angle) * radius * 0.3,
              ),
              width: radius * 0.5,
              height: radius * 0.2,
            ),
            featurePaint,
          );
        }
        
        // 極冠
        canvas.drawCircle(
          Offset(center.dx, center.dy - radius * 0.6),
          radius * 0.2,
          Paint()..color = Colors.white.withOpacity(0.4),
        );
        break;

      case "木星":
        // 繪製基本圓形
        canvas.drawCircle(center, radius, gradientPaint);
        
        // 使用裁剪確保條紋不會超出圓形
        canvas.save();
        canvas.clipPath(
          Path()..addOval(Rect.fromCircle(center: center, radius: radius))
        );
        
        // 添加條紋效果
        for (var i = -2; i <= 2; i++) {
          canvas.drawLine(
            Offset(0, center.dy + i * radius * 0.2),
            Offset(size.width, center.dy + i * radius * 0.2),
            Paint()
              ..color = Colors.orange[800]!.withOpacity(0.3)
              ..strokeWidth = radius * 0.15,
          );
        }
        canvas.restore();
        break;

      case "土星":
        // 繪製行星本體
        canvas.drawCircle(center, radius * 0.8, gradientPaint);
        
        // 繪製環
        final ringPaint = Paint()
          ..color = Colors.yellow[700]!.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.2;
        
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: radius * 2,
            height: radius * 0.5,
          ),
          ringPaint,
        );
        break;

      case "天王星":
        // 基本球體
        canvas.drawCircle(center, radius, gradientPaint);
        
        // 添加大氣層效果
        for (var i = 0; i < 2; i++) {
          canvas.drawCircle(
            center,
            radius * (1.1 + i * 0.05),
            Paint()
              ..color = Colors.lightBlue[200]!.withOpacity(0.1)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
          );
        }
        break;

      case "海王星":
        // 基本球體
        canvas.drawCircle(center, radius, gradientPaint);
        
        // 添加風暴
        final stormPaint = Paint()
          ..color = Colors.blue[900]!.withOpacity(0.4);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx - radius * 0.3, center.dy),
            width: radius * 0.6,
            height: radius * 0.2,
          ),
          stormPaint,
        );
        break;

      default:
        // 基本行星效果
        canvas.drawCircle(center, radius, gradientPaint);
    }

    // 添加光暈效果
    canvas.drawCircle(
      center,
      radius * 1.05,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1)
        ..color = color.withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
