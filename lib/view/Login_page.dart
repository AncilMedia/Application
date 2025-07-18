import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final int numberOfParticles = 50;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(numberOfParticles, (index) => Particle());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..addListener(() {
      for (var particle in _particles) {
        particle.update(MediaQuery.of(context).size);
      }
      setState(() {});
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Top-left circle
          Positioned(
            top: -screenHeight * 0.1,
            left: -screenWidth * 0.1,
            child: Container(
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
              decoration: BoxDecoration(
                color: Colors.tealAccent.shade100,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Bottom-right circle
          Positioned(
            bottom: -screenHeight * 0.1,
            right: -screenWidth * 0.1,
            child: Container(
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
              decoration: BoxDecoration(
                color: Colors.tealAccent.shade100,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Animated Particles
          CustomPaint(
            size: Size(screenWidth, screenHeight),
            painter: ParticlePainter(_particles),
          ),

          // Login Form with glass effect
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Field
                        Text(
                          "Name",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.cyan.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          style: TextStyle(color: Colors.cyan.shade900),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyan.shade900),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyan.shade900),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyan.shade900, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(color: Colors.cyan.shade900),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Text(
                          "Password",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.cyan.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          obscureText: _obscurePassword,
                          style: TextStyle(color: Colors.cyan.shade900),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyan.shade900),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyan.shade900),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyan.shade900, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Colors.cyan.shade900),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.cyan.shade900,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: InkWell(
                            onTap: () {
                              // Handle login
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * .05,
                              decoration: BoxDecoration(
                                color: Colors.teal.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Register prompt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "I don't have any account? ",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                              },
                              child: Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  double x = Random().nextDouble() * 400;
  double y = Random().nextDouble() * 800;
  double dx = (Random().nextDouble() - 0.5) * 2;
  double dy = (Random().nextDouble() - 0.5) * 2;
  double radius = Random().nextDouble() * 3 + 1;
  Color color = Colors.teal.withOpacity(0.5 + Random().nextDouble() * 0.5);

  void update(Size screenSize) {
    x += dx;
    y += dy;

    if (x <= 0 || x >= screenSize.width) dx = -dx;
    if (y <= 0 || y >= screenSize.height) dy = -dy;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
