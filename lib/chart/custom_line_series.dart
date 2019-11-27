import 'dart:math';
import 'dart:ui';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';

class CustomLineSeries<T, D> extends LineSeries<T, D> {
  CustomLineSeries({
    @required List<T> dataSource,
    @required ChartValueMapper<T, D> xValueMapper,
    @required ChartValueMapper<T, num> yValueMapper,
    String xAxisName,
    String yAxisName,
    Color color,
    double width,
    MarkerSettings markerSettings,
    EmptyPointSettings emptyPointSettings,
    DataLabelSettings dataLabelSettings,
    bool isVisible,
    bool enableTooltip,
    List<double> dashArray,
    double animationDuration,
  }) : super(
          dataSource: dataSource,
          xValueMapper: xValueMapper,
          yValueMapper: yValueMapper,
          xAxisName: xAxisName,
          yAxisName: yAxisName,
          color: color,
          width: width,
          markerSettings: markerSettings,
          emptyPointSettings: emptyPointSettings,
          dataLabelSettings: dataLabelSettings,
          isVisible: isVisible,
          enableTooltip: enableTooltip,
          dashArray: dashArray,
          animationDuration: animationDuration,
        );

  static Random randomNumer = Random();

  @override
  ChartSegment createSegment() {
    return CustomLineSegment(randomNumer.nextInt(4));
  }
}

class CustomLineSegment extends LineSegment {
  List<num> xValues;
  List<num> yValues;

  CustomLineSegment(int value) {
    //ignore: prefer_initializing_formals
    index = value;
    xValues = <num>[];
    yValues = <num>[];
  }

  double maximum, minimum;
  int index;
  List<Color> colors = <Color>[
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.cyan
  ];

  @override
  Paint getStrokePaint() {
    final Paint customerStrokePaint = Paint();
    customerStrokePaint.color = const Color.fromRGBO(53, 92, 125, 1);
    customerStrokePaint.strokeWidth = 2;
    customerStrokePaint.style = PaintingStyle.stroke;
    return customerStrokePaint;
  }

  @override
  void onPaint(Canvas canvas) {
    final double x1 = this.x1, y1 = this.y1, x2 = this.x2, y2 = this.y2;
    xValues.add(x1);
    xValues.add(x2);
    yValues.add(y1);
    yValues.add(y2);

    final Path path = Path();
    path.moveTo(x1, y1);
    path.lineTo(x2, y2);
    canvas.drawPath(path, getStrokePaint());

    if (currentSegmentIndex == series.segments.length - 1) {
      const double labelPadding = 10;
      final Paint topLinePaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final Paint bottomLinePaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      maximum = yValues.reduce(max);
      minimum = yValues.reduce(min);
      final Path bottomLinePath = Path();
      final Path topLinePath = Path();
      bottomLinePath.moveTo(0, maximum + 10);
      bottomLinePath.lineTo(xValues[xValues.length - 1], maximum + 5);

      topLinePath.moveTo(0, minimum - 5);
      topLinePath.lineTo(xValues[xValues.length - 1], minimum - 5);
      canvas.drawPath(
          _dashPath(
            bottomLinePath,
            dashArray: _CircularIntervalList<double>(<double>[15, 3, 3, 3]),
          ),
          bottomLinePaint);

      canvas.drawPath(
          _dashPath(
            topLinePath,
            dashArray: _CircularIntervalList<double>(<double>[15, 3, 3, 3]),
          ),
          topLinePaint);

      final TextSpan span = TextSpan(
        style: TextStyle(
            color: Colors.red[800], fontSize: 12.0, fontFamily: 'Roboto'),
        text: 'Low point',
      );
      final TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(tp.size.width, maximum + labelPadding));
      final TextSpan span1 = TextSpan(
        style: TextStyle(
            color: Colors.green[800], fontSize: 12.0, fontFamily: 'Roboto'),
        text: 'High point',
      );
      final TextPainter tp1 =
          TextPainter(text: span1, textDirection: TextDirection.ltr);
      tp1.layout();
      tp1.paint(canvas,
          Offset(tp1.size.width, minimum - labelPadding - tp1.size.height));
      yValues.clear();
    }
  }
}

Path _dashPath(
  Path source, {
  @required _CircularIntervalList<double> dashArray,
}) {
  if (source == null) {
    return null;
  }
  const double intialValue = 0.0;
  final Path path = Path();
  for (final PathMetric measurePath in source.computeMetrics()) {
    double distance = intialValue;
    bool draw = true;
    while (distance < measurePath.length) {
      final double length = dashArray.next;
      if (draw) {
        path.addPath(
            measurePath.extractPath(distance, distance + length), Offset.zero);
      }
      distance += length;
      draw = !draw;
    }
  }
  return path;
}

class _CircularIntervalList<T> {
  _CircularIntervalList(this._values);
  final List<T> _values;
  int _index = 0;
  T get next {
    if (_index >= _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}
