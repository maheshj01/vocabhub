import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/widgets/button.dart';

import 'onboarding.dart';

class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int index = 0;

  Future<void> onBoardComplete() async {
    setState(() {
      isLoading = true;
    });
    settingsController.onBoarded = true;
    setState(() {
      isLoading = false;
    });
    Navigate.pushAndPopAll(context, AppSignIn());
  }

  final List<Widget> pages = [
    OnboardingContentPage(
      index: 0,
      title: 'A Crowd Sourced platform',
      assetPath: 'assets/rive/team-work.gif',
      description: 'We are a community of learners, Your contribution helps everyone',
      animations: [],
      color: Colors.white,
    ),
    OnboardingContentPage(
      index: 1,
      title: 'Word of the Day',
      assetPath: 'assets/rive/wod.riv',
      description: 'Learn a new word everyday throught out the year',
      color: Color.fromRGBO(10, 6, 17, 1.0),
      animations: [
        'Animation 1',
      ],
    ),
    // Add your onboarding pages here
    OnboardingContentPage(
      index: 2,
      title: 'Explore curated words',
      description:
          'Explore personalized words and definitions everytime you scroll through the explore page',
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
      index: 3,
      title: 'Dark Mode',
      assetPath: 'assets/rive/dark.riv',
      description: 'Dark mode is here to save your eyes',
      animations: [
        'orbitAnimation',
      ],
      color: Color(0xff151421),
    ),
  ];
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
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
              child: index == 3
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
