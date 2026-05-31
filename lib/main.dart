import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const SunCoBypassApp());
}

class SunCoBypassApp extends StatelessWidget {
  const SunCoBypassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SunCoBypass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isConnected = false;
  bool _isLoading = false;

  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _toggleConnection() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _rotateController.repeat();
    });

    // Имитация подключения на 3 секунды
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
      _rotateController.stop();
      _isConnected = !_isConnected;
    });
  }

  String _getStatusText() {
    if (_isLoading) return 'Подключение...';
    return _isConnected ? 'Подключено' : 'Отключено';
  }

  Color _getSunColor() {
    if (_isLoading) return const Color(0xFFFFD54F); // Желтый при загрузке
    return _isConnected ? const Color(0xFF81C784) : const Color(0xFFFFB300); // Зеленый / Золотой
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Текст статуса вверху экрана
          Positioned(
            top: screenHeight * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  _getStatusText(),
                  key: ValueKey<String>(_getStatusText()),
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF212121),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          // 2. Слой грозовых облаков (нижний фон)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: CloudClipper(),
                child: Container(
                  height: screenHeight * 0.62,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF424242), // Светло-серый верх облаков
                        Color(0xFF212121), // Темный низ
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 3. Кнопка-Солнце с анимациями пульсации и вращения
          Positioned(
            top: (screenHeight * 0.38) - 85,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _toggleConnection,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_pulseController, _rotateController]),
                  builder: (context, child) {
                    double pulseScale = 1.0 + (_pulseController.value * 0.05);
                    if (_isLoading) pulseScale = 1.0;

                    return Transform.scale(
                      scale: pulseScale,
                      child: Transform.rotate(
                        angle: _rotateController.value * 2 * math.pi,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getSunColor(),
                            boxShadow: [
                              BoxShadow(
                                color: _getSunColor().withOpacity(0.6),
                                blurRadius: _isLoading ? 45 : 30 + (_pulseController.value * 15),
                                spreadRadius: _isLoading ? 15 : 5 + (_pulseController.value * 8),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 55,
                                    height: 55,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 4,
                                    ),
                                  )
                                : const Icon(
                                    Icons.power_settings_new,
                                    size: 75,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Профессиональная обрезка контейнера в форму облаков
class CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 70);

    var control1 = Offset(size.width * 0.15, -15);
    var end1 = Offset(size.width * 0.35, 40);
    path.quadraticBezierTo(control1.dx, control1.dy, end1.dx, end1.dy);

    var control2 = Offset(size.width * 0.5, 5);
    var end2 = Offset(size.width * 0.68, 50);
    path.quadraticBezierTo(control2.dx, control2.dy, end2.dx, end2.dy);

    var control3 = Offset(size.width * 0.85, 0);
    var end3 = Offset(size.width, 65);
    path.quadraticBezierTo(control3.dx, control3.dy, end3.dx, end3.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}