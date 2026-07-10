import 'package:vocabhub/constants/assets.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/onboarding/domain/onboarding_slide.dart';

/// The canonical onboarding tour content.
///
/// Previously this was an inline widget list in `onboard.dart`, with copy pulled
/// from index-aligned global lists (`onBoardingTitles` / `onBoardingDescriptions`)
/// in `strings.dart`. Consolidated here as plain data.
const List<OnboardingSlide> kOnboardingSlides = [
  OnboardingSlide(
    title: 'Word Power Unleashed',
    description:
        'Supercharge your vocabulary with 800+ curated GRE words, synonyms, '
        'mnemonics, and examples for comprehensive language learning.',
    assetPath: Assets.dark,
    media: SlideMedia.wordCarousel,
    backgroundColorValue: 0xFFB4FFFE,
    darkText: true,
  ),
  OnboardingSlide(
    title: 'Collaborative Learning Community',
    description:
        'Join our language community, contribute words, suggest edits, and share '
        'examples to build a platform for continuous learning and improvement.',
    assetPath: Constants.teamworkAsset,
    media: SlideMedia.networkImage,
    backgroundColorValue: 0xFFFFFFFF,
    darkText: true,
  ),
  OnboardingSlide(
    title: 'Word of the Day',
    description:
        'Stay inspired with our captivating "Word of the Day" feature, '
        'discovering intriguing new words with definitions, examples, and '
        'insights every day, all year long.',
    assetPath: Assets.wod,
    media: SlideMedia.rive,
    riveAnimations: ['Animation 1'],
    backgroundColorValue: 0xFF0A0611,
  ),
  OnboardingSlide(
    title: 'Explore curated words',
    description:
        "Explore a diverse range of captivating words in the 'Explore' section. "
        'We curate personalized learning experiences, empowering you to '
        'effectively expand your vocabulary and master new words.',
    assetPath: Assets.balloon,
    media: SlideMedia.rive,
    riveAnimations: [
      'Balloon Rotation',
      'Cloud Rotation',
      'Cloud 1',
      'Cloud 2',
      'Cloud 3',
      'Cloud 4',
    ],
    backgroundColorValue: 0xFFA8C9F8,
  ),
  OnboardingSlide(
    title: 'Dark Mode and color themes',
    description:
        'Personalize your app experience with Dark Mode and personalized color '
        "schemes. Enjoy a learning journey that's uniquely yours, with an app "
        'that matches your style and feels tailor-made for you.',
    assetPath: Assets.dark,
    media: SlideMedia.rive,
    riveAnimations: ['orbitAnimation'],
    backgroundColorValue: 0xFF151421,
  ),
];
