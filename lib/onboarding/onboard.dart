import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/widgets/button.dart';

import 'onboarding.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int index = 0;

  Future<void> onBoardComplete() async {
    setState(() {
      isLoading = true;
    });
    settingsController.onBoarded = true;
    setState(() {
      isLoading = false;
    });
    final user = ref.read(userNotifierProvider).value;
    if (user!.isLoggedIn) {
      Navigate.pushAndPopAll(context, AdaptiveLayout());
    } else {
      Navigate.pushAndPopAll(context, AppSignIn());
    }
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      OnboardingContentPage(
        index: 0,
        assetPath: 'assets/rive/dark.riv',
        animations: [
          'orbitAnimation',
        ],
        color: Color.fromARGB(255, 180, 255, 254),
      ),
      OnboardingContentPage(
        index: 1,
        assetPath: Constants.teamworkAsset,
        animations: [],
        color: Colors.white,
      ),
      OnboardingContentPage(
        index: 2,
        assetPath: 'assets/rive/wod.riv',
        color: Color.fromRGBO(10, 6, 17, 1.0),
        animations: [
          'Animation 1',
        ],
      ),
      // Add your onboarding pages here
      OnboardingContentPage(
        index: 3,
        color: Color(0xffA8C9F8),
        assetPath: 'assets/rive/balloon.riv',
        animations: [
          'Balloon Rotation',
          'Cloud Rotation',
          'Cloud 1',
          'Cloud 2',
          'Cloud 3',
          'Cloud 4',
        ],
      ),
      OnboardingContentPage(
        index: 4,
        assetPath: 'assets/rive/dark.riv',
        animations: [
          'orbitAnimation',
        ],
        color: Color(0xff151421),
      ),
    ];
    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
          child: PageView.builder(
            itemCount: pages.length,
            onPageChanged: (x) {
              setState(() {
                index = x;
              });
            },
            itemBuilder: (context, index) {
              return pages[index % pages.length];
              //   return Stack(children: [
              //     pages[index % pages.length],
              //     Align(
              //         alignment: Alignment.topCenter,
              //         child: ClipPath(
              //           clipper: CircleClipper(
              //             center: Offset(500, 400),
              //             radius: 100,
              //           ),
              //           child: Container(
              //             height: 200,
              //             width: 200,
              //             color: Colors.red,
              //             padding: const EdgeInsets.only(top: 100.0),
              //             child: FlutterLogo(),
              //           ),
              //         )),
              //   ]);
            },
          ),
        ),
        // Align(
        //     alignment: Alignment.topCenter,
        //     child: Padding(
        //       padding: const EdgeInsets.only(top: 100.0),
        //       child: Container(
        //         height: 200,
        //         width: 200,
        //         color: Colors.amber.withOpacity(0.2),
        //         padding: const EdgeInsets.only(top: 100.0),
        //       ),
        //     )),
        Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: index == 4
                  ? VHButton(
                      height: 48,
                      width: 160,
                      isLoading: isLoading,
                      onTap: onBoardComplete,
                      label: 'Get Started')
                  : SizedBox.shrink(),
            )),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: AnimatedSmoothIndicator(
              activeIndex: index,
              count: pages.length,
              effect: WormEffect(),
            ),
          ),
        )
      ],
    ));
  }
}

class ImageHolder extends StatelessWidget {
  String imageUrl;
  ImageHolder({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
        clipBehavior: Clip.hardEdge,
        clipper: CircleClipper(
          center: Offset(500, 400),
          radius: 100,
        ),
        child: Container(
          height: 200,
          width: 200,
          alignment: Alignment.center,
          color: Colors.grey,
        ));
  }
}

class SquareClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addRRect(RRect.fromLTRBR(100, 100, 100, 100, Radius.circular(16.0)));
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}

class CircleClipper extends CustomClipper<Path> {
  CircleClipper({required this.center, required this.radius});
  final Offset center;
  final double radius;
  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(radius: radius, center: center));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
