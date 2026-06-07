import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'dart:io';

void main() async {
  // 1. Thiết lập kết nối tới Postgres trong Docker
  final String dbHost = Platform.environment['DB_HOST'] ?? 'db_spending';
  final String dbName = Platform.environment['DB_NAME'] ?? 'spending_db';
  final String dbUser = Platform.environment['DB_USER'] ?? 'admin';
  final String dbPass = Platform.environment['DB_PASSWORD'] ?? 'secret';
  final int dbPort = int.parse(Platform.environment['DB_PORT'] ?? '5432');
  
  final conn = await Connection.open(
    Endpoint(
      host: dbHost, // Tên dịch vụ trong Docker Compose
      database: dbName,
      username: dbUser,
      password: dbPass,
      port: dbPort, // Cổng nội bộ của Docker luôn là 5432
    ),
    settings: ConnectionSettings(
      sslMode: dbHost == 'db_spending' ? SslMode.disable : SslMode.require,
    ),
  );

  final router = Router();

  // 2. Định nghĩa Endpoint GET: Lấy danh sách chi tiêu
  router.get('/expenses', (Request request) async {
    final results = await conn.execute('SELECT * FROM expenses');
    
    // Chuyển đổi dữ liệu từ DB sang định dạng JSON
   final data = results.map((row) {
      final rowMap = row.toColumnMap(); // Chuyển dòng thành Map dựa trên tên cột
      return {
        'id': rowMap['id'],    
        'title': rowMap['title'],
        'amount': rowMap['amount'],
        'date': (rowMap['date'] as DateTime).toIso8601String(),
      };
    }).toList();

    return Response.ok(jsonEncode(data), headers: {'Content-Type': 'application/json'});
  });

  // 1. Định nghĩa Endpoint POST: Tiếp nhận và lưu chi tiêu từ App Flutter gửi lên
  router.post('/expenses', (Request request) async {
    // Đọc chuỗi JSON gửi từ App
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    // Lấy các trường dữ liệu ra
    final String id = data['id'];
    final String title = data['title'];
    final double amount = (data['amount'] as num).toDouble();
    final String date = data['date'];

    // Lệnh SQL để chèn dữ liệu trực tiếp vào Postgres trên Supabase
    await conn.execute(
      r'INSERT INTO expenses (id, title, amount, date) VALUES ($1, $2, $3, $4) ON CONFLICT (id) DO NOTHING',
      parameters: [id, title, amount, DateTime.parse(date)],
    );

    return Response.ok(
      jsonEncode({'message': 'Đã lưu vào Postgres thành công'}), 
      headers: {'Content-Type': 'application/json'}
    );
  });

  // 3. Khởi chạy Server nội bộ của container tại cổng 8080
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router.call);
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('API Server đang chạy tại: http://${server.address.host}:${server.port}');
}