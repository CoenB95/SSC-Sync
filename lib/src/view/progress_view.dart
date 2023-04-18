import 'package:flutter/material.dart';

class AnimatedCircularProgressIndicator extends StatefulWidget {
  final double? progress;

  AnimatedCircularProgressIndicator({this.progress});

  @override
  State<StatefulWidget> createState() =>
      AnimatedCircularProgressIndicatorState();
}

class AnimatedCircularProgressIndicatorState
    extends State<AnimatedCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController anim;
  late Animation<double> animCurve;
  late Tween<double> progressTween;

  @override
  void initState() {
    super.initState();

    anim = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    animCurve = CurvedAnimation(
      parent: anim,
      curve: Curves.easeOut,
    );
    anim.forward(from: 0);
    progressTween = Tween<double>(begin: 0, end: widget.progress ?? 0);
  }

  @override
  void didUpdateWidget(AnimatedCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('widget update');

    if (widget.progress != oldWidget.progress) {
      double beginValue = progressTween.evaluate(animCurve);

      progressTween = Tween<double>(
        begin: beginValue,
        end: widget.progress ?? 0,
      );

      anim.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return CircularProgressIndicator(
          value: widget.progress == null
              ? null
              : progressTween.evaluate(animCurve),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    anim.dispose();
  }
}
