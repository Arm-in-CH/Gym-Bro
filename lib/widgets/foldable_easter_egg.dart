import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/services/foldable_device_service.dart';
import '../core/theme/app_tokens.dart';
import 'cabbage_mascot_loader.dart';

class FoldableEasterEggOverlay extends StatefulWidget {
  final Widget child;

  const FoldableEasterEggOverlay({
    super.key,
    required this.child,
  });

  @override
  State<FoldableEasterEggOverlay> createState() =>
      _FoldableEasterEggOverlayState();
}

class _FoldableEasterEggOverlayState extends State<FoldableEasterEggOverlay>
    with WidgetsBindingObserver {
  final FoldableDeviceService _foldableService = FoldableDeviceService();
  bool _isEggVisible = false;
  bool _isEggPending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foldableService.addListener(_onFoldableServiceChanged);

    // Initial check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEasterEggTrigger();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _foldableService.removeListener(_onFoldableServiceChanged);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Allow window layout info to propagate, then evaluate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkEasterEggTrigger();
      }
    });
  }

  void _onFoldableServiceChanged() {
    if (mounted) {
      _checkEasterEggTrigger();
    }
  }

  void _checkEasterEggTrigger() {
    if (!mounted) return;
    try {
      final mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery == null) return;
      _foldableService.updateDisplayMetrics(
        screenSize: mediaQuery.size,
        displayFeatures: mediaQuery.displayFeatures,
      );

      if (_foldableService.shouldTriggerEasterEgg() &&
          !_isEggVisible &&
          !_isEggPending) {
        _isEggPending = true;
        Future.delayed(const Duration(milliseconds: 650), () {
          _isEggPending = false;
          if (!mounted ||
              _isEggVisible ||
              !_foldableService.shouldTriggerEasterEgg()) return;
          _foldableService.markEasterEggShown();
          setState(() => _isEggVisible = true);
        });
      }
    } catch (_) {
      // Element may be deactivated during tree replacement
    }
  }

  void _dismissEgg() {
    if (mounted && _isEggVisible) {
      setState(() {
        _isEggVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_isEggVisible)
          Positioned.fill(
            child: FoldableEasterEggBanner(
              onDismiss: _dismissEgg,
            ),
          ),
      ],
    );
  }
}

class FoldableEasterEggBanner extends StatefulWidget {
  final VoidCallback onDismiss;
  final Duration displayDuration;

  const FoldableEasterEggBanner({
    super.key,
    required this.onDismiss,
    this.displayDuration = const Duration(seconds: 6),
  });

  @override
  State<FoldableEasterEggBanner> createState() =>
      _FoldableEasterEggBannerState();
}

class _FoldableEasterEggBannerState extends State<FoldableEasterEggBanner>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _progressController;

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOut,
      ),
    );

    // Auto-dismiss countdown progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: widget.displayDuration,
    );

    _entranceController.forward();
    _progressController.forward().then((_) {
      _startExit();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startExit() {
    if (_isExiting) return;
    _isExiting = true;
    _progressController.stop();
    _entranceController.reverse().whenComplete(() {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final size = MediaQuery.of(context).size;
    final maxCardWidth = math.min(size.width * 0.9, 520.0);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _startExit,
        child: Container(
          color: Colors.black.withOpacity(0.45),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            // Prevent tapping inside card from immediately propagating if user clicks button
            onTap: () {},
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Confetti Particle Canvas
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _FoldableConfettiPainter(
                                progress: _entranceController.value,
                              ),
                            ),
                          ),
                        ),
                        // Easter Egg Card Content
                        Container(
                          width: maxCardWidth,
                          decoration: BoxDecoration(
                            color: const Color(0xF00F172A),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: tokens.lime.withOpacity(0.6),
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: tokens.lime.withOpacity(0.25),
                                blurRadius: 32,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Top decorative header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tokens.lime.withOpacity(0.12),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: tokens.lime.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: tokens.lime,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'GYMBRO FOLD',
                                          style: TextStyle(
                                            color: tokens.textOnLime,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        color: Colors.white70,
                                        tooltip: 'بستن',
                                        onPressed: _startExit,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                const CabbageMascotLoader(
                                  compact: true,
                                  height: 92,
                                  text: 'کلم ورزشی آماده‌ی تمرینه',
                                  subtext: 'یک نفس بگیر و ست بعدی رو شروع کن.',
                                ),
                                const SizedBox(height: 16),

                                // Required Persian Message
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                    'اوه، ببین کی داره پُز می‌ده بابا!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Required Subtitle
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                    'حالا برو تمرینتو بکن.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: tokens.textMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Action Button: Dismiss & Go to workout
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: tokens.lime,
                                        foregroundColor: tokens.textOnLime,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: _startExit,
                                      icon: const Icon(
                                          Icons.fitness_center_rounded,
                                          size: 18),
                                      label: const Text(
                                        'باشه، بریم تمرین',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Auto-dismiss countdown bar
                                AnimatedBuilder(
                                  animation: _progressController,
                                  builder: (context, _) {
                                    return LinearProgressIndicator(
                                      value: 1.0 - _progressController.value,
                                      backgroundColor:
                                          tokens.lime.withOpacity(0.12),
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        tokens.lime,
                                      ),
                                      minHeight: 3,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FoldableConfettiPainter extends CustomPainter {
  final double progress;

  _FoldableConfettiPainter({required this.progress});

  static final List<_ConfettiParticle> _particles = List.generate(28, (i) {
    final random = math.Random(i * 37 + 11);
    return _ConfettiParticle(
      angle: random.nextDouble() * 2 * math.pi,
      distance: 90.0 + random.nextDouble() * 140.0,
      size: 4.0 + random.nextDouble() * 7.0,
      color: [
        const Color(0xFFA3E635), // Lime
        const Color(0xFFF59E0B), // Amber
        const Color(0xFF38BDF8), // Sky
        const Color(0xFFEC4899), // Pink
        Colors.white,
      ][i % 5],
      rotationSpeed: (random.nextDouble() - 0.5) * 4,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final eased = Curves.easeOutCubic.transform(progress);
      final r = p.distance * eased;
      final x = center.dx + math.cos(p.angle) * r;
      final y = center.dy + math.sin(p.angle) * r + (progress * 25.0);
      final alpha = (1.0 - (progress * 0.4)).clamp(0.0, 1.0);

      paint.color = p.color.withOpacity(alpha);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed * math.pi);
      canvas.drawCircle(Offset.zero, p.size, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FoldableConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ConfettiParticle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double rotationSpeed;

  const _ConfettiParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });
}
