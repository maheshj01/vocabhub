import 'package:flutter/material.dart';

class SearchBuilder extends StatefulWidget {
  final Function(String) onChanged;
  final Function? ontap;
  final bool readOnly;
  final bool autoFocus;
  final Widget suffixIcon;
  final TextEditingController? controller;
  SearchBuilder(
      {Key? key,
      required this.onChanged,
      this.ontap,
      this.controller,
      this.autoFocus = false,
      this.suffixIcon = const SizedBox.shrink(),
      this.readOnly = false})
      : super(key: key);

  @override
  _SearchBuilderState createState() => _SearchBuilderState();
}

class _SearchBuilderState extends State<SearchBuilder> {
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    if (widget.controller != null) {
      _searchController = widget.controller!;
    }
    _searchController.addListener(() {
      widget.onChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    /// dispose the controller if it is not passed from outside
    if (widget.controller == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  late TextEditingController _searchController;
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        child: TextField(
          readOnly: widget.readOnly,
          controller: _searchController,
          autofocus: widget.autoFocus,
          onTap: () => widget.ontap!(),
          cursorHeight: 24,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                  gapPadding: 0,
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  gapPadding: 0,
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2))),
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                  tooltip: 'clear',
                  icon: _searchController.text.isNotEmpty
                      ? Icon(
                          Icons.clear,
                          color: Theme.of(context).colorScheme.surfaceTint,
                        )
                      : SizedBox.shrink(),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _searchController.clear();
                    }
                  }),
              hintText: "Search by word, meaning"),
        ));
  }
}
