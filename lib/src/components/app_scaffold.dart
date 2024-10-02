import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/components/app_bar.dart';
import 'package:roadless/src/components/bottom_navigation_bar.dart';
import 'package:roadless/src/components/left_navigation_bar.dart';
import 'package:roadless/src/providers/navigation_provider.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentPage = ref.watch(navigationPageProvider);

    bool isPortraitMode = MediaQuery.orientationOf(context) == Orientation.portrait;

    return Scaffold(
      appBar: RoadlessAppBar(title: "Roadless"),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: isPortraitMode ? 0 : 80),
            child: currentPage,
          ),
          if (!isPortraitMode) LeftNavigationBar(),
        ],
      ),
      bottomNavigationBar: isPortraitMode ? RoadlessBottomNavigationBar() : null,
    );
  }
}
