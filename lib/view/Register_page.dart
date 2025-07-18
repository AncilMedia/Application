import 'dart:math';
import 'dart:ui';
import 'package:ancilmedia/view/Login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Controller/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final int numberOfParticles = 50;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Circles
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

          // Particle Background
          CustomPaint(
            size: Size(screenWidth, screenHeight),
            painter: ParticlePainter(_particles),
          ),

          // Glass Container for Form
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
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
                        _buildLabel("Name"),
                        _buildTextField(hint: "Enter your name", controller: _nameController),
                        _buildSpacer(),

                        _buildLabel("Phone Number"),
                        _buildTextField(
                          hint: "Enter your phone",
                          keyboard: TextInputType.phone,
                          controller: _phoneController,
                        ),
                        _buildSpacer(),

                        _buildLabel("Password"),
                        _buildTextField(
                          hint: "Enter your password",
                          obscure: _obscurePassword,
                          toggleVisibility: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          isVisible: !_obscurePassword,
                          controller: _passwordController,
                        ),
                        _buildSpacer(),

                        _buildLabel("Confirm Password"),
                        _buildTextField(
                          hint: "Confirm your password",
                          obscure: _obscureConfirmPassword,
                          toggleVisibility: () =>
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          isVisible: !_obscureConfirmPassword,
                          controller: _confirmPasswordController,
                        ),
                        _buildSpacer(),

                        SizedBox(
                          width: double.infinity,
                          child: InkWell(
                            onTap: () async {
                              if (_passwordController.text != _confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Passwords do not match')),
                                );
                                return;
                              }

                              final controller = RegisterController();
                              final success = await controller.registerUser(
                                _nameController.text.trim(),
                                _phoneController.text.trim(),
                                _passwordController.text.trim(),
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Registered successfully')),
                                );
                                Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Registration failed')),
                                );
                              }
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * .05,
                              decoration: BoxDecoration(
                                color: Colors.teal.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Register",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "I already have an account? ",
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => LoginPage()));
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
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String label) => Text(
    label,
    style: GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Colors.cyan.shade900,
    ),
  );

  Widget _buildSpacer() => const SizedBox(height: 16);

  Widget _buildTextField({
    required String hint,
    bool obscure = false,
    bool? isVisible,
    VoidCallback? toggleVisibility,
    TextInputType keyboard = TextInputType.text,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
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
        hintText: hint,
        hintStyle: TextStyle(color: Colors.cyan.shade900),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        suffixIcon: toggleVisibility != null
            ? IconButton(
          icon: Icon(
            isVisible! ? Icons.visibility : Icons.visibility_off,
            color: Colors.cyan.shade900,
          ),
          onPressed: toggleVisibility,
        )
            : null,
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
