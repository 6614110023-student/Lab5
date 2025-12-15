class User {
  final String name;
  final String email;
  final String? phoneNumber; // เพิ่ม field เบอร์โทร
  final String password; // เพิ่ม field รหัสผ่าน (เพื่อใช้ในการ login)

  User({
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.password,
  });
}

// **จำลองฐานข้อมูลผู้ใช้ที่ลงทะเบียนแล้ว (Static List)**
// User ที่สร้างด้วยการลงทะเบียนจะถูกเพิ่มเข้ามาใน List นี้
class UserRepository {
  static final List<User> registeredUsers = [
    // เพิ่มบัญชีเริ่มต้นไว้สำหรับทดสอบ
    User(
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      phoneNumber: '0812345678',
    ),
  ];

  // ฟังก์ชันสำหรับค้นหาผู้ใช้ด้วยอีเมลและรหัสผ่าน
  static User? findUser(String email, String password) {
    return registeredUsers.firstWhereOrNull(
      (user) => user.email == email && user.password == password,
    );
  }

  // ฟังก์ชันสำหรับตรวจสอบว่ามีอีเมลนี้อยู่แล้วหรือไม่
  static bool isEmailRegistered(String email) {
    return registeredUsers.any((user) => user.email == email);
  }
}

// Extension เพื่อให้ใช้ firstWhereOrNull ได้ง่ายขึ้น
extension IterableX<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
