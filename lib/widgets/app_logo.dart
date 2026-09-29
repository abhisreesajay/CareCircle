import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum LogoStyle { elder, caregiver, admin }

class AppLogo extends StatelessWidget {
  final double iconSize;
  final LogoStyle style;

  const AppLogo({
    super.key,
    this.iconSize = 32,
    this.style = LogoStyle.caregiver,
  });

  @override
  Widget build(BuildContext context) {
    Color containerColor;
    Color iconColor;
    Color textColor;

    switch (style) {
      case LogoStyle.elder:
        containerColor = ElderColors.secondary;
        iconColor = Colors.white;
        textColor = ElderColors.primary;
        break;
      case LogoStyle.admin:
        containerColor = AdminColors.accent;
        iconColor = Colors.white;
        textColor = AdminColors.primary;
        break;
      case LogoStyle.caregiver:
        containerColor = CaregiverColors.duskBlue;
        iconColor = CaregiverColors.lightBronze;
        textColor = CaregiverColors.duskBlue;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: containerColor.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Icon(
            Icons.diversity_1_rounded,
            color: iconColor,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CareCircle',
              style: TextStyle(
                fontSize: iconSize * 0.75,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              style == LogoStyle.admin
                  ? 'MANAGEMENT CONSOLE'
                  : style == LogoStyle.elder
                      ? 'ASSISTIVE PORTAL'
                      : 'CARE NETWORK',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: style == LogoStyle.elder ? ElderColors.secondary : CaregiverColors.dustyLavender,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
