import 'package:flutter/material.dart';
import 'package:vocabhub/utils/utils.dart';

class CircularAvatar extends StatelessWidget {
  final String? name;
  final VoidCallback? onTap;
  final String? url;
  final double radius;

  const CircularAvatar({
    super.key,
    this.name,
    this.onTap,
    this.url,
    this.radius = 32,
  }) : assert(name != null || url != null, 'name or url cannot be null');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget fallbackAvatar() {
      final initials = (name?.trim().isNotEmpty ?? false) ? name!.initals().toUpperCase() : '?';

      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    Widget image() {
      if (url == null || url!.isEmpty) {
        return fallbackAvatar();
      }

      if (url!.startsWith('assets/')) {
        return Image.asset(
          url!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallbackAvatar(),
        );
      }

      return Image.network(
        url!,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;

          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            child: child,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Center(
            child: SizedBox(
              width: radius * 0.6,
              height: radius * 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => fallbackAvatar(),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: radius * 2,
        width: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: ClipOval(
          child: image(),
        ),
      ),
    );
  }
}
