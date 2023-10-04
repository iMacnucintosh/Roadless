import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color.fromRGBO(255, 255, 255, 0.5),
      child: const Center(child: CircularProgressIndicator()));
  }
}
