import 'package:flutter/material.dart';
import '../models/model_user.dart';
import 'screen_profile.dart'; // import หน้า Profile

class HomeScreen extends StatefulWidget {
  // 1. เปลี่ยนเป็น StatefulWidget
  final User user; // รับ User object จากหน้า Login

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _currentUser; // 2. สร้าง State variable เพื่อเก็บ User ปัจจุบัน

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  // 3. ฟังก์ชันสำหรับเปิดหน้า Profile และรอรับผลลัพธ์
  void _navigateToProfile(BuildContext context) async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(initialUser: _currentUser),
      ),
    );

    // หากได้รับข้อมูล User ใหม่กลับมา
    if (updatedUser != null && updatedUser is User) {
      setState(() {
        _currentUser = updatedUser; // 4. อัปเดต State เพื่อให้ UI เปลี่ยนแปลง
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ใช้อ้างอิงจาก State variable
    final userName = _currentUser.name;
    final userEmail = _currentUser.email;
    final userPhone = _currentUser.phoneNumber ?? 'N/A'; // ดึงเบอร์โทร

    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าหลัก'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        actions: [
          // ปุ่มแก้ไข Profile
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                _navigateToProfile(context), // 5. ผูกปุ่มเข้ากับฟังก์ชัน
          ),
          // ปุ่ม Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar (คงเดิม)
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.indigo,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),

              // แสดงข้อมูล User
              Text(
                'ยินดีต้อนรับ!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),

              // Card แสดงข้อมูล
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.indigo),
                        title: const Text('ชื่อ'),
                        subtitle: Text(userName),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.indigo),
                        title: const Text('อีเมล'),
                        subtitle: Text(userEmail),
                      ),
                      const Divider(), // เพิ่มเบอร์โทร
                      ListTile(
                        leading: const Icon(Icons.phone, color: Colors.indigo),
                        title: const Text('เบอร์โทรศัพท์'),
                        subtitle: Text(userPhone),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ปุ่ม Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('ออกจากระบบ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // แสดง Dialog ยืนยันการ Logout (คงเดิม)
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ปิด Dialog
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // ปิด Dialog
              // กลับไปหน้า Login และล้าง stack ทั้งหมด
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false, // ลบทุก route ใน stack
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }
}

// 6. เปลี่ยน HomeScreen ใน main.dart
// Note: เนื่องจาก HomeScreen เปลี่ยนเป็น StatefulWidget
// ต้องเปลี่ยนการส่งค่าใน main.dart
