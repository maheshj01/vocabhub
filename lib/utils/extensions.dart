extension StringExtension on String {
  String capitalize() {
    var titleCase = RegExp(r'\b\w');
    return (this
        .replaceAllMapped(titleCase, (match) => match.group(0)!.toUpperCase()));
  }

  String initals() {
    /// Returns the first letter of each word in the string.
    return this.split(' ').map((e) => e.capitalize().substring(0, 1)).join();
  }
}
