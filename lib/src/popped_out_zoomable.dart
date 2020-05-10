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

  const PoppedOutZoomable({
    this.child,
    this.onZoomStart,
    this.onZoomEnd,
    this.onZoomUpdate,
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
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: widget.child,
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
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
        );
      },
    );
    overlayState.insert(_overlayEntry);
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_reversing || (!_zooming && -_numPointers < 2)) return;

    if (widget.onZoomUpdate != null) widget.onZoomUpdate(details.scale);

    _zoomValue.value = _zoomValue.value.copyWith(
      position: _position - (_scaleStartPosition - details.focalPoint),
      scale: details.scale >= 1.0 ? details.scale : null,
    );
  }

  void _handleScaleEnd(ScaleEndDetails details) async {
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
