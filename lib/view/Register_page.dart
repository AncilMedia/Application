import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ancilmedia/view/Login_page.dart';
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

  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(numberOfParticles, (_) => Particle());
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 100))
      ..addListener(() {
        for (var p in _particles) {
          p.update(MediaQuery.of(context).size);
        }
        setState(() {});
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildBackgroundCircles(size),
          CustomPaint(size: size, painter: ParticlePainter(_particles)),
          _buildGlassForm(),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircles(Size size) => Stack(
    children: [
      Positioned(top: -size.height * 0.1, left: -size.width * 0.1, child: _circle(size.width)),
      Positioned(bottom: -size.height * 0.1, right: -size.width * 0.1, child: _circle(size.width)),
    ],
  );

  Widget _circle(double width) => Container(
    width: width * 0.7,
    height: width * 0.7,
    decoration: BoxDecoration(
      color: Colors.tealAccent.shade100,
      shape: BoxShape.circle,
    ),
  );

  Widget _buildGlassForm() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))
              ],
            ),
            child: _buildFormContent(),
          ),
        ),
      ),
    ),
  );

  Widget _buildFormContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel("Name"),
      _buildTextField(hint: "Enter your name", controller: _nameController),
      _buildSpacer(),
      _buildLabel("Phone or Email"),
      _buildTextField(
        hint: "Enter your phone or email",
        controller: _contactController,
        keyboard: TextInputType.emailAddress,
      ),
      _buildSpacer(),
      _buildLabel("Password"),
      _buildTextField(
        hint: "Enter your password",
        obscure: _obscurePassword,
        toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
        isVisible: !_obscurePassword,
        controller: _passwordController,
      ),
      _buildSpacer(),
      _buildLabel("Confirm Password"),
      _buildTextField(
        hint: "Confirm your password",
        obscure: _obscureConfirmPassword,
        toggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        isVisible: !_obscureConfirmPassword,
        controller: _confirmPasswordController,
      ),
      _buildSpacer(),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade300),
          onPressed: _handleRegister,
          child:  Text("Register", style: GoogleFonts.poppins(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w500)),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Already have an account? ", style: GoogleFonts.poppins(fontSize: 14)),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: Text("Login",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.purple)),
          ),
        ],
      ),
    ],
  );

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || contact.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    _showSnackBar("Registering...");

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appId = packageInfo.packageName;
      final isEmail = contact.contains("@");

      // Ensure phone/email uniqueness for MongoDB
      final phoneValue = isEmail ? "dummy_${DateTime.now().millisecondsSinceEpoch}" : contact;
      final emailValue = isEmail ? contact : "user_${contact}@app.com";

      final result = await AuthController().registerUser(
        username: name,
        phone: phoneValue,
        email: emailValue,
        password: password,
        packageName: appId,
      );

      if (result) {
        _showSnackBar("🎉 Registered Successfully!");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      } else {
        _showSnackBar("❌ Registration failed or already exists.");
      }
    } catch (e) {
      print("Error: $e");
      _showSnackBar("⚠️ Error: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.teal.shade900),
  );

  Widget _buildSpacer() => const SizedBox(height: 16);

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    bool? isVisible,
    VoidCallback? toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: TextStyle(color: Colors.cyan.shade900),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.teal.shade900),
        suffixIcon: toggleVisibility != null
            ? IconButton(
          icon: Icon(isVisible! ? Icons.visibility : Icons.visibility_off, color: Colors.teal.shade900),
          onPressed: toggleVisibility,
        )
            : null,
      ),
    );
  }
}

// Particle Animation Classes
class Particle {
  double x = Random().nextDouble() * 400;
  double y = Random().nextDouble() * 800;
  double dx = (Random().nextDouble() - 0.5) * 2;
  double dy = (Random().nextDouble() - 0.5) * 2;
  double radius = Random().nextDouble() * 3 + 1;
  Color color = Colors.teal.withOpacity(0.5 + Random().nextDouble() * 0.5);

  void update(Size size) {
    x += dx;
    y += dy;
    if (x <= 0 || x >= size.width) dx = -dx;
    if (y <= 0 || y >= size.height) dy = -dy;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      paint.color = p.color;
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
