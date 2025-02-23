import 'package:flutter/material.dart';
import '../models/planet_info.dart';
import '../solar_system.dart';
import '../widgets/mini_planet_painter.dart';  // 添加這行來引入 MiniPlanetPainter 類

class PlanetDetailScreen extends StatelessWidget {
  final Planet planet;
  final PlanetInfo planetInfo;

  const PlanetDetailScreen({
    super.key,
    required this.planet,
    required this.planetInfo,
  });

  @override
  Widget build(BuildContext context) {
    // 根據行星名稱取得對應的圖片路徑
    String getImagePath(String name) {
      switch (name) {
        case "太陽":
          return "assets/sun.jpg";
        case "水星":
          return "assets/mercury.jpg";
        case "金星":
          return "assets/venus.jpg";
        case "地球":
          return "assets/earth.jpg";
        case "火星":
          return "assets/mars.jpg";
        case "木星":
          return "assets/jupiter.jpg";
        case "土星":
          return "assets/saturn.jpg";
        case "天王星":
          return "assets/uranus.jpg";
        case "海王星":
          return "assets/neptune.jpg";
        default:
          return "";
      }
    }

    return Dialog(
      backgroundColor: Colors.white,  // 改成白色背景
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox( // 添加最大高度限制
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // 設定為螢幕高度的 80%
        ),
        child: SingleChildScrollView( // 添加 ScrollView
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CustomPaint(
                        painter: MiniPlanetPainter(planet.color, planet.name),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      planet.name,
                      style: const TextStyle(
                        fontFamily: 'LXGWWenKaiTC',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,  // 改成黑色文字
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.black),  // 改成黑色圖示
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 添加行星圖片
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    getImagePath(planet.name),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  planetInfo.description,
                  style: const TextStyle(
                    fontFamily: 'LXGWWenKaiTC',
                    fontSize: 16,
                    color: Colors.black87,  // 改成深灰色文字
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "基本資料",
                  style: TextStyle(
                    fontFamily: 'LXGWWenKaiTC',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,  // 改成黑色文字
                  ),
                ),
                const SizedBox(height: 12),
                ...planetInfo.facts.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(
                          fontFamily: 'LXGWWenKaiTC',
                          color: Colors.black54,
                        ),  // 改成淺灰色文字
                      ),
                      Text(
                        e.value,
                        style: const TextStyle(
                          fontFamily: 'LXGWWenKaiTC',
                          color: Colors.black,  // 改成黑色文字
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
