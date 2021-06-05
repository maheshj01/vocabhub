extension StringExtension on String {
  String capitalize() {
    var titleCase = RegExp(r'\b\w');
    return (this
        .replaceAllMapped(titleCase, (match) => match.group(0)!.toUpperCase()));
  }
}
