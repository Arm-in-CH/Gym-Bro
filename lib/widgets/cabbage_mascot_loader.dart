import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';
import '../core/graphics/graphics.dart';

/// GymBro's Signature Mascot Loader: The Gym Cabbage (کلم ورزشی)
/// Inspired by the mascot in gymbro-next-vercel, optimized for 60fps Flutter MD3.
class CabbageMascotLoader extends StatefulWidget {
  final String text;
  final String subtext;
  final double height;
  final bool compact;

  const CabbageMascotLoader({
    super.key,
    this.text = 'کلم ورزشی در حال بلعیدن و هضم دمبل‌ها...',
    this.subtext = 'تبدیل دمبل‌ها به پروتئین خالص و ریکاوری عضله...',
    this.height = 130,
    this.compact = false,
  });

  @override
  State<CabbageMascotLoader> createState() => _CabbageMascotLoaderState();
}

class _CabbageMascotLoaderState extends State<CabbageMascotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.ticker,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      if (_controller.isAnimating) {
        _controller.stop();
        _controller.value = 0.5;
      }
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTokens;

    return Semantics(
      liveRegion: true,
      label: 'در حال بارگذاری: ${widget.text}',
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: AppRadii.roundedXl,
          border: Border.all(color: tokens.lime.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: tokens.lime.withOpacity(0.08),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: RepaintBoundary(
                child: SizedBox(
                  height: widget.compact ? 64 : 84,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        alignment: AlignmentDirectional.centerStart,
                        clipBehavior: Clip.hardEdge,
                        children: [
                          // Dumbbell / Gear Conveyor moving towards the Cabbage mouth
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  start: 60, end: 10),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final w = constraints.maxWidth;
                                  return ClipRect(
                                    child: Stack(
                                      clipBehavior: Clip.hardEdge,
                                      children: [
                                        _buildConveyorItem(
                                          progress: (_controller.value) % 1.0,
                                          width: w,
                                          graphic: const GymBroEquipmentIllustration(
                                            type: GymBroEquipmentType.dumbbell,
                                            size: 18,
                                          ),
                                          color: tokens.gold,
                                        ),
                                        _buildConveyorItem(
                                          progress:
                                              (_controller.value + 0.33) % 1.0,
                                          width: w,
                                          graphic: const GymBroEquipmentIllustration(
                                            type: GymBroEquipmentType.kettlebell,
                                            size: 18,
                                          ),
                                          color: tokens.lime,
                                        ),
                                        _buildConveyorItem(
                                          progress:
                                              (_controller.value + 0.66) % 1.0,
                                          width: w,
                                          graphic: const GymBroNutritionIllustration(
                                            type: GymBroNutritionType.water,
                                            size: 18,
                                          ),
                                          color: tokens.cyan,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Cabbage Mascot Character on the Left
                          Transform.translate(
                            offset: Offset(0,
                                math.sin(_controller.value * math.pi * 4) * 2),
                            child: _buildCabbageCharacter(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            AppSpacing.hSm,
            Text(
              widget.text,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (!widget.compact && widget.subtext.isNotEmpty) ...[
              AppSpacing.hXxs,
              Text(
                widget.subtext,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tokens.lime,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConveyorItem({
    required double progress,
    required double width,
    IconData? icon,
    Widget? graphic,
    required Color color,
  }) {
    // Moves from right/end (1.0) towards character mouth at start (0.0)
    final x = (1.0 - progress) * width;
    // Fades and scales in smoothly at start of conveyor (progress 0.0 - 0.10)
    // and cleanly shrinks & disappears into the mouth before hitting 0.92
    final scale = progress < 0.80
        ? (progress < 0.1 ? progress * 10 : 1.0)
        : math.max(0.0, (0.92 - progress) * 8.3);
    final opacity = progress < 0.88 ? 1.0 : math.max(0.0, (0.92 - progress) * 25.0);

    // Aligned directly with the cabbage mouth center (compact: 20px, regular: 30px)
    final topOffset = widget.compact ? 20.0 : 30.0;

    return PositionedDirectional(
      start: x.clamp(0.0, math.max(0.0, width - 28)),
      top: topOffset,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale.clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: -progress * math.pi * 4,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Center(
                child: graphic ??
                    (icon != null
                        ? Icon(icon, size: 16, color: color)
                        : const SizedBox.shrink()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCabbageCharacter() {
    // Chomp mouth open/close cycle (faster frequency)
    final chompCycle = math.sin(_controller.value * math.pi * 10).abs();
    final mouthHeight = 4.0 + (chompCycle * 10.0);

    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          // Outer Cabbage Leaf Layers
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF15803D),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lime.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          // Inner Bright Green Body
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF22C55E),
            ),
          ),

          // Red Gym Sweatband with "GYM" text
          Positioned(
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 2),
                ],
              ),
              child: const Text(
                'GYM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),

          // Eyes looking towards the food conveyor
          PositionedDirectional(
            top: 24,
            start: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEye(),
                const SizedBox(width: 8),
                _buildEye(),
              ],
            ),
          ),

          // Pink Blush Cheeks
          PositionedDirectional(
            top: 34,
            start: 12,
            child: Container(
              width: 8,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFF472B6).withOpacity(0.85),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          PositionedDirectional(
            top: 34,
            end: 12,
            child: Container(
              width: 8,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFF472B6).withOpacity(0.85),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Pac-Man Chomp Mouth on the trailing edge (towards conveyor)
          PositionedDirectional(
            end: 4,
            top: 34 - (mouthHeight / 2),
            child: Container(
              width: 14,
              height: mouthHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF881337),
                borderRadius: BorderRadiusDirectional.horizontal(
                  start: const Radius.circular(8),
                  end: Radius.circular(mouthHeight / 2),
                ),
                border: Border.all(color: Colors.white24, width: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Container(
          width: 2.5,
          height: 2.5,
          margin: const EdgeInsetsDirectional.only(top: 1, end: 1),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
