import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector;
import 'models/planet_info.dart';
import 'screens/planet_detail_screen.dart';
import 'widgets/mini_planet_painter.dart';  // 添加這行來引入 MiniPlanetPainter 類
import 'audio_player_controller.dart';

class Planet {
  final String name;
  final Color color;
  final double realDistance; // 真實天文單位（AU）
  final double relativeSize; // 相對地球大小
  final double eccentricity; // 軌道離心率
  final double inclination; // 軌道傾角（度）

  Planet({
    required this.name,
    required this.color,
    required this.realDistance,
    required this.relativeSize,
    required this.eccentricity,
    required this.inclination,
  });
}

class SolarSystem extends StatefulWidget {
  const SolarSystem({super.key});

  @override
  State<SolarSystem> createState() => _SolarSystemState();
}

class _SolarSystemState extends State<SolarSystem> with TickerProviderStateMixin {
  late AnimationController _controller;
  double _rotation = 0;
  double _viewAngleX = -30.0;
  double _viewAngleY = 30.0;
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  final AudioPlayerController _audioController = AudioPlayerController();
  bool isPlaying = false;

  final List<Planet> planets = [
    Planet(name: "水星", color: Colors.grey, realDistance: 0.387, relativeSize: 0.383, eccentricity: 0.206, inclination: 7.0),
    Planet(name: "金星", color: Colors.orange[300]!, realDistance: 0.723, relativeSize: 0.949, eccentricity: 0.007, inclination: 3.4),
    Planet(name: "地球", color: Colors.blue, realDistance: 1.0, relativeSize: 1.0, eccentricity: 0.017, inclination: 0.0),
    Planet(name: "火星", color: Colors.red, realDistance: 1.524, relativeSize: 0.532, eccentricity: 0.093, inclination: 1.9),
    Planet(name: "木星", color: Colors.orange, realDistance: 5.203, relativeSize: 11.209, eccentricity: 0.048, inclination: 1.3),
    Planet(name: "土星", color: Colors.yellow[700]!, realDistance: 9.537, relativeSize: 9.449, eccentricity: 0.054, inclination: 2.5),
    Planet(name: "天王星", color: Colors.lightBlue, realDistance: 19.191, relativeSize: 4.007, eccentricity: 0.047, inclination: 0.8),
    Planet(name: "海王星", color: Colors.blue[900]!, realDistance: 30.069, relativeSize: 3.883, eccentricity: 0.009, inclination: 1.8),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // 移除固定時間限制，改用無限大的持續時間
      duration: const Duration(days: 365), // 使用很長的時間
    )..repeat();

    // 修改旋轉速度計算方式
    _controller.addListener(() {
      setState(() {
        // 根據實際時間計算旋轉角度，而不是根據動畫值
        _rotation = (DateTime.now().millisecondsSinceEpoch / 1000) * 0.5;
      });
    });

    _audioController.initAudio().then((_) {
      _audioController.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 10.0,
            onInteractionUpdate: (details) {
              if (details.pointerCount == 1) {
                setState(() {
                  _viewAngleY += details.focalPointDelta.dx * 0.5;
                  _viewAngleX += details.focalPointDelta.dy * 0.5;
                });
              }
            },
            child: Center(
              child: CustomPaint(
                size: const Size(800, 800),
                painter: SolarSystemPainter(
                  _rotation,
                  planets,
                  _viewAngleX,
                  _viewAngleY,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: LegendPanel(planets: planets),
          ),
        ],
      ),
    );
  }
}

class LegendPanel extends StatelessWidget {
  final List<Planet> planets;

  const LegendPanel({super.key, required this.planets});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(context, "太陽", Colors.yellow),  // 添加 context
          const SizedBox(height: 8),
          ...planets.map((planet) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildLegendItem(context, planet.name, planet.color),  // 添加 context
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String name, Color color) {  // 添加 BuildContext 參數
    return InkWell(
      onTap: () {
        final planetInfo = planetInfoMap[name];
        if (planetInfo != null) {
          showDialog(
            context: context,
            builder: (context) => PlanetDetailScreen(
              planet: Planet(
                name: name,
                color: color,
                realDistance: 0, // 太陽的距離設為0
                relativeSize: 0, // 太陽的相對大小設為0
                eccentricity: 0, // 太陽的軌道離心率設為0
                inclination: 0, // 太陽的軌道傾角設為0
              ),
              planetInfo: planetInfo,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(
                painter: MiniPlanetPainter(color, name),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'LXGWWenKaiTC',  // 添加字體
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Star {
  final Offset position;
  final double size;
  final double brightness;
  final double twinkleSpeed; // 添加閃爍速度控制

  Star({
    required this.position,
    required this.size,
    required this.brightness,
    required this.twinkleSpeed,
  });
}

class SolarSystemPainter extends CustomPainter {
  static const double sunRadius = 109.0; // 太陽半徑（相對於地球）
  static const double sizeScale = 0.3; // 增加整體尺寸縮放因子
  static const double distanceScale = 0.5; // 減小軌道距離，讓行星更集中
  static const int starCount = 200; // 星星數量

  final double rotation;
  final List<Planet> planets;
  final double viewAngleX;
  final double viewAngleY;
  final List<Star> stars;

  SolarSystemPainter(
    this.rotation,
    this.planets,
    this.viewAngleX,
    this.viewAngleY,
  ) : stars = List.generate(starCount, (index) {
    return Star(
      position: Offset(
        math.Random().nextDouble() * 1600 - 400,
        math.Random().nextDouble() * 1600 - 400,
      ),
      size: math.Random().nextDouble() * 2 + 0.5,
      brightness: math.Random().nextDouble() * 0.5 + 0.3, // 降低基礎亮度範圍
      twinkleSpeed: math.Random().nextDouble() * 0.003 + 0.01, // 降低閃爍速度範圍
    );
  });

  vector.Vector3 projectPoint(double x, double y, double z, Size size) {
    final matrix = vector.Matrix4.identity()
      ..rotateX(vector.radians(viewAngleX))
      ..rotateY(vector.radians(viewAngleY));
    
    final point = vector.Vector3(x, y, z);
    final transformed = matrix.transform3(point);
    
    // 簡單的透視投影
    final perspective = 800.0;
    final scale = perspective / (perspective + transformed.z);
    
    return vector.Vector3(
      transformed.x * scale + size.width / 2,
      transformed.y * scale + size.height / 2,
      transformed.z
    );
  }

  void drawStars(Canvas canvas, Size size) {
    final starMatrix = vector.Matrix4.identity()
      ..rotateX(vector.radians(viewAngleX * 0.2))
      ..rotateY(vector.radians(viewAngleY * 0.2));

    for (final star in stars) {
      final time = DateTime.now().millisecondsSinceEpoch / 10000; // 將時間除以2000而不是1000，使整體更慢
      // 使用正弦函數創造更柔和的閃爍效果
      final twinkle = math.sin(time * star.twinkleSpeed) * 0.2 + 0.8;
      
      final point = vector.Vector3(star.position.dx, star.position.dy, 0);
      final transformed = starMatrix.transform3(point);
      
      final starPaint = Paint()
        ..color = Colors.white.withOpacity(star.brightness * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

      if (star.size < 1.0) {
        canvas.drawCircle(
          Offset(transformed.x + size.width/2, transformed.y + size.height/2),
          star.size,
          starPaint,
        );
      } else {
        final center = Offset(
          transformed.x + size.width/2,
          transformed.y + size.height/2,
        );
        canvas.drawCircle(center, star.size, starPaint);
        
        final glowPaint = Paint()
          ..color = Colors.white.withOpacity(star.brightness * twinkle * 0.3)
          ..strokeWidth = 0.5;
          
        // 光芒效果也隨閃爍變化
        canvas.drawLine(
          Offset(center.dx - star.size*2, center.dy),
          Offset(center.dx + star.size*2, center.dy),
          glowPaint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - star.size*2),
          Offset(center.dx, center.dy + star.size*2),
          glowPaint,
        );
      }
    }
  }

  void drawEllipticalOrbit(Canvas canvas, Size size, Offset center, double a, double e, double inclination, Paint paint) {
    final points = <Offset>[];
    final b = a * math.sqrt(1 - e * e); // 短半軸
    
    // 使用參數方程式生成橢圓上的點
    for (var theta = 0.0; theta < 2 * math.pi; theta += 0.05) {
      // 計算橢圓基本點（極坐標方程）
      final r = a * (1 - e * e) / (1 + e * math.cos(theta));
      final x = r * math.cos(theta);
      final y = r * math.sin(theta);
      
      // 應用軌道傾角
      final rotatedY = y * math.cos(inclination);
      final z = y * math.sin(inclination);
      
      // 投影到2D
      final projected = projectPoint(x, rotatedY, z, size);
      points.add(Offset(projected.x, projected.y));
    }

    // 繪製軌道路徑
    if (points.length > 1) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      // 不需要關閉路徑
      canvas.drawPath(path, paint);
    }
  }

  void drawPlanet(Canvas canvas, Offset center, double radius, Color color, String name) {
    // 繪製行星本體
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

    // 特殊處理不同行星
    switch (name) {
      case "水星":
        // 添加隕石坑效果
        canvas.drawCircle(center, radius, gradientPaint);
        final craterPaint = Paint()
          ..color = Colors.grey[800]!.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        
        // 隨機繪製幾個隕石坑
        final random = math.Random(1);  // 固定種子以保持坑的位置不變
        for (var i = 0; i < 5; i++) {
          final craterRadius = radius * (0.1 + random.nextDouble() * 0.2);
          final angle = random.nextDouble() * 2 * math.pi;
          final distance = radius * random.nextDouble() * 0.7;
          final craterPos = Offset(
            center.dx + math.cos(angle) * distance,
            center.dy + math.sin(angle) * distance,
          );
          canvas.drawCircle(craterPos, craterRadius, craterPaint);
        }
        break;

      case "金星":
        // 添加厚重大氣層效果
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            center,
            radius * (1.1 + i * 0.05),
            Paint()
              ..color = Colors.orange[300]!.withOpacity(0.1)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
          );
        }
        canvas.drawCircle(center, radius, gradientPaint);
        break;

      case "地球":
        // 先畫基本圓形
        canvas.drawCircle(center, radius, gradientPaint);
        
        // 使用裁剪確保所有效果都在圓形內
        canvas.save();
        canvas.clipPath(
          Path()..addOval(Rect.fromCircle(center: center, radius: radius))
        );
        
        // 添加大氣層
        canvas.drawCircle(
          center,
          radius * 1.15,
          Paint()
            ..color = Colors.blue[200]!.withOpacity(0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
        
        // 添加綠色陸地
        final landPaint = Paint()
          ..color = Colors.green[800]!.withOpacity(0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
        
        final random = math.Random(2);
        for (var i = 0; i < 12; i++) {
          final angle = random.nextDouble() * 2 * math.pi;
          final distance = radius * random.nextDouble() * 0.7;
          final landSize = radius * (0.25 + random.nextDouble() * 0.35);
          final landPos = Offset(
            center.dx + math.cos(angle) * distance,
            center.dy + math.sin(angle) * distance,
          );
          
          final path = Path();
          for (var j = 0; j < 8; j++) {
            final a = j * math.pi / 4;
            final r = landSize * (0.8 + random.nextDouble() * 0.4);
            final point = Offset(
              landPos.dx + math.cos(a) * r,
              landPos.dy + math.sin(a) * r,
            );
            if (j == 0) {
              path.moveTo(point.dx, point.dy);
            } else {
              path.lineTo(point.dx, point.dy);
            }
          }
          path.close();
          canvas.drawPath(path, landPaint);
          
          // 添加深色陰影效果
          final shadowPaint = Paint()
            ..color = Colors.green[900]!.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawPath(path, shadowPaint);
        }
        
        // 添加白色雲層
        final cloudPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        for (var i = 0; i < 6; i++) {
          final angle = random.nextDouble() * 2 * math.pi;
          final distance = radius * random.nextDouble() * 0.8;
          final cloudSize = radius * (0.15 + random.nextDouble() * 0.2);
          final cloudPos = Offset(
            center.dx + math.cos(angle) * distance,
            center.dy + math.sin(angle) * distance,
          );
          canvas.drawCircle(cloudPos, cloudSize, cloudPaint);
        }

        // 恢復畫布狀態
        canvas.restore();
        break;

      case "火星":
        // 增強極地和表面特徵
        canvas.drawCircle(center, radius, gradientPaint);
        // 極冠
        canvas.drawCircle(
          Offset(center.dx, center.dy - radius * 0.7),
          radius * 0.3,
          Paint()
            ..color = Colors.white.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
        // 表面特徵
        final featurePaint = Paint()
          ..color = Colors.red[900]!.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        for (var i = 0; i < 3; i++) {
          final angle = i * math.pi / 2;
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(
                center.dx + math.cos(angle) * radius * 0.4,
                center.dy + math.sin(angle) * radius * 0.4,
              ),
              width: radius * 0.6,
              height: radius * 0.3,
            ),
            featurePaint,
          );
        }
        break;

      case "木星":
        // 繪製基本圓形
        canvas.drawCircle(center, radius, gradientPaint);
        
        // 使用裁剪確保條紋不會超出圓形
        canvas.save();
        canvas.clipPath(
          Path()..addOval(Rect.fromCircle(center: center, radius: radius))
        );
        
        // 條紋
        for (var i = -4; i <= 4; i++) {
          final stripePaint = Paint()
            ..color = i.isEven 
              ? Colors.orange[800]!.withOpacity(0.3)
              : Colors.orange[600]!.withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius * 0.15;
          canvas.drawLine(
            Offset(center.dx - radius, center.dy + i * radius * 0.15),
            Offset(center.dx + radius, center.dy + i * radius * 0.15),
            stripePaint,
          );
        }
        
        // 大紅斑
        final spotPaint = Paint()
          ..color = Colors.red[900]!.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx - radius * 0.3, center.dy),
            width: radius * 0.8,
            height: radius * 0.3,
          ),
          spotPaint,
        );
        
        canvas.restore();
        break;

      case "土星":
        // 增強環系統效果
        canvas.drawCircle(center, radius, gradientPaint);
        // 多層環系統
        final ringColors = [
          Colors.yellow[700]!.withOpacity(0.4),
          Colors.yellow[600]!.withOpacity(0.3),
          Colors.yellow[500]!.withOpacity(0.2),
        ];
        for (var i = 0; i < ringColors.length; i++) {
          final ringPaint = Paint()
            ..color = ringColors[i]
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius * (0.4 - i * 0.1);
          canvas.drawOval(
            Rect.fromCenter(
              center: center,
              width: radius * (3.5 + i * 0.2),
              height: radius * (0.8 + i * 0.1),
            ),
            ringPaint,
          );
        }
        break;

      case "天王星":
        // 添加淡藍色大氣層和傾斜效果
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            center,
            radius * (1.1 + i * 0.05),
            Paint()
              ..color = Colors.lightBlue[200]!.withOpacity(0.1)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
        canvas.drawCircle(center, radius, gradientPaint);
        break;

      case "海王星":
        // 添加深藍色風暴系統
        canvas.drawCircle(center, radius, gradientPaint);
        final stormPaint = Paint()
          ..color = Colors.blue[900]!.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        
        // 添加多個風暴系統
        final random = math.Random(3);
        for (var i = 0; i < 3; i++) {
          final angle = random.nextDouble() * 2 * math.pi;
          final distance = radius * random.nextDouble() * 0.6;
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(
                center.dx + math.cos(angle) * distance,
                center.dy + math.sin(angle) * distance,
              ),
              width: radius * 0.4,
              height: radius * 0.2,
            ),
            stormPaint,
          );
        }
        break;
    }

    // 添加光暈效果
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..color = color.withOpacity(0.3);
    canvas.drawCircle(center, radius * 1.05, glowPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 先繪製星空背景
    drawStars(canvas, size);

    final maxDistance = planets.map((p) => p.realDistance).reduce(math.max);
    final scaleFactor = (size.width * 0.4) / maxDistance * distanceScale; // 增加基礎比例
    final baseSunSize = sunRadius * sizeScale;
    
    // 先繪製所有軌道
    for (var planet in planets) {
      final a = math.max(
        (planet.realDistance * scaleFactor),
        baseSunSize * 1.2
      );
      
      final orbitPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      drawEllipticalOrbit(
        canvas, 
        size,
        Offset(size.width / 2, size.height / 2),
        a,
        planet.eccentricity,
        vector.radians(planet.inclination),
        orbitPaint
      );
    }

    // 繪製太陽
    final sunPosition = projectPoint(0, 0, 0, size);
    final sunSize = baseSunSize * (800 / (800 + sunPosition.z));
    final sunCenter = Offset(sunPosition.x, sunPosition.y);

    // 1. 外層光暈效果（先畫最外層）
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(
        sunCenter,
        sunSize * (2.5 - i * 0.3),
        Paint()
          ..color = Colors.yellow.withOpacity(0.05)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50),
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
      sunCenter,
      sunSize,
      Paint()
        ..shader = sunGradient.createShader(
          Rect.fromCircle(center: sunCenter, radius: sunSize),
        )
    );

    // 4. 添加表面細節紋理
    final random = math.Random(1);
    for (var i = 0; i < 12; i++) {
      final angle = i * (math.pi / 6); // 均勻分布
      final distance = sunSize * 0.7;
      final length = sunSize * 0.8;
      final width = sunSize * 0.15;
      
      final flareGradient = RadialGradient(
        colors: [
          Colors.yellow[300]!.withOpacity(0.4),
          Colors.orange[500]!.withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      );

      canvas.save();
      canvas.translate(sunCenter.dx, sunCenter.dy);
      canvas.rotate(angle + rotation * 0.1); // 添加緩慢旋轉
      
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(distance * 0.5, 0),
          width: length,
          height: width,
        ),
        Paint()
          ..shader = flareGradient.createShader(
            Rect.fromCircle(center: Offset.zero, radius: sunSize),
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.restore();
    }

    // 5. 中層發光效果
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        sunCenter,
        sunSize * (1.3 - i * 0.1),
        Paint()
          ..color = Colors.yellow.withOpacity(0.2 - i * 0.05)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }

    // 5. 外層光暈效果
    canvas.drawCircle(
      sunCenter,
      sunSize * 1.8,
      Paint()
        ..color = Colors.yellow.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    // 繪製行星
    for (var planet in planets) {
      final a = math.max(
        (planet.realDistance * scaleFactor),
        baseSunSize * 1.2
      );
      
      // 使用與軌道相同的計算方式
      final theta = rotation * (1 / math.sqrt(planet.realDistance));
      final r = a * (1 - planet.eccentricity * planet.eccentricity) / 
               (1 + planet.eccentricity * math.cos(theta));
      
      final x = r * math.cos(theta);
      final y = r * math.sin(theta);
      
      // 應用軌道傾角
      final inclination = vector.radians(planet.inclination);
      final rotatedY = y * math.cos(inclination);
      final z = y * math.sin(inclination);
      
      final projected = projectPoint(x, rotatedY, z, size);
      // 調整行星大小計算方式，使其更明顯
      final planetSize = math.max(
        3.0,  // 設定最小尺寸
        planet.relativeSize * sizeScale * 3.0 * (800 / (800 + projected.z))
      );

      // 使用新的繪製方法
      drawPlanet(
        canvas,
        Offset(projected.x, projected.y),
        planetSize,
        planet.color,
        planet.name,
      );
    }
  }

  // 解開普勒方程（牛頓迭代法）
  double solveKepler(double M, double e) {
    double E = M; // 初始猜測值
    for (int i = 0; i < 5; i++) {
      E = E - (E - e * math.sin(E) - M) / (1 - e * math.cos(E));
    }
    return E;
  }

  @override
  bool shouldRepaint(SolarSystemPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
