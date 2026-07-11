import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// An animated, GPU-rendered page background.
///
/// Draws soft drifting colour blobs over a base surface via a single fragment
/// shader ([`shaders/background.frag`]) — no CPU mask blur and no
/// `BackdropFilter`, which is what the previous `BackgroundPainter` relied on.
///
/// Falls back to a static gradient when a shader can't be used: on web (runtime
/// shaders aren't reliably supported), when the OS requests reduced motion, or
/// if the shader fails to load. The widget paints only the background; page
/// content is stacked on top by the caller.
class MeshBackground extends StatefulWidget {
  const MeshBackground({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.baseColor,
    this.animate = true,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final Color baseColor;
  final bool animate;

  static const String _assetKey = 'shaders/background.frag';

  /// Loaded once and shared across every page surface.
  static ui.FragmentProgram? _program;
  static bool _loadFailed = false;

  static Future<void> _ensureProgram() async {
    if (_program != null || _loadFailed || kIsWeb) return;
    try {
      _program = await ui.FragmentProgram.fromAsset(_assetKey);
    } catch (_) {
      _loadFailed = true; // fall back to the gradient forever after.
    }
  }

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground> with SingleTickerProviderStateMixin {
  // Seconds since the widget mounted; the only thing that changes per frame.
  final ValueNotifier<double> _time = ValueNotifier<double>(0);
  Ticker? _ticker;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    MeshBackground._ensureProgram().then((_) {
      if (!mounted) return;
      final program = MeshBackground._program;
      if (program != null) {
        setState(() => _shader = program.fragmentShader());
      }
    });
  }

  /// Starts or stops the ticker to match [shouldAnimate]. Stopping lets the
  /// engine go idle (no per-vsync frames); the last [_time] value is retained
  /// so the blobs freeze in place instead of snapping back to t=0.
  void _syncTicker(bool shouldAnimate) {
    if (shouldAnimate) {
      _ticker ??= createTicker((elapsed) {
        _time.value = elapsed.inMicroseconds / 1e6;
      });
      if (!_ticker!.isActive) _ticker!.start();
    } else if (_ticker?.isActive ?? false) {
      _ticker!.stop();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _shader?.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect the OS "reduce motion" setting — hold a single static frame.
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final shouldAnimate = widget.animate && !reduceMotion;

    if (_shader == null) {
      // Web / reduced-motion / load failure → cheap static gradient.
      return _GradientFallback(
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
        baseColor: widget.baseColor,
      );
    }

    _syncTicker(shouldAnimate);

    // RepaintBoundary isolates the per-frame shader repaint from page content.
    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        willChange: shouldAnimate,
        size: Size.infinite,
        painter: _ShaderPainter(
          shader: _shader!,
          time: _time,
          animate: shouldAnimate,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
          baseColor: widget.baseColor,
        ),
      ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.shader,
    required this.time,
    required this.animate,
    required this.primaryColor,
    required this.secondaryColor,
    required this.baseColor,
  }) : super(repaint: animate ? time : null);

  final ui.FragmentShader shader;
  final ValueNotifier<double> time;
  final bool animate;
  final Color primaryColor;
  final Color secondaryColor;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Uniform order MUST match the declaration order in background.frag.
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time.value)
      ..setFloat(3, primaryColor.r)
      ..setFloat(4, primaryColor.g)
      ..setFloat(5, primaryColor.b)
      ..setFloat(6, primaryColor.a)
      ..setFloat(7, secondaryColor.r)
      ..setFloat(8, secondaryColor.g)
      ..setFloat(9, secondaryColor.b)
      ..setFloat(10, secondaryColor.a)
      ..setFloat(11, baseColor.r)
      ..setFloat(12, baseColor.g)
      ..setFloat(13, baseColor.b)
      ..setFloat(14, baseColor.a);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ShaderPainter old) {
    // Time changes drive repaint via `repaint:`; only rebuild-time changes
    // (colour/animation flips) need to be compared here.
    return old.primaryColor != primaryColor ||
        old.secondaryColor != secondaryColor ||
        old.baseColor != baseColor ||
        old.animate != animate;
  }
}

/// Static, dependency-free gradient used when the shader is unavailable.
class _GradientFallback extends StatelessWidget {
  const _GradientFallback({
    required this.primaryColor,
    required this.secondaryColor,
    required this.baseColor,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(primaryColor.withValues(alpha: 0.28), baseColor),
            baseColor,
            Color.alphaBlend(secondaryColor.withValues(alpha: 0.28), baseColor),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}
