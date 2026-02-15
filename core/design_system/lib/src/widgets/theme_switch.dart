import 'package:flutter/material.dart';

import '../utils/design_image.dart';
import 'buttons/custom_icon_button.dart';
import '../../gen/assets.gen.dart';

/// Switch to toggle between light and dark theme.
/// Uses [onThemeToggle] callback to trigger theme change (from DI etc).
/// On toggle: current icon slides down out of view, next icon slides up into view.
class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = isDark
        ? Assets.icons.sun.designImage(
            height: 24,
            width: 24,
            color: Theme.of(context).colorScheme.onSurface,
          )
        : Assets.icons.moon.designImage(
            height: 24,
            width: 24,
            color: Theme.of(context).colorScheme.onSurface,
          );
    return CustomIconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<bool>(isDark),
          child: icon,
        ),
      ),
      onTap: onThemeToggle,
    );
  }
}
