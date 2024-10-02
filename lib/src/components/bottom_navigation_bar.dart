import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/providers/navigation_provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class RoadlessBottomNavigationBar extends ConsumerWidget {
  const RoadlessBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentIndex = ref.watch(navigationIndexProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SalomonBottomBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          currentIndex: currentIndex,
          onTap: (i) => ref.read(navigationIndexProvider.notifier).state = i,
          items: [
            SalomonBottomBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              title: Text("Inicio"),
              selectedColor: Theme.of(context).colorScheme.primary,
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.list_outlined),
              activeIcon: Icon(Icons.list),
              title: Text("Listas"),
              selectedColor: Colors.orange,
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              title: Text("Favoritos"),
              selectedColor: Colors.pink,
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              title: Text("Comunidad"),
              selectedColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
