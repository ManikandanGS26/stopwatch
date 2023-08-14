import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(MyApp());
}

class UserTime {
  final String userName;
  final String time;
  UserTime(this.userName, this.time);
}

List<UserTime> _userTimes = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}
//SplashScreen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'STOPWATCH',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
    );
  }
}
//HomeScreen
class HomeScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimerScreen(userName: _nameController.text),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Enter your name!'),
                      ),
                    );
                  }
                },
                child: Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//TimerScreen
class TimerScreen extends StatefulWidget {
  final String userName;

  TimerScreen({required this.userName});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _isRunning = false;
  late Stopwatch _stopwatch;
  String _formattedTime = '00:00:00';
  late Color _timerColor;
  late Ticker _ticker;

  Color _runningColor = Colors.green;
  Color _pausedColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timerColor = _pausedColor;
    _ticker = Ticker(_updateTime);
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopwatch.stop();
      _ticker.stop();
    } else {
      _stopwatch.start();
      _ticker.start();
    }
    setState(() {
      _isRunning = !_isRunning;
      _timerColor = _isRunning ? _runningColor : _pausedColor;
    });
  }

  void _updateTime(Duration duration) {
    setState(() {
      _formattedTime = _formatTime(duration);
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return '$minutes:$seconds:$milliseconds';
  }

  void _saveAndNavigateToDataTable() {
    if (!_isRunning && _formattedTime != '00:00:00') {
      _userTimes.add(UserTime(widget.userName, _formattedTime));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DataTableScreen(userTimes: _userTimes),
        ),
      );
      setState(() {
        _formattedTime='00:00:00';
      });
    }
  }

  void _navigateToHomeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timer')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hello, ${widget.userName}!'),
              SizedBox(height: 20),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _timerColor,
                ),
                child: Text(_formattedTime),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _formattedTime == '00:00:00'
                    ? _toggleTimer
                    : (_isRunning ? _toggleTimer : _saveAndNavigateToDataTable),
                style: ElevatedButton.styleFrom(
                  primary: _isRunning
                      ? Colors.red
                      : (_formattedTime == '00:00:00'
                      ? Colors.indigo
                      : Colors.green),
                ),
                child: Text(
                  _isRunning
                      ? 'Stop'
                      : (_formattedTime == '00:00:00'
                      ? 'Start'
                      : 'Save'),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
//DataTableScreen
class DataTableScreen extends StatelessWidget {
  final List<UserTime> userTimes;

  DataTableScreen({required this.userTimes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List')),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: DataTable(
                columnSpacing: 16,
                columns: [
                  DataColumn(
                    label: Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                rows: userTimes.map((userTime) {
                  return DataRow(cells: [
                    DataCell(Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      padding: EdgeInsets.all(8),
                      child: Text(userTime.userName),
                    )),
                    DataCell(Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      padding: EdgeInsets.all(8),
                      child: Text(userTime.time),
                    )),
                  ]);
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text('New User'),
            ),
          ],
        ),
      ),
    );
  }
}
