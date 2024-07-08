import 'package:flutter/material.dart';

class CircularAvatar extends StatelessWidget {
  final String? name;
  final void Function()? onTap;
  final String? url;
  final double radius;

  const CircularAvatar({Key? key, this.name, this.onTap, this.url, this.radius = 32.0})
      : assert(name != null || url != null, 'name or url cannot be null'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget nameText = Text(name!, style: Theme.of(context).textTheme.headlineLarge!);
    Widget getImageProvider(String imagePath) {
      if (imagePath.contains('assets/')) {
        return Image.asset(imagePath);
      } else {
        return Image.network(
          url!,
          errorBuilder: (x, y, z) {
            return nameText;
          },
        );
      }
    }

    return GestureDetector(
        onTap: onTap,
        child: Container(
            height: radius * 2,
            width: radius * 2,
            decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(width: 2, color: Colors.grey),
                shape: BoxShape.circle),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: (url == null || url!.isEmpty) ? nameText : getImageProvider(url!),
            )));
  }
}
