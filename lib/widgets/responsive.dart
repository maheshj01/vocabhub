import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/utils/size_utils.dart';
import 'package:vocabhub/widgets/mesh_background.dart';

class ResponsiveBuilder extends ConsumerStatefulWidget {
  /// Used for all screen sizes.
  final Widget? child;

  /// Used when different layouts are needed.
  final WidgetBuilder? mobileBuilder;
  final WidgetBuilder? desktopBuilder;
  final WidgetBuilder? tabletBuilder;

  /// Maximum width for tablet/desktop layouts.
  final double? maxContentWidth;

  final bool animate;
  final double initialAnimationValue;
  final bool repeatAnimation;
  final VoidCallback? onAnimateComplete;
  final Duration animationDuration;

  const ResponsiveBuilder({
    super.key,
    this.child,
    this.mobileBuilder,
    this.desktopBuilder,
    this.tabletBuilder,
    this.maxContentWidth,
    this.animate = false,
    this.repeatAnimation = true,
    this.onAnimateComplete,
    this.animationDuration = const Duration(seconds: 6),
    this.initialAnimationValue = 0.0,
  })  : assert(
          child != null || (mobileBuilder != null && desktopBuilder != null),
          'Provide either child or both mobileBuilder and desktopBuilder.',
        ),
        assert(
          !(child != null &&
              (mobileBuilder != null || desktopBuilder != null || tabletBuilder != null)),
          'Cannot provide both child and builders.',
        );

  @override
  ConsumerState<ResponsiveBuilder> createState() => _ResponsiveBuilderState();
}

class _ResponsiveBuilderState extends ConsumerState<ResponsiveBuilder>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animationDuration);
    _maybeRunIntro();
  }

  /// The animated page background now self-animates on the GPU inside
  /// [MeshBackground]. This controller only drives one-shot intros that report
  /// back via [ResponsiveBuilder.onAnimateComplete]; repeating themes no longer
  /// need a perpetually-running ticker here.
  void _maybeRunIntro() {
    final isClassic = ref.read(appThemeProvider).isClassic;
    if (!isClassic && widget.animate && !widget.repeatAnimation) {
      _controller
        ..reset()
        ..addStatusListener(_handleStatus)
        ..forward();
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimateComplete?.call();
      _controller.stop();
    }
  }

  Widget _buildContent(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    if (widget.child != null) {
      return widget.child!;
    }

    switch (SizeUtils.screenTypeOf(constraints.maxWidth)) {
      case ScreenType.desktop:
        return _constrain(widget.desktopBuilder!(context));

      case ScreenType.tablet:
        return _constrain(
          (widget.tabletBuilder ?? widget.desktopBuilder!)(context),
        );

      case ScreenType.mobile:
        return widget.mobileBuilder!(context);
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ResponsiveBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate ||
        oldWidget.repeatAnimation != widget.repeatAnimation) {
      _controller.removeStatusListener(_handleStatus);
      _maybeRunIntro();
    }
  }

  /// Centers and width-constrains large-screen content when [maxContentWidth]
  /// is set; otherwise returns the child untouched.
  Widget _constrain(Widget child) {
    final maxWidth = widget.maxContentWidth;
    if (maxWidth == null) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    SizeUtils.size = MediaQuery.sizeOf(context);

    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = _buildContent(context, constraints);

          final isMobile = SizeUtils.screenTypeOf(constraints.maxWidth) == ScreenType.mobile;

          if (!isMobile) {
            return content;
          }

          final appTheme = ref.watch(appThemeProvider);
          final isLoggedIn = ref.watch(userNotifierProvider).isLoggedIn;

          // Logged-out screens (login, phone auth) always show the animated mesh
          // as the default first impression — a signed-out user hasn't chosen a
          // classic/static preference yet, so persisted settings don't apply.
          // Once signed in, the user's theme choice is respected.
          final showMesh = !isLoggedIn || !appTheme.isClassic;
          final animate = !isLoggedIn || appTheme.dynamicBackground;

          return Stack(
            children: [
              if (showMesh)
                Positioned.fill(
                  child: MeshBackground(
                    primaryColor: colorScheme.primary,
                    secondaryColor: colorScheme.inversePrimary,
                    baseColor: colorScheme.surface,
                    animate: animate,
                  ),
                ),
              content,
            ],
          );
        },
      ),
    );
  }
}
