import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedButtonDemo extends StatefulWidget {
  @override
  _AnimatedButtonDemoState createState() => _AnimatedButtonDemoState();
}

class _AnimatedButtonDemoState extends State<AnimatedButtonDemo> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CountdownButton(
                duration: Duration(seconds: 5),
                width: 200,
                height: 100,
                radius: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CountdownButton extends StatefulWidget {
  final Duration duration;
  final double height;
  final double width;
  final double radius;
  CountdownButton({
    required this.duration,
    required this.height,
    required this.width,
    required this.radius,
  });

  @override
  _CountdownButtonState createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _text = 'Send';
  ButtonState buttonState = ButtonState.send;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addListener(() {
      setState(() {});
      if (_controller.isCompleted) {
        buttonState = ButtonState.done;
        _text = "Done";
        timer.cancel();
        setState(() {});
      }
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: AnimatedBorder(widget.radius, _controller),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (buttonState == ButtonState.send) {
              _controller.forward();
              buttonState = ButtonState.cancel;
              setState(() {
                _text = "Cancel";
              });
            } else if (buttonState == ButtonState.cancel) {
              _controller.reset();
              timer.cancel();
              buttonState = ButtonState.send;
              setState(() {
                _text = "Send";
              });
            }
          },
          child: buildContainer(),
        ),
      ],
    );
  }

  Container buildContainer() {
    if (buttonState == ButtonState.send) {
      return Container(
        height: widget.height,
        child: Center(
            child: Text(
          _text,
          style: TextStyle(color: Colors.white, fontSize: 24),
        )),
        width: widget.width,
        decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(widget.radius)),
      );
    } else if (buttonState == ButtonState.cancel) {
      return Container(
        height: widget.height,
        child: Center(
            child: Text(
          _text,
          style: TextStyle(color: Colors.blue, fontSize: 24),
        )),
        width: widget.width,
      );
    }
    return Container(
      height: widget.height,
      child: Center(
          child: Text(
        _text,
        style: TextStyle(color: Colors.black38, fontSize: 24),
      )),
      width: widget.width,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black38, width: 4),
          borderRadius: BorderRadius.circular(widget.radius)),
    );
  }
}

class AnimatedBorder extends CustomPainter {
  double radius;
  AnimationController controller;

  AnimatedBorder(this.radius, this.controller);

  Paint blackPainter = Paint()
    ..color = Colors.black38
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  Paint bluePainter = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  Path blackPath = Path();
  Path bluePath = Path();
  Path path = Path();
  @override
  void paint(Canvas canvas, Size size) {
    var rRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width,
            height: size.height),
        Radius.circular(radius));
    path.addRRect(rRect);
    PathMetric pathMetric = path.computeMetrics(forceClosed: false).first;
    double pathLength = pathMetric.length;
    if (controller.value < 0.75) {
      blackPath = pathMetric.extractPath(
          pathLength / 4, pathLength * controller.value + pathLength / 4,
          startWithMoveTo: true);
      bluePath.addPath(
          pathMetric.extractPath(
              pathLength * controller.value + pathLength / 4, pathLength,
              startWithMoveTo: true),
          Offset.zero);
      bluePath.addPath(
          pathMetric.extractPath(0, pathLength * 0.25, startWithMoveTo: true),
          Offset.zero);
    } else {
      blackPath.addPath(
          pathMetric.extractPath(0, pathLength * (controller.value - 0.75),
              startWithMoveTo: true),
          Offset.zero);
      blackPath.addPath(
          pathMetric.extractPath(pathLength*0.25, pathLength ,
              startWithMoveTo: true),
          Offset.zero);
      bluePath.addPath(pathMetric.extractPath(pathLength * (controller.value - 0.75), pathLength * 0.25,
          startWithMoveTo: true), Offset.zero);
    }
    canvas.drawPath(bluePath, bluePainter);
    canvas.drawPath(blackPath, blackPainter);
    // canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

enum ButtonState { send, cancel, done }
