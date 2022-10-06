library adaptative_modals;

import 'package:flutter/material.dart';

/// A Calculator.
class AdaptativeModalPageRoute<T> extends ModalRoute<T> {
  AdaptativeModalPageRoute(
      {this.onWillDismiss,
      required this.builder,
      this.width = 640,
      this.height = 460,
      this.maxWidthRation,
      this.maxHeightRatio,
      this.margin,
      this.borderRadius = 16});

  /// Executed when touched modal barrier. If retuns true it will pop() the modal
  final bool Function()? onWillDismiss;

  /// Content of the modal
  /// Example
  /// ```dart
  ///   Navigator.of(context).push(AdaptativeModal(
  ///     builder: ((context) => AdaptativeModalScaffold(
  ///         body: Container(
  ///       child: Text('Hello World'),
  ///     )))));
  /// ```
  final Widget Function(BuildContext context) builder;

  /// Stablish max width o larger views
  /// or if [maxWidthRation] setted, minimun width on larger views
  final double width;

  /// Stablish max height o larger views
  /// or if [maxHeightRatio] setted, minimun height on larger views
  final double height;

  /// Value [0.0 - 1.0]
  /// If set, when view size is bigger than [width] it will expand using ratio
  /// Ex: 70% -> 0.7
  final double? maxWidthRation;

  /// Value [0.0 - 1.0]
  /// If set, when view size is bigger than [height] it will expand using ratio
  /// Ex: 70% -> 0.7
  final double? maxHeightRatio;

  /// Modal margin. This will be **zero** on view sizes **smaller than width or height**
  final EdgeInsets? margin;

  /// Modal border radius
  final double borderRadius;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => onWillDismiss != null ? onWillDismiss!() : true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ModalAmbient(
      height: height,
      maxHeightRatio: maxHeightRatio,
      maxWidthRation: maxWidthRation,
      width: width,
      animationValue: animation.value,
      secondaryAnimationValue: secondaryAnimation.value,
      margin: margin,
      borderRadius: borderRadius,
      child: child,
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);
}

class ModalAmbient extends StatelessWidget {
  const ModalAmbient({
    super.key,
    required this.child,
    required this.animationValue,
    required this.secondaryAnimationValue,
    required this.width,
    required this.height,
    required this.maxWidthRation,
    required this.maxHeightRatio,
    required this.margin,
    required this.borderRadius,
  });

  final Widget child;
  final double animationValue;
  final double secondaryAnimationValue;

  final double width;
  final double height;
  final double? maxWidthRation;
  final double? maxHeightRatio;
  final EdgeInsets? margin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final margin = this.margin ?? EdgeInsets.all(12);

      final totalWidth = this.width + margin.horizontal;
      final totalHeight = this.height + margin.vertical;

      double width = maxWidthRation != null ? (totalWidth - this.width) * maxWidthRation! + this.width : this.width;
      double height = maxHeightRatio != null ? (totalHeight - this.height) * maxHeightRatio! + this.height : this.height;

      double left = (constrains.maxWidth - width) / 2;
      double top = (constrains.maxHeight - height) / 2;

      bool smallerView = false;
      bool bottomRoundedCorners = true;

      final statusBarHeight = MediaQuery.of(context).viewPadding.top;
      final marginTop = statusBarHeight + 20;

      if (constrains.maxWidth < totalWidth) {
        left = 0;
        top = marginTop;
        width = constrains.maxWidth;
        height = constrains.maxHeight - top;
        bottomRoundedCorners = false;
        smallerView = true;
      } else if (constrains.maxHeight < totalHeight) {
        top = marginTop;
        height = constrains.maxHeight - top;
        smallerView = true;
        bottomRoundedCorners = false;
      }

      double half = animationValue / 3.2 + (1 - 0.3125);
      if (animationValue == 1) half = 1;

      return Stack(
        children: [
          ModalBarrier(
            color: Color.fromRGBO(0, 0, 0, (animationValue - secondaryAnimationValue) * 0.3),
          ),
          Positioned(
            width: width,
            height: height,
            left: left,
            top: top,
            child: Transform.translate(
              offset: Offset(
                  0,
                  (smallerView ? (1 - half) * (constrains.maxWidth) : (1 - half) * constrains.maxHeight / 2) +
                      secondaryAnimationValue * -25),
              child: Transform.scale(
                scale: (smallerView ? 1 : (half)) - (20 / width * secondaryAnimationValue),
                child: ModalContentContainer(
                  borderRadius: borderRadius,
                  bottomRoundedCorners: bottomRoundedCorners,
                  shadowLevel: animationValue,
                  child: Opacity(opacity: animationValue, child: child),
                ),
              ),
            ),
          )
        ],
      );
    });
  }
}

class ModalContentContainer extends StatelessWidget {
  const ModalContentContainer(
      {super.key, required this.bottomRoundedCorners, required this.child, required this.borderRadius, required this.shadowLevel});
  final bool bottomRoundedCorners;
  final Widget child;
  final double borderRadius;
  final double shadowLevel;

  @override
  Widget build(BuildContext context) {
    final double radiusBottom = bottomRoundedCorners ? this.borderRadius : 0;
    final borderRadius = BorderRadius.vertical(bottom: Radius.circular(radiusBottom), top: Radius.circular(this.borderRadius));
    return Container(
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 8, spreadRadius: -3, color: Color.fromRGBO(0, 0, 0, shadowLevel * 0.3))],
          borderRadius: borderRadius),
      child: ClipRRect(child: child, borderRadius: borderRadius),
    );
  }
}

class AdaptativeModal extends StatelessWidget {
  const AdaptativeModal({super.key, this.title, this.child});
  final Widget? title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.1)))),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: title,
                  ),
                ),
                Positioned(
                    right: 2,
                    top: 2,
                    child: CircularButton(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.close, size: 20),
                    ))
              ],
            ),
          )),
      body: child,
    );
  }
}

class CircularButton extends StatelessWidget {
  CircularButton({super.key, this.child, this.onTap});
  final Widget? child;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8),
          child: child,
        ),
      ),
    );
  }
}
