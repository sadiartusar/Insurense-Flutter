import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:general_insurance_management_system/page/home.dart';
import 'package:general_insurance_management_system/page/registration.dart';
import 'package:general_insurance_management_system/page/user_profile.dart';
import 'package:general_insurance_management_system/service/auth_service.dart';
import 'dart:ui'; // Necesario para ImageFilter.blur

// Se mantiene como StatefulWidget para manejar el estado de _obscurePassword
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool _obscurePassword = true;

  final storage = new FlutterSecureStorage();
  AuthService authService = AuthService();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla para un diseño responsive
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Usamos un Stack para poner el fondo de degradado
      body: Stack(
        children: [
          // 1. FONDO DE DEGRADADO VIBRANTE
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.deepPurple.shade900],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),

          // 2. CONTENIDO DEL LOGIN
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- TARJETA DE LOGIN (Efecto "Glassmorphism") ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(28.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 3. ICONO/LOGO
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: Icon(
                                  Icons.security, // Icono de seguridad para seguros
                                  size: 45,
                                  color: Colors.deepPurple.shade700,
                                ),
                              ),
                              SizedBox(height: 16.0),

                              // 4. TÍTULO
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Login to your Insurance Portal",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 30.0),

                              // 5. CAMPO DE EMAIL (Estilo moderno)
                              TextField(
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  labelText: 'Email',
                                  hintText: 'example@gmail.com',
                                  icon: Icons.email_outlined,
                                ),
                              ),
                              SizedBox(height: 20.0),

                              // 6. CAMPO DE CONTRASEÑA (Estilo moderno)
                              TextField(
                                controller: password,
                                obscureText: _obscurePassword,
                                style: TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Your secure password',
                                  icon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 30.0),

                              // 7. BOTÓN DE LOGIN (Con degradado)
                              _buildGradientButton(context),

                            ],
                          ),
                        ),
                      ),
                    ),

                    // 8. ENLACE DE REGISTRO (Fuera de la tarjeta)
                    SizedBox(height: 25.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Registration()),
                            );
                          },
                          child: Text(
                            'Register Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
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
        ],
      ),
    );
  }

  // --- WIDGETS DE AYUDA PARA UN CÓDIGO MÁS LIMPIO ---

  /// Construye la decoración moderna para los TextField
  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none, // Sin borde visible
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white, width: 2.0), // Borde blanco al enfocar
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  /// Construye el botón de Login con un degradado
  Widget _buildGradientButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade300, Colors.purple.shade300],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          loginUser(context);
        },
        child: Text(
          "LOGIN",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Transparente para mostrar el degradado
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
    );
  }


  // --- LÓGICA DE LOGIN (Fixed & Improved) ---
  Future<void> loginUser(BuildContext context) async {
    try {
      final success = await authService.login(email.text, password.text);

      if (!success) {
        _showErrorDialog('Login Failed', 'Invalid email or password.');
        return;
      }

      final role = await authService.getUserRole();

      if (role == 'ADMIN') {
        // 👉 যদি Admin হয়, তাহলে HomePage এ যাবে
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (role == 'USER') {
        // 👉 যদি User হয়, তাহলে তার Profile লোড করে UserPage এ যাবে
        final profile = await authService.getUserProfile();

        if (profile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserPage(profile: profile),
            ),
          );
        } else {
          _showErrorDialog('Error', 'Failed to load user profile.');
        }
      } else {
        _showErrorDialog('Access Denied', 'Unknown user role.');
      }
    } catch (error) {
      print('Login failed: $error');
      _showErrorDialog('Login Error', 'Something went wrong. Try again later.');
    }
  }



  // Función de ayuda para mostrar errores al usuario
  Future<void> _showErrorDialog(String title, String content) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe tocar el botón
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}