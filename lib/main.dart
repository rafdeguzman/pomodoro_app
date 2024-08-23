import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class RadialProgress extends StatelessWidget {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;
  final double size;
  final Duration duration;

  const RadialProgress({
    Key? key,
    required this.progress,
    required this.duration,
    this.color = Colors.blue,
    this.strokeWidth = 20.0,
    this.startAngle = -pi / 2 + 0.2,
    this.sweepAngle = 2 * pi - 0.4,
    this.size = 200.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RadialProgressPainter(
              progress: progress,
              color: color,
              strokeWidth: strokeWidth,
              startAngle: startAngle,
              sweepAngle: sweepAngle,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDuration(duration),
                style: TextStyle(
                  fontSize: size / 8,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}

class _RadialProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  _RadialProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round // Add this line
      ..style = PaintingStyle.stroke;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Ensure progress doesn't close the gap
    final progressAngle = sweepAngle * progress.clamp(0.0, 1.0);

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? _timer;
  Duration _duration = Duration.zero;
  static const _maxDuration = Duration(seconds: 10); // 10 seconds
  bool _isSessionActive = false;
  bool _isSessionCompleted = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startSession() {
    setState(() {
      _isSessionActive = true;
      _isSessionCompleted = false;
      _duration = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_duration < _maxDuration) {
          _duration += const Duration(seconds: 1);
          if (_duration == _maxDuration) {
            _timer?.cancel();
            _isSessionActive = false;
            _isSessionCompleted = true;
          }
        }
      });
    });
  }

  void endSession() {
    _timer?.cancel();
    setState(() {
      _isSessionActive = false;
      _isSessionCompleted = _duration == _maxDuration;
    });
  }

  void completeSession() {
    setState(() {
      _duration = Duration.zero;
      _isSessionCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _duration.inSeconds / _maxDuration.inSeconds;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Session Progress:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            RadialProgress(
              progress: progress,
              duration: _duration,
              color: Colors.deepPurple,
              size: 250,
              strokeWidth: 25,
            ),
            const SizedBox(height: 30),
            _buildSessionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionButton() {
    String buttonText;
    Color buttonColor;
    VoidCallback onPressed;

    if (_isSessionActive) {
      buttonText = 'End Session';
      buttonColor = Colors.grey;
      onPressed = endSession;
    } else if (_isSessionCompleted) {
      buttonText = 'Complete Session';
      buttonColor = Colors.green;
      onPressed = completeSession;
    } else {
      buttonText = 'Start Session';
      buttonColor = Colors.blue;
      onPressed = startSession;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
