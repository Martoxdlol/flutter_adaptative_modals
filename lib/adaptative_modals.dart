library adaptative_modals;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A Calculator.
class AdaptativeModalPageRoute<T> extends PageRoute<T> {
  AdaptativeModalPageRoute({
    this.onWillDismiss,
    required this.builder,
    this.width = 640,
    this.height = 460,
    this.maxWidthRation,
    this.maxHeightRatio,
    this.margin,
    this.borderRadius = 16,
    this.fullScreen = false,
    this.pageTransition,
  });

  static AdaptativeModalPageRoute? of(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route is AdaptativeModalPageRoute) {
      return route;
    }
    return null;
  }

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

  /// Use the entire screen when viewing on a samller view
  final bool fullScreen;

  /// Use this transition on a smaller view
  final Widget Function(Widget child, Animation<double> animation, Animation<double> secondaryAnimation)? pageTransition;

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
      fullScreen: fullScreen,
      pageTransition: pageTransition?.call(child, animation, secondaryAnimation),
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

  static final _stacks = <NavigatorState, List<AdaptativeModalPageRoute>>{};

  @override
  TickerFuture didPush() {
    if (navigator == null) return super.didPush();
    if (_stacks[navigator] == null) _stacks[navigator!] = [];
    final index = _stacks[navigator]?.indexOf(this) ?? -1;
    if (index == -1) _stacks[navigator]!.add(this);
    return super.didPush();
  }

  @override
  bool didPop(T? result) {
    if (navigator == null) return super.didPop(result);
    if (_stacks[navigator] == null) _stacks[navigator!] = [];
    final index = _stacks[navigator]?.indexOf(this) ?? -1;
    if (index != -1) _stacks[navigator]!.remove(this);
    return super.didPop(result);
  }
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
    required this.fullScreen,
    required this.pageTransition,
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
  final bool fullScreen;
  final Widget? pageTransition;

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
      final double marginTop = fullScreen ? 0 : statusBarHeight + 20;

      final routes = AdaptativeModalPageRoute._stacks[ModalRoute.of(context)!.navigator];
      final int index = routes?.indexOf(ModalRoute.of(context)! as AdaptativeModalPageRoute) ?? 0;
      // final totalRoutes = routes?.length ?? 0;

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

      if (smallerView && pageTransition != null) return pageTransition!;

      final double scaleY = (smallerView ? 1 : (half));
      final double scaleX = scaleY - (40 / width * secondaryAnimationValue);
      final double leftCompensation = (1 - scaleX) * width / 2;
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
            child: Transform(
              transform:
                  Matrix4.translationValues(leftCompensation, (1 - animationValue) * totalHeight / 1.5 - secondaryAnimationValue * 20, 0) +
                      Transform.scale(
                        scaleX: scaleX,
                        scaleY: scaleY,
                      ).transform,
              child: ModalContentContainer(
                borderRadius: (fullScreen && smallerView) ? 0 : borderRadius,
                bottomRoundedCorners: bottomRoundedCorners,
                shadowLevel: index < 2 ? animationValue : 0,
                child: Opacity(opacity: animationValue, child: child),
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

class AdaptativeModal extends StatefulWidget {
  const AdaptativeModal({
    super.key,
    required this.title,
    required this.child,
  });

  final Widget title;
  final Widget child;

  @override
  State<AdaptativeModal> createState() => _AdaptativeModalState(child: child, title: title);
}

class _AdaptativeModalState extends State<AdaptativeModal> with SingleTickerProviderStateMixin {
  _AdaptativeModalState({required this.child, required this.title});
  final Widget title;
  final Widget child;

  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final scaffold = Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                controller.animateTo(constrains.maxHeight == 0 ? 0 : animation.value + details.delta.dy / constrains.maxHeight,
                    duration: Duration(seconds: 0));
              },
              onVerticalDragEnd: (details) {
                final left = constrains.maxHeight * (1 - animation.value);

                double time = left / details.velocity.pixelsPerSecond.dy;

                double value = time < 0 ? 0 : 1;

                if (time < 0) time = -time;
                if (time > 1.2) {
                  time = 0.2;
                  if (animation.value > 0.5) {
                    value = 1;
                  } else {
                    value = 0;
                  }
                } else if (time > 0.4) time = 0.4;

                final duration = Duration(milliseconds: (time * 1000).toInt());
                details.velocity.pixelsPerSecond;
                controller.animateTo(value, duration: duration);
                Timer(Duration(milliseconds: duration.inMilliseconds ~/ 1.5), () {
                  Navigator.of(context).pop();
                });
              },
              onTap: () {
                // controller.animateTo(0.4, duration: Duration(seconds: 1));
              },
              child: Container(
                height: 40,
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
                          child: const Icon(Icons.close, size: 20),
                        ))
                  ],
                ),
              ),
            )),
        body: child,
      );

      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform(
          transform: Matrix4.translationValues(0, animation.value * constrains.maxHeight, 0),
          child: child,
        ),
        child: scaffold,
      );
    });
  }
}

// class AdaptativeModal extends StatelessWidget {
//   const AdaptativeModal({super.key, this.title, this.child});
//   final Widget? title;
//   final Widget? child;
//   final AnimationController controller = AnimationController(vsync: this);
//   final Animation animation = CurvedAnimation(parent: controller, curve: Curves.linear);
//   final tween = Tween<double>(begin: -200, end: 0);

//   @override
//   Widget build(BuildContext context) {
//     final scaffold = Scaffold(
//       appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(40),
//           child: GestureDetector(
//             child: Container(
//               height: 40,
//               decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.1)))),
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Center(
//                       child: title,
//                     ),
//                   ),
//                   Positioned(
//                       right: 2,
//                       top: 2,
//                       child: CircularButton(
//                         onTap: () {
//                           Navigator.of(context).pop();
//                         },
//                         child: const Icon(Icons.close, size: 20),
//                       ))
//                 ],
//               ),
//             ),
//           )),
//       body: child,
//     );

//     return AnimatedBuilder(
//       animation: animation,
//       builder: (context, child) => child!,
//       child: scaffold,
//     );
//   }
// }

class CircularButton extends StatelessWidget {
  CircularButton({super.key, this.child, this.onTap});
  final Widget? child;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          child: Center(child: child),
        ),
      ),
    );
  }
}
