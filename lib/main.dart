import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Syncfusion Demo',
        theme: ThemeData(
            primarySwatch: Colors.blue,
        ),
        home: LiveLineChart(title: 'Syncfusion Demo'),
    );
  }
}

class LiveLineChart extends StatefulWidget {
  LiveLineChart({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LiveLineChartState createState() => _LiveLineChartState();
}

class _LiveLineChartState extends State<LiveLineChart> {

  double _updatingInterval = 5;
  Timer _timer;
  List<Tick> _chartData = [];
  List<CartesianChartAnnotation> _annotations = [];

  @override
  void initState() {
    super.initState();
    _chartData.add(Tick(DateTime.now(), 78.5));
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.title),
        ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Ticks: ${_chartData.length}'),
                      Text('Updating Interval: ${_updatingInterval?.toInt()}'),
                    ],
                ),
                Slider(
                    divisions: 9,
                    label: 'Updating Interval: ${_updatingInterval?.toInt()}',
                    min: 1,
                    max: 10,
                    onChanged: _startTimer,
                    value: _updatingInterval,
                  ),
                  Expanded(
                      flex: 1,
                      child: Center(child: _getChart()),
                  ),
                ],
            ),
        ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _appendNewTick(Timer timer) {
    setState(() {
      _chartData.add(
          Tick(
              _chartData.last.date.add(Duration(seconds: 2)),
              generateQuote(_chartData.last.quote))
      );

      if (_chartData.last.date.second % 5 == 0) {
        _annotations.add(CartesianChartAnnotation(
                widget: Container(child: const Text('*')),
                coordinateUnit: CoordinateUnit.point,
                x: _chartData.last.date,
                y: _chartData.last.quote,
        ));
      }
    });
  }

  List<LineSeries<Tick, DateTime>> _getChartSeries() =>
      <LineSeries<Tick, DateTime>>[
        LineSeries<Tick, DateTime>(
            animationDuration: 100,
            dataSource: _chartData,
            markerSettings: MarkerSettings(
                isVisible: true,
            ),
            width: 2,
            xValueMapper: (Tick tick, _) => tick.date,
            yValueMapper: (Tick tick, _) => tick.quote,
        )];

  SfCartesianChart _getChart() => SfCartesianChart(
      annotations: _annotations,
      primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.Hms(),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          intervalType: DateTimeIntervalType.seconds,
          // interval: 30,
          // zoomFactor: 0.2,
          // zoomPosition: 0.9,
      ),
      primaryYAxis: NumericAxis(
          axisLine: AxisLine(width: 0),
          majorTickLines: MajorTickLines(size:0),
      ),
      series: _getChartSeries(),
      zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          zoomMode: ZoomMode.x,
      ),
      onZoomStart: (ZoomPanArgs args) => _timer.cancel(),
      onZoomEnd: (ZoomPanArgs args) => _startTimer(_updatingInterval),
      crosshairBehavior: CrosshairBehavior(
          activationMode: ActivationMode.singleTap,
          enable: true,
          lineType: CrosshairLineType.both,
          lineWidth: 2,
          shouldAlwaysShow: true,
      ),
      tooltipBehavior: TooltipBehavior(
          enable: true,
          canShowMarker: true,
          format: 'point.x / point.y'
      ),
      );

  void _startTimer([double duration]) {
      if (_timer != null && _timer.isActive) {
        _timer.cancel();
      }
      _timer = Timer.periodic(Duration(seconds: (duration ?? _updatingInterval).toInt()), _appendNewTick);

      setState(() => _updatingInterval = duration ?? 5);
  }
}

class Tick {
  final DateTime date;
  final double quote;

  Tick(this.date, this.quote);
}
