part of zoomable;

class Zoomable extends StatelessWidget {
  final Widget child;
  final ValueChanged<double> onZoomStart;
  final ValueChanged<double> onZoomEnd;
  final bool poppedOut;
  final double initialScale;
  final ValueChanged<double> onZoomUpdate;
  final bool doubleTapZoom;
  final double maxScale;
  final double doubleTapScale;
  final Duration animationDuration;
  final Color backgroundColor;

  const Zoomable({
    this.child,
    this.onZoomStart,
    this.onZoomEnd,
    this.onZoomUpdate,
    this.poppedOut = true,
    this.initialScale = 1,
    this.doubleTapZoom = true,
    this.doubleTapScale = 2,
    this.maxScale = 5,
    this.backgroundColor = Colors.black12,
    this.animationDuration = const Duration(milliseconds: 200),
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return poppedOut
        ? PoppedOutZoomable(
      child: child,
      onZoomEnd: onZoomEnd,
      onZoomStart: onZoomStart,
      onZoomUpdate: onZoomUpdate,
      backgroundColor: backgroundColor,
      animationDuration: animationDuration,
    )
        : StandardZoomable(
      child: child,
      onZoomEnd: onZoomEnd,
      onZoomStart: onZoomStart,
      onZoomUpdate: onZoomUpdate,
      maxScale: maxScale,
      doubleTapScale: doubleTapScale,
      animationDuration: animationDuration,
    );
  }
}
