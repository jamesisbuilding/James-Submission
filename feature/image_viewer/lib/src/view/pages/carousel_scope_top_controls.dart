part of 'image_viewer_main_view.dart';

class _CarouselTopControls extends StatelessWidget {
  const _CarouselTopControls({
    required this.onThemeToggle,
    required this.onOpenGallery,
  });

  final VoidCallback onThemeToggle;
  final VoidCallback onOpenGallery;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          right: 16,
          child: ThemeSwitch(onThemeToggle: onThemeToggle),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScrollDirectionToggle(),
              const SizedBox(width: 4),
              CustomIconButton(
                onTap: onOpenGallery,
                icon: Assets.icons.gallery.designImage(
                  height: 24,
                  width: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }
}
