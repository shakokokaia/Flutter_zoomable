part of zoomable;

class Zoomable extends StatefulWidget {
  final Widget child;
  final ValueChanged<double> onZoomStart;
  final ValueChanged<double> onZoomEnd;
  final bool poppedOut;
  final double initialScale;
  final ValueChanged<double> onZoomUpdate;
  final bool doubleTapZoom;

  Zoomable({
    this.child,
    this.onZoomStart,
    this.onZoomEnd,
    this.onZoomUpdate,
    this.poppedOut = true,
    this.initialScale = 1,
    this.doubleTapZoom = true,
  });

  @override
  _ZoomableState createState() => _ZoomableState();
}

class _ZoomableState extends State<Zoomable> {
  @override
  Widget build(BuildContext context) {
    return widget.poppedOut
        ? PoppedOutZoomable(
            child: widget.child,
            onZoomEnd: widget.onZoomEnd,
            onZoomStart: widget.onZoomStart,
            onZoomUpdate: widget.onZoomUpdate,
          )
        : Center(child: Text('Popped in zoomable is in development'));
  }
}
