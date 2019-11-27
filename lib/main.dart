import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import './chart/custom_line_series.dart';
import './chart/custom_zoom_pan_behavior.dart';
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
  double _customBarrier;
  double _updatingInterval = 5;
  double _zoomPosition = 1;

  bool _hasOffset = false;

  List<CartesianChartAnnotation> _annotations = [];
  List<Tick> _chartData = [];
  List<PlotBand> _plotBands = [];
  Timer _timer;
  ZoomPanBehavior _zoomPanBehavior = CustomZoomPanBehavior(
    enablePinching: true,
    enablePanning: true,
    zoomMode: ZoomMode.x,
  );

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
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Text('Ticks: ${_chartData.length}'),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                          'Updating Interval: ${_updatingInterval?.toInt()}'),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Slider(
                  divisions: 9,
                  label: 'Updating Interval: ${_updatingInterval?.toInt()}',
                  min: 1,
                  max: 10,
                  onChanged: _startTimer,
                  value: _updatingInterval,
                ),
                ToggleButtons(
                  children: <Widget>[
                    Text('PlotOffet'),
                  ],
                  onPressed: (int index) =>
                      setState(() => _hasOffset = !_hasOffset),
                  isSelected: <bool>[_hasOffset],
                ),
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: <Widget>[
            //     Expanded(
            //       child: Center(
            //         child: Container(
            //           width: 60,
            //           child: TextField(
            //             keyboardType: TextInputType.number,
            //             onChanged: (value) => setState(
            //                 () => _customBarrier = double.parse(value ?? '0')),
            //             decoration: InputDecoration(
            //               contentPadding: const EdgeInsets.only(top: -10),
            //               labelText: 'Barrier',
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //     Expanded(
            //       child: Center(
            //         child: FlatButton(
            //           color: Colors.blue,
            //           textColor: Colors.white,
            //           child: Text('Add'),
            //           onPressed: _addBarrier,
            //         ),
            //       ),
            //     ),
            //     Expanded(
            //       child: Center(
            //         child: FlatButton(
            //           child: Text('Add Random'),
            //           color: Colors.blue,
            //           textColor: Colors.white,
            //           onPressed: () => _addBarrier(isRandom: true),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            Expanded(
              flex: 1,
              child: Center(child: _getChart()),
            ),
          ],
        ),
      ),
      // This is the home button, it should be visible when the chart is scrolled to right.
      floatingActionButton: Visibility(
        visible: _zoomPosition < 1,
        child: FloatingActionButton(
          onPressed: () => setState(() => _zoomPosition = 1),
          child: Icon(Icons.arrow_right),
          backgroundColor: Colors.grey,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _addBarrier({bool isRandom = false}) {
    Random random = Random();
    setState(() => _plotBands.add(
          PlotBand(
            isVisible: true,
            start: _chartData.last.date.subtract(Duration(seconds: 2)),
            end: _chartData.last.date,
            color: Colors.primaries[random.nextInt(Colors.primaries.length)],
            associatedAxisStart: !isRandom
                ? _customBarrier
                : _chartData[random.nextInt(_chartData.length)].quote,
            associatedAxisEnd: (!isRandom
                    ? _customBarrier
                    : _chartData[random.nextInt(_chartData.length)].quote) +
                1,
          ),
        ));
    print(_plotBands.length);
  }

  void _appendNewTick(Timer timer) {
    setState(() {
      _chartData.add(Tick(_chartData.last.date.add(Duration(seconds: 2)),
          generateQuote(_chartData.last.quote)));

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

  List<CustomLineSeries<Tick, DateTime>> _getChartSeries() =>
      <CustomLineSeries<Tick, DateTime>>[
        CustomLineSeries<Tick, DateTime>(
          animationDuration: 100,
          dataSource: _chartData,
          markerSettings: MarkerSettings(
            isVisible: true,
          ),
          width: 2,
          xValueMapper: (Tick tick, _) => tick.date,
          yValueMapper: (Tick tick, _) => tick.quote,
        ),
      ];

  SfCartesianChart _getChart() => SfCartesianChart(
        annotations: _annotations,
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.Hms(),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          intervalType: DateTimeIntervalType.seconds,
          // interval: 30,
          plotBands: _plotBands,
          plotOffset: _hasOffset ? 60 : null,
          zoomFactor: 0.2,
          zoomPosition: _zoomPosition,
        ),
        primaryYAxis: NumericAxis(
          axisLine: AxisLine(width: 0),
          majorTickLines: MajorTickLines(size: 0),
        ),
        series: _getChartSeries(),
        zoomPanBehavior: _zoomPanBehavior,
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
            enable: true, canShowMarker: true, format: 'point.x / point.y'),
      );

  void _startTimer([double duration]) {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    _timer = Timer.periodic(
        Duration(seconds: (duration ?? _updatingInterval).toInt()),
        _appendNewTick);

    setState(() => _updatingInterval = duration ?? 5);
  }
}

class Tick {
  final DateTime date;
  final double quote;

  Tick(this.date, this.quote);
}
