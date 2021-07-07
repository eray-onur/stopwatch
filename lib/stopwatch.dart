import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stopwatch/platform_alert.dart';

class StopWatch extends StatefulWidget {
  static const route = '/stopwatch';
  final String name;
  final String email;
  const StopWatch({Key key, this.name, this.email}) : super(key: key);
  @override
  State createState() => StopWatchState();
}

class StopWatchState extends State<StopWatch> {
  bool isTicking = false;
  int milliseconds = 0;
  final laps = <int>[];
  Timer timer;

  final itemHeight = 60.0;
  final scrollContainer = ScrollController();

  String _secondsToText() => this.milliseconds == 1 ? 'second' : 'seconds';

  void _startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 100), _onTick);

    setState(() {
      laps.clear();
      milliseconds = 0;
      isTicking = true;
    });
  }

  String _secondsText(int milliseconds) {
    final seconds = milliseconds / 1000;
    return '$seconds seconds';
  }

  void _stopTimer(BuildContext context) {
    timer.cancel();
    setState(() {
      isTicking = false;
    });

    final controller = showBottomSheet(context: context, builder: _buildRunCompleteSheet);
    Future.delayed(Duration(seconds: 4)).then((_) {
      controller.close();
    });
  }

  Widget _buildRunCompleteSheet(BuildContext context) {
    final totalRuntime = laps.fold(milliseconds, (total, lap) => total + lap);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
        child: Container(
          color: Theme.of(context).cardColor,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Run Finished!', style: textTheme.headline6),
                Text('Total Run Time is ${_secondsText(totalRuntime)}'),
              ],
            ),
          ),
        )
    );
  }

  void _lap() {
    setState(() {
      laps.add(milliseconds);
      milliseconds = 0;
    });
    scrollContainer.animateTo(
        itemHeight * laps.length,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn
    );
  }

  void _onTick(Timer timer) {
    if(isTicking) {
      setState(() {
        milliseconds += 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = ModalRoute.of(context).settings.arguments ?? "";

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(child: _buildCounter(context)),
          Expanded(child: _buildLapDisplay(context)),
        ],
      )
    );
  }

  Widget _buildCounter(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Lap ${laps.length + 1}',
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: Colors.white),
          ),
          Text(
            _secondsText(milliseconds),
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Colors.white),
          ),
          _buildControls(context)
        ],
      ),
    );
  }

  Widget _buildLapDisplay(BuildContext context) {
    return ListView.builder(
      controller: scrollContainer,
      itemExtent: itemHeight,
      itemCount: laps.length,
      itemBuilder: (context, index) {
        final milliseconds = laps[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 50),
          title: Text('Lap ${index + 1}'),
          trailing: Text(_secondsText(milliseconds)),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.greenAccent),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: Text('start'),
          onPressed: isTicking ? null : _startTimer,
        ),
        SizedBox(width: 20),
        ElevatedButton(
            onPressed: isTicking ? _lap : null,
            child: Text('Lap')),
        SizedBox(width: 20),
        Builder(
          builder: (context) =>
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: Text('Stop'),
                onPressed: isTicking ? () => _stopTimer(context) : null,
              ),
        )

      ],
    );
  }

  @override
  void dispose() {
    if(timer != null) {
      timer.cancel();
    }
    super.dispose();
  }
}