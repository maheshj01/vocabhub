import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:rive/rive.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';

class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int index = 0;

  List<String> urls = [
    'https://sites.uci.edu/sbass/files/2022/05/AF7A55DF-ABEE-4850-B93D-846C75426F32-400x400.png',
    'https://www.theunbiasedblog.com/wp-content/uploads/2021/07/OutfitSticker2.png',
    'https://www.theunbiasedblog.com/wp-content/uploads/2021/07/Sticker4.png',
    'https://i.pinimg.com/originals/86/78/38/867838a7898ee96dfdcfb53eda0d3430.png'
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final List<Widget> pages = [
      // Add your onboarding pages here
      OnboardingContentPage(
        index: 0,
        title: 'Explore curated words',
        description:
            'Explore personalized words and definitions everytime you scroll through the explore page',
        color: Color(0xffDECEED),
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
        index: 1,
        title: 'Word of the Day',
        description: 'Learn a new word everyday throught out the year',
        color: Color.fromRGBO(10, 6, 17, 1.0),
        animations: [
          'Animation 1',
        ],
      ),
      OnboardingContentPage(
        index: 2,
        title: 'Dark Mode',
        description: 'Dark mode is here to save your eyes',
        animations: [
          'orbitAnimation',
        ],
        color: Color(0xff151421),
      ),
      OnboardingContentPage(
        index: 3,
        title: 'Crowd Sourced',
        description: 'We are a community of learners, Your contribution helps everyone',
        animations: [],
        color: Colors.white,
      )
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

class OnboardingContentPage extends StatefulWidget {
  final String title;
  final String description;
  final Color? color;
  final int index;
  final List<String> animations;
  const OnboardingContentPage(
      {Key? key,
      required this.index,
      required this.title,
      required this.description,
      required this.color,
      required this.animations})
      : super(key: key);

  @override
  State<OnboardingContentPage> createState() => _OnboardingContentPageState();
}

class _OnboardingContentPageState extends State<OnboardingContentPage> {
  final assetPaths = [
    'assets/rive/balloon.riv',
    'assets/rive/wod.riv',
    'assets/rive/dark.riv',
    'assets/rive/team-work.gif',
  ];

  @override
  void didUpdateWidget(covariant OnboardingContentPage oldWidget) {
    // TODO: implement didUpdateWidget
    print(oldWidget.index == widget.index);
    super.didUpdateWidget(oldWidget);
  }

  late RiveAnimationController _controller;

  // Toggles between play and pause animation states
  void _togglePlay() => setState(() => _controller.isActive = !_controller.isActive);

  /// Tracks if the animation is playing by whether controller is running
  bool get isPlaying => _controller.isActive;

  @override
  void initState() {
    _controller = SimpleAnimation('Animation 1');
    super.initState();
  }

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

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: widget.color,
      alignment: Alignment.center,
      child: Column(
        children: [
          32.0.vSpacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: widget.index == 0 || widget.index == 3 ? Colors.black : Colors.white,
              ),
            ),
          ),
          widget.index < 3
              ? SizedBox(
                  height: size.height * 0.5,
                  child: RiveAnimation.asset(
                    '${assetPaths[widget.index]}',
                    animations: widget.animations,
                    controllers: [_controller],
                  ),
                )
              : SizedBox(
                  height: size.height * 0.5,
                  child: Image.asset(
                    '${assetPaths[widget.index]}',
                  )),
          32.0.vSpacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.description,
              style: TextStyle(
                fontSize: 18.0,
                color: widget.index == 0 || widget.index == 3 ? Colors.black : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          32.0.vSpacer(),
          widget.index == 3
              ? VHButton(height: 48, isLoading: isLoading, onTap: onBoardComplete, label: 'Lets Go')
              : SizedBox.shrink()
        ],
      ),
    );
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
