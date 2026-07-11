/// Pure domain value object: a user's contribution tallies shown on the profile
/// screen. No framework imports — plain immutable data.
class ContributionStats {
  final int wordsAdded;
  final int wordsEdited;
  final int underReview;

  const ContributionStats({
    this.wordsAdded = 0,
    this.wordsEdited = 0,
    this.underReview = 0,
  });

  static const ContributionStats empty = ContributionStats();

  int get total => wordsAdded + wordsEdited + underReview;
}
