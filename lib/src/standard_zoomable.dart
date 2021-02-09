part of zoomable;

class StandardZoomable extends StatefulWidget {
  final Widget child;
  final ValueChanged<double> onZoomStart;
  final ValueChanged<double> onZoomEnd;
  final ValueChanged<double> onZoomUpdate;
  final double maxScale;
  final double doubleTapScale;
  final Duration animationDuration;

  const StandardZoomable({
    this.child,
    this.onZoomStart,
    this.onZoomEnd,
    this.onZoomUpdate,
    this.maxScale,
    this.doubleTapScale,
    this.animationDuration,
  });

  @override
  State<StatefulWidget> createState() {
    return _StandardZoomableState();
  }
}

class _StandardZoomableState extends State<StandardZoomable>
    with TickerProviderStateMixin {
  AnimationController _scaleAnimController;
  AnimationController _offsetAnimController;
  ScaleUpdateDetails _latestScaleUpdateDetails;
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _doubleTapPosition;
  bool _isScaling = false;
  bool _isDragging = false;
  double _maxDragOver = 100;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..translate(_offset.dx, _offset.dy)
        ..scale(_scale, _scale),
      child: Listener(
        onPointerUp: _onPointerUp,
        child: GestureDetector(
          onDoubleTap: _onDoubleTap,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleAnimController?.dispose();
    _offsetAnimController?.dispose();
    super.dispose();
  }

  void _onPointerUp(PointerUpEvent event) {
    _doubleTapPosition = event.localPosition;
  }

  void _onDoubleTap() {
    final targetScale = _scale == 1.0 ? widget.doubleTapScale : 1.0;
    _animationScale(targetScale);
    if (targetScale == 1.0) {
      _animationOffset(Offset.zero);
    }
  widget.onZoomUpdate(targetScale);
  }

  void _onScaleStart(ScaleStartDetails details) {
    widget.onZoomStart?.call(_scale);
    _scaleAnimController?.stop();
    _offsetAnimController?.stop();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (details.scale != 1.0) {
        _scaling(details);
      } else {
        _dragging(details);
      }
    });
    widget.onZoomUpdate?.call(_scale);
  }

  void _scaling(ScaleUpdateDetails details) {
    if (_isDragging) return;

    _isScaling = true;
    if (_latestScaleUpdateDetails == null) {
      _latestScaleUpdateDetails = details;
      return;
    }

    double scaleIncrement = details.scale - _latestScaleUpdateDetails.scale;
    if (details.scale < 1.0 && _scale > 1.0) {
      scaleIncrement *= _scale;
    }
    if (_scale < 1.0 && scaleIncrement < 0) {
      scaleIncrement *= (_scale - 0.5);
    } else if (_scale > widget.maxScale && scaleIncrement > 0) {
      scaleIncrement *= (2.0 - (_scale - widget.maxScale));
    }
    _scale += scaleIncrement;

    double scaleOffsetX = context.size.width * (_scale - 1.0) / 2;
    double scaleOffsetY = context.size.height * (_scale - 1.0) / 2;
    double scalePointDX =
        (details.localFocalPoint.dx + scaleOffsetX - _offset.dx) / _scale;
    double scalePointDY =
        (details.localFocalPoint.dy + scaleOffsetY - _offset.dy) / _scale;
    _offset += Offset(
      (context.size.width / 2 - scalePointDX) * scaleIncrement,
      (context.size.height / 2 - scalePointDY) * scaleIncrement,
    );

    _latestScaleUpdateDetails = details;
  }

  void _dragging(ScaleUpdateDetails details) {
    if (_isScaling) return;

    _isDragging = true;
    if (_latestScaleUpdateDetails == null) {
      _latestScaleUpdateDetails = details;
      return;
    }

    double offsetXIncrement = (details.localFocalPoint.dx -
        _latestScaleUpdateDetails.localFocalPoint.dx) *
        _scale;
    double offsetYIncrement = (details.localFocalPoint.dy -
        _latestScaleUpdateDetails.localFocalPoint.dy) *
        _scale;
    double scaleOffsetX = context.size.width * (_scale - 1.0) / 2;
    if (scaleOffsetX <= 0) {
      offsetXIncrement = 0;
    } else if (_offset.dx > scaleOffsetX) {
      offsetXIncrement *=
          (_maxDragOver - (_offset.dx - scaleOffsetX)) / _maxDragOver;
    } else if (_offset.dx < -scaleOffsetX) {
      offsetXIncrement *=
          (_maxDragOver - (-scaleOffsetX - _offset.dx)) / _maxDragOver;
    }
    double scaleOffsetY =
        (context.size.height * _scale - MediaQuery
            .of(context)
            .size
            .height) / 2;
    if (scaleOffsetY <= 0) {
      offsetYIncrement = 0;
    } else if (_offset.dy > scaleOffsetY) {
      offsetYIncrement *=
          (_maxDragOver - (_offset.dy - scaleOffsetY)) / _maxDragOver;
    } else if (_offset.dy < -scaleOffsetY) {
      offsetYIncrement *=
          (_maxDragOver - (-scaleOffsetY - _offset.dy)) / _maxDragOver;
    }

    _offset += Offset(offsetXIncrement, offsetYIncrement);

    _latestScaleUpdateDetails = details;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_scale < 1.0) {
      _animationScale(1.0);
    } else if (_scale > widget.maxScale) {
      _animationScale(widget.maxScale);
    }
    if (_scale <= 1.0) {
      _animationOffset(Offset.zero);
    } else if (_isDragging) {
      double realScale = _scale > widget.maxScale ? widget.maxScale : _scale;
      double targetOffsetX = _offset.dx,
          targetOffsetY = _offset.dy;
      double scaleOffsetX = context.size.width * (realScale - 1.0) / 2;
      if (scaleOffsetX <= 0) {
        targetOffsetX = 0;
      } else if (_offset.dx > scaleOffsetX) {
        targetOffsetX = scaleOffsetX;
      } else if (_offset.dx < -scaleOffsetX) {
        targetOffsetX = -scaleOffsetX;
      }
      double scaleOffsetY = (context.size.height * realScale -
          MediaQuery
              .of(context)
              .size
              .height) /
          2;
      if (scaleOffsetY < 0) {
        targetOffsetY = 0;
      } else if (_offset.dy > scaleOffsetY) {
        targetOffsetY = scaleOffsetY;
      } else if (_offset.dy < -scaleOffsetY) {
        targetOffsetY = -scaleOffsetY;
      }
      if (_offset.dx != targetOffsetX || _offset.dy != targetOffsetY) {
        _animationOffset(Offset(targetOffsetX, targetOffsetY));
      } else {
        double duration = (widget.animationDuration.inSeconds +
            widget.animationDuration.inMilliseconds / 1000);
        Offset targetOffset =
            _offset + details.velocity.pixelsPerSecond * duration;
        targetOffsetX = targetOffset.dx;
        if (targetOffsetX > scaleOffsetX) {
          targetOffsetX = scaleOffsetX;
        } else if (targetOffsetX < -scaleOffsetX) {
          targetOffsetX = -scaleOffsetX;
        }
        targetOffsetY = targetOffset.dy;
        if (targetOffsetY > scaleOffsetY) {
          targetOffsetY = scaleOffsetY;
        } else if (targetOffsetY < -scaleOffsetY) {
          targetOffsetY = -scaleOffsetY;
        }
        _animationOffset(Offset(targetOffsetX, targetOffsetY));
      }
    }

    _isScaling = false;
    _isDragging = false;
    _latestScaleUpdateDetails = null;
    widget.onZoomEnd?.call(_scale);
  }

  void _animationScale(double targetScale) {
    _scaleAnimController?.dispose();
    _scaleAnimController =
        AnimationController(vsync: this, duration: widget.animationDuration);
    Animation anim = Tween<double>(begin: _scale, end: targetScale)
        .animate(_scaleAnimController);
    anim.addListener(() {
      setState(() {
        _scaling(ScaleUpdateDetails(
          focalPoint: _doubleTapPosition,
          localFocalPoint: _doubleTapPosition,
          scale: anim.value,
          horizontalScale: anim.value,
          verticalScale: anim.value,
        ));
      });
    });
    anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onScaleEnd(ScaleEndDetails());
      }
    });
    _scaleAnimController.forward();
  }

  void _animationOffset(Offset targetOffset) {
    _offsetAnimController?.dispose();
    _offsetAnimController =
        AnimationController(vsync: this, duration: widget.animationDuration);
    Animation anim = _offsetAnimController
        .drive<Offset>(Tween<Offset>(begin: _offset, end: targetOffset));
    anim.addListener(() {
      setState(() => _offset = anim.value);
    });
    _offsetAnimController.fling();
  }
}
