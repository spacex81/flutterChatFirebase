import 'package:client/main.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CenterContentWidget extends StatelessWidget {
  final Widget child;
  final BoxDecoration? decoration;

  const CenterContentWidget({required this.child, this.decoration, super.key});

  @override
  Widget build(BuildContext context) {
    double horizontalMarginSide() {
      return math.max(
          0, (MediaQuery.of(context).size.width - kPageContentWidth) / 2);
    }

    return Container(
      clipBehavior: Clip.none,
      decoration: decoration,
      child: Align(
        alignment: Alignment.topCenter,
        child: Builder(
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(
                left: horizontalMarginSide(),
                right: horizontalMarginSide(),
              ),
              child: SafeArea(
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
