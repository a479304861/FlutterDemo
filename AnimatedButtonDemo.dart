import 'dart:math';
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
                width: 300,
                height: 100,
                radius: 20,
              ),
              SizedBox(
                height: 24,
              ),
              CountdownButton(
                duration: Duration(seconds: 60),
                width: 240,
                height: 240,
                radius: 240,
              ),
              SizedBox(
                height: 24,
              ),
              CountdownButton(
                duration: Duration(seconds: 5),
                width: 100,
                height: 100,
                radius: 0,
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addListener(() {
      if (_controller.isCompleted) {
        buttonState = ButtonState.done;
        _text = "Done";
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (buttonState == ButtonState.send) {
          _controller.forward();
          buttonState = ButtonState.cancel;
          setState(() {
            _text = "Cancel";
          });
        } else if (buttonState == ButtonState.cancel) {
          _controller.reset();
          buttonState = ButtonState.send;
          setState(() {
            _text = "Send";
          });
        }
      },
      child: CustomPaint(
        painter: AnimatedBorder(widget.radius, _controller),
        child: buildContainer(),
      ),
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
    );
  }
}

class AnimatedBorder extends CustomPainter {
  double radius;
  AnimationController controller;

  AnimatedBorder(this.radius, this.controller);

  Paint blackPainter = Paint()
    ..color = Colors.black38
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  Paint bluePainter = Paint()
    ..isAntiAlias = true
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  Path blackPath = Path();
  Path bluePath = Path();
  Path path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    initPath(size);
    PathMetric pathMetric = path.computeMetrics(forceClosed: false).first;
    double pathLength = pathMetric.length;
    blackPath = pathMetric.extractPath(0, pathLength * controller.value);
    bluePath =
        pathMetric.extractPath(pathLength * controller.value, pathLength);
    canvas.drawPath(bluePath, bluePainter);
    canvas.drawPath(blackPath, blackPainter);
  }

  void initPath(Size size) {
    if (radius > min(size.width / 2, size.height / 2)) {
      radius = min(size.width / 2, size.height / 2);
    }
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width - radius, 0);
    path.arcTo(
        Rect.fromCircle(
            center: Offset(size.width - radius, radius), radius: radius),
        3 * pi / 2,
        pi / 2,
        false);
    path.lineTo(size.width, size.height - radius);
    path.arcTo(
        Rect.fromCircle(
            center: Offset(size.width - radius, size.height - radius),
            radius: radius),
        0,
        pi / 2,
        false);
    path.lineTo(radius, size.height);
    path.arcTo(
        Rect.fromCircle(
            center: Offset(radius, size.height - radius), radius: radius),
        pi / 2,
        pi / 2,
        false);
    path.lineTo(0, radius);
    path.arcTo(Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        pi, pi / 2, false);
    path.lineTo(size.width / 2, 0);
    path.close();
    //使用以下方式会导致不从最上面中间开始
    // path.addRRect(RRect.fromRectAndRadius(
    //     Rect.fromCenter(
    //         center: Offset(size.width / 2, size.height / 2),
    //         width: size.width,
    //         height: size.height),
    //     Radius.circular(radius)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

enum ButtonState { send, cancel, done }
