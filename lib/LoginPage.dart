import 'package:cloud_firestore/cloud_firestore.dart'; // google cloud database where we will be store our data
import 'package:flutter/material.dart'; // material design toolkit
import 'package:firebase_auth/firebase_auth.dart'; // firebase authentication functions
import 'package:google_sign_in/google_sign_in.dart'; // sign in with google button
import 'package:library_management_app/HomePage.dart';
import 'package:library_management_app/registrationPage.dart'; // registration page screen
import 'package:slide_to_act/slide_to_act.dart'; // slide to conform button

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<SlideActionState> _slideKey = GlobalKey<SlideActionState>();

  bool _busy = false;

  @override
  void dispose() {
    // clear the data which is stored in ram by textediting controller
    _email.dispose();
    _password.dispose();
    super.dispose(); // cheak to clear the texteditingcontroller of parent class
  }

  Future<void> _checkUserAndNavigate(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      // ✅ User already registered in Firestore
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      // 🚨 First login: needs registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => registerPage(uid: user.uid)),
      );
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _email.text.trim(),
            password: _password.text.trim(),
          );

      final user = userCred.user;
      if (user != null) {
        await _checkUserAndNavigate(user);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Email sign-in failed');
    } finally {
      _slideKey.currentState?.reset();
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCred = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final user = userCred.user;
      if (user != null) {
        await _checkUserAndNavigate(user);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Google sign-in failed');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(fontSize: 28, color: Colors.white),
                      ),
                      const SizedBox(height: 28),

                      // Email
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _input('Email'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter email';
                          }
                          if (!v.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _input('Password'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter password';
                          if (v.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Swipe to Login
                      AbsorbPointer(
                        absorbing: _busy,
                        child: SlideAction(
                          key: _slideKey, // <-- FIXED
                          text: _busy ? 'Please wait...' : 'Swipe to Login',
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          outerColor: Colors.grey.shade900,
                          innerColor: Colors.white,
                          sliderButtonIcon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                          ),
                          submittedIcon: const Icon(
                            Icons.check,
                            color: Colors.black,
                          ),
                          elevation: 0,
                          onSubmit: _signInWithEmail,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: const [
                          Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Google Sign-In
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _signInWithGoogle,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          label: const Text('Continue with Google'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: _busy
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                try {
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                        email: _email.text.trim(),
                                        password: _password.text.trim(),
                                      );
                                  _checkUserAndNavigate(
                                    FirebaseAuth.instance.currentUser!,
                                  );
                                } on FirebaseAuthException catch (e) {
                                  _showError(e.message ?? 'Sign up failed');
                                }
                              },
                        child: const Text(
                          'Create account with email',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.black,
      hintStyle: const TextStyle(color: Colors.white38),
    );
  }
}
