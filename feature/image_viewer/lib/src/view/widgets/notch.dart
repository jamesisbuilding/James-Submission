import 'dart:ui';

import 'package:flutter/material.dart';

class DraggableNotch extends StatelessWidget {
  final Color? color;
  final bool showShadow;
  const DraggableNotch({super.key, this.color, this.showShadow = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 80,
          height: 6,
          constraints: BoxConstraints(maxWidth: 80),
          decoration: BoxDecoration(
            boxShadow: (color != null && !showShadow)
                ? null
                : [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(2, 2),
                    ),
                  ],
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), 
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
