import 'dart:convert';
import 'package:http/http.dart' as http;
import './database_helper.dart'; // Giả sử em để file SQLite ở đây
import '../model/expense.dart';

class SyncService {
  // 1. Địa chỉ IP của API Server (Lưu ý quan trọng cho Emulator)
  final String baseUrl = 'https://spending-backend-api.onrender.com'; 

  Future<void> syncExpenses() async {
    final db = await DatabaseHelper.instance.database;

    // 2. Truy vấn tất cả chi tiêu chưa được đồng bộ
    final List<Map<String, dynamic>> unsyncedMaps = await db.query(
      'expenses', 
      where: 'is_synced = ?', 
      whereArgs: [0], // 0 nghĩa là False / Chưa đồng bộ
    );

    for (var map in unsyncedMaps) {
      final expense = Expense.fromMap(map); // Giả sử em có hàm fromMap
      
      print('--- BẮT ĐẦU GỬI DATA LÊN RENDER: ${Uri.parse('$baseUrl/expenses')} ---');
      try {
        // 3. Gửi yêu cầu POST lên API
        final response = await http.post(
          Uri.parse('$baseUrl/expenses'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(expense.toJson()), // Biến đối tượng thành chuỗi JSON
        );

        // 4. Nếu Server báo thành công (201 Created hoặc 200 OK)
        if (response.statusCode == 201 || response.statusCode == 200) {
          await db.update(
            'expenses',
            {'is_synced': 1}, // Đánh dấu đã đồng bộ
            where: 'id = ?',
            whereArgs: [expense.id],
          );
          print('Đã đồng bộ thành công: ${expense.title}');
        }
      } catch (e) {
        print('Lỗi kết nối Server: $e');
        break; // Dừng vòng lặp nếu mất mạng hoàn toàn
      }
    }
  }
}
