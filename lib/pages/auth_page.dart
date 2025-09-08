import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  bool isLogin = true;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  FirebaseAuth? _auth;

  late AnimationController _btnController;
  late Animation<double> _btnScaleAnimation;

  late AnimationController _cardController;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _btnScaleAnimation =
        CurvedAnimation(parent: _btnController, curve: Curves.easeInOut);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));

    _cardFade = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeIn,
    );

    _cardController.forward();
  }

  @override
  void dispose() {
    _btnController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  // 🔹 Login
  Future<void> _login() async {
    try {
      final userCred = await _auth!.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // ✅ Firestore’da doküman yoksa oluştur
      final userDoc = FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid);

      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        await userDoc.set({
          "email": userCred.user!.email,
          "displayName": userCred.user!.displayName ?? "",
          "isAdmin": false, // yeni giriş yapanlara default false
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } catch (e) {
      _showError("❌ Giriş hatası: $e");
    }
  }

  // 🔹 Register
  Future<void> _register() async {
    if (registerPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showError("❌ Şifreler uyuşmuyor");
      return;
    }

    try {
      final userCred = await _auth!.createUserWithEmailAndPassword(
        email: registerEmailController.text.trim(),
        password: registerPasswordController.text.trim(),
      );

      // ✅ Firestore’a kullanıcıyı kaydet
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .set({
        "email": registerEmailController.text.trim(),
        "displayName": nameController.text.trim(),
        "isAdmin": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } catch (e) {
      _showError("❌ Kayıt hatası: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/arkaplan.png"),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.45)),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _cardSlide,
              child: FadeTransition(
                opacity: _cardFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.recycling,
                                  size: 44, color: Colors.white),
                              const SizedBox(height: 4),
                              Text(
                                "Atık Yönetim Sistemi",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Switch
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isLogin
                                          ? const Color(0xFF2E7D32)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Giriş Yap",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isLogin
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !isLogin
                                          ? const Color(0xFF2E7D32)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Kayıt Ol",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: !isLogin
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: isLogin
                                ? _buildLoginForm()
                                : _buildRegisterForm(),
                          ),
                        ),
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

  // 🔹 Login Form
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        key: const ValueKey("login"),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: _inputDecoration("E-posta", Icons.email),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: _inputDecoration("Şifre", Icons.lock),
          ),
          const SizedBox(height: 14),
          ScaleTransition(
            scale: _btnScaleAnimation,
            child: GestureDetector(
              onTapDown: (_) => _btnController.reverse(),
              onTapUp: (_) {
                _btnController.forward();
                if (_loginFormKey.currentState!.validate()) {
                  _login();
                }
              },
              onTapCancel: () => _btnController.forward(),
              child: _buttonContainer("Giriş Yap"),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Register Form
  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        key: const ValueKey("register"),
        children: [
          TextFormField(
            controller: nameController,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: _inputDecoration("Ad Soyad", Icons.person),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: registerEmailController,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: _inputDecoration("E-posta", Icons.email),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: registerPasswordController,
            obscureText: true,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: _inputDecoration("Şifre", Icons.lock),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: true,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: _inputDecoration("Şifre Tekrar", Icons.lock_outline),
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _btnScaleAnimation,
            child: GestureDetector(
              onTapDown: (_) => _btnController.reverse(),
              onTapUp: (_) {
                _btnController.forward();
                if (_registerFormKey.currentState!.validate()) {
                  _register();
                }
              },
              onTapCancel: () => _btnController.forward(),
              child: _buttonContainer("Kayıt Ol"),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white),
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buttonContainer(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
