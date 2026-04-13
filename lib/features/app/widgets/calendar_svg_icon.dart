import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CalendarSvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final double blurRadius;
  final Offset offset;
  final EdgeInsets padding;
  final Color shadowColor;

  const CalendarSvgIcon({
    super.key,
    required this.assetPath,
    this.size = 32,
    this.blurRadius = 8,
    this.offset = const Offset(0, 2),
    this.padding = const EdgeInsets.all(0),
    this.shadowColor = const Color(0x1A000000),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: blurRadius,
            offset: offset,
          ),
        ],
      ),
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
      ),
    );
  }
}
