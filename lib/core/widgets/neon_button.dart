import 'package:flutter/material.dart';
import '../theme.dart';

class NeonButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color glowColor;
  final Color buttonColor;
  final double radius;
  final double blurRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  const NeonButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.glowColor = NovaTheme.primary,
    this.buttonColor = NovaTheme.primary,
    this.radius = 16.0,
    this.blurRadius = 20.0,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: blurRadius,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onPressed,
          child: Padding(
            padding: padding,
            child: Center(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class NeonIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color glowColor;
  final Color buttonColor;
  final Color iconColor;
  final double size;
  final double blurRadius;

  const NeonIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.glowColor = NovaTheme.primary,
    this.buttonColor = NovaTheme.primary,
    this.iconColor = Colors.black,
    this.size = 56.0,
    this.blurRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: blurRadius,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Material(
        color: buttonColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}
