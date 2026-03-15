import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_page.dart';
import 'profile_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  // NEW: State variable to hold the screen while we check for an active session
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  // --- NEW: Session Logic ---
  Future<void> _checkExistingSession() async {
    // A tiny delay ensures Firebase Web has time to read from the browser's local storage
    await Future.delayed(const Duration(milliseconds: 500));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          String role = userDoc.get('role');

          if (role == 'admin') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const AdminPage()));
            return; // Stop execution here so we don't show the login screen
          } else if (role == 'organization' ||
              role == 'department' ||
              role == 'administration') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const ProfilePage()));
            return;
          }
        }
      } catch (e) {
        // If there's an error checking the session, we silently fail and just let them log in manually.
      }
    }

    // If no user is found, stop checking and show the login form
    if (mounted) setState(() => _isCheckingSession = false);
  }

  Future<void> _processLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in both email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Authenticate the user
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2. Fetch their role from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        _showError(
            'Account authenticated, but no access role assigned. Contact IT.');
        await FirebaseAuth.instance.signOut();
        return;
      }

      // --- NEW: RECORD LOGIN HISTORY ---
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('login_history')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'device': 'Web Portal', // Can be expanded later
      });
      // ---------------------------------

      String role = userDoc.get('role');

      // 3. Route based on role
      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const AdminPage()));
      } else if (role == 'organization' ||
          role == 'department' ||
          role == 'administration') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const ProfilePage()));
      } else {
        _showError('Unknown role assigned to this account.');
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication failed.');
    } catch (e) {
      _showError('An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // NEW: Show a loading spinner while checking for an existing session
    if (_isCheckingSession) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF002147)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF002147),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- NEW: Logo Image Implementation ---
                // Try to load the image. If it fails (or URL is empty), fallback to the shield and text.
                Image.network(
                  '../assets/loginLogo.png', // Replace with your actual Logo Web Link!
                  height:
                      280, // Adjust this height based on the proportions of your logo
                  errorBuilder: (context, error, stackTrace) => const Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Color(0xFF002147),
                        child:
                            Icon(Icons.shield, color: Colors.white, size: 40),
                      ),
                      SizedBox(height: 25),
                      Text('CampusConnect Portal',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF002147))),
                    ],
                  ),
                ),

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : _processLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Log In',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('© 2026 University of Bohol',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
