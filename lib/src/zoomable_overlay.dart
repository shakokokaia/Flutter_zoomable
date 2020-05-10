part of zoomable;

class ZoomableOverlay extends StatefulWidget {
  final Offset origin;
  final double width;
  final double height;
  final Widget child;
  final ValueNotifier<ZoomableValue> zoomValue;

  ZoomableOverlay({
    this.origin,
    this.width,
    this.height,
    this.child,
    this.zoomValue,
  });

  @override
  ZoomableState createState() => ZoomableState();
}

class ZoomableState extends State<ZoomableOverlay>
    with TickerProviderStateMixin {
  AnimationController _reverseAnimationController;
  Offset _position;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    this._position = widget.origin;

    widget.zoomValue.addListener(() {
      if (widget.zoomValue.value == null) {
        reverse();
        return;
      }

      if (widget.zoomValue.value.scale != _scale)
        updateScale(widget.zoomValue.value.scale);
      if (widget.zoomValue.value.position != _position)
        updatePosition(widget.zoomValue.value.position);
    });
  }

  @override
  void dispose() {
    _reverseAnimationController.dispose();
    widget.zoomValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: ((_scale - 1.0) /
                  ((MediaQuery.of(context).size.height / widget.height) - 1.0))
              .clamp(0.0, 1.0),
          child: Container(color: Colors.transparent),
        ),
        Positioned(
          top: _position.dy,
          left: _position.dx,
          width: widget.width,
          height: widget.height,
          child: Transform.scale(
            scale: _scale,
            child: widget.child,
          ),
        ),
      ],
    );
  }

  void updatePosition(Offset newPosition) {
    setState(() => _position = newPosition);
  }

  void updateScale(double newScale) {
    setState(() => _scale = newScale);
  }

  TickerFuture reverse() {
    Offset origin = widget.origin;
    Offset reverseStartPosition = _position;
    double reverseStartScale = _scale;

    _reverseAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {
          _position = Offset.lerp(
            reverseStartPosition,
            origin,
            Curves.easeInOut.transform(_reverseAnimationController.value),
          );

          _scale = lerpDouble(
            reverseStartScale,
            1.0,
            Curves.easeInOut.transform(_reverseAnimationController.value),
          );
        });
      });

    return _reverseAnimationController.forward(from: 0.0);
  }
}
