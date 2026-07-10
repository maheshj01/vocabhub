import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/onboarding/domain/onboarding_slide.dart';
import 'package:vocabhub/onboarding/presentation/onboarding_notifier.dart';
import 'package:vocabhub/onboarding/presentation/widgets/onboarding_slide_view.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/utils/size_utils.dart';
import 'package:vocabhub/widgets/button.dart';

/// The onboarding tour. A single paged flow that lays each slide out
/// responsively — stacked on phones, media-beside-copy on tablet/desktop — and
/// persists completion through the [OnboardingNotifier].
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();

  /// Max width the paged content is centered within on large screens, so it
  /// doesn't stretch edge-to-edge on desktop/web.
  static const _maxContentWidth = 1100.0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingNotifierProvider.notifier).complete();
    if (!mounted) return;
    if (authController.user.isLoggedIn) {
      Navigate.pushAndPopAll(context, AdaptiveLayout());
    } else {
      Navigate.pushAndPopAll(context, AppSignIn());
    }
  }

  void _next(int count) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final slides = state.slides;
    if (slides.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final slide = state.currentSlide!;
    final onColor = slide.darkText ? Colors.black87 : Colors.white;

    return Scaffold(
      // Animate the backdrop so the color eases between slides.
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: Color(slide.backgroundColorValue),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: notifier.onPageChanged,
                      itemBuilder: (context, i) => _SlideLayout(slide: slides[i]),
                    ),
                  ),
                ),
              ),

              // Skip — top-right, marks onboarding complete and moves on.
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: state.isCompleting ? null : _finish,
                    child: Text('Skip', style: TextStyle(color: onColor)),
                  ),
                ),
              ),

              // Page indicator + primary CTA.
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSmoothIndicator(
                        activeIndex: state.index,
                        count: state.count,
                        effect: WormEffect(
                          dotColor: onColor.withValues(alpha: 0.3),
                          activeDotColor: onColor,
                          dotHeight: 8,
                          dotWidth: 8,
                        ),
                      ),
                      const SizedBox(height: 24),
                      state.isLastSlide
                          ? VHButton(
                              height: 48,
                              width: 180,
                              isLoading: state.isCompleting,
                              onTap: _finish,
                              label: 'Get Started',
                            )
                          : VHButton(
                              height: 48,
                              width: 140,
                              onTap: () => _next(state.count),
                              label: 'Next',
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays out one slide: media above copy on narrow screens, media beside copy on
/// wide ones. Uses the parent's available width (not device type) to decide.
class _SlideLayout extends StatelessWidget {
  final OnboardingSlide slide;
  const _SlideLayout({required this.slide});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= SizeUtils.kTabletBreakPoint;
        final media = Padding(
          padding: const EdgeInsets.all(16.0),
          child: OnboardingSlideView(slide: slide),
        );
        final copy = _SlideCopy(slide: slide, large: isWide);

        if (isWide) {
          return Row(
            children: [
              Expanded(child: media),
              Expanded(child: Center(child: copy)),
            ],
          );
        }
        return Column(
          children: [
            Expanded(child: media),
            Padding(
              padding: const EdgeInsets.only(bottom: 140.0),
              child: copy,
            ),
          ],
        );
      },
    );
  }
}

/// Title + description for a slide, width-constrained for readability.
class _SlideCopy extends StatelessWidget {
  final OnboardingSlide slide;
  final bool large;
  const _SlideCopy({required this.slide, required this.large});

  @override
  Widget build(BuildContext context) {
    final onColor = slide.darkText ? Colors.black87 : Colors.white;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: large ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Text(
              slide.title,
              textAlign: large ? TextAlign.start : TextAlign.center,
              style: TextStyle(
                fontSize: large ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: onColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              slide.description,
              textAlign: large ? TextAlign.start : TextAlign.center,
              style: TextStyle(fontSize: large ? 18 : 16, color: onColor, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
