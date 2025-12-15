import 'package:flutter/material.dart';
import '../models//model_user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // สร้าง GlobalKey สำหรับ Form (คงเดิม)
  final _formKey = GlobalKey<FormState>();

  // Controllers สำหรับ TextFormField (คงเดิม)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // State สำหรับ Show/Hide Password (คงเดิม)
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 1. เปลี่ยนชื่อตัวแปรและเพิ่มตัวแปรสำหรับทุก Field เพื่อเก็บข้อความ Error แบบ Real-Time
  String? _error_realtime_name;
  String? _error_realtime_email;
  String? _error_realtime_password;
  String? _error_realtime_confirm_password;
  String? _error_realtime_phone;

  // Regex (คงเดิม)
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    // อย่าลืม dispose controllers! (คงเดิม)
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // 2. ฟังก์ชัน Validate Name (ใหม่)
  void _validateName(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'กรุณากรอกชื่อ';
    }
    setState(() {
      _error_realtime_name = error;
    });
  }

  // 3. ฟังก์ชัน Validate Email (ปรับปรุงให้ถูกต้องและใช้ onChanged)
  void _validateEmail(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'กรุณากรอกอีเมล';
    } else if (!emailRegex.hasMatch(value)) {
      error = 'รูปแบบอีเมลไม่ถูกต้อง';
    }

    // ตั้งค่า error ใน State
    setState(() {
      _error_realtime_email = error;
    });
  }

  // 4. ฟังก์ชัน Validate Password (ปรับปรุง)
  void _validatePassword(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'กรุณากรอกรหัสผ่าน';
    } else if (value.length < 6) {
      error = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }

    // ตรวจสอบยืนยันรหัสผ่านทันทีที่รหัสผ่านเปลี่ยน
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword(_confirmPasswordController.text);
    }

    setState(() {
      _error_realtime_password = error;
    });
  }

  // 5. ฟังก์ชัน Validate Confirm Password (ใหม่)
  void _validateConfirmPassword(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'กรุณายืนยันรหัสผ่าน';
    } else if (value != _passwordController.text) {
      error = 'รหัสผ่านไม่ตรงกัน';
    }

    setState(() {
      _error_realtime_confirm_password = error;
    });
  }

  // 6. ฟังก์ชัน Validate Phone (ใหม่)
  void _validatePhone(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'กรุณากรอกเบอร์โทรศัพท์';
    } else if (value.length != 10) {
      error = 'เบอร์โทรศัพท์ต้องมี 10 ตัวอักษร';
    }

    setState(() {
      _error_realtime_phone = error;
    });
  }

  // 7. ฟังก์ชันจัดการการลงทะเบียน (ปรับปรุงการเรียกใช้ Validation)
  void _handleRegister() {
    // 1. ตรวจสอบ Form ว่าผ่าน Validation หรือไม่ (ใช้ validator ดั้งเดิม)
    if (_formKey.currentState!.validate()) {
      // 2. เรียก Real-Time Validation เพื่อให้มั่นใจว่าทุก field ผ่านการตรวจสอบ
      _validateName(_nameController.text);
      _validateEmail(_emailController.text);
      _validatePassword(_passwordController.text);
      _validateConfirmPassword(_confirmPasswordController.text);
      _validatePhone(_phoneNumberController.text);

      // 3. ตรวจสอบ Real-Time Error อีกครั้ง
      if (_error_realtime_name == null &&
          _error_realtime_email == null &&
          _error_realtime_password == null &&
          _error_realtime_confirm_password == null &&
          _error_realtime_phone == null) {
        // 4. สร้าง User object ใหม่พร้อมรหัสผ่านและเบอร์โทร
        final newUser = User(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text, // เก็บ password
          phoneNumber: _phoneNumberController.text, // เก็บเบอร์โทร
        );

        // 5. **เพิ่มผู้ใช้ใหม่เข้าสู่ Static Repository**
        if (UserRepository.isEmailRegistered(_emailController.text)) return;
        UserRepository.registeredUsers.add(newUser);
        UserRepository.registeredUsers.forEach((user) => print(user.email));

        // 6. แสดง SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลงทะเบียนสำเร็จ! สามารถเข้าสู่ระบบได้แล้ว'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigation ไปหน้า Login
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลงทะเบียน'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, // ผูก GlobalKey กับ Form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ไอคอนด้านบน
              const Icon(Icons.person_add, size: 80, color: Colors.indigo),
              const SizedBox(height: 32),

              // ชื่อ-นามสกุล (ผูก onChanged และ errorText)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  // **ต้องไม่ใช้ const**
                  labelText: 'ชื่อ-นามสกุล',
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                  errorText: _error_realtime_name, // **Real-Time Error**
                ),
                onChanged: _validateName, // **Real-Time Validation**
                // 📝 Note: สามารถลบ validator ดั้งเดิมได้ แต่ถ้าเก็บไว้ก็ยังทำงานเมื่อกด Submit
                validator: (value) {
                  return null; // ปล่อยให้ onChanged จัดการ
                },
              ),
              const SizedBox(height: 16),

              // อีเมล (ผูก onChanged และ errorText)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  // **ต้องไม่ใช้ const**
                  labelText: 'อีเมล',
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                  errorText: _error_realtime_email, // **Real-Time Error**
                ),
                onChanged: _validateEmail, // **Real-Time Validation**
                validator: (value) {
                  return null; // ปล่อยให้ onChanged จัดการ
                },
              ),
              const SizedBox(height: 16),

              // รหัสผ่าน (ผูก onChanged และ errorText)
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  // **ต้องไม่ใช้ const**
                  labelText: 'รหัสผ่าน',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  errorText: _error_realtime_password, // **Real-Time Error**
                  // ปุ่ม Show/Hide Password
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
                  return null; // ปล่อยให้ onChanged จัดการ
                },
              ),
              const SizedBox(height: 16),

              // ยืนยันรหัสผ่าน (ผูก onChanged และ errorText)
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  // **ต้องไม่ใช้ const**
                  labelText: 'ยืนยันรหัสผ่าน',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  errorText:
                      _error_realtime_confirm_password, // **Real-Time Error**
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                onChanged: _validateConfirmPassword, // **Real-Time Validation**
                validator: (value) {
                  return null; // ปล่อยให้ onChanged จัดการ
                },
              ),
              const SizedBox(height: 16),

              // เบอร์โทรศัพท์ (ผูก onChanged และ errorText)
              TextFormField(
                controller: _phoneNumberController,
                keyboardType:
                    TextInputType.phone, // แนะนำให้เปลี่ยน keyboard type
                decoration: InputDecoration(
                  // **ต้องไม่ใช้ const**
                  labelText: 'เบอร์โทรศัพท์',
                  prefixIcon: const Icon(Icons.phone), // เปลี่ยนไอคอนให้ตรง
                  border: const OutlineInputBorder(),
                  errorText: _error_realtime_phone, // **Real-Time Error**
                ),
                onChanged: _validatePhone, // **Real-Time Validation**
                validator: (value) {
                  return null; // ปล่อยให้ onChanged จัดการ
                },
              ),
              const SizedBox(height: 24),

              // ปุ่มลงทะเบียน (คงเดิม)
              ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ลงทะเบียน', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),

              // ลิงก์ไปหน้า Login (คงเดิม)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('มีบัญชีอยู่แล้ว? '),
                  TextButton(
                    onPressed: () {
                      // Navigation แบบ Named Route
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('เข้าสู่ระบบ'),
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
