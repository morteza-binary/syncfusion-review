import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';

typedef ChartPaddingCallback = void Function();

class CustomZoomPanBehavior extends ZoomPanBehavior {
  ChartPaddingCallback onPanning;

  CustomZoomPanBehavior(
      {bool enablePinching: false,
      bool enableDoubleTapZooming: false,
      bool enablePanning: false,
      bool enableSelectionZooming: false,
      ZoomMode zoomMode: ZoomMode.xy,
      double maximumZoomLevel,
      double selectionRectBorderWidth: 1,
      Color selectionRectBorderColor,
      Color selectionRectColor,
      ChartPaddingCallback onPanning})
      : super(
          enablePinching: enablePinching,
          enableDoubleTapZooming: enableDoubleTapZooming,
          enablePanning: enablePanning,
          enableSelectionZooming: enableSelectionZooming,
          zoomMode: zoomMode,
          maximumZoomLevel: maximumZoomLevel,
          selectionRectBorderWidth: selectionRectBorderWidth,
          selectionRectBorderColor: selectionRectBorderColor,
          selectionRectColor: selectionRectColor,
        ) {
    this.onPanning = onPanning;
  }

  @override
  void onPan(double xPos, double yPos) {
    super.onPan(xPos, yPos);

    if (onPanning != null) {
      onPanning();
    }
  }
}
