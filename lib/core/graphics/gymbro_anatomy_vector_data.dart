import 'package:flutter/material.dart';
import '../../widgets/body_muscle_map.dart';
import 'gymbro_icon_data.dart';

enum BodyMapView { front, back }

/// High-precision athletic anatomical vector dataset for GymBro.
/// Designed with hand-sculpted Bézier contours matching professional biomechanical standards (Hevy, MuscleWiki).
/// Viewport bounds: 240.0 x 370.0 (Center X: 120.0).
class GymBroAnatomyVectorData {
  GymBroAnatomyVectorData._();

  static const double viewBoxWidth = 240.0;
  static const double viewBoxHeight = 370.0;

  // Heatmap palette tokens
  static const Color primaryLime = Color(0xFFC9F36A);
  static const Color warmAmber = Color(0xFFFFB86B);
  static const Color softCyan = Color(0xFF78CFE0);
  static const Color basePlate = Color(0xFF202A37);
  static const Color contourBorder = Color(0xFF2C384A);
  static const Color silhouetteBase = Color(0xFF111620);
  static const Color silhouetteBorder = Color(0xFF1E293B);

  // ----------------- SILHOUETTES -----------------

  static Path getAnteriorSilhouette() {
    final p = Path();
    p.moveTo(120.0, 14.0);
    p.cubicTo(129.0, 14.0, 136.0, 21.0, 136.0, 32.0);
    p.cubicTo(136.0, 43.0, 129.0, 52.0, 124.0, 54.0);
    p.lineTo(125.0, 64.0);
    p.cubicTo(134.0, 65.0, 150.0, 71.0, 163.0, 78.0);
    p.cubicTo(176.0, 85.0, 185.0, 96.0, 184.0, 110.0);
    p.cubicTo(183.0, 124.0, 178.0, 142.0, 176.0, 158.0);
    p.cubicTo(188.0, 172.0, 204.0, 195.0, 210.0, 215.0);
    p.cubicTo(214.0, 227.0, 212.0, 235.0, 206.0, 238.0);
    p.cubicTo(200.0, 240.0, 192.0, 233.0, 188.0, 224.0);
    p.cubicTo(182.0, 208.0, 172.0, 186.0, 166.0, 172.0);
    p.lineTo(165.0, 174.0);
    p.cubicTo(163.0, 186.0, 161.0, 198.0, 156.0, 210.0);
    p.cubicTo(164.0, 226.0, 170.0, 248.0, 169.0, 272.0);
    p.cubicTo(168.0, 290.0, 162.0, 304.0, 158.0, 310.0);
    p.lineTo(161.0, 324.0);
    p.cubicTo(166.0, 338.0, 164.0, 354.0, 158.0, 360.0);
    p.cubicTo(152.0, 364.0, 146.0, 364.0, 142.0, 358.0);
    p.cubicTo(138.0, 350.0, 136.0, 338.0, 136.0, 322.0);
    p.cubicTo(136.0, 308.0, 137.0, 296.0, 135.0, 284.0);
    p.cubicTo(133.0, 268.0, 128.0, 238.0, 126.0, 220.0);
    p.lineTo(120.0, 220.0);
    p.lineTo(114.0, 220.0);
    p.cubicTo(112.0, 238.0, 107.0, 268.0, 105.0, 284.0);
    p.cubicTo(103.0, 296.0, 104.0, 308.0, 104.0, 322.0);
    p.cubicTo(104.0, 338.0, 102.0, 350.0, 98.0, 358.0);
    p.cubicTo(94.0, 364.0, 88.0, 364.0, 82.0, 360.0);
    p.cubicTo(76.0, 354.0, 74.0, 338.0, 79.0, 324.0);
    p.lineTo(82.0, 310.0);
    p.cubicTo(78.0, 304.0, 72.0, 290.0, 71.0, 272.0);
    p.cubicTo(70.0, 248.0, 76.0, 226.0, 84.0, 210.0);
    p.cubicTo(79.0, 198.0, 77.0, 186.0, 75.0, 174.0);
    p.lineTo(74.0, 172.0);
    p.cubicTo(68.0, 186.0, 58.0, 208.0, 52.0, 224.0);
    p.cubicTo(48.0, 233.0, 40.0, 240.0, 34.0, 238.0);
    p.cubicTo(28.0, 235.0, 26.0, 227.0, 30.0, 215.0);
    p.cubicTo(36.0, 195.0, 52.0, 172.0, 64.0, 158.0);
    p.cubicTo(62.0, 142.0, 57.0, 124.0, 56.0, 110.0);
    p.cubicTo(55.0, 96.0, 64.0, 85.0, 77.0, 78.0);
    p.cubicTo(90.0, 71.0, 106.0, 65.0, 115.0, 64.0);
    p.lineTo(116.0, 54.0);
    p.cubicTo(111.0, 52.0, 104.0, 43.0, 104.0, 32.0);
    p.cubicTo(104.0, 21.0, 111.0, 14.0, 120.0, 14.0);
    p.close();
    return p;
  }

  static Path getPosteriorSilhouette() {
    final p = Path();
    p.moveTo(120.0, 14.0);
    p.cubicTo(129.0, 14.0, 136.0, 21.0, 136.0, 32.0);
    p.cubicTo(136.0, 43.0, 129.0, 52.0, 124.0, 54.0);
    p.lineTo(125.0, 64.0);
    p.cubicTo(134.0, 65.0, 150.0, 71.0, 163.0, 78.0);
    p.cubicTo(176.0, 85.0, 185.0, 96.0, 184.0, 110.0);
    p.cubicTo(183.0, 124.0, 178.0, 142.0, 176.0, 158.0);
    p.cubicTo(188.0, 172.0, 204.0, 195.0, 210.0, 215.0);
    p.cubicTo(214.0, 227.0, 212.0, 235.0, 206.0, 238.0);
    p.cubicTo(200.0, 240.0, 192.0, 233.0, 188.0, 224.0);
    p.cubicTo(182.0, 208.0, 172.0, 186.0, 166.0, 172.0);
    p.lineTo(165.0, 174.0);
    p.cubicTo(163.0, 186.0, 161.0, 198.0, 156.0, 210.0);
    p.cubicTo(164.0, 226.0, 170.0, 248.0, 169.0, 272.0);
    p.cubicTo(168.0, 290.0, 162.0, 304.0, 158.0, 310.0);
    p.lineTo(161.0, 324.0);
    p.cubicTo(166.0, 338.0, 164.0, 354.0, 158.0, 360.0);
    p.cubicTo(152.0, 364.0, 146.0, 364.0, 142.0, 358.0);
    p.cubicTo(138.0, 350.0, 136.0, 338.0, 136.0, 322.0);
    p.cubicTo(136.0, 308.0, 137.0, 296.0, 135.0, 284.0);
    p.cubicTo(133.0, 268.0, 128.0, 238.0, 126.0, 220.0);
    p.lineTo(120.0, 220.0);
    p.lineTo(114.0, 220.0);
    p.cubicTo(112.0, 238.0, 107.0, 268.0, 105.0, 284.0);
    p.cubicTo(103.0, 296.0, 104.0, 308.0, 104.0, 322.0);
    p.cubicTo(104.0, 338.0, 102.0, 350.0, 98.0, 358.0);
    p.cubicTo(94.0, 364.0, 88.0, 364.0, 82.0, 360.0);
    p.cubicTo(76.0, 354.0, 74.0, 338.0, 79.0, 324.0);
    p.lineTo(82.0, 310.0);
    p.cubicTo(78.0, 304.0, 72.0, 290.0, 71.0, 272.0);
    p.cubicTo(70.0, 248.0, 76.0, 226.0, 84.0, 210.0);
    p.cubicTo(79.0, 198.0, 77.0, 186.0, 75.0, 174.0);
    p.lineTo(74.0, 172.0);
    p.cubicTo(68.0, 186.0, 58.0, 208.0, 52.0, 224.0);
    p.cubicTo(48.0, 233.0, 40.0, 240.0, 34.0, 238.0);
    p.cubicTo(28.0, 235.0, 26.0, 227.0, 30.0, 215.0);
    p.cubicTo(36.0, 195.0, 52.0, 172.0, 64.0, 158.0);
    p.cubicTo(62.0, 142.0, 57.0, 124.0, 56.0, 110.0);
    p.cubicTo(55.0, 96.0, 64.0, 85.0, 77.0, 78.0);
    p.cubicTo(90.0, 71.0, 106.0, 65.0, 115.0, 64.0);
    p.lineTo(116.0, 54.0);
    p.cubicTo(111.0, 52.0, 104.0, 43.0, 104.0, 32.0);
    p.cubicTo(104.0, 21.0, 111.0, 14.0, 120.0, 14.0);
    p.close();
    return p;
  }

  // ----------------- ANTERIOR MUSCLES -----------------

  static Path chestLeft() {
    final p = Path();
    p.moveTo(117.0, 84.0);
    p.cubicTo(104.0, 84.0, 92.0, 88.0, 86.0, 94.0);
    p.cubicTo(82.0, 99.0, 81.0, 106.0, 82.0, 113.0);
    p.cubicTo(84.0, 122.0, 94.0, 127.0, 104.0, 127.0);
    p.cubicTo(112.0, 127.0, 116.0, 123.0, 117.0, 118.0);
    p.close();
    return p;
  }

  static Path chestRight() {
    final p = Path();
    p.moveTo(123.0, 84.0);
    p.cubicTo(136.0, 84.0, 148.0, 88.0, 154.0, 94.0);
    p.cubicTo(158.0, 99.0, 159.0, 106.0, 158.0, 113.0);
    p.cubicTo(156.0, 122.0, 146.0, 127.0, 136.0, 127.0);
    p.cubicTo(128.0, 127.0, 124.0, 123.0, 123.0, 118.0);
    p.close();
    return p;
  }

  static Path shouldersLeft() {
    final p = Path();
    p.moveTo(84.0, 81.0);
    p.cubicTo(75.0, 84.0, 66.0, 91.0, 64.0, 100.0);
    p.cubicTo(62.0, 108.0, 64.0, 116.0, 68.0, 120.0);
    p.cubicTo(73.0, 116.0, 78.0, 108.0, 81.0, 99.0);
    p.cubicTo(83.0, 93.0, 84.0, 86.0, 84.0, 81.0);
    p.close();
    return p;
  }

  static Path shouldersRight() {
    final p = Path();
    p.moveTo(156.0, 81.0);
    p.cubicTo(165.0, 84.0, 174.0, 91.0, 176.0, 100.0);
    p.cubicTo(178.0, 108.0, 176.0, 116.0, 172.0, 120.0);
    p.cubicTo(167.0, 116.0, 162.0, 108.0, 159.0, 99.0);
    p.cubicTo(157.0, 93.0, 156.0, 86.0, 156.0, 81.0);
    p.close();
    return p;
  }

  static Path bicepsLeft() {
    final p = Path();
    p.moveTo(69.0, 122.0);
    p.cubicTo(64.0, 128.0, 62.0, 138.0, 64.0, 148.0);
    p.cubicTo(66.0, 156.0, 71.0, 160.0, 75.0, 160.0);
    p.cubicTo(77.0, 154.0, 78.0, 144.0, 77.0, 134.0);
    p.cubicTo(76.0, 127.0, 73.0, 124.0, 69.0, 122.0);
    p.close();
    return p;
  }

  static Path bicepsRight() {
    final p = Path();
    p.moveTo(171.0, 122.0);
    p.cubicTo(176.0, 128.0, 178.0, 138.0, 176.0, 148.0);
    p.cubicTo(174.0, 156.0, 169.0, 160.0, 165.0, 160.0);
    p.cubicTo(163.0, 154.0, 162.0, 144.0, 163.0, 134.0);
    p.cubicTo(164.0, 127.0, 167.0, 124.0, 171.0, 122.0);
    p.close();
    return p;
  }

  static Path forearmsLeft() {
    final p = Path();
    p.moveTo(74.0, 163.0);
    p.cubicTo(66.0, 172.0, 54.0, 186.0, 48.0, 198.0);
    p.cubicTo(44.0, 207.0, 43.0, 216.0, 46.0, 220.0);
    p.cubicTo(50.0, 221.0, 55.0, 215.0, 61.0, 205.0);
    p.cubicTo(68.0, 193.0, 75.0, 180.0, 77.0, 170.0);
    p.close();
    return p;
  }

  static Path forearmsRight() {
    final p = Path();
    p.moveTo(166.0, 163.0);
    p.cubicTo(174.0, 172.0, 186.0, 186.0, 192.0, 198.0);
    p.cubicTo(196.0, 207.0, 197.0, 216.0, 194.0, 220.0);
    p.cubicTo(190.0, 221.0, 185.0, 215.0, 179.0, 205.0);
    p.cubicTo(172.0, 193.0, 165.0, 180.0, 163.0, 170.0);
    p.close();
    return p;
  }

  static Path absUpperLeft() {
    final p = Path();
    p.moveTo(103.0, 131.0);
    p.cubicTo(107.0, 131.0, 113.0, 131.0, 117.0, 131.0);
    p.cubicTo(117.0, 137.0, 117.0, 143.0, 117.0, 147.0);
    p.cubicTo(112.0, 147.0, 106.0, 147.0, 102.0, 146.0);
    p.cubicTo(101.0, 141.0, 101.0, 136.0, 103.0, 131.0);
    p.close();
    return p;
  }

  static Path absUpperRight() {
    final p = Path();
    p.moveTo(123.0, 131.0);
    p.cubicTo(127.0, 131.0, 133.0, 131.0, 137.0, 131.0);
    p.cubicTo(139.0, 136.0, 139.0, 141.0, 138.0, 146.0);
    p.cubicTo(134.0, 147.0, 128.0, 147.0, 123.0, 147.0);
    p.cubicTo(123.0, 143.0, 123.0, 137.0, 123.0, 131.0);
    p.close();
    return p;
  }

  static Path absMidLeft() {
    final p = Path();
    p.moveTo(102.0, 150.0);
    p.cubicTo(107.0, 150.0, 113.0, 150.0, 117.0, 150.0);
    p.cubicTo(117.0, 157.0, 117.0, 165.0, 117.0, 170.0);
    p.cubicTo(112.0, 170.0, 106.0, 170.0, 101.0, 169.0);
    p.cubicTo(100.0, 162.0, 100.0, 156.0, 102.0, 150.0);
    p.close();
    return p;
  }

  static Path absMidRight() {
    final p = Path();
    p.moveTo(123.0, 150.0);
    p.cubicTo(127.0, 150.0, 133.0, 150.0, 138.0, 150.0);
    p.cubicTo(140.0, 156.0, 140.0, 162.0, 139.0, 169.0);
    p.cubicTo(134.0, 170.0, 128.0, 170.0, 123.0, 170.0);
    p.cubicTo(123.0, 165.0, 123.0, 157.0, 123.0, 150.0);
    p.close();
    return p;
  }

  static Path absLowerLeft() {
    final p = Path();
    p.moveTo(102.0, 173.0);
    p.cubicTo(107.0, 173.0, 113.0, 173.0, 117.0, 173.0);
    p.cubicTo(117.0, 183.0, 116.0, 195.0, 116.0, 202.0);
    p.cubicTo(111.0, 200.0, 105.0, 196.0, 103.0, 191.0);
    p.cubicTo(101.0, 184.0, 101.0, 178.0, 102.0, 173.0);
    p.close();
    return p;
  }

  static Path absLowerRight() {
    final p = Path();
    p.moveTo(123.0, 173.0);
    p.cubicTo(127.0, 173.0, 133.0, 173.0, 138.0, 173.0);
    p.cubicTo(139.0, 178.0, 139.0, 184.0, 137.0, 191.0);
    p.cubicTo(135.0, 196.0, 129.0, 200.0, 124.0, 202.0);
    p.cubicTo(124.0, 195.0, 123.0, 183.0, 123.0, 173.0);
    p.close();
    return p;
  }

  static Path obliquesLeft() {
    final p = Path();
    p.moveTo(98.0, 134.0);
    p.cubicTo(92.0, 144.0, 88.0, 158.0, 86.0, 172.0);
    p.cubicTo(85.0, 184.0, 87.0, 196.0, 91.0, 206.0);
    p.cubicTo(95.0, 204.0, 98.0, 198.0, 100.0, 190.0);
    p.cubicTo(98.0, 176.0, 98.0, 156.0, 100.0, 142.0);
    p.cubicTo(100.0, 138.0, 99.0, 135.0, 98.0, 134.0);
    p.close();
    return p;
  }

  static Path obliquesRight() {
    final p = Path();
    p.moveTo(142.0, 134.0);
    p.cubicTo(148.0, 144.0, 152.0, 158.0, 154.0, 172.0);
    p.cubicTo(155.0, 184.0, 153.0, 196.0, 149.0, 206.0);
    p.cubicTo(145.0, 204.0, 142.0, 198.0, 140.0, 190.0);
    p.cubicTo(142.0, 176.0, 142.0, 156.0, 140.0, 142.0);
    p.cubicTo(140.0, 138.0, 141.0, 135.0, 142.0, 134.0);
    p.close();
    return p;
  }

  static Path quadricepsLeft() {
    final p = Path();
    p.moveTo(94.0, 212.0);
    p.cubicTo(86.0, 224.0, 78.0, 244.0, 76.0, 266.0);
    p.cubicTo(75.0, 278.0, 80.0, 286.0, 86.0, 288.0);
    p.cubicTo(92.0, 289.0, 96.0, 284.0, 98.0, 274.0);
    p.cubicTo(101.0, 282.0, 106.0, 285.0, 110.0, 283.0);
    p.cubicTo(114.0, 278.0, 114.0, 266.0, 112.0, 250.0);
    p.cubicTo(110.0, 234.0, 104.0, 220.0, 94.0, 212.0);
    p.close();
    return p;
  }

  static Path quadricepsRight() {
    final p = Path();
    p.moveTo(146.0, 212.0);
    p.cubicTo(154.0, 224.0, 162.0, 244.0, 164.0, 266.0);
    p.cubicTo(165.0, 278.0, 160.0, 286.0, 154.0, 288.0);
    p.cubicTo(148.0, 289.0, 144.0, 284.0, 142.0, 274.0);
    p.cubicTo(139.0, 282.0, 134.0, 285.0, 130.0, 283.0);
    p.cubicTo(126.0, 278.0, 126.0, 266.0, 128.0, 250.0);
    p.cubicTo(130.0, 234.0, 136.0, 220.0, 146.0, 212.0);
    p.close();
    return p;
  }

  static Path frontCalvesLeft() {
    final p = Path();
    p.moveTo(88.0, 296.0);
    p.cubicTo(82.0, 306.0, 78.0, 322.0, 80.0, 338.0);
    p.cubicTo(82.0, 348.0, 88.0, 355.0, 94.0, 354.0);
    p.cubicTo(98.0, 352.0, 101.0, 342.0, 101.0, 330.0);
    p.cubicTo(101.0, 318.0, 98.0, 306.0, 94.0, 298.0);
    p.close();
    return p;
  }

  static Path frontCalvesRight() {
    final p = Path();
    p.moveTo(152.0, 296.0);
    p.cubicTo(158.0, 306.0, 162.0, 322.0, 160.0, 338.0);
    p.cubicTo(158.0, 348.0, 152.0, 355.0, 146.0, 354.0);
    p.cubicTo(142.0, 352.0, 139.0, 342.0, 139.0, 330.0);
    p.cubicTo(139.0, 318.0, 142.0, 306.0, 146.0, 298.0);
    p.close();
    return p;
  }

  // ----------------- POSTERIOR MUSCLES -----------------

  static Path upperBack() {
    final p = Path();
    p.moveTo(120.0, 56.0);
    p.cubicTo(126.0, 56.0, 142.0, 66.0, 154.0, 78.0);
    p.cubicTo(146.0, 86.0, 136.0, 94.0, 132.0, 108.0);
    p.cubicTo(128.0, 122.0, 124.0, 136.0, 120.0, 146.0);
    p.cubicTo(116.0, 136.0, 112.0, 122.0, 108.0, 108.0);
    p.cubicTo(104.0, 94.0, 94.0, 86.0, 86.0, 78.0);
    p.cubicTo(98.0, 66.0, 114.0, 56.0, 120.0, 56.0);
    p.close();
    return p;
  }

  static Path rearShouldersLeft() {
    final p = Path();
    p.moveTo(84.0, 81.0);
    p.cubicTo(75.0, 84.0, 66.0, 91.0, 64.0, 100.0);
    p.cubicTo(62.0, 108.0, 64.0, 116.0, 68.0, 120.0);
    p.cubicTo(72.0, 116.0, 77.0, 106.0, 80.0, 97.0);
    p.cubicTo(82.0, 91.0, 84.0, 85.0, 84.0, 81.0);
    p.close();
    return p;
  }

  static Path rearShouldersRight() {
    final p = Path();
    p.moveTo(156.0, 81.0);
    p.cubicTo(165.0, 84.0, 174.0, 91.0, 176.0, 100.0);
    p.cubicTo(178.0, 108.0, 176.0, 116.0, 172.0, 120.0);
    p.cubicTo(168.0, 116.0, 163.0, 106.0, 160.0, 97.0);
    p.cubicTo(158.0, 91.0, 156.0, 85.0, 156.0, 81.0);
    p.close();
    return p;
  }

  static Path tricepsLeft() {
    final p = Path();
    p.moveTo(67.0, 118.0);
    p.cubicTo(62.0, 126.0, 60.0, 138.0, 62.0, 150.0);
    p.cubicTo(65.0, 158.0, 71.0, 160.0, 75.0, 158.0);
    p.cubicTo(77.0, 150.0, 78.0, 138.0, 76.0, 128.0);
    p.cubicTo(75.0, 122.0, 71.0, 118.0, 67.0, 118.0);
    p.close();
    return p;
  }

  static Path tricepsRight() {
    final p = Path();
    p.moveTo(173.0, 118.0);
    p.cubicTo(178.0, 126.0, 180.0, 138.0, 178.0, 150.0);
    p.cubicTo(175.0, 158.0, 169.0, 160.0, 165.0, 158.0);
    p.cubicTo(163.0, 150.0, 162.0, 138.0, 164.0, 128.0);
    p.cubicTo(165.0, 122.0, 169.0, 118.0, 173.0, 118.0);
    p.close();
    return p;
  }

  static Path rearForearmsLeft() {
    final p = Path();
    p.moveTo(74.0, 163.0);
    p.cubicTo(66.0, 172.0, 54.0, 186.0, 48.0, 198.0);
    p.cubicTo(44.0, 207.0, 43.0, 216.0, 46.0, 220.0);
    p.cubicTo(50.0, 221.0, 55.0, 215.0, 61.0, 205.0);
    p.cubicTo(68.0, 193.0, 75.0, 180.0, 77.0, 170.0);
    p.close();
    return p;
  }

  static Path rearForearmsRight() {
    final p = Path();
    p.moveTo(166.0, 163.0);
    p.cubicTo(174.0, 172.0, 186.0, 186.0, 192.0, 198.0);
    p.cubicTo(196.0, 207.0, 197.0, 216.0, 194.0, 220.0);
    p.cubicTo(190.0, 221.0, 185.0, 215.0, 179.0, 205.0);
    p.cubicTo(172.0, 193.0, 165.0, 180.0, 163.0, 170.0);
    p.close();
    return p;
  }

  static Path latsLeft() {
    final p = Path();
    p.moveTo(106.0, 116.0);
    p.cubicTo(96.0, 118.0, 86.0, 126.0, 82.0, 138.0);
    p.cubicTo(80.0, 148.0, 82.0, 162.0, 87.0, 176.0);
    p.cubicTo(92.0, 178.0, 100.0, 174.0, 106.0, 164.0);
    p.cubicTo(110.0, 152.0, 112.0, 136.0, 110.0, 124.0);
    p.close();
    return p;
  }

  static Path latsRight() {
    final p = Path();
    p.moveTo(134.0, 116.0);
    p.cubicTo(144.0, 118.0, 154.0, 126.0, 158.0, 138.0);
    p.cubicTo(160.0, 148.0, 158.0, 162.0, 153.0, 176.0);
    p.cubicTo(148.0, 178.0, 140.0, 174.0, 134.0, 164.0);
    p.cubicTo(130.0, 152.0, 128.0, 136.0, 130.0, 124.0);
    p.close();
    return p;
  }

  static Path lowerBack() {
    final p = Path();
    p.moveTo(112.0, 154.0);
    p.cubicTo(116.0, 150.0, 120.0, 150.0, 128.0, 154.0);
    p.cubicTo(127.0, 168.0, 127.0, 186.0, 126.0, 202.0);
    p.cubicTo(123.0, 204.0, 120.0, 205.0, 117.0, 204.0);
    p.cubicTo(114.0, 204.0, 113.0, 186.0, 112.0, 154.0);
    p.close();
    return p;
  }

  static Path glutesLeft() {
    final p = Path();
    p.moveTo(118.0, 206.0);
    p.cubicTo(108.0, 206.0, 96.0, 209.0, 88.0, 217.0);
    p.cubicTo(82.0, 225.0, 81.0, 238.0, 84.0, 248.0);
    p.cubicTo(88.0, 256.0, 98.0, 258.0, 108.0, 256.0);
    p.cubicTo(115.0, 254.0, 118.0, 248.0, 118.0, 238.0);
    p.close();
    return p;
  }

  static Path glutesRight() {
    final p = Path();
    p.moveTo(122.0, 206.0);
    p.cubicTo(132.0, 206.0, 144.0, 209.0, 152.0, 217.0);
    p.cubicTo(158.0, 225.0, 159.0, 238.0, 156.0, 248.0);
    p.cubicTo(152.0, 256.0, 142.0, 258.0, 132.0, 256.0);
    p.cubicTo(125.0, 254.0, 122.0, 248.0, 122.0, 238.0);
    p.close();
    return p;
  }

  static Path hamstringsLeft() {
    final p = Path();
    p.moveTo(90.0, 260.0);
    p.cubicTo(82.0, 268.0, 78.0, 284.0, 80.0, 300.0);
    p.cubicTo(82.0, 308.0, 88.0, 314.0, 94.0, 314.0);
    p.cubicTo(100.0, 314.0, 106.0, 308.0, 108.0, 298.0);
    p.cubicTo(111.0, 286.0, 110.0, 272.0, 108.0, 260.0);
    p.close();
    return p;
  }

  static Path hamstringsRight() {
    final p = Path();
    p.moveTo(150.0, 260.0);
    p.cubicTo(158.0, 268.0, 162.0, 284.0, 160.0, 300.0);
    p.cubicTo(158.0, 308.0, 152.0, 314.0, 146.0, 314.0);
    p.cubicTo(140.0, 314.0, 134.0, 308.0, 132.0, 298.0);
    p.cubicTo(129.0, 286.0, 130.0, 272.0, 132.0, 260.0);
    p.close();
    return p;
  }

  static Path backCalvesLeft() {
    final p = Path();
    p.moveTo(88.0, 318.0);
    p.cubicTo(80.0, 326.0, 76.0, 338.0, 78.0, 350.0);
    p.cubicTo(80.0, 358.0, 86.0, 362.0, 92.0, 360.0);
    p.cubicTo(96.0, 358.0, 100.0, 350.0, 100.0, 338.0);
    p.cubicTo(100.0, 328.0, 96.0, 320.0, 92.0, 318.0);
    p.close();
    return p;
  }

  static Path backCalvesRight() {
    final p = Path();
    p.moveTo(152.0, 318.0);
    p.cubicTo(160.0, 326.0, 164.0, 338.0, 162.0, 350.0);
    p.cubicTo(160.0, 358.0, 154.0, 362.0, 148.0, 360.0);
    p.cubicTo(144.0, 358.0, 140.0, 350.0, 140.0, 338.0);
    p.cubicTo(140.0, 328.0, 144.0, 320.0, 148.0, 318.0);
    p.close();
    return p;
  }

  // ----------------- REGION MAPPING -----------------

  /// Returns a combined Path for the requested BodyMuscleRegion.
  static Path getRegionPath(BodyMuscleRegion region) {
    final p = Path();
    switch (region) {
      case BodyMuscleRegion.chest:
        p.addPath(chestLeft(), Offset.zero);
        p.addPath(chestRight(), Offset.zero);
        break;
      case BodyMuscleRegion.shoulders:
        p.addPath(shouldersLeft(), Offset.zero);
        p.addPath(shouldersRight(), Offset.zero);
        break;
      case BodyMuscleRegion.biceps:
        p.addPath(bicepsLeft(), Offset.zero);
        p.addPath(bicepsRight(), Offset.zero);
        break;
      case BodyMuscleRegion.forearms:
        p.addPath(forearmsLeft(), Offset.zero);
        p.addPath(forearmsRight(), Offset.zero);
        break;
      case BodyMuscleRegion.abs:
        p.addPath(absUpperLeft(), Offset.zero);
        p.addPath(absUpperRight(), Offset.zero);
        p.addPath(absMidLeft(), Offset.zero);
        p.addPath(absMidRight(), Offset.zero);
        p.addPath(absLowerLeft(), Offset.zero);
        p.addPath(absLowerRight(), Offset.zero);
        p.addPath(obliquesLeft(), Offset.zero);
        p.addPath(obliquesRight(), Offset.zero);
        break;
      case BodyMuscleRegion.quadriceps:
        p.addPath(quadricepsLeft(), Offset.zero);
        p.addPath(quadricepsRight(), Offset.zero);
        break;
      case BodyMuscleRegion.frontCalves:
        p.addPath(frontCalvesLeft(), Offset.zero);
        p.addPath(frontCalvesRight(), Offset.zero);
        break;
      case BodyMuscleRegion.rearShoulders:
        p.addPath(rearShouldersLeft(), Offset.zero);
        p.addPath(rearShouldersRight(), Offset.zero);
        break;
      case BodyMuscleRegion.rearForearms:
        p.addPath(rearForearmsLeft(), Offset.zero);
        p.addPath(rearForearmsRight(), Offset.zero);
        break;
      case BodyMuscleRegion.triceps:
        p.addPath(tricepsLeft(), Offset.zero);
        p.addPath(tricepsRight(), Offset.zero);
        break;
      case BodyMuscleRegion.upperBack:
        p.addPath(upperBack(), Offset.zero);
        break;
      case BodyMuscleRegion.lats:
        p.addPath(latsLeft(), Offset.zero);
        p.addPath(latsRight(), Offset.zero);
        break;
      case BodyMuscleRegion.lowerBack:
        p.addPath(lowerBack(), Offset.zero);
        break;
      case BodyMuscleRegion.glutes:
        p.addPath(glutesLeft(), Offset.zero);
        p.addPath(glutesRight(), Offset.zero);
        break;
      case BodyMuscleRegion.hamstrings:
        p.addPath(hamstringsLeft(), Offset.zero);
        p.addPath(hamstringsRight(), Offset.zero);
        break;
      case BodyMuscleRegion.backCalves:
        p.addPath(backCalvesLeft(), Offset.zero);
        p.addPath(backCalvesRight(), Offset.zero);
        break;
    }
    return p;
  }

  /// Maps a [GymBroMuscleGroup] to its corresponding anatomy Path.
  static Path getMuscleGroupPath(GymBroMuscleGroup group) {
    switch (group) {
      case GymBroMuscleGroup.chest:
        return getRegionPath(BodyMuscleRegion.chest);
      case GymBroMuscleGroup.back:
        final p = Path();
        p.addPath(upperBack(), Offset.zero);
        p.addPath(latsLeft(), Offset.zero);
        p.addPath(latsRight(), Offset.zero);
        p.addPath(lowerBack(), Offset.zero);
        return p;
      case GymBroMuscleGroup.shoulders:
        return getRegionPath(BodyMuscleRegion.shoulders);
      case GymBroMuscleGroup.biceps:
        return getRegionPath(BodyMuscleRegion.biceps);
      case GymBroMuscleGroup.triceps:
        return getRegionPath(BodyMuscleRegion.triceps);
      case GymBroMuscleGroup.forearms:
        return getRegionPath(BodyMuscleRegion.forearms);
      case GymBroMuscleGroup.abs:
        return getRegionPath(BodyMuscleRegion.abs);
      case GymBroMuscleGroup.obliques:
        final p = Path();
        p.addPath(obliquesLeft(), Offset.zero);
        p.addPath(obliquesRight(), Offset.zero);
        return p;
      case GymBroMuscleGroup.quadriceps:
        return getRegionPath(BodyMuscleRegion.quadriceps);
      case GymBroMuscleGroup.hamstrings:
        return getRegionPath(BodyMuscleRegion.hamstrings);
      case GymBroMuscleGroup.calves:
        return getRegionPath(BodyMuscleRegion.backCalves);
      case GymBroMuscleGroup.glutes:
        return getRegionPath(BodyMuscleRegion.glutes);
    }
  }

  /// Preferred anatomical view for displaying a [GymBroMuscleGroup].
  static BodyMapView getMuscleGroupPreferredView(GymBroMuscleGroup group) {
    switch (group) {
      case GymBroMuscleGroup.chest:
      case GymBroMuscleGroup.shoulders:
      case GymBroMuscleGroup.biceps:
      case GymBroMuscleGroup.forearms:
      case GymBroMuscleGroup.abs:
      case GymBroMuscleGroup.obliques:
      case GymBroMuscleGroup.quadriceps:
        return BodyMapView.front;
      case GymBroMuscleGroup.back:
      case GymBroMuscleGroup.triceps:
      case GymBroMuscleGroup.hamstrings:
      case GymBroMuscleGroup.glutes:
      case GymBroMuscleGroup.calves:
        return BodyMapView.back;
    }
  }

  // ----------------- PRECISE HIT-TESTING -----------------

  /// Pixel-perfect mathematical Bézier hit testing against all muscles in the active view.
  static BodyMuscleRegion? hitTest(Offset point, BodyMapView view) {
    if (view == BodyMapView.front) {
      const frontRegions = [
        BodyMuscleRegion.chest,
        BodyMuscleRegion.shoulders,
        BodyMuscleRegion.biceps,
        BodyMuscleRegion.abs,
        BodyMuscleRegion.forearms,
        BodyMuscleRegion.quadriceps,
        BodyMuscleRegion.frontCalves,
      ];
      for (final r in frontRegions) {
        if (getRegionPath(r).contains(point)) return r;
      }
    } else {
      const backRegions = [
        BodyMuscleRegion.upperBack,
        BodyMuscleRegion.rearShoulders,
        BodyMuscleRegion.triceps,
        BodyMuscleRegion.lats,
        BodyMuscleRegion.lowerBack,
        BodyMuscleRegion.rearForearms,
        BodyMuscleRegion.glutes,
        BodyMuscleRegion.hamstrings,
        BodyMuscleRegion.backCalves,
      ];
      for (final r in backRegions) {
        if (getRegionPath(r).contains(point)) return r;
      }
    }
    return null;
  }
}
