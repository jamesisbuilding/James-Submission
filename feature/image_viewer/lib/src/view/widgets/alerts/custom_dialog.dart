import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

void showCustomDialog({
  required BuildContext context,
  required String message,
  required Function onDismiss,
  required Widget icon,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showGeneralDialog(
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        // Not used, see 'transitionBuilder'
        return const SizedBox.shrink();
      },
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final bounceAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: bounceAnimation,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(20),

            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                alignment: Alignment.center,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [icon],
                ),
                content: Text(message, textAlign: TextAlign.center),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  MainButton(
                    onTap: () {
                      Navigator.of(context).pop();
                      onDismiss();
                    },
                    label: 'Okay',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  });
}
