import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/providers/navigation_provider.dart';

class LeftNavigationBar extends ConsumerWidget {
  const LeftNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: 0,
      top: 10,
      bottom: 10,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        child: SizedBox(
          width: 70,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            runSpacing: 20,
            children: [
              LeftMenuIcon(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                selectedColor: Theme.of(context).colorScheme.primary,
                index: 0,
              ),
              LeftMenuIcon(
                icon: Icon(Icons.list_outlined),
                activeIcon: Icon(Icons.list),
                selectedColor: Colors.orange,
                index: 1,
              ),
              LeftMenuIcon(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                selectedColor: Colors.pink,
                index: 2,
              ),
              LeftMenuIcon(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                selectedColor: Colors.teal,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftMenuIcon extends ConsumerStatefulWidget {
  const LeftMenuIcon({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.index,
    this.selectedColor,
  });

  final Icon icon;
  final Icon activeIcon;
  final int index;
  final Color? selectedColor;

  @override
  LeftMenuIconState createState() => LeftMenuIconState();
}

class LeftMenuIconState extends ConsumerState<LeftMenuIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = widget.selectedColor ?? Theme.of(context).colorScheme.primary;
    var currentIndex = ref.watch(navigationIndexProvider);

    return GestureDetector(
      onTap: () => _controller.repeat(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedScale(
        scale: currentIndex == widget.index ? _controller.value : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 50,
          height: 50,
          decoration: currentIndex == widget.index
              ? BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: IconButton(
            iconSize: currentIndex == widget.index ? 28 : 24,
            icon: currentIndex == widget.index ? widget.activeIcon : widget.icon,
            color: currentIndex == widget.index ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurfaceVariant,
            onPressed: () => ref.read(navigationIndexProvider.notifier).state = widget.index,
          ),
        ),
      ),
    );
  }
}
