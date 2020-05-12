part of zoomable;

class ZoomableValue {
  final Offset position;
  final double scale;

  const ZoomableValue({this.position, this.scale = 1});

  ZoomableValue copyWith({Offset position, double scale}) => ZoomableValue(
        position: position ?? this.position,
        scale: scale ?? this.scale,
      );
}

class PoppedOutZoomable extends StatefulWidget {
  final Widget child;
  final ValueChanged<double> onZoomStart;
  final ValueChanged<double> onZoomEnd;
  final ValueChanged<double> onZoomUpdate;
  final Color backgroundColor;
  final Duration animationDuration;

  const PoppedOutZoomable({
    this.child,
    this.onZoomStart,
    this.onZoomEnd,
    this.onZoomUpdate,
    this.backgroundColor,
    this.animationDuration,
  });

  @override
  _PoppedOutZoomableState createState() => _PoppedOutZoomableState();
}

class _PoppedOutZoomableState extends State<PoppedOutZoomable> {
  OverlayEntry _overlayEntry;
  Offset _scaleStartPosition;
  int _numPointers = 0;
  Offset _position;
  bool _zooming = false;
  bool _reversing = false;
  ValueNotifier<ZoomableValue> _zoomValue;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => ++_numPointers,
      onPointerUp: (_) => --_numPointers,
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: Container(
          foregroundDecoration:
              _zooming ? BoxDecoration(color: widget.backgroundColor) : null,
          child: Opacity(
            opacity: widget.backgroundColor != null ? _zooming ? 0 : 1 : 1,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_overlayEntry != null || _reversing || _numPointers < 2) return;

    if (widget.onZoomStart != null) widget.onZoomStart(1);
    setState(() => _zooming = true);

    OverlayState overlayState = Overlay.of(context);
    double width = context.size.width;
    double height = context.size.height;
    _position = (context.findRenderObject() as RenderBox)
        .localToGlobal(Offset(0.0, 0.0));
    _scaleStartPosition = details.focalPoint;

    _zoomValue =
        ValueNotifier<ZoomableValue>(ZoomableValue(position: _position));

    _overlayEntry = OverlayEntry(
      maintainState: true,
      builder: (BuildContext context) {
        return ZoomableOverlay(
          origin: _position,
          zoomValue: _zoomValue,
          height: height,
          width: width,
          child: widget.child,
          animationDuration: widget.animationDuration,
        );
      },
    );
    overlayState.insert(_overlayEntry);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_reversing || (!_zooming && _numPointers < 2)) return;

    if (widget.onZoomUpdate != null) widget.onZoomUpdate(details.scale);

    _zoomValue.value = _zoomValue.value.copyWith(
      position: _position - (_scaleStartPosition - details.focalPoint),
      scale: details.scale >= 1.0 ? details.scale : null,
    );
  }

  void _onScaleEnd(ScaleEndDetails details) async {
    if (_reversing || !_zooming) return;
    _reversing = true;
    if (widget.onZoomEnd != null) widget.onZoomEnd(1);
    _zoomValue.value = _zoomValue.value = null;
    Future<void>.delayed(Duration(milliseconds: 200)).then((_) {
      _zoomValue = null;
      _overlayEntry?.remove();
      _overlayEntry = null;
      _position = null;
      _scaleStartPosition = null;
      _reversing = false;
      setState(() => _zooming = false);
    });
  }
}

class ZoomableOverlay extends StatefulWidget {
  final Offset origin;
  final double width;
  final double height;
  final Widget child;
  final ValueNotifier<ZoomableValue> zoomValue;
  final Duration animationDuration;

  ZoomableOverlay({
    this.origin,
    this.width,
    this.height,
    this.child,
    this.zoomValue,
    this.animationDuration,
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
    widget.zoomValue.addListener(_stateListener);
  }

  void _stateListener() {
    if (widget.zoomValue.value == null) {
      _reverseAnimation();
      return;
    }

    if (widget.zoomValue.value.scale != _scale)
      setState(() => _scale = widget.zoomValue.value.scale);

    if (widget.zoomValue.value.position != _position)
      setState(() => _position = widget.zoomValue.value.position);
  }

  @override
  void dispose() {
    _reverseAnimationController?.dispose();
    widget.zoomValue?.dispose();
    super.dispose();
  }

  void _reverseAnimation() {
    _reverseAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..addListener(() {
        setState(() {
          _position = Offset.lerp(_position, widget.origin,
              Curves.easeInOut.transform(_reverseAnimationController.value));
          _scale = lerpDouble(_scale, 1,
              Curves.easeInOut.transform(_reverseAnimationController.value));
        });
      });
    _reverseAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(_position.dx, _position.dy)
            ..scale(_scale, _scale),
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
