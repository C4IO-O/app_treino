import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class RestTimerScreen extends StatefulWidget {
  final ValueNotifier<int> restNotifier;
  final int totalSeconds;
  final Function(int)? onTimeSelected;
  final VoidCallback? onStop;

  const RestTimerScreen({
    super.key,
    required this.totalSeconds,
    required this.restNotifier,
    this.onTimeSelected,
    this.onStop,
  });

  @override
  State<RestTimerScreen> createState() => _RestTimerScreenState();
}

class _RestTimerScreenState extends State<RestTimerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Contagem regressiva ---
  Timer? _countdownTimer;
  int _selectedMinutes = 2;
  int _selectedSeconds = 0;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;

  // --- Cronómetro ---
  int _stopwatchMillis = 0;
  Timer? _stopwatchTimer;
  bool _stopwatchRunning = false;

  bool get _isRest => widget.totalSeconds > 0;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = 2;
    _selectedSeconds = 0;
    _minutesController = FixedExtentScrollController(
      initialItem: _selectedMinutes,
    );
    _secondsController = FixedExtentScrollController(
      initialItem: _selectedSeconds,
    );
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    _stopwatchTimer?.cancel();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  // --- Stopwatch ---
  void startStopwatch() {
    _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() => _stopwatchMillis += 10);
    });
    setState(() => _stopwatchRunning = true);
  }

  // pausar cronómetro
  void pauseStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() => _stopwatchRunning = false);
  }

// formatação pra página de contagem regressiva
String format(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

// formatação pra página de cronómetro
  String formatStopwatch(int millis) {
    final minutes = millis ~/ 60000;
    final seconds = (millis ~/ 1000) % 60;
    final centis = (millis ~/ 10) % 100;
    return '${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')} , ${centis.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Contagem Regressiva'),
            Tab(text: 'Cronómetro'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildCountdown(), buildStopwatch()],
      ),
    );
  }

  // --- Página 1: Contagem Regressiva ---
  Widget buildRunningCountdown() {
    return ValueListenableBuilder<int>(
      valueListenable: widget.restNotifier,
      builder: (context, remainingcountdown, _) {
        final progress = widget.totalSeconds > 0
            ? remainingcountdown / widget.totalSeconds
            : 0.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(280, 280),
                    painter: CirclePainter(progress: progress),
                  ),
                  Text(
                    format(remainingcountdown),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => widget.restNotifier.value = max(
                    0,
                    widget.restNotifier.value - 10,
                  ),
                  icon: const Icon(Icons.remove_circle_outline, size: 48),
                ),
                const SizedBox(width: 48),
                IconButton(
                  onPressed: () => widget.restNotifier.value += 10,
                  icon: const Icon(Icons.add_circle_outline, size: 48),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                widget.onStop?.call();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text(
                'Parar',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildConfigCountdown() {
    final presets = [60, 90, 120, 150, 180, 240];

    return Column(
      children: [
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Minutos', style: TextStyle(color: Colors.grey)),
            Text('Segundos', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: ListWheelScrollView(
                  controller: _minutesController,
                  itemExtent: 50,
                  perspective: 0.003,
                  onSelectedItemChanged: (val) =>
                      setState(() => _selectedMinutes = val),
                  children: List.generate(
                    60,
                    (i) => Center(
                      child: Text(
                        i.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: _selectedMinutes == i ? 28 : 20,
                          fontWeight: _selectedMinutes == i
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedMinutes == i
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                ':',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 100,
                child: ListWheelScrollView(
                  controller: _secondsController,
                  itemExtent: 50,
                  perspective: 0.003,
                  onSelectedItemChanged: (val) =>
                      setState(() => _selectedSeconds = val),
                  children: List.generate(
                    60,
                    (i) => Center(
                      child: Text(
                        i.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: _selectedSeconds == i ? 28 : 20,
                          fontWeight: _selectedSeconds == i
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedSeconds == i
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final s = presets[index];
              final label = '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMinutes = s ~/ 60;
                    _selectedSeconds = s % 60;
                    _minutesController.jumpToItem(_selectedMinutes);
                    _secondsController.jumpToItem(_selectedSeconds);
                  });
                },
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C2C2C),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(label, style: const TextStyle(fontSize: 13)),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            final total = _selectedMinutes * 60 + _selectedSeconds;
            if (total > 0) {
              widget.onTimeSelected?.call(total);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Text(
            'Iniciar',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildCountdown() {
    if (_isRest) {
      return buildRunningCountdown();
    }
    return buildConfigCountdown();
  }

  // --- Página 2: Cronómetro ---
  Widget buildStopwatch() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        formatStopwatch(_stopwatchMillis),
        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 48),
      // botão único centralizado quando está no início
      if (!_stopwatchRunning && _stopwatchMillis == 0)
        ElevatedButton(
          onPressed: startStopwatch,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          child: const Text('Iniciar', style: TextStyle(fontSize: 16, color: Colors.white)),
        )
        else if (_stopwatchRunning)
  // Parar — centralizado
  ElevatedButton(
    onPressed: pauseStopwatch,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    ),
    child: const Text('Parar', style: TextStyle(fontSize: 16, color: Colors.white)),
  )
      else
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_stopwatchRunning)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () => setState(() => _stopwatchMillis = 0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                    child: const Text('Resetar', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: _stopwatchRunning ? pauseStopwatch : startStopwatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: Text(
                    _stopwatchRunning ? 'Parar' : 'Continuar',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
    ],
  );
}
    }
    class CirclePainter extends CustomPainter {
  final double progress;
  CirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF2C2C2C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CirclePainter old) => old.progress != progress;
}
