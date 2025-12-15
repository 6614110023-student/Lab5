import 'package:flutter/material.dart';
import '../models/model_user.dart';

class ProfileScreen extends StatefulWidget {
  final User initialUser; // รับ User object เข้ามา

  const ProfileScreen({super.key, required this.initialUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // State Variables สำหรับ Real-Time Validation
  String? _error_realtime_name;
  String? _error_realtime_email;
  String? _error_realtime_phone;
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    // 1. กำหนดค่าเริ่มต้นให้กับ Controller จาก User object ที่ได้รับมา
    _nameController = TextEditingController(text: widget.initialUser.name);
    _emailController = TextEditingController(text: widget.initialUser.email);
    _phoneController = TextEditingController(
      text: widget.initialUser.phoneNumber,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ฟังก์ชัน Validate Name
  void _validateName(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'กรุณากรอกชื่อ';
    }
    setState(() {
      _error_realtime_name = error;
    });
  }

  // ฟังก์ชัน Validate Email
  void _validateEmail(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'กรุณากรอกอีเมล';
    } else if (!_emailRegex.hasMatch(value)) {
      error = 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    // ตรวจสอบ Email ซ้ำ (ยกเว้น Email เดิมของผู้ใช้เอง)
    else if (value != widget.initialUser.email &&
        UserRepository.isEmailRegistered(value)) {
      error = 'อีเมลนี้ถูกใช้แล้ว';
    }

    setState(() {
      _error_realtime_email = error;
    });
  }

  // ฟังก์ชัน Validate Phone
  void _validatePhone(String value) {
    String? error;
    if (value.length != 10) {
      error = 'เบอร์โทรศัพท์ต้องมี 10 ตัวอักษร';
    }
    setState(() {
      _error_realtime_phone = error;
    });
  }

  void _handleSave() {
    // 2. เรียก Real-Time Validation ทั้งหมด
    _validateName(_nameController.text);
    _validateEmail(_emailController.text);
    _validatePhone(_phoneController.text);

    if (_formKey.currentState!.validate() &&
        _error_realtime_name == null &&
        _error_realtime_email == null &&
        _error_realtime_phone == null) {
      // 3. จำลองการอัปเดตข้อมูลใน Static List
      final oldUser = widget.initialUser;
      final newUser = User(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: oldUser.password, // รหัสผ่านคงเดิม
      );

      // ค้นหาและแทนที่ User object เดิมใน List
      final index = UserRepository.registeredUsers.indexWhere(
        (user) => user.email == oldUser.email,
      );
      if (index != -1) {
        UserRepository.registeredUsers[index] = newUser;
      }

      // 4. แสดงข้อความสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('อัปเดตข้อมูลสำเร็จ!'),
          backgroundColor: Colors.green,
        ),
      );

      // 5. กลับไปหน้า Home พร้อมส่งข้อมูล User ใหม่กลับไปด้วย
      Navigator.pop(context, newUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลส่วนตัว'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person, size: 80, color: Colors.indigo),
              const SizedBox(height: 32),

              // ชื่อ
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อ-นามสกุล',
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                  errorText: _error_realtime_name,
                ),
                onChanged: _validateName,
              ),
              const SizedBox(height: 16),

              // อีเมล
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'อีเมล',
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                  errorText: _error_realtime_email,
                ),
                onChanged: _validateEmail,
              ),
              const SizedBox(height: 16),

              // เบอร์โทรศัพท์
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                  errorText: _error_realtime_phone,
                ),
                onChanged: _validatePhone,
              ),
              const SizedBox(height: 32),

              // ปุ่มบันทึก
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'บันทึกข้อมูล',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
