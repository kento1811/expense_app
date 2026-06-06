import 'package:flutter/material.dart';
import 'pages/home_page.dart';
void main() {
  runApp(const SpendingApp());
}

class SpendingApp extends StatelessWidget {
  const SpendingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 3. Tên ứng dụng hiển thị trên hệ điều hành (Task Switcher)
      title: 'Quản Lý Chi Tiêu', 
      
      // 4. Tắt biểu tượng "Debug" ở góc màn hình cho chuyên nghiệp
      debugShowCheckedModeBanner: false, 

      // 5. Lý thuyết chuyên sâu: Định nghĩa Theme (Bộ quy tắc thiết kế)
      theme: ThemeData(
        useMaterial3: true, // Kích hoạt giao diện Material 3 mới nhất
        
        // Tạo bộ màu xanh mướt tự động từ một màu "hạt giống" (Seed Color)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 157, 255, 44), // Màu xanh tươi em đã chọn
          brightness: Brightness.light, // Chế độ sáng
        ),
      ),

      // 6. Điểm điều phối: Chỉ định trang nào hiện ra đầu tiên khi mở app
      home: const HomePage(), 
    );
  }
}