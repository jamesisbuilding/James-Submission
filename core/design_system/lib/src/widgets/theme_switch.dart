import 'package:flutter/material.dart';

import '../utils/design_image.dart';
import 'buttons/custom_icon_button.dart';
import '../../gen/assets.gen.dart';

/// Switch to toggle between light and dark theme.
/// Uses [onThemeToggle] callback to trigger theme change (from DI etc).
class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomIconButton(
      icon: isDark
          ? Assets.icons.sun.designImage(
              height: 24,
              width: 24,
              color: Theme.of(context).colorScheme.onSurface,
            )
          : Assets.icons.moon.designImage(
              height: 24,
              width: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      onTap: onThemeToggle,
    );
  }
}
