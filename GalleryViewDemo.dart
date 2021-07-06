import 'package:flutter/material.dart';

class GalleryViewDemo extends StatefulWidget {
  @override
  _GalleryViewDemoState createState() => _GalleryViewDemoState();
}

class _GalleryViewDemoState extends State<GalleryViewDemo> {
  ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FCC 010"),
      ),
      body: Scrollbar(
        controller: _controller,
        child: GalleryView.builder(
          controller: _controller,
          itemCount: 101,
          minPerRow: 5,
          maxPerRow: 20,
          itemBuilder: (_, index) {
            return Container(
              color: Colors.primaries[index % 18],
            );
          },
        ),
      ),
    );
  }
}

class GalleryView extends StatefulWidget {
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final int itemCount;
  final int minPerRow;
  final int maxPerRow;

  GalleryView.builder({
    required this.itemBuilder,
    this.controller,
    required this.itemCount,
    this.minPerRow = 1,
    this.maxPerRow = 7,
  });

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  double _scale = 1;
  double _lateScale = 1;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var maxWidth = screenWidth / this.widget.maxPerRow;
    var nowWidth = maxWidth * _scale;
    var minWidth = screenWidth / this.widget.minPerRow;
    if (nowWidth > minWidth) nowWidth = minWidth;
    print('$nowWidth');
    return GestureDetector(
      onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
        setState(() {
          if (scaleUpdateDetails.scale == 1) {
            _lateScale = 1;
          }
          _scale = _scale * (1 + scaleUpdateDetails.scale - _lateScale);
          _lateScale = scaleUpdateDetails.scale;
        });
        if (_scale <= 1) _scale = 1;
        // print('$_scale');
      },
      child: Container(
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: nowWidth),
            itemCount: this.widget.itemCount,
            itemBuilder: this.widget.itemBuilder),
      ),
    );
  }
}
