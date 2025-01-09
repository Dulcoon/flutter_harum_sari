import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
import '../utils/toast_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      print("Form validated");
      _formKey.currentState!.save();
      print("Email: $email, Password: $password");

      final url =
          Uri.parse('https://52e8-36-81-70-227.ngrok-free.app/api/login');
      print("URL parsed: $url");

      try {
        final response = await http.post(
          url,
          headers: {'Accept': 'application/json'},
          body: {
            'email': email, // Using the email entered by the user
            'password': password,
          },
        );

        print("Response received: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final token = data['token'];
          final user = data['user'];
          final name = user['name'];
          final userEmail =
              user['email']; // Renaming to userEmail to avoid confusion

          if (token != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_id', user['id'].toString());
            await prefs.setString('auth_token', token);
            await prefs.setString('name', name);
            await prefs.setString('email', userEmail);
            // Storing the email from the API
            print('ini emaiul');
            print(prefs.getString('email'));
            await prefs.setBool('isLoggedIn', true);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          } else {
            print("Token is null");
            ToastUtils.showToastMessage("Token is null");
          }
        } else {
          final error =
              json.decode(response.body)['message'] ?? 'Unknown error';
          print("Error: $error");
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $error')));
        }
      } catch (e) {
        print("Error during login: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      print("Form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const Icon(
                Icons.lock,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Login to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Email',
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (value) => email = value!,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your email' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Password',
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        onSaved: (value) => password = value!,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: (login),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          'Don’t have an account? Register here',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
