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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _timer;
  int _seconds = 0;
  int _maxSeconds = 10; // Default session length
  bool _isSessionActive = false;
  bool _isSessionCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _updateAnimationDuration();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimationDuration() {
    _animationController.duration = Duration(seconds: _maxSeconds);
  }

  void startSession() {
    setState(() {
      _isSessionActive = true;
      _isSessionCompleted = false;
      _seconds = 0;
    });
    _animationController.reset();
    _animationController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_seconds < _maxSeconds) {
          _seconds++;
          if (_seconds == _maxSeconds) {
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
    _animationController.stop();
    setState(() {
      _isSessionActive = false;
      _isSessionCompleted = _seconds == _maxSeconds;
    });
  }

  void completeSession() {
    setState(() {
      _seconds = 0;
      _isSessionCompleted = false;
    });
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
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
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return RadialProgress(
                  progress: _animationController.value,
                  duration: Duration(seconds: _seconds),
                  color: Colors.deepPurple,
                  size: 250,
                  strokeWidth: 25,
                );
              },
            ),
            const SizedBox(height: 30),
            _buildSessionButton(),
            const SizedBox(height: 20),
            _buildSessionLengthSlider(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionLengthSlider() {
    return Column(
      children: [
        Text(
          'Session Length: $_maxSeconds seconds',
          style: const TextStyle(fontSize: 16),
        ),
        Slider(
          value: _maxSeconds.toDouble(),
          min: 5,
          max: 60,
          divisions: 11,
          label: _maxSeconds.toString(),
          onChanged: _isSessionActive
              ? null
              : (double value) {
                  setState(() {
                    _maxSeconds = value.round();
                    _updateAnimationDuration();
                  });
                },
        ),
      ],
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
