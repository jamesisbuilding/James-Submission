
import 'package:flutter/material.dart';

class MeasureSize extends StatefulWidget {
  const MeasureSize({super.key, required this.onChange, required this.child});

  final void Function(Size?) onChange;
  final Widget child;

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    final size = box?.size;
    if (size != null && size != _lastSize) {
      _lastSize = size;
      widget.onChange(size);
    }
  }

  @override
  void didUpdateWidget(MeasureSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
