import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_list.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //show login or signup 
  bool _showLogin = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    try {
      if (_showLogin) {
        //login
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        //signup
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      //auth successful
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TaskListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showLogin ? 'Login' : 'Sign Up', style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)), 
                        ),),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)), 
                        ),),
              obscureText: true,
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: _authenticate,
                child: Text(_showLogin ? 'Login' : 'Sign Up', style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),),
              ),
            ),
            const SizedBox(height: 24),

            TextButton(
              onPressed: () {
                setState(() {
                  _showLogin = !_showLogin;
                  _errorMessage = '';
                });
              },
              child: Text(
                _showLogin
                    ? "Don't have an account? Sign up"
                    : 'Already have an account? Log in', style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
