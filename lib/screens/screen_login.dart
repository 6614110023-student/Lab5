import 'package:flutter/material.dart';
import '../models/model_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false; // State สำหรับ Remember Me

  // 1. State Variables สำหรับ Real-Time Validation
  String? _error_realtime_email;
  String? _error_realtime_password;
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 2. ฟังก์ชัน Validate Email (Real-Time)
  void _validateEmail(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'กรุณากรอกอีเมล';
    } else if (!_emailRegex.hasMatch(value)) {
      error = 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    setState(() {
      _error_realtime_email = error;
    });
  }

  // 3. ฟังก์ชัน Validate Password (Real-Time)
  void _validatePassword(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'กรุณากรอกรหัสผ่าน';
    }
    setState(() {
      _error_realtime_password = error;
    });
  }

  void _handleLogin() {
    // 4. เรียก Real-Time Validation ล่วงหน้าก่อน Form Validation
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);

    // 5. ตรวจสอบ Form Validation และ Real-Time Error
    if (_formKey.currentState!.validate() &&
        _error_realtime_email == null &&
        _error_realtime_password == null) {
      // 6. ตรวจสอบ User Validation (มีบัญชีจริงหรือไม่)
      final User? user = UserRepository.findUser(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Login สำเร็จ
        debugPrint('Remember Me: $_rememberMe');

        // Navigation ไปหน้า Home พร้อมส่ง User object
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: user, // ส่ง User object ไปด้วย
        );
      } else {
        // Login ไม่สำเร็จ (อีเมลหรือรหัสผ่านผิด)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'อีเมลหรือรหัสผ่านไม่ถูกต้อง หรือคุณยังไม่ได้ลงทะเบียน',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เข้าสู่ระบบ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ไอคอน
              const Icon(Icons.account_circle, size: 100, color: Colors.indigo),
              const SizedBox(height: 32),

              // อีเมล
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  // **ลบ const**
                  labelText: 'อีเมล',
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                  errorText: _error_realtime_email, // **Real-Time Error**
                ),
                onChanged: _validateEmail, // **Real-Time Validation**
                validator: (value) {
                  // เก็บ validator เดิมไว้ แต่ onChanged ทำงานก่อน
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // รหัสผ่าน
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  // **ลบ const**
                  labelText: 'รหัสผ่าน',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  errorText: _error_realtime_password, // **Real-Time Error**
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onChanged: _validatePassword, // **Real-Time Validation**
                validator: (value) {
                  // เก็บ validator เดิมไว้
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Remember Me Checkbox (คงเดิม)
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text('จดจำฉันไว้'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // TODO: หน้าลืมรหัสผ่าน
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ฟีเจอร์ลืมรหัสผ่าน')),
                      );
                    },
                    child: const Text('ลืมรหัสผ่าน?'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ปุ่มเข้าสู่ระบบ (คงเดิม)
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),

              // ลิงก์ไปหน้า Register (คงเดิม)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ยังไม่มีบัญชี? '),
                  TextButton(
                    onPressed: () {
                      // Navigation แบบ Named Route
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('ลงทะเบียน'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
